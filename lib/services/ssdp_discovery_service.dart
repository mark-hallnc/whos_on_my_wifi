import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import '../models/network_info.dart';
import '../models/upnp_description.dart';
import 'network_discovery_service.dart';
import 'upnp_description_fetcher.dart';

class SsdpPacket {
  const SsdpPacket(this.data, this.address);
  final List<int> data;
  final String address;
}

abstract interface class SsdpTransport {
  Stream<SsdpPacket> get packets;
  void search();
  Future<void> close();
}

class UdpSsdpTransport implements SsdpTransport {
  UdpSsdpTransport._(this.socket) {
    subscription = socket.listen(
      (event) {
        if (event != RawSocketEvent.read) return;
        for (var count = 0; count < 32; count++) {
          final packet = socket.receive();
          if (packet == null) break;
          if (packet.data.length <= 8192) {
            controller.add(SsdpPacket(packet.data, packet.address.address));
          }
        }
      },
      onError: controller.addError,
      onDone: controller.close,
    );
  }
  final RawDatagramSocket socket;
  final controller = StreamController<SsdpPacket>.broadcast();
  late final StreamSubscription<RawSocketEvent> subscription;
  bool closed = false;
  static Future<SsdpTransport> open(NetworkInfo network) async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    final interface = interfaces
        .where(
          (i) => i.addresses.any((a) => a.address == network.localIpAddress),
        )
        .firstOrNull;
    if (interface == null) {
      throw const SocketException('Local interface unavailable');
    }
    final socket = await RawDatagramSocket.bind(
      network.localIpAddress!,
      0,
      reuseAddress: false,
    );
    try {
      // Use the supported IP_MULTICAST_IF option; Dart's convenience setter
      // is unimplemented. The IPv4 address selects the captured LAN interface.
      socket.setRawOption(
        RawSocketOption(
          RawSocketOption.levelIPv4,
          RawSocketOption.IPv4MulticastInterface,
          InternetAddress(network.localIpAddress!).rawAddress,
        ),
      );
      socket.multicastHops = 2;
      socket.multicastLoopback = false;
      socket.writeEventsEnabled = false;
      return UdpSsdpTransport._(socket);
    } catch (_) {
      socket.close();
      rethrow;
    }
  }

  @override
  Stream<SsdpPacket> get packets => controller.stream;
  @override
  void search() {
    final bytes = ascii.encode(SsdpDiscoveryService.searchRequest);
    if (socket.send(bytes, InternetAddress('239.255.255.250'), 1900) !=
        bytes.length) {
      throw const SocketException('Could not send SSDP discovery');
    }
  }

  @override
  Future<void> close() async {
    if (closed) return;
    closed = true;
    socket.close();
    await subscription.cancel();
    await controller.close();
  }
}

abstract interface class SsdpDiscovery {
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function() verifyNetwork,
    required void Function(SsdpAdvertisement, UpnpDescription?, Uri?) onDevice,
  });
}

class SsdpDiscoveryService implements SsdpDiscovery {
  SsdpDiscoveryService({
    this.openTransport = UdpSsdpTransport.open,
    UpnpDescriptionFetcher? fetcher,
  }) : fetcher = fetcher ?? UpnpDescriptionFetcher();
  static const listeningDuration = Duration(seconds: 3);
  static const stageDuration = Duration(seconds: 4);
  static const fetchConcurrency = 3;
  static const maxAdvertisements = 128;
  static const maxLocations = 32;
  static String get searchRequest => [
    'M-SEARCH * HTTP/1.1',
    'HOST: 239.255.255.250:1900',
    'MAN: "ssdp:discover"',
    'MX: 2',
    'ST: ssdp:all',
    '',
    '',
  ].join('\r\n');
  final Future<SsdpTransport> Function(NetworkInfo) openTransport;
  final UpnpDescriptionFetcher fetcher;
  bool _active = false;

  @override
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function() verifyNetwork,
    required void Function(SsdpAdvertisement, UpnpDescription?, Uri?) onDevice,
  }) async {
    if (_active || cancellation.isCancelled) return [];
    _active = true;
    final stage = ScanCancellation();
    final warnings = <String>{};
    final done = Completer<void>();
    final pending = Queue<SsdpAdvertisement>();
    final seen = <String>{};
    final locations = <Uri, Future<UpnpDescription?>>{};
    final workers = <Future<void>>{};
    final policy = LocalDescriptionPolicy(network);
    SsdpTransport? transport;
    StreamSubscription<SsdpPacket>? subscription;
    Future<void>? closing;
    Future<void>? monitoring;
    var listening = true;
    Timer? listenTimer;
    Timer? deadline;
    Timer? monitor;
    Future<void> close() => closing ??= transport?.close() ?? Future.value();
    void finish() {
      listening = false;
      stage.cancel();
      pending.clear();
      unawaited(close());
      if (!done.isCompleted) done.complete();
    }

    void completeIfDrained() {
      if (!listening &&
          pending.isEmpty &&
          workers.isEmpty &&
          !done.isCompleted) {
        done.complete();
      }
    }

    Future<void> verify() async {
      if (stage.isCancelled || cancellation.isCancelled) return;
      await verifyNetwork();
      if (cancellation.isCancelled) finish();
    }

    late void Function() pump;
    Future<void> process(SsdpAdvertisement ad) async {
      try {
        await verify();
        if (stage.isCancelled) return;
        onDevice(ad, null, null);
        final location = policy.location(ad.headers['location'], ad.address);
        if (location == null ||
            locations.containsKey(location) ||
            (!locations.containsKey(location) &&
                locations.length >= maxLocations)) {
          return;
        }
        // Each advertisement is retained, but fetch/merge each description once.
        // Duplicate service advertisements must not occupy all fetch workers.
        final description = await (locations[location] = fetcher.fetch(
          location,
          ad.address,
          network,
          stage,
        ));
        await verify();
        if (!stage.isCancelled && description != null) {
          onDevice(ad, description, location);
        }
      } on Exception {
        warnings.add('Some smart-device descriptions could not be read.');
      }
    }

    pump = () {
      while (!stage.isCancelled &&
          workers.length < fetchConcurrency &&
          pending.isNotEmpty) {
        final ad = pending.removeFirst();
        late Future<void> task;
        task = process(ad).whenComplete(() {
          workers.remove(task);
          pump();
          completeIfDrained();
        });
        workers.add(task);
      }
      completeIfDrained();
    };
    cancellation.addListener(finish);
    try {
      await verify();
      if (stage.isCancelled) return [];
      transport = await openTransport(network);
      if (stage.isCancelled) {
        await transport.close();
        return [];
      }
      subscription = transport.packets.listen(
        (packet) {
          if (!listening ||
              stage.isCancelled ||
              seen.length >= maxAdvertisements ||
              !policy.isLocal(packet.address)) {
            return;
          }
          final ad = SsdpAdvertisement.parse(packet.data, packet.address);
          if (ad == null || !seen.add(ad.identity)) return;
          pending.add(ad);
          pump();
        },
        onError: (Object error) {
          warnings.add('Smart-device discovery unavailable.');
          finish();
        },
        onDone: () {
          listening = false;
          completeIfDrained();
        },
      );
      transport.search();
      listenTimer = Timer(listeningDuration, () {
        listening = false;
        unawaited(close());
        completeIfDrained();
      });
      deadline = Timer(stageDuration, finish);
      monitor = Timer.periodic(const Duration(milliseconds: 400), (_) {
        if (monitoring != null || stage.isCancelled) return;
        monitoring = verify()
            .catchError((Object error) {
              cancellation.cancel('Network access unavailable. Scan stopped.');
            })
            .whenComplete(() => monitoring = null);
      });
      await done.future;
    } on SocketException catch (error) {
      if ([1, 13].contains(error.osError?.errorCode)) {
        cancellation.cancel(
          'Local network permission unavailable. Scan stopped.',
        );
      } else {
        warnings.add(
          'Smart-device discovery unavailable; other results are retained.',
        );
      }
    } on Exception {
      warnings.add(
        'Smart-device discovery unavailable; other results are retained.',
      );
    } finally {
      finish();
      listenTimer?.cancel();
      deadline?.cancel();
      monitor?.cancel();
      await subscription?.cancel();
      await close();
      await Future.wait(workers.toList());
      await monitoring;
      cancellation.removeListener(finish);
      _active = false;
    }
    return warnings.toList();
  }
}
