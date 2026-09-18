import 'support/no_ssdp_discovery.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:whos_on_my_wifi/services/network_discovery_service.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/models/network_info.dart';
import 'package:whos_on_my_wifi/models/scan_result.dart';
import 'package:whos_on_my_wifi/services/network_scanner.dart';
import 'package:whos_on_my_wifi/utils/ipv4_subnet.dart';

NetworkInfo network(int prefix, {String? gateway}) => NetworkInfo(
  id: 'test',
  connectionType: NetworkConnectionType.wifi,
  localIpAddress: '192.168.1.1',
  ipv4PrefixLength: prefix,
  gatewayAddress: gateway,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const nsd = MethodChannel('whos_on_my_wifi/nsd');
  setUp(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          nsd,
          (_) async => throw MissingPluginException(),
        ),
  );
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nsd, null),
  );
  test('/24 excludes current device, network and broadcast', () {
    final subnet = Ipv4Subnet('192.168.1.77', 24);
    expect(subnet.candidateCount, 253);
    expect(subnet.candidates.length, 253);
    expect(subnet.candidates.first, '192.168.1.1');
    expect(subnet.candidates.last, '192.168.1.254');
    expect(subnet.candidates, isNot(contains('192.168.1.77')));
    expect(subnet.candidates, isNot(contains('192.168.1.0')));
    expect(subnet.candidates, isNot(contains('192.168.1.255')));
  });
  test('/30 contains only the other usable host', () {
    final subnet = Ipv4Subnet('192.168.1.1', 30);
    expect(subnet.candidateCount, 1);
    expect(subnet.candidates, ['192.168.1.2']);
  });
  test('/31 allows both point-to-point endpoints', () {
    expect(Ipv4Subnet('192.168.1.0', 31).candidates, ['192.168.1.1']);
    expect(Ipv4Subnet('192.168.1.1', 31).candidates, ['192.168.1.0']);
    expect(Ipv4Subnet('192.168.1.1', 31).candidateCount, 1);
  });
  test('/32 has no remote candidates', () {
    final subnet = Ipv4Subnet('192.168.1.1', 32);
    expect(subnet.candidateCount, 0);
    expect(subnet.candidates, isEmpty);
  });
  test('large subnets are counted without enumeration', () {
    expect(Ipv4Subnet('192.168.1.1', 0).candidateCount, 4294967293);
    expect(Ipv4Subnet('192.168.1.1', 22).candidateCount, 1021);
    expect(Ipv4Subnet('192.168.1.1', 21).candidateCount, 2045);
  });
  test('over-cap result does not probe any addresses', () async {
    var probes = 0;
    final scanner = NetworkScanner(
      ssdpDiscovery: const NoSsdpDiscovery(),
      probe: (_) async {
        probes++;
        return [];
      },
    );
    final result = await scanner.discover(network: network(21));
    expect(result.state, ScanState.subnetTooLarge);
    expect(result.totalCandidates, 2045);
    expect(result.addressesChecked, 0);
    expect(result.message, contains('1024'));
    expect(probes, 0);
  });
  test('/22 stays under cap and is fully checked', () async {
    final result = await NetworkScanner(
      ssdpDiscovery: const NoSsdpDiscovery(),
      probe: (_) async => [],
    ).discover(network: network(22));
    expect(result.state, ScanState.completed);
    expect(result.addressesChecked, 1021);
  });
  test(
    'bounded workers report live evidence and deduplicate gateway',
    () async {
      final gate = Completer<void>();
      var active = 0;
      var peak = 0;
      final probed = <String>[];
      final updates = <ScanResult>[];
      final scanner = NetworkScanner(
        ssdpDiscovery: const NoSsdpDiscovery(),
        probe: (ip) async {
          probed.add(ip);
          active++;
          if (active > peak) peak = active;
          await gate.future;
          active--;
          return ip == '192.168.1.2'
              ? ['TCP connection succeeded on port 80']
              : [];
        },
      );
      final pending = scanner.discover(
        network: network(24, gateway: '192.168.1.2'),
        onProgress: updates.add,
      );
      await Future<void>.delayed(Duration.zero);
      expect(probed.length, NetworkScanner.concurrency);
      gate.complete();
      final result = await pending;
      expect(peak, NetworkScanner.concurrency);
      expect(probed.toSet().length, 253);
      expect(probed, isNot(contains('192.168.1.1')));
      expect(result.state, ScanState.completed);
      expect(result.addressesChecked, 253);
      expect(result.devices.length, 2);
      expect(result.devices.first.displayName, 'This device');
      expect(result.devices.first.isCurrentDevice, isTrue);
      final gateway = result.devices.last;
      expect(gateway.displayName, 'Router / Gateway');
      expect(gateway.isGateway, isTrue);
      expect(gateway.discoveryEvidence.length, 2);
      expect(gateway.manufacturer, isNull);
      expect(gateway.macAddress, isNull);
      expect(updates.first.state, ScanState.running);
      expect(updates.last.state, ScanState.completed);
      expect(updates.where((r) => r.state == ScanState.running).length, 254);
      expect(updates.first.addressesChecked, 0);
    },
  );
  test('unknown remote host contains only observed identity', () async {
    final result = await NetworkScanner(
      ssdpDiscovery: const NoSsdpDiscovery(),
      probe: (_) async => ['TCP success'],
    ).discover(network: network(30));
    final remote = result.devices.last;
    expect(remote.displayName, 'Unknown device');
    expect(remote.isOnline, isTrue);
    expect(remote.hostname, isNull);
    expect(remote.customName, isNull);
    expect(remote.discoveryEvidence, ['TCP success']);
    expect(remote.lastSeen.isBefore(remote.firstSeen), isFalse);
  });
  test('probe failure has a final failed state', () async {
    final updates = <ScanResult>[];
    final result = await NetworkScanner(
      ssdpDiscovery: const NoSsdpDiscovery(),
      probe: (_) async => throw StateError('failure'),
    ).discover(network: network(24), onProgress: updates.add);
    expect(result.state, ScanState.failed);
    expect(updates.last.state, ScanState.failed);
    expect(result.message, isNotEmpty);
  });
  test('missing prefix never assumes /24', () async {
    final result =
        await NetworkScanner(
          ssdpDiscovery: const NoSsdpDiscovery(),
          probe: (_) async => fail('Unexpected probe'),
        ).discover(
          network: const NetworkInfo(
            id: 'test',
            connectionType: NetworkConnectionType.wifi,
            localIpAddress: '192.168.1.1',
          ),
        );
    expect(result.state, ScanState.failed);
  });
  test('/32 includes current device once even if also gateway', () async {
    final result = await NetworkScanner(
      ssdpDiscovery: const NoSsdpDiscovery(),
      probe: (_) async => fail('Unexpected probe'),
    ).discover(network: network(32, gateway: '192.168.1.1'));
    expect(result.state, ScanState.completed);
    expect(result.devices.length, 1);
    expect(result.devices.single.isCurrentDevice, isTrue);
    expect(result.devices.single.isGateway, isTrue);
    expect(result.addressesChecked, 0);
  });

  test(
    'cancellation freezes partial results and stops scheduling; restart works',
    () async {
      final pending = <Completer<List<String>>>[];
      final token = ScanCancellation();
      final updates = <ScanResult>[];
      final scanner = NetworkScanner(
        ssdpDiscovery: const NoSsdpDiscovery(),
        probe: (_) {
          final probe = Completer<List<String>>();
          pending.add(probe);
          return probe.future;
        },
      );
      final scan = scanner.discover(
        network: network(24),
        cancellation: token,
        onProgress: updates.add,
      );
      await Future<void>.delayed(Duration.zero);
      expect(pending.length, NetworkScanner.concurrency);
      pending.first.complete(['TCP success']);
      await Future<void>.delayed(Duration.zero);
      expect(updates.last.devicesFound, 2);
      final checked = updates.last.addressesChecked;
      final scheduled = pending.length;
      token.cancel();
      expect(updates.last.state, ScanState.cancelled);
      expect(updates.last.devicesFound, 2);
      // A duplicate request still joins the old scan until its workers drain.
      final duplicate = scanner.discover(network: network(30));
      expect(identical(scan, duplicate), isTrue);
      for (final probe in pending.skip(1)) {
        probe.complete(['Late reply']);
      }
      final result = await scan;
      expect(result.state, ScanState.cancelled);
      expect(result.addressesChecked, checked);
      expect(result.devicesFound, 2);
      expect(pending.length, scheduled);
      expect(updates.last.addressesChecked, checked);
      final again = await scanner.discover(network: network(32));
      expect(again.state, ScanState.completed);
      expect(again.addressesChecked, 0);
      expect(again.devicesFound, 1);
    },
  );

  test(
    'network change drops in-flight evidence and preserves old results',
    () async {
      final initial = network(24);
      var current = initial;
      final probes = <Completer<List<String>>>[];
      final scanner = NetworkScanner(
        ssdpDiscovery: const NoSsdpDiscovery(),
        probe: (_) {
          final probe = Completer<List<String>>();
          probes.add(probe);
          return probe.future;
        },
      );
      final scan = scanner.discover(
        network: initial,
        verifyNetwork: (start) async =>
            NetworkScanner.networkChangeReason(start, current),
      );
      await Future<void>.delayed(Duration.zero);
      probes.first.complete(['Old network host']);
      await Future<void>.delayed(Duration.zero);
      final count = probes.length;
      current = const NetworkInfo(
        id: 'other',
        connectionType: NetworkConnectionType.wifi,
        localIpAddress: '10.0.0.1',
        ipv4PrefixLength: 24,
      );
      for (final probe in probes.skip(1)) {
        probe.complete(['New network reply']);
      }
      final result = await scan;
      expect(result.state, ScanState.cancelled);
      expect(result.message, 'Network changed. Scan stopped.');
      expect(result.devicesFound, 2);
      expect(result.addressesChecked, 1);
      expect(probes.length, count);
      expect(result.network, same(initial));
    },
  );

  test('each identity component detects a network change', () {
    final initial = network(24);
    for (final changed in [
      network(25),
      network(24, gateway: '192.168.1.254'),
      const NetworkInfo(
        id: 'test',
        connectionType: NetworkConnectionType.wifi,
        localIpAddress: '192.168.1.2',
        ipv4PrefixLength: 24,
      ),
      const NetworkInfo(
        id: 'new-id',
        connectionType: NetworkConnectionType.wifi,
        localIpAddress: '192.168.1.1',
        ipv4PrefixLength: 24,
      ),
    ]) {
      expect(
        NetworkScanner.networkChangeReason(initial, changed),
        'Network changed. Scan stopped.',
      );
    }
    expect(NetworkScanner.networkChangeReason(initial, initial), isNull);
    expect(
      NetworkScanner.networkChangeReason(
        initial,
        const NetworkInfo(id: 'lost'),
      ),
      'Network connection lost. Scan stopped.',
    );
  });

  test('permission loss cancels instead of failing', () async {
    final result = await NetworkScanner(
      ssdpDiscovery: const NoSsdpDiscovery(),
      probe: (_) async => throw const SocketException(
        'Permission denied',
        osError: OSError('Permission denied', 13),
      ),
    ).discover(network: network(30));
    expect(result.state, ScanState.cancelled);
    expect(result.message, contains('permission unavailable'));
  });

  test('already cancelled preparation does not schedule work', () async {
    final token = ScanCancellation()..cancel();
    final result = await NetworkScanner(
      ssdpDiscovery: const NoSsdpDiscovery(),
      probe: (_) async => fail('Unexpected probe'),
    ).discover(network: network(24), cancellation: token);
    expect(result.state, ScanState.cancelled);
  });
}
