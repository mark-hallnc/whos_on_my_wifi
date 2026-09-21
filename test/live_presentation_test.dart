import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:whos_on_my_wifi/data/database/app_database.dart'
    show AppDatabase;
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/models/network_info.dart';
import 'package:whos_on_my_wifi/models/scan_result.dart';
import 'package:whos_on_my_wifi/models/discovered_service.dart';
import 'package:whos_on_my_wifi/repositories/device_repository.dart';
import 'package:whos_on_my_wifi/repositories/persistent_device_repository.dart';
import 'package:whos_on_my_wifi/services/scan_history_overlay.dart';
import 'package:whos_on_my_wifi/app/current_network_controller.dart';
import 'package:whos_on_my_wifi/services/network_info_service.dart';
import 'package:whos_on_my_wifi/services/local_network_permission_service.dart';
import 'package:whos_on_my_wifi/screens/home_screen.dart';
import 'package:whos_on_my_wifi/screens/device_details_screen.dart';
import 'package:whos_on_my_wifi/widgets/device_card.dart';
import 'package:whos_on_my_wifi/widgets/current_network_card.dart';

const lan = NetworkInfo(
  id: 'lan',
  name: 'Home',
  connectionType: NetworkConnectionType.wifi,
  localIpAddress: '192.168.1.10',
  ipv4PrefixLength: 24,
  subnet: '192.168.1.0/24',
);
NetworkDevice device(
  String id, {
  String ip = '192.168.1.42',
  String? mac,
  String? custom,
  bool online = false,
  bool self = false,
  int minute = 0,
}) => NetworkDevice(
  id: id,
  ipAddress: ip,
  macAddress: mac,
  customName: custom,
  isOnline: online,
  isCurrentDevice: self,
  firstSeen: DateTime.utc(2026, 9, 21),
  lastSeen: DateTime.utc(2026, 9, 21, 0, minute),
);
ScanResult snapshot(
  List<NetworkDevice> devices, {
  ScanState state = ScanState.completed,
  int minute = 0,
}) => ScanResult(
  network: lan,
  devices: devices,
  state: state,
  startedAt: DateTime.utc(2026, 9, 21, 0, minute),
  completedAt: DateTime.utc(2026, 9, 21, 0, minute, 1),
);

class Repo implements DeviceRepository {
  Repo(this.result);
  final ScanResult result;
  @override
  Future<ScanResult> loadSnapshot() async => result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'WS endpoint UUID survives persistence and follows an IP change',
    () async {
      final repo = PersistentDeviceRepository(
        AppDatabase(NativeDatabase.memory()),
      );
      addTearDown(repo.close);
      NetworkDevice seen(String ip, int minute) =>
          device(
            'observed',
            ip: ip,
            online: true,
            minute: minute,
          ).withPresentation(
            services: [
              DiscoveredService(
                name: 'Web Services device',
                type: 'ws-discovery',
                discoveryMethod: 'WS-Discovery',
                host: ip,
                attributes: const {
                  'endpoint': 'urn:uuid:11111111-2222-3333-4444-555555555555',
                },
              ),
            ],
          );
      final first = await repo.saveScan(snapshot([seen('192.168.1.42', 0)]));
      final second = await repo.saveScan(
        snapshot([seen('192.168.1.43', 1)], minute: 1),
      );
      expect(second.devices, hasLength(1));
      expect(second.devices.single.id, first.devices.single.id);
      expect(
        second.devices.single.previousIpAddresses,
        contains('192.168.1.42'),
      );
      expect(second.reconciliation!.newDeviceIds, isEmpty);
    },
  );
  test(
    'fresh online IP wins over conflicting historical identity without stealing metadata',
    () {
      final old = device('old', mac: '00:11:22:33:44:55', custom: 'Old camera');
      final fresh = device(
        'fresh',
        mac: '00:11:22:33:44:66',
        online: true,
        minute: 1,
      );
      final result = ScanHistoryOverlay.merge(snapshot([fresh]), [old]);
      expect(result.devices, hasLength(1));
      expect(result.devices.single.id, 'fresh');
      expect(result.devices.single.customName, isNull);
      expect(result.onlineDevices, 1);
      expect(old.customName, 'Old camera');
    },
  );
  test(
    'same safe identity retains custom metadata; historical-only IP collisions are suppressed',
    () {
      final old = device('old', mac: '00:11:22:33:44:55', custom: 'Office PC');
      final fresh = device(
        'fresh',
        mac: old.macAddress,
        online: true,
        minute: 1,
      );
      final result = ScanHistoryOverlay.merge(snapshot([fresh]), [old]);
      expect(result.devices.single.customName, 'Office PC');
      expect(result.devices.single.isOnline, isTrue);
      expect(
        ScanHistoryOverlay.present(
          snapshot([old, device('other', minute: 2)]),
        ).devices.single.id,
        'other',
      );
    },
  );
  test(
    'current phone is online only on its active network; counts use the presented cards',
    () {
      final scan = snapshot([
        device('phone', ip: '192.168.1.9', self: true),
        device('old', ip: '192.168.1.10'),
        device('peer', online: true),
      ]);
      final result = ScanHistoryOverlay.present(scan, activeNetwork: lan);
      expect(result.devices, hasLength(2));
      expect(result.onlineDevices, 2);
      expect(
        result.devices.singleWhere((d) => d.isCurrentDevice).ipAddress,
        lan.localIpAddress,
      );
      final disconnected = ScanHistoryOverlay.present(
        snapshot([device('phone', self: true)]),
        activeNetwork: const NetworkInfo(id: 'none'),
      );
      expect(disconnected.onlineDevices, 0);
    },
  );
  test(
    'cancelled and failed partial presentation retain prior known presence',
    () {
      for (final state in [ScanState.failed, ScanState.cancelled]) {
        final result = ScanHistoryOverlay.merge(snapshot([], state: state), [
          device('peer', online: true),
        ]);
        expect(result.onlineDevices, 1);
      }
      expect(
        ScanHistoryOverlay.merge(snapshot([]), [
          device('peer', online: true),
        ]).onlineDevices,
        0,
      );
    },
  );
  test(
    'DHCP reuse retains both database histories but displays one live card',
    () async {
      final repo = PersistentDeviceRepository(
        AppDatabase(NativeDatabase.memory()),
      );
      addTearDown(repo.close);
      await repo.saveScan(
        snapshot([device('old', mac: '00:11:22:33:44:55', online: true)]),
      );
      final result = await repo.saveScan(
        snapshot([
          device('new', mac: '00:11:22:33:44:66', online: true, minute: 1),
        ], minute: 1),
      );
      final saved = (await repo.getSavedNetworks()).single;
      expect(await repo.getDevicesForNetwork(saved.id), hasLength(2));
      final live = ScanHistoryOverlay.present(result, activeNetwork: lan);
      expect(live.devices, hasLength(1));
      expect(live.onlineDevices, 1);
      expect(live.devices.single.macAddress, '00:11:22:33:44:66');
    },
  );
  testWidgets(
    'home online summary and card statuses share one normalized snapshot',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = CurrentNetworkController(
        service: const NetworkInfoService(),
        permissions: const LocalNetworkPermissionService(),
      )..info = lan;
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            network: controller,
            repository: Repo(
              snapshot([
                device('phone', ip: lan.localIpAddress!, self: true),
                device('fresh', online: true, minute: 1),
                device('old'),
              ]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final cards = tester
          .widgetList<DeviceCard>(find.byType(DeviceCard))
          .toList();
      final summary = tester.widget<CurrentNetworkCard>(
        find.byType(CurrentNetworkCard),
      );
      expect(cards, hasLength(2));
      expect(
        summary.result.onlineDevices,
        cards.where((c) => c.device.isOnline).length,
      );
      expect(find.text('2 online • 2 known'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DeviceCard),
          matching: find.text('Online'),
        ),
        findsNWidgets(2),
      );
      expect(find.text('Offline'), findsNothing);
      expect(find.text('Scan completed'), findsNothing);
      expect(find.textContaining('addresses checked'), findsNothing);
    },
  );
  testWidgets('details hide empty sections and keep raw data collapsed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: DeviceDetailsScreen(
          device: device('internal-debug-id'),
          network: lan,
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final text in [
      'Services',
      'Ports',
      'Previous IPs',
      'No notes for this device.',
      'Manufacturer',
      'MAC',
      'Network isolation',
      'Only limited network information is available.',
      'Local device ID',
      'internal-debug-id',
    ]) {
      expect(find.text(text), findsNothing, reason: text);
    }
    expect(find.text('Identification'), findsOneWidget);
    expect(find.text('Technical details'), findsOneWidget);
    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    expect(find.text('Local device ID'), findsOneWidget);
    expect(find.text('internal-debug-id'), findsOneWidget);
  });
}
