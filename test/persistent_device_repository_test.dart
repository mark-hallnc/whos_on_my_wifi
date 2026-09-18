import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/data/database/app_database.dart'
    show AppDatabase;
import 'package:whos_on_my_wifi/models/network_info.dart';
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/models/discovered_service.dart';
import 'package:whos_on_my_wifi/models/upnp_description.dart';
import 'package:whos_on_my_wifi/models/scan_result.dart';
import 'package:whos_on_my_wifi/repositories/persistent_device_repository.dart';
import 'package:whos_on_my_wifi/services/device_identity_service.dart';

const network = NetworkInfo(
  id: 'android-123',
  name: 'Home',
  localIpAddress: '192.168.1.2',
  ipv4PrefixLength: 24,
  gatewayAddress: '192.168.1.1',
  connectionType: NetworkConnectionType.wifi,
);
final start = DateTime.utc(2026, 9, 18);
NetworkDevice observed({
  String ip = '192.168.1.42',
  String? mac = '00:11:22:33:44:55',
  String? hostname,
  int minute = 0,
  String? udn,
  List<DiscoveredService> services = const [],
}) => NetworkDevice(
  id: ip,
  ipAddress: ip,
  macAddress: mac,
  hostname: hostname,
  firstSeen: start.add(Duration(minutes: minute)),
  lastSeen: start.add(Duration(minutes: minute)),
  isOnline: true,
  services: services,
  upnpDescription: udn == null ? null : UpnpDescription({'UDN': udn}, []),
);
ScanResult scan(
  List<NetworkDevice> devices, {
  int minute = 0,
  ScanState state = ScanState.completed,
  NetworkInfo info = network,
}) => ScanResult(
  network: info,
  devices: devices,
  state: state,
  startedAt: start.add(Duration(minutes: minute)),
  completedAt: state == ScanState.completed
      ? start.add(Duration(minutes: minute, seconds: 5))
      : null,
  totalCandidates: 253,
  addressesChecked: state == ScanState.completed ? 253 : 12,
  discoveryMethods: const ['TCP', 'mDNS', 'SSDP'],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late PersistentDeviceRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PersistentDeviceRepository(db);
  });
  tearDown(() => repo.close());

  test(
    'network inserted and reused despite ephemeral Android ID; SSID alone insufficient',
    () async {
      await repo.saveScan(scan([observed()]));
      await repo.saveScan(
        scan(
          [observed(minute: 1)],
          minute: 1,
          info: const NetworkInfo(
            id: 'android-999',
            name: 'Home',
            localIpAddress: '192.168.1.3',
            ipv4PrefixLength: 24,
            gatewayAddress: '192.168.1.1',
            connectionType: NetworkConnectionType.wifi,
          ),
        ),
      );
      final saved = await repo.getSavedNetworks();
      expect(saved.length, 1);
      expect(saved.single.deviceCount, 1);
      expect(saved.single.scanCount, 2);
      expect(
        saved.single.lastScanned,
        start.add(const Duration(minutes: 1, seconds: 5)),
      );
      expect(
        DeviceIdentityService.networkKey(network),
        isNot(
          DeviceIdentityService.networkKey(
            const NetworkInfo(
              id: 'x',
              name: 'Home',
              localIpAddress: '10.0.0.2',
              ipv4PrefixLength: 24,
              gatewayAddress: '10.0.0.1',
              connectionType: NetworkConnectionType.wifi,
            ),
          ),
        ),
      );
    },
  );
  test(
    'same device preserves earliest firstSeen and updates lastSeen; new flag expires next scan',
    () async {
      final a = await repo.saveScan(scan([observed()]));
      expect(a.devices.single.isNew, isTrue);
      final b = await repo.saveScan(scan([observed(minute: 5)], minute: 5));
      expect(b.devices.single.id, a.devices.single.id);
      expect(b.devices.single.firstSeen, start);
      expect(b.devices.single.lastSeen, start.add(const Duration(minutes: 5)));
      expect(b.devices.single.isNew, isFalse);
    },
  );
  test(
    'global MAC follows DHCP and normalized IP visits retain dates',
    () async {
      final first = await repo.saveScan(scan([observed()]));
      final next = await repo.saveScan(
        scan([observed(ip: '192.168.1.97', minute: 2)], minute: 2),
      );
      expect(next.devices.single.id, first.devices.single.id);
      expect(next.devices.single.previousIpAddresses, ['192.168.1.42']);
      final visits = await repo.getDeviceHistory(first.devices.single.id);
      expect(visits.map((v) => v.address), ['192.168.1.97', '192.168.1.42']);
      expect(visits.last.firstSeen, start);
    },
  );
  test(
    'private MAC alone does not follow IP change; corroborated private identity can',
    () async {
      await repo.saveScan(scan([observed(mac: 'DA:12:34:56:78:90')]));
      final result = await repo.saveScan(
        scan([
          observed(mac: 'DA:12:34:56:78:90', ip: '192.168.1.97', minute: 1),
        ], minute: 1),
      );
      expect(result.devices.length, 2);
      expect(result.devices.where((d) => d.isOnline).length, 1);
      expect(
        DeviceIdentityService.fallbackMatch(
          observed(mac: 'DA:12:34:56:78:90', hostname: 'camera.local'),
          observed(
            mac: 'DA:12:34:56:78:90',
            hostname: 'camera.local',
            ip: '192.168.1.97',
            minute: 1,
          ),
        ),
        isTrue,
      );
    },
  );
  test('UPnP UUID and specific Cast ID match across IP changes', () async {
    const udn = 'uuid:01234567-89ab-cdef-0123-456789abcdef';
    await repo.saveScan(scan([observed(mac: null, udn: udn)]));
    final result = await repo.saveScan(
      scan([
        observed(mac: null, udn: udn, ip: '192.168.1.97', minute: 1),
      ], minute: 1),
    );
    expect(result.devices.length, 1);
    expect(
      DeviceIdentityService.strongKeys(
        observed(
          mac: null,
          services: const [
            DiscoveredService(
              name: 'Living Room',
              type: '_googlecast._tcp.',
              discoveryMethod: 'mDNS',
              attributes: {'id': '0123456789abcdef0123456789abcdef'},
            ),
          ],
        ),
      ),
      ['cast:0123456789abcdef0123456789abcdef'],
    );
  });
  test(
    'user custom name, notes and classification survive scanner updates',
    () async {
      final first = (await repo.saveScan(scan([observed()]))).devices.single;
      await repo.updateDevice(
        first.id,
        customName: 'Garage Camera',
        classification: DeviceClassification.mine,
        notes: 'Above the door',
      );
      final device = (await repo.saveScan(
        scan([observed(minute: 1, ip: '192.168.1.97')], minute: 1),
      )).devices.single;
      expect(device.customName, 'Garage Camera');
      expect(device.classification, DeviceClassification.mine);
      expect(device.notes, 'Above the door');
      await repo.updateDevice(
        first.id,
        customName: '',
        classification: DeviceClassification.guest,
        notes: '',
      );
      expect((await repo.getDevice(first.id))!.customName, isNull);
    },
  );
  test('services deduplicate across scans and IP changes', () async {
    const service = DiscoveredService(
      name: 'Web',
      type: '_http._tcp.',
      discoveryMethod: 'mDNS',
      host: '192.168.1.42',
      port: 80,
    );
    await repo.saveScan(
      scan([
        observed(services: [service, service]),
      ]),
    );
    final next = await repo.saveScan(
      scan([
        observed(
          minute: 1,
          ip: '192.168.1.97',
          services: const [
            DiscoveredService(
              name: 'Web',
              type: '_http._tcp.',
              discoveryMethod: 'mDNS',
              host: '192.168.1.97',
              port: 80,
            ),
          ],
        ),
      ], minute: 1),
    );
    expect(next.devices.single.services.length, 1);
    expect(next.devices.single.services.single.host, '192.168.1.97');
  });
  for (final state in [
    ScanState.completed,
    ScanState.cancelled,
    ScanState.failed,
    ScanState.subnetTooLarge,
  ]) {
    test('$state establishes absence only when completed', () async {
      await repo.saveScan(scan([observed()]));
      final next = await repo.saveScan(scan([], minute: 1, state: state));
      expect(next.devices.single.isOnline, state != ScanState.completed);
      final row = await db
          .customSelect('SELECT online FROM stored_devices')
          .getSingle();
      expect(row.read<int>('online'), state == ScanState.completed ? 0 : 1);
      expect(
        (await db.customSelect('SELECT * FROM network_scans').get()).length,
        2,
      );
      expect(next.devicesFound, 0);
    });
  }
  test(
    'fallback upgrades to MAC with corroboration; ID and user metadata retained',
    () async {
      final first = (await repo.saveScan(
        scan([observed(mac: null, hostname: 'camera.local')]),
      )).devices.single;
      await repo.updateDevice(
        first.id,
        customName: 'Garage',
        classification: DeviceClassification.known,
        notes: 'Keep',
      );
      final next = await repo.saveScan(
        scan([observed(hostname: 'camera.local', minute: 1)], minute: 1),
      );
      expect(next.devices.single.id, first.id);
      expect(next.devices.single.customName, 'Garage');
      expect(
        (await db
                .customSelect('SELECT identity_key FROM stored_devices')
                .getSingle())
            .read<String>('identity_key'),
        'mac:00:11:22:33:44:55',
      );
    },
  );
  test(
    'IP alone is temporary; conflicting identities never inherit user metadata',
    () async {
      final first = (await repo.saveScan(
        scan([observed(mac: null)]),
      )).devices.single;
      final same = await repo.saveScan(
        scan([observed(mac: null, minute: 1)], minute: 1),
      );
      expect(same.devices.single.id, first.id);
      final later = await repo.saveScan(
        scan([observed(mac: null, minute: 1500)], minute: 1500),
      );
      expect(later.devices.length, 2);
      expect(
        DeviceIdentityService.fallbackMatch(
          observed(hostname: 'same'),
          observed(mac: '00:11:22:33:44:66', hostname: 'same', minute: 1),
        ),
        isFalse,
      );
    },
  );
  test(
    'duplicate scan and duplicate observations do not insert duplicates',
    () async {
      final result = scan([observed(), observed()]);
      await repo.saveScan(result);
      await repo.saveScan(result);
      expect((await repo.getSavedNetworks()).single.deviceCount, 1);
      expect(
        (await db.customSelect('SELECT * FROM network_scans').get()).length,
        1,
      );
      expect(
        (await db.customSelect('SELECT * FROM device_ip_history').get()).length,
        1,
      );
    },
  );
  test('conflicting protocol aliases cannot merge two known devices', () async {
    const udn = 'uuid:01234567-89ab-cdef-0123-456789abcdef';
    await repo.saveScan(
      scan([
        observed(),
        observed(ip: '192.168.1.43', mac: '00:11:22:33:44:66', udn: udn),
      ]),
    );
    await repo.saveScan(scan([observed(udn: udn, minute: 1)], minute: 1));
    expect((await repo.getSavedNetworks()).single.deviceCount, 2);
  });
  test(
    'scan history retains 100 rows without deleting devices or IP history',
    () async {
      await repo.saveScan(scan([observed()]));
      for (var i = 1; i < 105; i++) {
        await repo.saveScan(scan([], minute: i, state: ScanState.cancelled));
      }
      expect(
        (await db.customSelect('SELECT * FROM network_scans').get()).length,
        100,
      );
      expect((await repo.getSavedNetworks()).single.deviceCount, 1);
      expect(
        (await db.customSelect('SELECT * FROM device_ip_history').get()).length,
        1,
      );
    },
  );
  test('failed transaction rolls back network, device and scan writes', () async {
    await repo.getSavedNetworks();
    await db.customStatement(
      "CREATE TRIGGER reject_scan BEFORE INSERT ON network_scans BEGIN SELECT RAISE(ABORT,'test'); END",
    );
    await expectLater(repo.saveScan(scan([observed()])), throwsA(anything));
    expect(await repo.getSavedNetworks(), isEmpty);
    expect(
      await db.customSelect('SELECT * FROM stored_devices').get(),
      isEmpty,
    );
  });
  test('historical network views never claim online state', () async {
    await repo.saveScan(scan([observed()]));
    final saved = (await repo.getSavedNetworks()).single;
    expect(
      (await repo.getDevicesForNetwork(saved.id)).single.isOnline,
      isFalse,
    );
    expect(
      (await repo.loadCurrentNetworkSnapshot(network)).devices.single.isOnline,
      isTrue,
    );
  });
  test(
    'file database survives reopen; saved devices start offline and preserve edits',
    () async {
      final temp = await Directory.systemTemp.createTemp('wifi-db-test-');
      final file = File('${temp.path}/history.sqlite');
      final first = PersistentDeviceRepository(
        AppDatabase(NativeDatabase(file)),
      );
      final device = (await first.saveScan(scan([observed()]))).devices.single;
      await first.updateDevice(
        device.id,
        customName: 'Saved name',
        classification: DeviceClassification.guest,
        notes: 'Durable',
      );
      await first.close();
      final reopened = PersistentDeviceRepository(
        AppDatabase(NativeDatabase(file)),
      );
      try {
        final snapshot = await reopened.loadCurrentNetworkSnapshot(network);
        expect(snapshot.devices.single.customName, 'Saved name');
        expect(snapshot.devices.single.notes, 'Durable');
        expect(
          snapshot.devices.single.classification,
          DeviceClassification.guest,
        );
        expect(snapshot.devices.single.isOnline, isFalse);
        expect(snapshot.devices.single.isNew, isFalse);
      } finally {
        await reopened.close();
        await temp.delete(recursive: true);
      }
    },
  );
}
