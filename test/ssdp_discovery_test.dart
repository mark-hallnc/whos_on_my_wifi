import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:whos_on_my_wifi/models/discovered_service.dart';
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/models/network_info.dart';
import 'package:whos_on_my_wifi/models/upnp_description.dart';
import 'package:whos_on_my_wifi/services/network_discovery_service.dart';
import 'package:whos_on_my_wifi/services/network_scanner.dart';
import 'package:whos_on_my_wifi/services/local_service_discovery_service.dart';
import 'package:whos_on_my_wifi/models/scan_result.dart';
import 'package:whos_on_my_wifi/services/ssdp_device_merger.dart';
import 'package:whos_on_my_wifi/services/ssdp_discovery_service.dart';
import 'package:whos_on_my_wifi/services/upnp_description_fetcher.dart';
import 'package:whos_on_my_wifi/services/service_device_merger.dart';

const lan = NetworkInfo(
  id: 'test',
  connectionType: NetworkConnectionType.wifi,
  localIpAddress: '192.168.1.2',
  ipv4PrefixLength: 24,
);
const address = '192.168.1.42';
final location = Uri.parse('http://192.168.1.42:8060/device.xml');
const xml = '''<?xml version="1.0"?>
<root xmlns="urn:schemas-upnp-org:device-1-0"><device>
<deviceType>urn:schemas-upnp-org:device:MediaRenderer:1</deviceType>
<friendlyName>Living Room Roku</friendlyName><manufacturer>Roku</manufacturer>
<manufacturerURL>https://example.com</manufacturerURL>
<modelName>Roku Ultra</modelName><modelNumber>4802</modelNumber>
<modelDescription>Streaming media player</modelDescription><modelURL>https://example.com/model</modelURL>
<serialNumber>12345</serialNumber><UDN>uuid:roku-1</UDN><presentationURL>/home</presentationURL>
<serviceList><service><serviceType>urn:schemas-upnp-org:service:AVTransport:1</serviceType>
<serviceId>urn:upnp-org:serviceId:AVTransport</serviceId><controlURL>/control</controlURL>
<eventSubURL>/events</eventSubURL><SCPDURL>/service.xml</SCPDURL></service></serviceList>
</device></root>''';
List<int> response({String url = 'http://192.168.1.42:8060/device.xml'}) =>
    ascii.encode(
      [
        'HTTP/1.1 200 OK',
        'lOcAtIoN: $url',
        'ST: upnp:rootdevice',
        'USN: uuid:roku-1',
        'SERVER: test/1 UPnP/1.0',
        'CACHE-CONTROL: max-age=1800',
        'EXT:',
        'BOOTID.UPNP.ORG: 1',
        'CONFIGID.UPNP.ORG: 2',
        '',
        '',
      ].join('\r\n'),
    );
SsdpAdvertisement advertisement() =>
    SsdpAdvertisement.parse(response(), address)!;
UpnpDescription description() => UpnpDescription.parse(utf8.encode(xml))!;

class FakeHeaders implements HttpHeaders {
  final values = <String, String>{};
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) =>
      values[name] = value.toString();
  @override
  String? value(String name) => values[name];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeResponse extends StreamView<List<int>> implements HttpClientResponse {
  FakeResponse(super.stream, {this.statusCode = 200, this.contentLength = -1});
  @override
  final int statusCode;
  @override
  final int contentLength;
  @override
  final headers = FakeHeaders();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRequest implements HttpClientRequest {
  FakeRequest(this.response);
  final FakeResponse response;
  @override
  final headers = FakeHeaders();
  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  bool aborted = false;
  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    aborted = true;
  }

  @override
  Future<HttpClientResponse> close() async => response;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeClient implements HttpClient {
  FakeClient(this.request);
  final FakeRequest request;
  bool closed = false;
  int requests = 0;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    requests++;
    return request;
  }

  @override
  void close({bool force = false}) {
    closed = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isSetter) return null;
    return super.noSuchMethod(invocation);
  }
}

class FakeTransport implements SsdpTransport {
  final controller = StreamController<SsdpPacket>.broadcast();
  bool closed = false;
  @override
  Stream<SsdpPacket> get packets => controller.stream;
  @override
  void search() {}
  @override
  Future<void> close() async {
    closed = true;
    await controller.close();
  }
}

class DelayedFetcher extends UpnpDescriptionFetcher {
  final started = Completer<void>();
  final result = Completer<UpnpDescription?>();
  int calls = 0;
  @override
  Future<UpnpDescription?> fetch(
    Uri location,
    String sender,
    NetworkInfo network,
    ScanCancellation cancellation,
  ) {
    calls++;
    if (!started.isCompleted) started.complete();
    return result.future;
  }
}

class FixtureNsd implements LocalServiceDiscovery {
  @override
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function(ResolvedLocalService) onService,
    required Future<void> Function() verifyNetwork,
  }) async {
    await onService(
      ResolvedLocalService(
        name: 'Cast',
        type: '_googlecast._tcp.',
        port: 8009,
        addresses: [address],
      ),
    );
    return [];
  }
}

class FixtureSsdp implements SsdpDiscovery {
  FixtureSsdp({this.cancelAfterFirst = false});
  final bool cancelAfterFirst;
  @override
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function() verifyNetwork,
    required void Function(SsdpAdvertisement, UpnpDescription?, Uri?) onDevice,
  }) async {
    await verifyNetwork();
    onDevice(advertisement(), description(), location);
    if (cancelAfterFirst) cancellation.cancel();
    // Simulate a late callback to exercise the scanner's own cancellation gate.
    onDevice(
      SsdpAdvertisement('192.168.1.43', {'st': 'upnp:rootdevice'}),
      null,
      null,
    );
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const neighbors = MethodChannel('whos_on_my_wifi/neighbors');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() => messenger.setMockMethodCallHandler(neighbors, (_) async => null));
  tearDown(() => messenger.setMockMethodCallHandler(neighbors, null));
  for (final cancel in [false, true]) {
    test(
      'normal scanner integrates SSDP and preserves partial results: cancel=$cancel',
      () async {
        final result = await NetworkScanner(
          probe: (ip) async => ip == address ? ['TCP response'] : [],
          serviceDiscovery: FixtureNsd(),
          ssdpDiscovery: FixtureSsdp(cancelAfterFirst: cancel),
        ).discover(network: lan);
        expect(
          result.state,
          cancel ? ScanState.cancelled : ScanState.completed,
        );
        final device = result.devices.singleWhere(
          (d) => d.ipAddress == address,
        );
        expect(device.discoveryEvidence, contains('TCP response'));
        expect(device.services.length, 2);
        expect(device.displayName, 'Living Room Roku');
        expect(
          result.devices.any((d) => d.ipAddress == '192.168.1.43'),
          !cancel,
        );
        expect(result.discoveryMethods, contains('SSDP / UPnP'));
      },
    );
  }
  test('M-SEARCH has valid CRLF framing and requested multicast headers', () {
    expect(
      SsdpDiscoveryService.searchRequest,
      'M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: "ssdp:discover"\r\nMX: 2\r\nST: ssdp:all\r\n\r\n',
    );
  });
  test(
    'SSDP parses case-insensitive headers, location, and optional fields',
    () {
      final result = advertisement();
      expect(result.headers.length, 8);
      expect(result.headers['location'], location.toString());
      expect(result.headers['ext'], '');
      expect(result.headers['server'], 'test/1 UPnP/1.0');
      expect(result.headers['bootid.upnp.org'], '1');
      expect(
        SsdpAdvertisement.parse(
          ascii.encode('HTTP/1.1 200 OK\r\nST: x\r\n\r\n'),
          address,
        ),
        isNotNull,
      );
    },
  );
  test('malformed and duplicate ambiguous headers are ignored safely', () {
    for (final text in [
      'garbage',
      'NOTIFY * HTTP/1.1\r\n\r\n',
      'HTTP/1.1 200 OK\r\nLOCATION: a\r\nlocation: b\r\n\r\n',
      'HTTP/1.1 200 OK\r\nmissing colon\r\n\r\n',
    ]) {
      expect(SsdpAdvertisement.parse(ascii.encode(text), address), isNull);
    }
    expect(SsdpAdvertisement.parse(List.filled(8193, 65), address), isNull);
  });
  test('LOCATION is confined to the local literal responder IPv4', () {
    final policy = LocalDescriptionPolicy(lan);
    expect(policy.location(location.toString(), address), location);
    for (final url in [
      'http://8.8.8.8/device.xml',
      'http://127.0.0.1/',
      'http://192.168.2.42/',
      'http://192.168.1.43/',
      'http://router.local/',
      'file:///etc/passwd',
      'ftp://192.168.1.42/',
      'http://user:pw@192.168.1.42/',
      'http://192.168.1.42/#fragment',
      'http://[::1]/',
      'http://192.168.1.255/',
    ]) {
      expect(policy.location(url, address), isNull, reason: url);
    }
  });
  test('XML parses identity, model, device type, URLs and service lists', () {
    final result = description();
    expect(result.friendlyName, 'Living Room Roku');
    expect(result.manufacturer, 'Roku');
    expect(result.modelName, 'Roku Ultra');
    expect(result.modelNumber, '4802');
    expect(result.modelDescription, 'Streaming media player');
    expect(result.deviceType, 'urn:schemas-upnp-org:device:MediaRenderer:1');
    expect(result.fields.keys, containsAll(UpnpDescription.fieldNames));
    expect(
      result.services.single.keys,
      containsAll(UpnpDescription.serviceFields),
    );
    expect(result.services.single['controlURL'], '/control');
    expect(
      UpnpDescription.parse(utf8.encode('<root><device/></root>')),
      isNotNull,
    );
  });
  test(
    'unsafe entities, malformed, oversized and deeply nested XML rejected',
    () {
      for (final input in [
        '<!DOCTYPE root SYSTEM "http://evil/"><root><device/></root>',
        '<!DOCTYPE root [<!ENTITY a "boom">]><root><device>&a;</device></root>',
        '<root><device>',
        '${'<a>' * 40}${'</a>' * 40}',
      ]) {
        expect(UpnpDescription.parse(utf8.encode(input)), isNull);
      }
      expect(
        UpnpDescription.parse(List.filled(UpnpDescription.maxBytes + 1, 65)),
        isNull,
      );
    },
  );
  test('SSDP-only hosts added even without a fetched description', () {
    final devices = <String, NetworkDevice>{};
    SsdpDeviceMerger.merge(devices, advertisement(), lan);
    expect(devices[address]!.isOnline, isTrue);
    expect(devices[address]!.openPorts, isEmpty);
    SsdpDeviceMerger.merge(
      devices,
      advertisement(),
      lan,
      description: description(),
      location: location,
    );
    expect(devices[address]!.displayName, 'Living Room Roku');
    expect(devices[address]!.hostname, isNull);
    expect(devices[address]!.manufacturer, 'Roku');
    expect(devices[address]!.modelName, 'Roku Ultra');
    expect(devices[address]!.type, DeviceType.mediaDevice);
    expect(devices[address]!.openPorts, [8060]);
  });
  test(
    'merges TCP/mDNS data, custom names, stronger type/confidence and history',
    () {
      final first = DateTime(2020);
      final devices = {
        address: NetworkDevice(
          id: 'keep',
          ipAddress: address,
          firstSeen: first,
          lastSeen: first,
          customName: 'My TV',
          hostname: 'tv.local',
          type: DeviceType.television,
          confidence: IdentificationConfidence.high,
          classification: DeviceClassification.mine,
          openPorts: [80],
          discoveryEvidence: ['TCP success'],
          services: const [
            DiscoveredService(
              name: 'Cast',
              type: '_googlecast._tcp.',
              discoveryMethod: 'mDNS / Android NSD',
            ),
          ],
        ),
      };
      for (var i = 0; i < 2; i++) {
        SsdpDeviceMerger.merge(
          devices,
          advertisement(),
          lan,
          description: description(),
          location: location,
        );
      }
      final result = devices[address]!;
      expect(devices.length, 1);
      expect(result.id, 'keep');
      expect(result.firstSeen, first);
      expect(result.lastSeen.isAfter(first), isTrue);
      expect(result.displayName, 'My TV');
      expect(result.hostname, 'tv.local');
      expect(result.type, DeviceType.television);
      expect(result.confidence, IdentificationConfidence.high);
      expect(result.classification, DeviceClassification.mine);
      expect(result.services.length, 2);
      expect(result.openPorts, [80, 8060]);
      expect(
        result.discoveryEvidence.toSet().length,
        result.discoveryEvidence.length,
      );
      expect(result.ssdpAdvertisements.length, 1);
      // A later mDNS observation must retain UPnP metadata too.
      ServiceDeviceMerger.merge(
        devices,
        ResolvedLocalService(
          name: 'Cast',
          type: '_googlecast._tcp.',
          port: 8009,
          addresses: [address],
        ),
        lan,
      );
      expect(devices[address]!.modelName, 'Roku Ultra');
      expect(devices[address]!.discoveredName, 'Living Room Roku');
    },
  );
  test('vague or vendor-specific device types stay unknown', () {
    expect(
      SsdpDeviceMerger.typeHint('urn:vendor:device:TV:1'),
      DeviceType.unknown,
    );
    expect(
      SsdpDeviceMerger.typeHint('urn:schemas-upnp-org:device:Basic:1'),
      DeviceType.unknown,
    );
    expect(
      SsdpDeviceMerger.typeHint(
        'urn:schemas-upnp-org:device:InternetGatewayDevice:1',
      ),
      DeviceType.router,
    );
  });
  test('HTTP fetch succeeds and closes resources', () async {
    final request = FakeRequest(FakeResponse(Stream.value(utf8.encode(xml))));
    final client = FakeClient(request);
    final result = await UpnpDescriptionFetcher(
      clientFactory: () => client,
    ).fetch(location, address, lan, ScanCancellation());
    expect(result!.friendlyName, 'Living Room Roku');
    expect(client.closed, isTrue);
    expect(request.followRedirects, isFalse);
  });
  test(
    'oversized chunked descriptions and external redirects are rejected',
    () async {
      for (final response in [
        FakeResponse(
          Stream.value(List.filled(UpnpDescription.maxBytes + 1, 65)),
        ),
        FakeResponse(
          const Stream.empty(),
          contentLength: UpnpDescription.maxBytes + 1,
        ),
        FakeResponse(const Stream.empty(), statusCode: 302)
          ..headers.set('location', 'http://8.8.8.8/'),
        FakeResponse(Stream.value(utf8.encode(xml)))
          ..headers.set('content-encoding', 'gzip'),
      ]) {
        final request = FakeRequest(response);
        final client = FakeClient(request);
        expect(
          await UpnpDescriptionFetcher(
            clientFactory: () => client,
          ).fetch(location, address, lan, ScanCancellation()),
          isNull,
        );
        expect(request.followRedirects, isFalse);
        expect(request.maxRedirects, 0);
        expect(client.requests, 1);
        expect(client.closed, isTrue);
      }
    },
  );
  test('unsafe LOCATION never opens an HTTP client', () async {
    final fetcher = UpnpDescriptionFetcher(
      clientFactory: () => fail('Unexpected request'),
    );
    expect(
      await fetcher.fetch(
        Uri.parse('http://8.8.8.8/'),
        address,
        lan,
        ScanCancellation(),
      ),
      isNull,
    );
  });
  test(
    'SSDP duplicates fetched once; cancellation ignores late description',
    () async {
      final transport = FakeTransport();
      final fetcher = DelayedFetcher();
      final token = ScanCancellation();
      final devices = <String, NetworkDevice>{};
      final service = SsdpDiscoveryService(
        openTransport: (_) async => transport,
        fetcher: fetcher,
      );
      final scan = service.discover(
        network: lan,
        cancellation: token,
        verifyNetwork: () async {},
        onDevice: (ad, data, url) => SsdpDeviceMerger.merge(
          devices,
          ad,
          lan,
          description: data,
          location: url,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      transport.controller.add(SsdpPacket(response(), address));
      transport.controller.add(SsdpPacket(response(), address));
      await fetcher.started.future;
      token.cancel();
      fetcher.result.complete(description());
      await scan;
      expect(fetcher.calls, 1);
      expect(transport.closed, isTrue);
      expect(devices[address]!.upnpDescription, isNull);
      expect(devices[address]!.ssdpAdvertisements.length, 1);
    },
  );
  test('network change before merge drops responses', () async {
    final transport = FakeTransport();
    final token = ScanCancellation();
    var changed = false;
    var merged = 0;
    final scan = SsdpDiscoveryService(openTransport: (_) async => transport)
        .discover(
          network: lan,
          cancellation: token,
          verifyNetwork: () async {
            if (changed) token.cancel('Network changed. Scan stopped.');
          },
          onDevice: (_, _, _) => merged++,
        );
    await Future<void>.delayed(Duration.zero);
    changed = true;
    transport.controller.add(SsdpPacket(response(), address));
    await scan;
    expect(merged, 0);
    expect(transport.closed, isTrue);
  });
  test('quiet discovery stops listening at its bounded window', () async {
    final transport = FakeTransport();
    final pending = SsdpDiscoveryService(openTransport: (_) async => transport)
        .discover(
          network: lan,
          cancellation: ScanCancellation(),
          verifyNetwork: () async {},
          onDevice: (_, _, _) {},
        );
    await pending.timeout(const Duration(seconds: 5));
    expect(transport.closed, isTrue);
  });
}
