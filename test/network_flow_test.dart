import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/app/wifi_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('whos_on_my_wifi/network');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Map<String, Object?> network;
  late String permission;
  late int requests;
  late int reads;
  late int settingsOpened;
  late String requestResult;
  setUp(() {
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
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Future<void> launch(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const WifiApp());
    await tester.pumpAndSettle();
  }

  testWidgets(
    'real network replaces sample card; refresh clears disconnected data',
    (tester) async {
      await launch(tester);
      expect(find.text('Actual Wi-Fi'), findsOneWidget);
      expect(find.text('Subnet  192.168.10.64/26'), findsOneWidget);
      expect(find.text('Home Wi-Fi'), findsNothing);
      expect(find.text('8 of 8 devices'), findsOneWidget);
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
      await launch(tester);
      await tester.tap(find.text('Scan Network'));
      await tester.pumpAndSettle();
      expect(reads, 2);
      expect(requests, 0);
      expect(find.text('Network scanning is coming'), findsOneWidget);
    },
  );

  testWidgets(
    'rationale precedes runtime prompt and grant is not requested again',
    (tester) async {
      permission = 'notRequested';
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
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scan Network'));
      await tester.pumpAndSettle();
      expect(find.text('Network scanning is coming'), findsOneWidget);
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
    expect(find.text('8 of 8 devices'), findsOneWidget);
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
}
