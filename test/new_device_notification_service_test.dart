import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:whos_on_my_wifi/data/database/app_database.dart'
    show AppDatabase;
import 'package:whos_on_my_wifi/repositories/persistent_device_repository.dart';
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/models/scan_reconciliation.dart';
import 'package:whos_on_my_wifi/models/scan_result.dart';
import 'package:whos_on_my_wifi/services/new_device_notification_service.dart';
import 'persistent_device_repository_test.dart'
    show network, start, observed, scan;

class FakePreferences implements NotificationPreferenceStore {
  bool enabled = true;
  @override
  Future<bool> readEnabled() async => enabled;
  @override
  Future<void> writeEnabled(bool value) async {
    enabled = value;
  }
}

class FakeDelivery implements NotificationDelivery {
  bool allowed = true;
  bool fails = false;
  int requests = 0;
  VoidCallback? onTap;
  final alerts = <NewDeviceAlert>[];
  @override
  Future<void> initialize(VoidCallback tap) async {
    onTap = tap;
  }

  @override
  Future<bool> isAllowed() async => allowed;
  @override
  Future<void> requestPermission() async {
    requests++;
  }

  @override
  Future<void> show(NewDeviceAlert alert) async {
    if (fails) throw StateError('OS unavailable');
    alerts.add(alert);
  }
}

ScanResult result({
  int count = 1,
  bool baseline = false,
  ScanState state = ScanState.completed,
  bool self = false,
}) {
  final devices = List.generate(
    count,
    (i) => NetworkDevice(
      id: 'device:$i',
      ipAddress: '192.168.1.${50 + i}',
      firstSeen: start,
      lastSeen: start,
      isNew: true,
      isCurrentDevice: self,
    ),
  );
  return ScanResult(
    network: network,
    devices: devices,
    state: state,
    reconciliation: ScanReconciliation(
      networkId: 1,
      scanKey: '1:scan',
      isBaseline: baseline,
      isSuccessful: state == ScanState.completed,
      newDeviceIds: devices.map((d) => d.id).toSet(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeDelivery delivery;
  late FakePreferences preferences;
  late NewDeviceNotificationService service;
  setUp(() {
    delivery = FakeDelivery();
    preferences = FakePreferences();
    service = NewDeviceNotificationService(
      delivery: delivery,
      preferences: preferences,
    );
  });
  tearDown(() => service.dispose());

  test('startup and scans never request permission', () async {
    delivery.allowed = false;
    await service.initialize();
    await service.notifyCompletedScan(result());
    expect(delivery.requests, 0);
    expect(service.enabled, isTrue);
    expect(delivery.alerts, isEmpty);
  });
  test('missing platform preference plugin does not prevent startup', () async {
    final unavailable = NewDeviceNotificationService(delivery: delivery);
    await unavailable.initialize();
    expect(unavailable.error, isNotNull);
    unavailable.dispose();
  });
  test(
    'actual repository baseline and subsequent reconciliation drive delivery',
    () async {
      final repository = PersistentDeviceRepository(
        AppDatabase(NativeDatabase.memory()),
      );
      try {
        await service.notifyCompletedScan(
          await repository.saveScan(scan([observed()])),
        );
        expect(delivery.alerts, isEmpty);
        final second = await repository.saveScan(
          scan([
            observed(minute: 1),
            observed(ip: '192.168.1.50', mac: '00:11:22:33:44:66', minute: 1),
          ], minute: 1),
        );
        await service.notifyCompletedScan(second);
        expect(delivery.alerts.length, 1);
        final third = await repository.saveScan(
          scan([
            observed(minute: 2),
            observed(ip: '192.168.1.70', mac: '00:11:22:33:44:66', minute: 2),
          ], minute: 2),
        );
        await service.notifyCompletedScan(third);
        expect(delivery.alerts.length, 1);
      } finally {
        await repository.close();
      }
    },
  );
  test('baseline never produces OS notification', () async {
    await service.notifyCompletedScan(result(baseline: true));
    expect(delivery.alerts, isEmpty);
  });
  test('one new device uses real identity and network', () async {
    await service.notifyCompletedScan(result());
    expect(delivery.alerts.single.title, 'New device found');
    expect(delivery.alerts.single.body, '192.168.1.50 was discovered on Home');
  });
  test('several new devices produce one summary notification', () async {
    await service.notifyCompletedScan(result(count: 10));
    expect(delivery.alerts.length, 1);
    expect(delivery.alerts.single.title, '10 new devices found');
  });
  test(
    'disabled preference blocks OS delivery and survives new service',
    () async {
      await service.setEnabled(false);
      await service.notifyCompletedScan(result());
      expect(delivery.alerts, isEmpty);
      final reopened = NewDeviceNotificationService(
        delivery: delivery,
        preferences: preferences,
      );
      await reopened.initialize();
      expect(reopened.enabled, isFalse);
      reopened.dispose();
    },
  );
  test('denied permission leaves in-app new metadata intact', () async {
    delivery.allowed = false;
    await service.setEnabled(true);
    expect(delivery.requests, 1);
    final scan = result();
    await service.notifyCompletedScan(scan);
    expect(delivery.alerts, isEmpty);
    expect(scan.devices.single.isNew, isTrue);
    expect(scan.reconciliation!.newDeviceIds.length, 1);
    expect(delivery.requests, 1);
  });
  for (final state in [
    ScanState.cancelled,
    ScanState.failed,
    ScanState.subnetTooLarge,
    ScanState.running,
  ]) {
    test('$state cannot notify', () async {
      await service.notifyCompletedScan(result(state: state));
      expect(delivery.alerts, isEmpty);
    });
  }
  test('current phone excluded defensively', () async {
    await service.notifyCompletedScan(result(self: true));
    expect(delivery.alerts, isEmpty);
  });
  test('duplicate and concurrent delivery attempts notify only once', () async {
    await Future.wait([
      service.notifyCompletedScan(result()),
      service.notifyCompletedScan(result()),
    ]);
    await service.notifyCompletedScan(result());
    expect(delivery.alerts.length, 1);
  });
  test('OS delivery errors are nonfatal', () async {
    delivery.fails = true;
    await service.notifyCompletedScan(result());
    expect(service.error, isNotNull);
  });
  test('notification tap emits navigation signal without scanning', () async {
    await service.initialize();
    delivery.onTap!();
    expect(service.tapRevision, 1);
  });
  test('name priority avoids inventing a device identity', () {
    NetworkDevice device({
      String? custom,
      String? friendly,
      String? hostname,
      String? vendor,
    }) => NetworkDevice(
      id: 'x',
      ipAddress: '192.168.1.50',
      firstSeen: start,
      lastSeen: start,
      customName: custom,
      discoveredName: friendly,
      hostname: hostname,
      manufacturer: vendor,
    );
    expect(
      NewDeviceNotificationService.identityLabel(
        device(custom: 'Garage', friendly: 'TV'),
      ),
      'Garage',
    );
    expect(
      NewDeviceNotificationService.identityLabel(
        device(friendly: 'Living Room', hostname: 'tv.local'),
      ),
      'Living Room',
    );
    expect(
      NewDeviceNotificationService.identityLabel(device(hostname: 'tv.local')),
      'tv.local',
    );
    expect(
      NewDeviceNotificationService.identityLabel(device(vendor: 'Samsung')),
      'Samsung device',
    );
    expect(
      NewDeviceNotificationService.identityLabel(device()),
      '192.168.1.50',
    );
  });
}
