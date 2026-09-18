import 'support/no_ssdp_discovery.dart';
import 'dart:async';
import 'package:whos_on_my_wifi/app/current_network_controller.dart';
import 'package:whos_on_my_wifi/repositories/mock_device_repository.dart';
import 'package:whos_on_my_wifi/screens/home_screen.dart';
import 'package:whos_on_my_wifi/services/network_scanner.dart';
import 'package:whos_on_my_wifi/services/network_info_service.dart';
import 'package:whos_on_my_wifi/services/local_network_permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/app/wifi_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('whos_on_my_wifi/network');
  const nsdChannel = MethodChannel('whos_on_my_wifi/nsd');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Map<String, Object?> network;
  late String permission;
  late int requests;
  late int reads;
  late int settingsOpened;
  late String requestResult;
  setUp(() {
    messenger.setMockMethodCallHandler(
      nsdChannel,
      (_) async => throw MissingPluginException(),
    );
    network = {
      'connectionType': 'wifi',
      'isWifiConnected': true,
      'ssid': 'Actual Wi-Fi',
      'ipv4Address': '192.168.10.77',
      'ipv4PrefixLength': 26,
    };
    permission = 'notRequired';
    requestResult = 'granted';
    requests = 0;
    reads = 0;
    settingsOpened = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'getNetworkInfo':
          reads++;
          return network;
        case 'getLocalNetworkPermission':
          return permission;
        case 'requestLocalNetworkPermission':
          requests++;
          return permission = requestResult;
        case 'openAppSettings':
          settingsOpened++;
          return true;
        default:
          throw MissingPluginException();
      }
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(nsdChannel, null);
  });

  Future<void> launch(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      WifiApp(scanner: NetworkScanner(ssdpDiscovery: const NoSsdpDiscovery())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'real network replaces sample card; refresh clears disconnected data',
    (tester) async {
      await launch(tester);
      expect(find.text('Actual Wi-Fi'), findsOneWidget);
      expect(find.text('Subnet  192.168.10.64/26'), findsOneWidget);
      expect(find.text('Home Wi-Fi'), findsNothing);
      expect(find.text('0 of 0 devices'), findsOneWidget);
      expect(requests, 0);
      network = {'connectionType': 'none'};
      await tester.tap(find.byTooltip('Refresh network'));
      await tester.pumpAndSettle();
      expect(find.text('No network connection'), findsOneWidget);
      expect(find.textContaining('192.168.10.77'), findsNothing);
      expect(reads, 2);
    },
  );

  testWidgets(
    'scan refreshes first and skips permission UX when not required',
    (tester) async {
      network['ipv4PrefixLength'] = 32;
      await launch(tester);
      await tester.tap(find.text('Scan Network'));
      await tester.pumpAndSettle();
      expect(reads, 3); // Includes the scanner's network identity check.
      expect(requests, 0);
      expect(find.text('Scan completed'), findsOneWidget);
    },
  );

  testWidgets(
    'rationale precedes runtime prompt and grant is not requested again',
    (tester) async {
      permission = 'notRequested';
      network['ipv4PrefixLength'] = 32;
      await launch(tester);
      expect(requests, 0);
      await tester.tap(find.text('Scan Network'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Scanning stays on your device.'),
        findsOneWidget,
      );
      expect(requests, 0);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(requests, 1);
      await tester.tap(find.text('Scan Network'));
      await tester.pumpAndSettle();
      expect(find.text('Scan completed'), findsOneWidget);
      expect(requests, 1);
    },
  );

  testWidgets('denial keeps preview usable and provides settings path', (
    tester,
  ) async {
    permission = 'notRequested';
    requestResult = 'permanentlyDenied';
    await launch(tester);
    await tester.tap(find.text('Scan Network'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('0 of 0 devices'), findsOneWidget);
    await tester.tap(find.text('Scan Network'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(settingsOpened, 1);
    expect(requests, 1);
  });

  testWidgets('returning to foreground refreshes connection and permission', (
    tester,
  ) async {
    await launch(tester);
    network = {
      'connectionType': 'cellular',
      'ipv4Address': '10.2.0.8',
      'ipv4PrefixLength': 32,
    };
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
    expect(find.text('Cellular connection'), findsOneWidget);
    expect(find.text('Not connected to Wi-Fi'), findsOneWidget);
    expect(reads, 2);
  });

  testWidgets('scan replaces mock cards and displays live progress', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    network['ipv4Address'] = '192.168.10.1';
    network['ipv4PrefixLength'] = 30;
    final gate = Completer<List<String>>();
    final controller = CurrentNetworkController(
      service: const NetworkInfoService(),
      permissions: const LocalNetworkPermissionService(),
    );
    addTearDown(controller.dispose);
    await controller.refresh();
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          repository: MockDeviceRepository(),
          network: controller,
          scanner: NetworkScanner(
            ssdpDiscovery: const NoSsdpDiscovery(),
            probe: (_) => gate.future,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('8 of 8 devices'), findsOneWidget);
    await tester.tap(find.text('Scan Network'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Scanning network...'), findsOneWidget);
    expect(
      find.text('0 of 1 addresses checked; 1 devices found'),
      findsOneWidget,
    );
    expect(find.text('8 of 8 devices'), findsNothing);
    expect(find.text('This device'), findsOneWidget);
    gate.complete(['TCP connection succeeded on port 80']);
    await tester.pumpAndSettle();
    expect(find.text('Scan completed'), findsOneWidget);
    expect(
      find.text('1 of 1 addresses checked; 2 devices found'),
      findsOneWidget,
    );
    expect(find.text('Unknown device'), findsOneWidget);
    expect(find.text('192.168.10.2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large subnet displays limit instead of starting probes', (
    tester,
  ) async {
    network['ipv4PrefixLength'] = 21;
    await launch(tester);
    await tester.tap(find.text('Scan Network'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Automatic scanning is limited to 1024'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('This device'), findsOneWidget);
  });

  Future<
    ({
      CurrentNetworkController controller,
      Completer<List<String>> gate,
      List<String> probes,
    })
  >
  launchControlled(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = CurrentNetworkController(
      service: const NetworkInfoService(),
      permissions: const LocalNetworkPermissionService(),
    );
    addTearDown(controller.dispose);
    final gate = Completer<List<String>>();
    final probes = <String>[];
    await controller.refresh();
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          repository: MockDeviceRepository(),
          network: controller,
          scanner: NetworkScanner(
            ssdpDiscovery: const NoSsdpDiscovery(),
            probe: (ip) {
              probes.add(ip);
              return gate.future;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan Network'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Cancel Scan'), findsOneWidget);
    expect(probes.length, NetworkScanner.concurrency);
    return (controller: controller, gate: gate, probes: probes);
  }

  testWidgets(
    'cancel preserves results, drains workers and allows another scan',
    (tester) async {
      final scan = await launchControlled(tester);
      await tester.tap(find.text('Cancel Scan'));
      await tester.pump();
      expect(find.text('Scan cancelled.'), findsOneWidget);
      expect(find.text('This device'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      scan.gate.complete(['Late result']);
      await tester.pumpAndSettle();
      expect(scan.probes.length, NetworkScanner.concurrency);
      expect(find.text('Scan Network'), findsOneWidget);
      expect(find.text('Unknown device'), findsNothing);
      network['ipv4PrefixLength'] = 32;
      await tester.tap(find.text('Scan Network'));
      await tester.pumpAndSettle();
      expect(find.text('Scan completed'), findsOneWidget);
      expect(
        find.text('0 of 0 addresses checked; 1 devices found'),
        findsOneWidget,
      );
    },
  );

  testWidgets('background cancels; resume refreshes without restarting', (
    tester,
  ) async {
    final scan = await launchControlled(tester);
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    scan.gate.complete(['Late result']);
    await tester.pumpAndSettle();
    expect(
      find.text('App moved to the background. Scan cancelled.'),
      findsOneWidget,
    );
    expect(find.text('This device'), findsOneWidget);
    final previousReads = reads;
    for (final state in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
    expect(reads, greaterThan(previousReads));
    expect(scan.probes.length, NetworkScanner.concurrency);
    expect(find.text('Scan Network'), findsOneWidget);
  });

  for (final change in ['network', 'permission', 'disconnected']) {
    testWidgets('$change change cancels and retains partial results', (
      tester,
    ) async {
      final scan = await launchControlled(tester);
      switch (change) {
        case 'network':
          network['ipv4Address'] = '10.1.1.2';
        case 'permission':
          permission = 'denied';
        case 'disconnected':
          network = {'connectionType': 'none'};
      }
      // This also exercises cancellation from a manual network refresh.
      await scan.controller.refresh();
      scan.gate.complete(['Reply from changed network']);
      await tester.pumpAndSettle();
      expect(
        find.text(switch (change) {
          'network' => 'Network changed. Scan stopped.',
          'permission' => 'Local network permission unavailable. Scan stopped.',
          _ => 'Network connection lost. Scan stopped.',
        }),
        findsOneWidget,
      );
      expect(find.text('This device'), findsOneWidget);
      expect(find.text('Unknown device'), findsNothing);
      expect(find.text('Scan Network'), findsOneWidget);
      expect(scan.probes.length, NetworkScanner.concurrency);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('disposing home cancels pending workers without stale updates', (
    tester,
  ) async {
    final scan = await launchControlled(tester);
    await tester.pumpWidget(const SizedBox());
    scan.gate.complete(['Late reply']);
    await tester.pumpAndSettle();
    expect(scan.probes.length, NetworkScanner.concurrency);
    expect(tester.takeException(), isNull);
  });
}
