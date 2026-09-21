import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/models/network_info.dart';
import 'package:whos_on_my_wifi/models/scan_result.dart';
import 'package:whos_on_my_wifi/models/upnp_description.dart';
import 'package:whos_on_my_wifi/services/local_service_discovery_service.dart';
import 'package:whos_on_my_wifi/services/network_discovery_service.dart';
import 'package:whos_on_my_wifi/services/network_scanner.dart';
import 'package:whos_on_my_wifi/services/service_device_merger.dart';
import 'package:whos_on_my_wifi/services/ssdp_discovery_service.dart';
import 'package:whos_on_my_wifi/services/tcp_host_probe.dart';
import 'package:whos_on_my_wifi/services/scan_history_overlay.dart';

const lan = NetworkInfo(
  id: 'lan',
  connectionType: NetworkConnectionType.wifi,
  localIpAddress: '192.168.1.1',
  ipv4PrefixLength: 24,
  gatewayAddress: '192.168.1.2',
);
ResolvedLocalService service(String ip) => ResolvedLocalService(
  name: 'Office Printer',
  type: '_ipp._tcp.',
  port: 631,
  addresses: [ip],
);

class NsdFake implements LocalServiceDiscovery {
  List<ResolvedLocalService> services = [];
  Future<void>? gate;
  bool started = false;
  Future<void> Function(ResolvedLocalService)? emit;
  @override
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function() verifyNetwork,
    required Future<void> Function(ResolvedLocalService) onService,
  }) async {
    started = true;
    emit = onService;
    for (final found in services) {
      await onService(found);
    }
    if (gate != null) await gate;
    return [];
  }
}

class SsdpFake implements SsdpDiscovery {
  List<SsdpAdvertisement> ads = [];
  bool started = false;
  Future<void>? gate;
  @override
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function() verifyNetwork,
    required void Function(SsdpAdvertisement, UpnpDescription?, Uri?) onDevice,
  }) async {
    started = true;
    for (final ad in ads) {
      onDevice(ad, null, null);
    }
    if (gate != null) await gate;
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'cancellation releases a stalled platform verification and ignores its late result',
    () async {
      final read = Completer<String?>();
      final token = ScanCancellation();
      final updates = <ScanResult>[];
      final scanner = NetworkScanner(
        serviceDiscovery: NsdFake(),
        ssdpDiscovery: SsdpFake(),
        probe: (_) async => fail('No probe may start'),
      );
      final scan = scanner.discover(
        network: lan,
        cancellation: token,
        verifyNetwork: (_) => read.future,
        onProgress: updates.add,
      );
      await Future<void>.delayed(Duration.zero);
      token.cancel();
      expect(
        (await scan.timeout(const Duration(seconds: 1))).state,
        ScanState.cancelled,
      );
      final count = updates.length;
      read.complete('Network changed. Scan stopped.');
      await Future<void>.delayed(NetworkScanner.progressInterval * 2);
      expect(updates.length, count);
    },
  );
  for (final prefix in [23, 22]) {
    test('/$prefix respects its smaller worker limit', () async {
      final gate = Completer<void>();
      var active = 0, peak = 0;
      final scan =
          NetworkScanner(
            serviceDiscovery: NsdFake(),
            ssdpDiscovery: SsdpFake(),
            probe: (_) async {
              active++;
              if (active > peak) peak = active;
              await gate.future;
              active--;
              return [];
            },
          ).discover(
            network: NetworkInfo(
              id: 'lan',
              connectionType: NetworkConnectionType.wifi,
              localIpAddress: '192.168.1.1',
              ipv4PrefixLength: prefix,
            ),
          );
      await Future<void>.delayed(Duration.zero);
      expect(active, prefix == 23 ? 40 : 32);
      gate.complete();
      final result = await scan;
      expect(peak, NetworkScanner.workersFor(result.totalCandidates));
      expect(result.state, ScanState.completed);
    });
  }
  test('only platform-specific explicit refusal is reachability', () async {
    for (final entry in {
      'android': 111,
      'linux': 111,
      'windows': 10061,
      'macos': 61,
    }.entries) {
      expect(
        TcpHostProbe.isRefused(
          SocketException('ignored', osError: OSError('', entry.value)),
          operatingSystem: entry.key,
        ),
        isTrue,
      );
    }
    for (final code in [null, 110, 101, 113, 104, 61]) {
      expect(
        TcpHostProbe.isRefused(
          SocketException(
            'Connection refused',
            osError: code == null ? null : OSError('', code),
          ),
          operatingSystem: 'android',
        ),
        isFalse,
      );
    }
    var calls = 0;
    final found = await TcpHostProbe.probe(
      '192.168.1.2',
      operatingSystem: 'android',
      attempt: (_, port, timeout) async {
        calls++;
        throw const SocketException('', osError: OSError('', 111));
      },
    );
    expect(calls, 1);
    expect(found.single, contains('refused'));
  });
  test(
    'timeouts fall through two small tiers; success stops immediately',
    () async {
      final ports = <int>[];
      final timeouts = <Duration>[];
      final result = await TcpHostProbe.probe(
        '192.168.1.2',
        attempt: (_, port, timeout) async {
          ports.add(port);
          timeouts.add(timeout);
          if (port != 631) throw TimeoutException('no response');
        },
      );
      expect(ports, [80, 443, 22, 445, 631]);
      expect(timeouts.take(4), everyElement(TcpHostProbe.primaryTimeout));
      expect(timeouts.last, TcpHostProbe.secondaryTimeout);
      expect(result.single, contains('631'));
      expect(
        await TcpHostProbe.probe(
          '192.168.1.2',
          attempt: (_, _, _) async => throw TimeoutException(''),
        ),
        isEmpty,
      );
    },
  );
  test(
    'new service evidence stops remaining ports on an in-flight IP',
    () async {
      var live = false, calls = 0;
      expect(
        await TcpHostProbe.probe(
          '192.168.1.2',
          knownLive: () => live,
          attempt: (_, _, _) async {
            calls++;
            live = true;
            throw TimeoutException('');
          },
        ),
        isEmpty,
      );
      expect(calls, 1);
    },
  );
  test('adaptive concurrency boundaries', () {
    expect([1, 256, 257, 512, 513, 1024].map(NetworkScanner.workersFor), [
      48,
      48,
      40,
      40,
      32,
      32,
    ]);
  });
  test(
    'all sources overlap; late TCP preserves service identity; updates batch',
    () async {
      final gate = Completer<void>();
      final nsd = NsdFake()..gate = gate.future;
      final ssdp = SsdpFake()..gate = gate.future;
      final updates = <ScanResult>[];
      var active = 0, peak = 0, checks = 0;
      final scan =
          NetworkScanner(
            serviceDiscovery: nsd,
            ssdpDiscovery: ssdp,
            probe: (ip) async {
              active++;
              if (active > peak) peak = active;
              await gate.future;
              active--;
              return ip == '192.168.1.2' ? ['TCP success'] : [];
            },
          ).discover(
            network: lan,
            onProgress: updates.add,
            verifyNetwork: (_) async {
              checks++;
              return null;
            },
          );
      await Future<void>.delayed(Duration.zero);
      expect(nsd.started && ssdp.started, isTrue);
      expect(active, 48);
      await nsd.emit!(service('192.168.1.2'));
      await nsd.emit!(service('192.168.1.2'));
      await Future<void>.delayed(NetworkScanner.progressInterval * 2);
      expect(updates.last.devices.last.services, hasLength(1));
      gate.complete();
      final result = await scan;
      expect(peak, 48);
      expect(
        result.devices.where((d) => d.ipAddress == '192.168.1.2'),
        hasLength(1),
      );
      expect(result.devices.last.services, hasLength(1));
      expect(result.devices.last.discoveryEvidence, contains('TCP success'));
      expect(result.diagnostics!.tcpHosts, 1);
      expect(result.diagnostics!.nsdOnlyHosts, 0);
      expect(
        result.diagnostics!.durations.keys,
        containsAll(['tcp', 'nsd', 'ssdp', 'identifying', 'finalizing']),
      );
      expect(result.addressesChecked, 253);
      expect(updates.last.state, ScanState.completed);
      expect(updates.length, lessThan(12));
      expect(checks, lessThan(10));
    },
  );
  test('service-only sources deduplicate and skip pending TCP work', () async {
    final nsd = NsdFake()
      ..services = [service('192.168.1.254'), service('192.168.1.254')];
    final ssdp = SsdpFake()
      ..ads = [
        SsdpAdvertisement('192.168.1.253', {
          'st': 'upnp:rootdevice',
          'usn': 'uuid:test',
        }),
      ];
    final probed = <String>[];
    final result = await NetworkScanner(
      serviceDiscovery: nsd,
      ssdpDiscovery: ssdp,
      probe: (ip) async {
        probed.add(ip);
        return [];
      },
    ).discover(network: lan);
    expect(probed, isNot(contains('192.168.1.254')));
    expect(probed, isNot(contains('192.168.1.253')));
    expect(probed.toSet().length, probed.length);
    expect(result.diagnostics!.skippedProbes, 2);
    expect(result.diagnostics!.nsdOnlyHosts, 1);
    expect(result.diagnostics!.ssdpOnlyHosts, 1);
    expect(result.diagnostics!.serviceOnlyHosts, 2);
    expect(result.devices, hasLength(4));
    expect(result.possibleIsolation, isFalse);
  });
  test(
    'isolation requires responding gateway, not just gateway metadata',
    () async {
      Future<ScanResult> run(bool gateway) => NetworkScanner(
        serviceDiscovery: NsdFake(),
        ssdpDiscovery: SsdpFake(),
        probe: (ip) async =>
            gateway && ip == lan.gatewayAddress ? ['TCP success'] : [],
      ).discover(network: lan);
      expect((await run(false)).possibleIsolation, isFalse);
      expect((await run(true)).possibleIsolation, isTrue);
    },
  );
  test(
    'history counts offline devices separately and preserves diagnostics',
    () async {
      final scan = await NetworkScanner(
        serviceDiscovery: NsdFake(),
        ssdpDiscovery: SsdpFake(),
        probe: (_) async => [],
      ).discover(network: lan);
      final merged = ScanHistoryOverlay.merge(scan, [
        NetworkDevice(
          id: 'old',
          ipAddress: '192.168.1.99',
          firstSeen: DateTime(2025),
          lastSeen: DateTime(2025),
          isOnline: true,
        ),
      ]);
      expect(merged.onlineDevices, 2);
      expect(merged.knownDevices, 3);
      expect(merged.devicesFound, 2);
      expect(merged.diagnostics, same(scan.diagnostics));
    },
  );
}
