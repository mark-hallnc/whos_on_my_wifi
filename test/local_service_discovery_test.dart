import 'support/no_ssdp_discovery.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/models/network_info.dart';
import 'package:whos_on_my_wifi/models/scan_result.dart';
import 'package:whos_on_my_wifi/services/service_device_merger.dart';
import 'package:whos_on_my_wifi/services/local_service_discovery_service.dart';
import 'package:whos_on_my_wifi/services/network_discovery_service.dart';
import 'package:whos_on_my_wifi/services/network_scanner.dart';

const network = NetworkInfo(
  id: 'lan',
  connectionType: NetworkConnectionType.wifi,
  localIpAddress: '192.168.1.1',
  ipv4PrefixLength: 24,
);
Map<String, Object> service({
  String type = '_googlecast._tcp.',
  int port = 8009,
  String name = 'Living Room',
  List<String> addresses = const ['192.168.1.42'],
}) => {
  'name': name,
  'type': type,
  'port': port,
  'addresses': addresses,
  'attributes': <String, String>{},
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const channel = MethodChannel('whos_on_my_wifi/nsd');
  late int id;
  late int stops;
  late Completer<void> started;
  setUp(() {
    id = 0;
    stops = 0;
    started = Completer<void>();
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'start') {
        id = (call.arguments as Map)['id'] as int;
        started.complete();
      }
      if (call.method == 'stop') stops++;
      return null;
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  Future<void> emit(
    String method, [
    Map<String, Object> data = const {},
  ]) async {
    final completed = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.channelBuffers.push(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall(method, {'id': id, ...data}),
      ),
      (_) => completed.complete(),
    );
    await completed.future;
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'merge preserves TCP data, custom name, stronger type and first seen',
    () {
      final first = DateTime(2020);
      final devices = {
        '192.168.1.42': NetworkDevice(
          id: 'existing',
          ipAddress: '192.168.1.42',
          firstSeen: first,
          lastSeen: first,
          customName: 'My speaker',
          type: DeviceType.iot,
          confidence: IdentificationConfidence.high,
          classification: DeviceClassification.mine,
          discoveryEvidence: ['TCP success'],
          openPorts: [80],
          notes: 'keep',
        ),
      };
      ServiceDeviceMerger.merge(
        devices,
        ResolvedLocalService.fromPlatform(service())!,
        network,
      );
      final result = devices.values.single;
      expect(result.id, 'existing');
      expect(result.displayName, 'My speaker');
      expect(result.firstSeen, first);
      expect(result.lastSeen.isAfter(first), isTrue);
      expect(result.discoveryEvidence, contains('TCP success'));
      expect(result.type, DeviceType.iot);
      expect(result.confidence, IdentificationConfidence.high);
      expect(result.classification, DeviceClassification.mine);
      expect(result.notes, 'keep');
      expect(result.openPorts, [80, 8009]);
    },
  );

  test('NSD-only device, service and advertised ports are deduplicated', () {
    final devices = <String, NetworkDevice>{};
    final found = ResolvedLocalService.fromPlatform(service())!;
    ServiceDeviceMerger.merge(devices, found, network);
    ServiceDeviceMerger.merge(devices, found, network);
    final result = devices.values.single;
    expect(result.displayName, 'Living Room');
    expect(result.isOnline, isTrue);
    expect(result.services.length, 1);
    expect(result.services.single.discoveryMethod, 'mDNS / Android NSD');
    expect(result.services.single.label, 'Google Cast');
    expect(result.openPorts, [8009]);
    expect(result.type, DeviceType.mediaDevice);
    expect(result.confidence, IdentificationConfidence.medium);
  });

  test('printer hint is strong; ambiguous services do not imply hardware', () {
    for (final type in ResolvedLocalService.serviceTypes) {
      final devices = <String, NetworkDevice>{};
      ServiceDeviceMerger.merge(
        devices,
        ResolvedLocalService.fromPlatform(service(type: type))!,
        network,
      );
      final printer = [
        '_ipp._tcp.',
        '_ipps._tcp.',
        '_printer._tcp.',
      ].contains(type);
      expect(
        devices.values.single.type,
        printer ? DeviceType.printer : switch (type) {
          '_googlecast._tcp.' => DeviceType.mediaDevice,
          '_workstation._tcp.' => DeviceType.computer,
          _ => DeviceType.unknown,
        },
      );
      expect(
        devices.values.single.confidence,
        printer || ['_googlecast._tcp.', '_airplay._tcp.', '_raop._tcp.', '_workstation._tcp.'].contains(type)
            ? IdentificationConfidence.medium
            : IdentificationConfidence.low,
      );
    }
  });

  test('generic names never replace useful identity', () {
    final devices = <String, NetworkDevice>{};
    for (final name in [
      'localhost',
      'android',
      'unknown',
      '_http',
      '192.168.1.42',
    ]) {
      ServiceDeviceMerger.merge(
        devices,
        ResolvedLocalService.fromPlatform(service(name: name))!,
        network,
      );
      expect(devices.values.single.displayName, 'Unknown device');
    }
    ServiceDeviceMerger.merge(
      devices,
      ResolvedLocalService.fromPlatform(service())!,
      network,
    );
    ServiceDeviceMerger.merge(
      devices,
      ResolvedLocalService.fromPlatform(service(name: 'android'))!,
      network,
    );
    expect(devices.values.single.displayName, 'Living Room');
  });

  test(
    'off-subnet, network, broadcast and IPv6 addresses never create IPv4 rows',
    () {
      final devices = <String, NetworkDevice>{};
      final found = ResolvedLocalService.fromPlatform(
        service(
          addresses: [
            '10.0.0.42',
            '192.168.1.0',
            '192.168.1.255',
            '127.0.0.1',
            'fe80::123',
            '192.168.1.42',
          ],
        ),
      )!;
      ServiceDeviceMerger.merge(devices, found, network);
      expect(devices.keys, ['192.168.1.42']);
      expect(
        devices.values.single.services.single.addresses,
        contains('fe80::123'),
      );
    },
  );

  test('parser normalizes types and rejects malformed services', () {
    expect(
      ResolvedLocalService.fromPlatform(
        service(type: '_IPP._TCP.local.'),
      )!.type,
      '_ipp._tcp.',
    );
    expect(ResolvedLocalService.fromPlatform(service(port: 0)), isNull);
    expect(ResolvedLocalService.fromPlatform(service(port: 65536)), isNull);
    expect(
      ResolvedLocalService.fromPlatform(service(type: '_other._tcp.')),
      isNull,
    );
    expect(
      ResolvedLocalService.fromPlatform(service(addresses: ['bad address'])),
      isNull,
    );
  });

  test(
    'platform bridge merges NSD-only devices into final scanner results',
    () async {
      final updates = <ScanResult>[];
      final scanner = NetworkScanner(
        ssdpDiscovery: const NoSsdpDiscovery(),
        probe: (_) async => [],
      );
      final pending = scanner.discover(
        network: network,
        onProgress: updates.add,
      );
      await started.future;
      expect(updates.last.state, ScanState.discoveringServices);
      expect(updates.last.addressesChecked, 253);
      await emit('service', service());
      await emit('service', service());
      await emit('done');
      final result = await pending;
      expect(result.state, ScanState.completed);
      expect(result.devices.length, 2);
      expect(result.devices.last.discoveredName, 'Living Room');
      expect(result.devices.last.hostname, isNull);
      expect(result.devices.last.services.length, 1);
      expect(stops, 1);
    },
  );

  test(
    'cancellation stops native discovery and ignores late service replies',
    () async {
      final token = ScanCancellation();
      final updates = <ScanResult>[];
      final pending =
          NetworkScanner(
            ssdpDiscovery: const NoSsdpDiscovery(),
            probe: (_) async => [],
          ).discover(
            network: network,
            cancellation: token,
            onProgress: updates.add,
          );
      await started.future;
      await emit('service', service());
      token.cancel();
      await emit('service', service(addresses: ['192.168.1.43']));
      final result = await pending;
      expect(result.state, ScanState.cancelled);
      expect(result.devices.length, 2);
      expect(result.devices.last.services.length, 1);
      expect(stops, 1);
    },
  );

  test(
    'network change during NSD drops evidence and preserves TCP results',
    () async {
      var changed = false;
      final pending =
          NetworkScanner(
            ssdpDiscovery: const NoSsdpDiscovery(),
            probe: (_) async => [],
          ).discover(
            network: network,
            verifyNetwork: (_) async =>
                changed ? 'Network changed. Scan stopped.' : null,
          );
      await started.future;
      changed = true;
      await emit('service', service());
      final result = await pending;
      expect(result.state, ScanState.cancelled);
      expect(result.message, 'Network changed. Scan stopped.');
      expect(result.devices.length, 1);
      expect(stops, 1);
    },
  );

  testWidgets('quiet service window has a deadline and stops the bridge', (
    tester,
  ) async {
    final pending = AndroidNsdDiscoveryService().discover(
      network: network,
      cancellation: ScanCancellation(),
      onService: (_) async {},
      verifyNetwork: () async {},
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await pending;
    expect(stops, 1);
  });
}
