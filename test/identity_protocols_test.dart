import 'dart:convert';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/models/network_info.dart';
import 'package:whos_on_my_wifi/models/discovered_service.dart';
import 'package:whos_on_my_wifi/services/dns_wire.dart';
import 'package:whos_on_my_wifi/services/nbns_discovery_service.dart';
import 'package:whos_on_my_wifi/services/llmnr_resolver.dart';
import 'package:whos_on_my_wifi/services/ws_discovery_service.dart';
import 'package:whos_on_my_wifi/services/local_identity_discovery.dart';
import 'package:whos_on_my_wifi/services/identity_datagrams.dart';
import 'package:whos_on_my_wifi/services/network_discovery_service.dart';
import 'package:whos_on_my_wifi/services/device_identity_service.dart';
import 'package:whos_on_my_wifi/services/network_scanner.dart';
import 'package:whos_on_my_wifi/services/local_service_discovery_service.dart';
import 'package:whos_on_my_wifi/services/service_device_merger.dart';
import 'package:whos_on_my_wifi/models/scan_result.dart';
import 'support/no_ssdp_discovery.dart';

class EmptyNsd implements LocalServiceDiscovery {
  @override
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function() verifyNetwork,
    required Future<void> Function(ResolvedLocalService) onService,
  }) async => [];
}

const lan = NetworkInfo(
  id: 'lan',
  connectionType: NetworkConnectionType.wifi,
  localIpAddress: '192.168.1.10',
  ipv4PrefixLength: 24,
);
const ip = '192.168.1.42';
NetworkDevice host({
  String address = ip,
  List<int> ports = const [],
  String? name,
  bool online = true,
}) => NetworkDevice(
  id: address,
  ipAddress: address,
  firstSeen: DateTime(2026),
  lastSeen: DateTime(2026),
  isOnline: online,
  openPorts: ports,
  hostname: name,
);
List<int> nbns(int id, {String name = 'OFFICE-PC', int flags = 0x0400}) {
  final entries = [
    ...ascii.encode(name.padRight(15)),
    0,
    ...DnsWire.word(flags),
    ...ascii.encode('WORKGROUP'.padRight(15)),
    0,
    0x84,
    0,
  ];
  final data = [
    2,
    ...entries,
    0,
    0x11,
    0x22,
    0x33,
    0x44,
    0x55,
    ...List.filled(40, 0),
  ];
  return [
    ...DnsWire.word(id),
    0x84,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0x21,
    0,
    1,
    0,
    0,
    0,
    0,
    ...DnsWire.word(data.length),
    ...data,
  ];
}

List<int> llmnr(
  int id, {
  String name = 'printer-room.local',
  String address = ip,
}) {
  final query = LlmnrResolver.query(address, id);
  query[2] = 0x80;
  query[7] = 1;
  final data = DnsWire.encodeName(name);
  return [
    ...query,
    0xc0,
    12,
    0,
    12,
    0,
    1,
    0,
    0,
    0,
    30,
    ...DnsWire.word(data.length),
    ...data,
  ];
}

String ws(
  String id, {
  String xaddr = 'http://192.168.1.42/device',
  String type = 'p:PrintDeviceType',
  String namespace = 'http://schemas.microsoft.com/windows/2006/08/wdp/print',
}) =>
    '''
<s:Envelope xmlns:s="${WsDiscoveryService.soap}" xmlns:a="${WsDiscoveryService.addressing}"
 xmlns:d="${WsDiscoveryService.discovery}" xmlns:p="$namespace">
 <s:Header><a:RelatesTo>$id</a:RelatesTo><a:Action>${WsDiscoveryService.discovery}/ProbeMatches</a:Action></s:Header>
 <s:Body><d:ProbeMatches><d:ProbeMatch><a:EndpointReference><a:Address>urn:uuid:11111111-2222-3333-4444-555555555555</a:Address></a:EndpointReference>
 <d:Types>$type</d:Types><d:Scopes>urn:example:office</d:Scopes><d:XAddrs>$xaddr</d:XAddrs>
 </d:ProbeMatch></d:ProbeMatches></s:Body></s:Envelope>''';

class Query {
  Query(this.destination, this.port, this.request, this.token, this.emit);
  final String destination;
  final int port;
  final List<int> request;
  final ScanCancellation token;
  final bool Function(IdentityPacket) emit;
  int get id => DnsWire(request).u16();
}

class FakeDatagrams implements IdentityDatagrams {
  final calls = <Query>[];
  Future<void> Function(Query)? handle;
  @override
  Future<void> exchange({
    required NetworkInfo network,
    required String destination,
    required int port,
    required List<int> request,
    required Duration duration,
    required ScanCancellation cancellation,
    required bool Function(IdentityPacket) onPacket,
    int hops = 1,
  }) async {
    final query = Query(destination, port, request, cancellation, onPacket);
    calls.add(query);
    await handle?.call(query);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'multiple WS endpoints on one IP keep both identifiers without duplicate devices',
    () {
      final devices = <String, NetworkDevice>{};
      for (final endpoint in [
        'urn:uuid:11111111-2222-3333-4444-555555555555',
        'urn:uuid:22222222-2222-3333-4444-555555555555',
      ]) {
        IdentityObservation.merge(
          devices,
          IdentityObservation(
            ip,
            DiscoveredService(
              name: 'Web Services device',
              type: 'ws-discovery',
              discoveryMethod: 'WS-Discovery',
              host: ip,
              attributes: {'endpoint': endpoint},
            ),
            'Discovered via WS-Discovery',
          ),
          lan,
        );
      }
      expect(devices, hasLength(1));
      expect(devices[ip]!.services, hasLength(2));
      expect(DeviceIdentityService.strongKeys(devices[ip]!), hasLength(2));
    },
  );
  test(
    'normal scan overlaps WS discovery and retains the enriched WS-only device',
    () async {
      final fake = FakeDatagrams();
      fake.handle = (q) async {
        if (q.port != 3702) return;
        final id = RegExp(
          r'<a:MessageID>([^<]+)</a:MessageID>',
        ).firstMatch(utf8.decode(q.request))!.group(1)!;
        q.emit(IdentityPacket(utf8.encode(ws(id)), ip, 3702));
      };
      final result = await NetworkScanner(
        serviceDiscovery: EmptyNsd(),
        ssdpDiscovery: const NoSsdpDiscovery(),
        identityDiscovery: LocalIdentityDiscovery(
          transport: fake,
          enabled: true,
        ),
        probe: (_) async => [],
      ).discover(network: lan);
      expect(result.state, ScanState.completed);
      final found = result.devices.singleWhere((d) => d.ipAddress == ip);
      expect(found.type, DeviceType.printer);
      expect(result.discoveryMethods, contains('WS-Discovery'));
      expect(result.diagnostics!.serviceOnlyHosts, 1);
    },
  );
  test(
    'WS results publish before window ends and survive later cancellation',
    () async {
      final fake = FakeDatagrams(), token = ScanCancellation();
      final found = <IdentityObservation>[];
      final gate = Completer<void>();
      fake.handle = (q) async {
        final id = RegExp(
          r'<a:MessageID>([^<]+)</a:MessageID>',
        ).firstMatch(utf8.decode(q.request))!.group(1)!;
        q.emit(IdentityPacket(utf8.encode(ws(id)), ip, 3702));
        await gate.future;
        q.emit(IdentityPacket(utf8.encode(ws(id)), ip, 3702));
      };
      final pending = LocalIdentityDiscovery(transport: fake, enabled: true)
          .discover(
            network: lan,
            cancellation: token,
            verifyNetwork: () async {},
            onDevice: found.add,
          );
      await Future<void>.delayed(Duration.zero);
      expect(found, hasLength(1));
      token.cancel();
      gate.complete();
      await pending;
      expect(found, hasLength(1));
    },
  );
  test('NBSTAT query encoding and safe computer/workgroup/unit ID parsing', () {
    final query = NbnsDiscoveryService.query(123);
    expect(query.sublist(12, 17), [32, 67, 75, 65, 65]);
    expect(query.sublist(query.length - 4), [0, 33, 0, 1]);
    final found = NbnsDiscoveryService.parse(nbns(123), 123)!;
    expect(found.name, 'OFFICE-PC');
    expect(found.workgroup, 'WORKGROUP');
    expect(found.mac!.value, '00:11:22:33:44:55');
  });
  test(
    'NBNS rejects truncation, wrong transaction, inactive/conflicting names and malformed names',
    () {
      final valid = nbns(123);
      for (var n = 0; n < valid.length; n++) {
        expect(NbnsDiscoveryService.parse(valid.sublist(0, n), 123), isNull);
      }
      expect(NbnsDiscoveryService.parse(valid, 124), isNull);
      expect(NbnsDiscoveryService.parse(nbns(123, flags: 0x0c00), 123), isNull);
      expect(
        NbnsDiscoveryService.parse(nbns(123, name: 'UNKNOWN'), 123),
        isNull,
      );
    },
  );
  test('LLMNR PTR query and compressed response recover useful name', () {
    expect(LlmnrResolver.reverse(ip), '42.1.168.192.in-addr.arpa');
    expect(LlmnrResolver.parse(llmnr(55), ip, 55), 'printer-room');
  });
  test(
    'LLMNR rejects malformed, conflicting, unrelated and pointer-loop responses',
    () {
      final valid = llmnr(55);
      for (var n = 0; n < valid.length; n++) {
        expect(LlmnrResolver.parse(valid.sublist(0, n), ip, 55), isNull);
      }
      expect(LlmnrResolver.parse(valid, ip, 56), isNull);
      expect(LlmnrResolver.parse(valid, '192.168.1.43', 55), isNull);
      final conflict = [...valid]..[2] = 0x84;
      expect(LlmnrResolver.parse(conflict, ip, 55), isNull);
      final loop = [...valid]
        ..[12] = 0xc0
        ..[13] = 12;
      expect(LlmnrResolver.parse(loop, ip, 55), isNull);
    },
  );
  test(
    'WS-Discovery stores local endpoint, namespaced types, scopes and XAddrs',
    () {
      final found = WsDiscoveryService.parse(
        utf8.encode(ws('urn:uuid:request')),
        ip,
        lan,
        'urn:uuid:request',
      ).single;
      expect(found.endpoint, startsWith('urn:uuid:'));
      expect(found.xaddrs, ['http://192.168.1.42/device']);
      expect(
        found.types.single,
        '{http://schemas.microsoft.com/windows/2006/08/wdp/print}PrintDeviceType',
      );
      expect(found.scopes, ['urn:example:office']);
      expect(WsDiscoveryService.probe('urn:uuid:test'), contains('<d:Probe/>'));
    },
  );
  test(
    'WS-Discovery rejects external/different-host XAddrs, entities, malformed, oversized and unrelated XML',
    () {
      for (final url in [
        'https://8.8.8.8/x',
        'http://example.com/x',
        'file:///x',
        'http://192.168.1.43/x',
        'http://user@192.168.1.42/x',
      ]) {
        expect(
          WsDiscoveryService.parse(
            utf8.encode(ws('id', xaddr: url)),
            ip,
            lan,
            'id',
          ),
          isEmpty,
        );
      }
      for (final text in [
        '<invalid',
        '<!DOCTYPE a [<!ENTITY x "x">]>${ws('id')}',
        ' ' * 32769,
        ws('other'),
      ]) {
        expect(
          WsDiscoveryService.parse(utf8.encode(text), ip, lan, 'id'),
          isEmpty,
        );
      }
      expect(
        WsDiscoveryService.parse(utf8.encode(ws('id')), '8.8.8.8', lan, 'id'),
        isEmpty,
      );
    },
  );
  test(
    'NBNS plus real SMB evidence yields computer/medium; LLMNR alone stays low',
    () {
      final devices = {
        ip: host(ports: [445]),
      };
      final found = IdentityObservation(
        ip,
        const DiscoveredService(
          name: 'OFFICE-PC',
          hostname: 'OFFICE-PC',
          type: 'nbns:node-status',
          discoveryMethod: 'NBNS',
        ),
        'NetBIOS name: OFFICE-PC',
      );
      IdentityObservation.merge(devices, found, lan);
      IdentityObservation.merge(devices, found, lan);
      expect(devices[ip]!.displayName, 'OFFICE-PC');
      expect(devices[ip]!.type, DeviceType.computer);
      expect(devices[ip]!.confidence, IdentificationConfidence.medium);
      expect(devices[ip]!.services, hasLength(1));
      expect(devices[ip]!.discoveryEvidence, hasLength(1));
      final plain = {ip: host()};
      IdentityObservation.merge(
        plain,
        IdentityObservation(
          ip,
          const DiscoveredService(
            name: 'printer-room',
            hostname: 'printer-room',
            type: 'llmnr:ptr',
            discoveryMethod: 'LLMNR',
          ),
          'LLMNR hostname: printer-room',
        ),
        lan,
      );
      expect(plain[ip]!.type, DeviceType.unknown);
      expect(plain[ip]!.confidence, IdentificationConfidence.low);
    },
  );
  test(
    'WS printer/camera hints are namespace-specific; generic device is not a computer',
    () {
      for (final pair in <String, DeviceType>{
        '{http://schemas.microsoft.com/windows/2006/08/wdp/print}PrintDeviceType':
            DeviceType.printer,
        '{http://www.onvif.org/ver10/network/wsdl}NetworkVideoTransmitter':
            DeviceType.camera,
        '{http://unknown}PrintDeviceType': DeviceType.unknown,
        '{http://schemas.xmlsoap.org/ws/2006/02/devprof}Device':
            DeviceType.unknown,
      }.entries) {
        final devices = <String, NetworkDevice>{};
        IdentityObservation.merge(
          devices,
          IdentityObservation(
            ip,
            DiscoveredService(
              name: 'Web Services device',
              type: 'ws-discovery',
              discoveryMethod: 'WS-Discovery',
              attributes: {
                'types': pair.key,
                'endpoint': 'urn:uuid:11111111-2222-3333-4444-555555555555',
              },
            ),
            'Discovered via WS-Discovery',
          ),
          lan,
        );
        expect(devices[ip]!.type, pair.value);
        expect(devices[ip]!.confidence, isNot(IdentificationConfidence.high));
        expect(
          DeviceIdentityService.strongKeys(devices[ip]!),
          contains('wsd:urn:uuid:11111111-2222-3333-4444-555555555555'),
        );
      }
    },
  );
  test(
    'targeted protocols are bounded and never query unconfirmed/off-subnet targets',
    () async {
      final fake = FakeDatagrams();
      final service = LocalIdentityDiscovery(transport: fake, enabled: true);
      await service.enrich(
        network: lan,
        devices: [
          for (var n = 20; n < 60; n++)
            host(address: '192.168.1.$n', ports: [445]),
          host(address: '8.8.8.8', ports: [445]),
          host(address: '192.168.1.60', ports: [445], online: false),
        ],
        cancellation: ScanCancellation(),
        verifyNetwork: () async {},
        onDevice: (_) {},
      );
      expect(fake.calls.where((c) => c.port == 137), hasLength(16));
      expect(fake.calls.where((c) => c.port == 5355), hasLength(12));
      expect(
        fake.calls
            .where((c) => c.port == 5355)
            .every((c) => c.destination == LlmnrResolver.multicast),
        isTrue,
      );
      expect(
        fake.calls.any(
          (c) => c.destination == '8.8.8.8' || c.destination == '192.168.1.60',
        ),
        isFalse,
      );
    },
  );
  test(
    'targeted reply sender/port checked; names merge only after network verification',
    () async {
      final fake = FakeDatagrams();
      final found = <IdentityObservation>[];
      fake.handle = (q) async {
        final reply = q.port == 137 ? nbns(q.id) : llmnr(q.id);
        expect(q.emit(IdentityPacket(reply, '192.168.1.99', q.port)), isFalse);
        expect(q.emit(IdentityPacket(reply, ip, 99)), isFalse);
        expect(q.emit(IdentityPacket(reply, ip, q.port)), isTrue);
      };
      await LocalIdentityDiscovery(transport: fake, enabled: true).enrich(
        network: lan,
        devices: [
          host(ports: [445]),
        ],
        cancellation: ScanCancellation(),
        verifyNetwork: () async {},
        onDevice: found.add,
      );
      expect(found, hasLength(2));
      expect(found.first.mac!.value, '00:11:22:33:44:55');
    },
  );
  test('cancellation stops exchanges and ignores late replies', () async {
    final fake = FakeDatagrams(), token = ScanCancellation();
    final found = <IdentityObservation>[];
    fake.handle = (q) async {
      token.cancel();
      q.emit(IdentityPacket(nbns(q.id), ip, 137));
    };
    await LocalIdentityDiscovery(transport: fake, enabled: true).enrich(
      network: lan,
      devices: [
        host(ports: [445]),
      ],
      cancellation: token,
      verifyNetwork: () async {},
      onDevice: found.add,
    );
    expect(found, isEmpty);
    expect(fake.calls.every((q) => q.token.isCancelled), isTrue);
  });
  test(
    'WS duplicate replies merge once and network change rejects pending observations',
    () async {
      for (final changed in [false, true]) {
        final fake = FakeDatagrams(), token = ScanCancellation();
        final found = <IdentityObservation>[];
        fake.handle = (q) async {
          final xml = utf8.decode(q.request);
          final id = RegExp(
            r'<a:MessageID>([^<]+)</a:MessageID>',
          ).firstMatch(xml)!.group(1)!;
          q.emit(IdentityPacket(utf8.encode(ws(id)), ip, 3702));
          q.emit(IdentityPacket(utf8.encode(ws(id)), ip, 3702));
        };
        await LocalIdentityDiscovery(transport: fake, enabled: true).discover(
          network: lan,
          cancellation: token,
          verifyNetwork: () async {
            if (changed) token.cancel('Network changed. Scan stopped.');
          },
          onDevice: found.add,
        );
        expect(found, hasLength(changed ? 0 : 1));
      }
    },
  );
}
