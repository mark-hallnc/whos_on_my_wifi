import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'tcp_host_probe.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../models/scan_result.dart';
import '../utils/ipv4_subnet.dart';
import 'network_discovery_service.dart';
import 'network_info_service.dart';
import 'local_service_discovery_service.dart';
import 'service_device_merger.dart';
import 'ssdp_discovery_service.dart';
import 'ssdp_device_merger.dart';
import 'neighbor_table_service.dart';
import 'vendor_lookup_service.dart';
import 'mac_device_enricher.dart';
import 'device_identification_service.dart';

typedef HostProbe = Future<List<String>> Function(String address);

class NetworkScanner implements NetworkDiscoveryService {
  NetworkScanner({
    this.networkInfoService = const NetworkInfoService(),
    this.probe,
    LocalServiceDiscovery? serviceDiscovery,
    SsdpDiscovery? ssdpDiscovery,
    this.neighborTable = const NeighborTableService(),
    VendorLookupService? vendorLookup,
  }) : serviceDiscovery = serviceDiscovery ?? AndroidNsdDiscoveryService(),
       ssdpDiscovery = ssdpDiscovery ?? SsdpDiscoveryService(),
       vendorLookup = vendorLookup ?? VendorLookupService.bundled;

  static const concurrency = 48;
  static const maxCandidates = 1024;
  static const tcpTimeout = TcpHostProbe.primaryTimeout;
  static const tcpPorts = TcpHostProbe.primaryPorts;
  final NetworkInfoService networkInfoService;
  final HostProbe? probe;
  final LocalServiceDiscovery serviceDiscovery;
  final SsdpDiscovery ssdpDiscovery;
  final NeighborTableService neighborTable;
  final VendorLookupService vendorLookup;
  Future<ScanResult>? _active;

  /// Compare OS identity, not the display name/SSID (which can be unavailable).
  static String? networkChangeReason(NetworkInfo initial, NetworkInfo current) {
    if ((current.connectionType != NetworkConnectionType.wifi &&
            current.connectionType != NetworkConnectionType.ethernet) ||
        current.localIpAddress == null ||
        current.ipv4PrefixLength == null) {
      return 'Network connection lost. Scan stopped.';
    }
    if (initial.id != current.id ||
        initial.connectionType != current.connectionType ||
        initial.localIpAddress != current.localIpAddress ||
        initial.ipv4PrefixLength != current.ipv4PrefixLength ||
        initial.networkAddress != current.networkAddress ||
        initial.gatewayAddress != current.gatewayAddress) {
      return 'Network changed. Scan stopped.';
    }
    return null;
  }

  static const progressInterval = Duration(milliseconds: 150);
  static const networkCheckInterval = Duration(milliseconds: 400);
  static const networkCheckTimeout = Duration(seconds: 2);
  static int workersFor(int candidates) => candidates <= 256
      ? 48
      : candidates <= 512
      ? 40
      : 32;

  static Future<List<String>> probeTcp(
    String address, {
    ScanCancellation? cancellation,
  }) => TcpHostProbe.probe(address, cancellation: cancellation);
  @override
  Future<ScanResult> discover({
    NetworkInfo? network,
    ScanCancellation? cancellation,
    VerifyScanNetwork? verifyNetwork,
    void Function(ScanResult)? onProgress,
  }) {
    // Keep the lock until all existing workers have drained, even on cancel.
    if (_active != null) return _active!;
    final completion = Completer<ScanResult>();
    _active = completion.future;
    final token = cancellation ?? ScanCancellation();
    unawaited(() async {
      try {
        completion.complete(
          await _discover(
            network: network,
            cancellation: token,
            verifyNetwork: verifyNetwork,
            onProgress: onProgress,
          ),
        );
      } catch (error, stack) {
        completion.completeError(error, stack);
      } finally {
        _active = null;
      }
    }());
    return completion.future;
  }

  Future<ScanResult> _discover({
    NetworkInfo? network,
    required ScanCancellation cancellation,
    VerifyScanNetwork? verifyNetwork,
    void Function(ScanResult)? onProgress,
  }) async {
    final started = DateTime.now();
    final clock = Stopwatch()..start();
    final work = ScanCancellation();
    final stopped = Completer<String?>();
    var failed = false;
    var info = network ?? const NetworkInfo(id: 'unavailable');
    final devices = <String, NetworkDevice>{};
    final tcpHosts = <String>{}, nsdHosts = <String>{}, ssdpHosts = <String>{};
    final durations = <String, Duration>{};
    var total = 0, checked = 0, skipped = 0;
    var phase = ScanPhase.preparing;
    var state = ScanState.preparing;
    String? message = 'Preparing scan...';
    var possibleIsolation = false;
    final serviceLimitations = <String>[];
    var servicesStarted = false, ssdpStarted = false;
    Timer? publication, monitor;
    var lastPublication = Duration.zero;

    ScanResult snapshot(ScanState status, [String? text]) => ScanResult(
      network: info,
      devices: devices.values.toList(),
      startedAt: started,
      completedAt: status == ScanState.completed ? DateTime.now() : null,
      state: status,
      phase: phase,
      totalCandidates: total,
      addressesChecked: checked,
      message: text,
      possibleIsolation: possibleIsolation,
      diagnostics: ScanDiagnostics(
        elapsed: clock.elapsed,
        tcpHosts: tcpHosts.length,
        nsdOnlyHosts: nsdHosts
            .difference(tcpHosts)
            .difference(ssdpHosts)
            .length,
        ssdpOnlyHosts: ssdpHosts
            .difference(tcpHosts)
            .difference(nsdHosts)
            .length,
        serviceOnlyHosts: {
          ...nsdHosts,
          ...ssdpHosts,
        }.difference(tcpHosts).length,
        skippedProbes: skipped,
        devicesWithMac: devices.values
            .where((d) => d.macAddress != null)
            .length,
        identifiedDevices: devices.values
            .where((d) => d.confidence != IdentificationConfidence.low)
            .length,
        durations: durations,
      ),
      discoveryMethods: [
        'Local network metadata',
        'TCP connection',
        if (servicesStarted) 'mDNS / Android NSD',
        if (ssdpStarted) 'SSDP / UPnP',
      ],
      limitations: [
        ...serviceLimitations,
        'Devices with no TCP response or resolved service advertisement may be missed.',
        'The gateway is included from network metadata, not proof of a probe response.',
      ],
    );
    void emit() {
      publication?.cancel();
      publication = null;
      lastPublication = clock.elapsed;
      onProgress?.call(snapshot(state, message));
    }

    void publish() {
      if (work.isCancelled) return;
      final delay = progressInterval - (clock.elapsed - lastPublication);
      if (delay <= Duration.zero) {
        emit();
      } else {
        publication ??= Timer(delay, () {
          publication = null;
          if (!work.isCancelled) emit();
        });
      }
    }

    void transition(ScanPhase next, ScanState status, String text) {
      phase = next;
      state = status;
      message = text;
      emit();
    }

    void cancelWork() => work.cancel(cancellation.reason);
    void workStopped() {
      if (!stopped.isCompleted) stopped.complete();
      publication?.cancel();
      publication = null;
      if (!failed) {
        cancellation.cancel(work.reason);
        state = ScanState.cancelled;
        message = work.reason;
        emit();
      }
    }

    work.addListener(workStopped);
    cancellation.addListener(cancelWork);
    if (cancellation.isCancelled) cancelWork();
    ScanResult cancelled() => snapshot(ScanState.cancelled, work.reason);

    Future<void>? checking;
    Duration? lastCheck;
    Future<void> verify({bool force = false}) {
      if (work.isCancelled || verifyNetwork == null) return Future.value();
      if (checking != null) return checking!;
      if (!force &&
          lastCheck != null &&
          clock.elapsed - lastCheck! < networkCheckInterval) {
        return Future.value();
      }
      return checking = () async {
        final expired = Completer<String?>();
        final deadline = Timer(
          networkCheckTimeout,
          () => expired.complete('Network access unavailable. Scan stopped.'),
        );
        try {
          // Platform reads cannot always be cancelled. Release scan workers on
          // cancellation and ignore the late read rather than waiting for it.
          final reason = await Future.any([
            verifyNetwork(info),
            stopped.future,
            expired.future,
          ]);
          if (!work.isCancelled && reason != null) work.cancel(reason);
        } catch (_) {
          work.cancel('Network access unavailable. Scan stopped.');
        } finally {
          deadline.cancel();
          lastCheck = clock.elapsed;
          checking = null;
        }
      }();
    }

    bool knownLive(String ip) =>
        nsdHosts.contains(ip) || ssdpHosts.contains(ip);
    void add(
      String ip,
      List<String> evidence, {
      bool local = false,
      bool gateway = false,
    }) {
      final now = DateTime.now();
      final old = devices[ip];
      devices[ip] =
          old?.withPresentation(
            online: true,
            lastSeen: now,
            discoveryEvidence: {...old.discoveryEvidence, ...evidence}.toList(),
          ) ??
          NetworkDevice(
            id: ip,
            ipAddress: ip,
            firstSeen: now,
            lastSeen: now,
            isOnline: true,
            isCurrentDevice: local,
            isGateway: gateway,
            discoveryEvidence: evidence,
          );
    }

    Future<void> guarded(Future<void> Function() task) async {
      try {
        await task();
      } catch (error) {
        if (error is SocketException &&
            (error.osError?.errorCode == 1 || error.osError?.errorCode == 13)) {
          work.cancel('Local network permission unavailable. Scan stopped.');
        } else if (!work.isCancelled) {
          failed = true;
          work.cancel('Discovery stopped.');
        }
        rethrow;
      }
    }

    Future<void> measured(String name, Future<void> Function() task) async {
      final timer = Stopwatch()..start();
      try {
        await guarded(task);
      } finally {
        durations[name] = timer.elapsed;
      }
    }

    try {
      if (work.isCancelled) return cancelled();
      info = network ?? await networkInfoService.getCurrentNetwork();
      if (work.isCancelled) return cancelled();
      if ((info.connectionType != NetworkConnectionType.wifi &&
              info.connectionType != NetworkConnectionType.ethernet) ||
          info.localIpAddress == null ||
          info.ipv4PrefixLength == null) {
        state = ScanState.failed;
        message =
            'Connect to a Wi-Fi or Ethernet network with an IPv4 address to scan.';
        emit();
        return snapshot(state, message);
      }
      final subnet = Ipv4Subnet(info.localIpAddress!, info.ipv4PrefixLength!);
      total = subnet.candidateCount;
      add(
        info.localIpAddress!,
        ['Current local IPv4 address'],
        local: true,
        gateway: info.gatewayAddress == info.localIpAddress,
      );
      final gateway = info.gatewayAddress;
      if (gateway != null &&
          gateway != info.localIpAddress &&
          InternetAddress.tryParse(gateway)?.type == InternetAddressType.IPv4) {
        add(gateway, ['Default gateway reported by Android'], gateway: true);
      }
      if (total > maxCandidates) {
        state = ScanState.subnetTooLarge;
        message =
            'This subnet has $total candidate addresses. Automatic scanning is limited to $maxCandidates addresses.';
        emit();
        return snapshot(state, message);
      }
      await verify(force: true);
      if (work.isCancelled) return cancelled();
      durations['preparing'] = clock.elapsed;
      monitor = Timer.periodic(
        networkCheckInterval,
        (_) => unawaited(verify(force: true)),
      );
      transition(
        ScanPhase.discoveringHosts,
        ScanState.running,
        'Discovering devices...',
      );
      final candidates = subnet.candidates.iterator;
      Future<void> worker() async {
        while (!work.isCancelled) {
          await verify();
          if (work.isCancelled || !candidates.moveNext()) break;
          final ip = candidates.current;
          if (knownLive(ip)) {
            skipped++;
          } else {
            final evidence = await (probe != null
                ? probe!(ip)
                : TcpHostProbe.probe(
                    ip,
                    cancellation: work,
                    knownLive: () => knownLive(ip),
                  ));
            await verify();
            if (work.isCancelled) break;
            if (evidence.isNotEmpty) {
              tcpHosts.add(ip);
              add(ip, evidence, gateway: ip == gateway);
            }
          }
          checked++;
          publish();
        }
      }

      // Start service discovery before scheduling workers. All tasks share the
      // same cancellation scope and are drained before releasing the scan lock.
      servicesStarted = true;
      ssdpStarted = true;
      await Future.wait([
        measured('nsd', () async {
          serviceLimitations.addAll(
            await serviceDiscovery.discover(
              network: info,
              cancellation: work,
              verifyNetwork: verify,
              onService: (service) async {
                if (work.isCancelled) return;
                ServiceDeviceMerger.merge(devices, service, info);
                for (final ip in service.addresses) {
                  if (devices[ip]?.services.any(
                        (s) => s.discoveryMethod == 'mDNS / Android NSD',
                      ) ??
                      false) {
                    nsdHosts.add(ip);
                  }
                }
                publish();
              },
            ),
          );
        }),
        measured('ssdp', () async {
          serviceLimitations.addAll(
            await ssdpDiscovery.discover(
              network: info,
              cancellation: work,
              verifyNetwork: verify,
              onDevice: (ad, description, location) {
                if (work.isCancelled) return;
                SsdpDeviceMerger.merge(
                  devices,
                  ad,
                  info,
                  description: description,
                  location: location,
                );
                if (devices[ad.address]?.ssdpAdvertisements.isNotEmpty ??
                    false) {
                  ssdpHosts.add(ad.address);
                }
                publish();
              },
            ),
          );
        }),
        measured('tcp', () async {
          await Future.wait(
            List.generate(
              min(workersFor(total), total),
              (_) => guarded(worker),
            ),
          );
          if (!work.isCancelled) {
            transition(
              ScanPhase.discoveringServices,
              ScanState.discoveringServices,
              'Discovering network services...',
            );
          }
        }),
      ]);
      await verify(force: true);
      if (work.isCancelled) return cancelled();
      transition(
        ScanPhase.identifying,
        ScanState.discoveringServices,
        'Identifying devices...',
      );
      await measured('identifying', () async {
        final neighbors = await neighborTable.read(info, work);
        await verify(force: true);
        if (work.isCancelled) return;
        if (neighbors.isNotEmpty) {
          try {
            await vendorLookup.loadBundledDatabase();
          } on Exception {
            serviceLimitations.add(
              'Bundled MAC vendor information unavailable.',
            );
          }
          await verify();
          if (work.isCancelled) return;
          MacDeviceEnricher.merge(devices, neighbors, vendorLookup);
        }
        devices.updateAll(
          (_, device) => DeviceIdentificationService.identify(device),
        );
      });
      if (work.isCancelled) return cancelled();
      transition(
        ScanPhase.finalizing,
        ScanState.discoveringServices,
        'Finalizing scan...',
      );
      final finalize = Stopwatch()..start();
      await verify(force: true);
      if (work.isCancelled) return cancelled();
      final live = {...tcpHosts, ...nsdHosts, ...ssdpHosts};
      // A hypothesis only: require a responding gateway, a fully scanned LAN,
      // no external peers, and both service sources completing without warnings.
      possibleIsolation =
          total >= 16 &&
          checked == total &&
          gateway != null &&
          live.contains(gateway) &&
          live.every((ip) => ip == gateway || ip == info.localIpAddress) &&
          serviceLimitations.isEmpty;
      durations['finalizing'] = finalize.elapsed;
      state = ScanState.completed;
      message = possibleIsolation
          ? 'Device-to-device communication may be restricted on this network.'
          : null;
      emit();
      return snapshot(state, message);
    } catch (_) {
      if (!failed && work.isCancelled) return cancelled();
      state = ScanState.failed;
      message =
          'Could not complete the scan. Check local network access and try again.';
      emit();
      return snapshot(state, message);
    } finally {
      publication?.cancel();
      monitor?.cancel();
      cancellation.removeListener(cancelWork);
      work.removeListener(workStopped);
      await checking;
      clock.stop();
    }
  }
}
