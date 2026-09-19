import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/data/database/app_database.dart'
    show AppDatabase;
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/models/scan_result.dart';
import 'package:whos_on_my_wifi/repositories/persistent_device_repository.dart';
import 'persistent_device_repository_test.dart'
    show observed, scan, network, start;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late PersistentDeviceRepository repository;
  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = PersistentDeviceRepository(database);
  });
  tearDown(() => repository.close());

  test(
    'first successful scan creates baseline, not new-device alerts',
    () async {
      final result = await repository.saveScan(scan([observed()]));
      final outcome = result.reconciliation!;
      expect(outcome.isBaseline, isTrue);
      expect(outcome.insertedDeviceIds, {result.devices.single.id});
      expect(outcome.newDeviceIds, isEmpty);
      expect(result.devices.single.isNew, isFalse);
    },
  );

  test(
    'same identities match; inserted external device alone is new',
    () async {
      final first = await repository.saveScan(scan([observed()]));
      final second = await repository.saveScan(
        scan([
          observed(minute: 1),
          observed(ip: '192.168.1.50', mac: '00:11:22:33:44:66', minute: 1),
        ], minute: 1),
      );
      final outcome = second.reconciliation!;
      expect(outcome.isBaseline, isFalse);
      expect(outcome.matchedDeviceIds, {first.devices.single.id});
      expect(outcome.updatedDeviceIds, outcome.matchedDeviceIds);
      expect(outcome.newDeviceIds, outcome.insertedDeviceIds);
      expect(second.devices.where((d) => d.isNew).length, 1);
      final third = await repository.saveScan(
        scan([
          observed(minute: 2),
          observed(ip: '192.168.1.50', mac: '00:11:22:33:44:66', minute: 2),
        ], minute: 2),
      );
      expect(third.reconciliation!.newDeviceIds, isEmpty);
      expect(third.devices.any((d) => d.isNew), isFalse);
    },
  );

  test('MAC plus changed IP/hostname remains known', () async {
    await repository.saveScan(scan([observed(hostname: 'old.local')]));
    final next = await repository.saveScan(
      scan([
        observed(ip: '192.168.1.97', hostname: 'new.local', minute: 1),
      ], minute: 1),
    );
    expect(next.reconciliation!.newDeviceIds, isEmpty);
    expect(next.reconciliation!.matchedDeviceIds.length, 1);
  });

  test('protocol UUID survives IP and randomized MAC changes', () async {
    const uuid = 'uuid:01234567-89ab-cdef-0123-456789abcdef';
    await repository.saveScan(
      scan([observed(mac: 'DA:11:22:33:44:55', udn: uuid)]),
    );
    final next = await repository.saveScan(
      scan([
        observed(
          ip: '192.168.1.97',
          mac: 'DA:11:22:33:44:66',
          udn: uuid,
          minute: 1,
        ),
      ], minute: 1),
    );
    expect(next.devices.length, 1);
    expect(next.reconciliation!.newDeviceIds, isEmpty);
  });

  test('fallback identity upgrade is matched, not inserted', () async {
    await repository.saveScan(
      scan([observed(mac: null, hostname: 'printer.local')]),
    );
    final next = await repository.saveScan(
      scan([observed(hostname: 'printer.local', minute: 1)], minute: 1),
    );
    expect(next.reconciliation!.insertedDeviceIds, isEmpty);
    expect(next.reconciliation!.newDeviceIds, isEmpty);
    expect(next.reconciliation!.matchedDeviceIds.length, 1);
  });

  test('current phone never counts as a new external device', () async {
    await repository.saveScan(scan([]));
    final next = await repository.saveScan(
      scan([
        NetworkDevice(
          id: 'self',
          ipAddress: '192.168.1.2',
          firstSeen: start,
          lastSeen: start,
          isCurrentDevice: true,
        ),
      ], minute: 1),
    );
    expect(next.reconciliation!.insertedDeviceIds.length, 1);
    expect(next.reconciliation!.newDeviceIds, isEmpty);
    expect(next.devices.single.isNew, isFalse);
  });

  for (final state in [
    ScanState.cancelled,
    ScanState.failed,
    ScanState.subnetTooLarge,
  ]) {
    test(
      '$state reports no new devices and does not establish baseline',
      () async {
        final partial = await repository.saveScan(
          scan([observed()], state: state),
        );
        expect(partial.reconciliation!.newDeviceIds, isEmpty);
        expect(partial.reconciliation!.isSuccessful, isFalse);
        final baseline = await repository.saveScan(
          scan([
            observed(minute: 1),
            observed(ip: '192.168.1.50', mac: '00:11:22:33:44:66', minute: 1),
          ], minute: 1),
        );
        expect(baseline.reconciliation!.isBaseline, isTrue);
        expect(baseline.reconciliation!.newDeviceIds, isEmpty);
        final partialAfter = await repository.saveScan(
          scan(
            [observed(ip: '192.168.1.51', mac: '00:11:22:33:44:77', minute: 2)],
            minute: 2,
            state: state,
          ),
        );
        expect(partialAfter.reconciliation!.newDeviceIds, isEmpty);
        expect(partialAfter.devices.any((d) => d.isNew), isFalse);
        expect(partialAfter.reconciliation!.offlineDeviceIds, isEmpty);
      },
    );
  }

  test('completed scan reports devices actually marked offline', () async {
    final first = await repository.saveScan(scan([observed()]));
    final next = await repository.saveScan(scan([], minute: 1));
    expect(next.reconciliation!.offlineDeviceIds, {first.devices.single.id});
    final again = await repository.saveScan(scan([], minute: 2));
    expect(again.reconciliation!.offlineDeviceIds, isEmpty);
  });

  test(
    'repeat save returns no actionable new IDs; snapshot keeps badge',
    () async {
      await repository.saveScan(scan([]));
      final next = scan([observed(minute: 1)], minute: 1);
      final first = await repository.saveScan(next);
      expect(first.reconciliation!.newDeviceIds.length, 1);
      final duplicate = await repository.saveScan(next);
      expect(duplicate.reconciliation!.isDuplicate, isTrue);
      expect(duplicate.reconciliation!.newDeviceIds, isEmpty);
      expect(
        (await repository.loadCurrentNetworkSnapshot(
          network,
        )).devices.single.isNew,
        isTrue,
      );
      repository.clearPresence();
      expect(
        (await repository.loadCurrentNetworkSnapshot(
          network,
        )).devices.single.isNew,
        isFalse,
      );
    },
  );

  test(
    'baseline remains established after successful history row is pruned',
    () async {
      await repository.saveScan(scan([]));
      // Simulate history retention without removing the durable network summary.
      await database.customStatement('DELETE FROM network_scans');
      final next = await repository.saveScan(
        scan([observed(minute: 1)], minute: 1),
      );
      expect(next.reconciliation!.isBaseline, isFalse);
      expect(next.reconciliation!.newDeviceIds.length, 1);
    },
  );
}
