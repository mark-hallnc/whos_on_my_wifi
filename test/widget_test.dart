import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/app/wifi_app.dart';
import 'package:whos_on_my_wifi/widgets/device_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('whos_on_my_wifi/network');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(
    () => messenger.setMockMethodCallHandler(
      channel,
      (call) async => call.method == 'getNetworkInfo'
          ? {'connectionType': 'none'}
          : 'notRequired',
    ),
  );
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  testWidgets(
    'Preview supports search, details, and an honest scan placeholder',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const WifiApp());
      await tester.pumpAndSettle();
      expect(find.text("Who's on My WiFi"), findsOneWidget);
      expect(find.text('8 of 8 devices'), findsOneWidget);
      expect(find.text('Not scanned yet'), findsOneWidget);
      await tester.tap(find.text('Scan Network'));
      await tester.pumpAndSettle();
      expect(find.text('Network scanning is coming'), findsOneWidget);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '192.168.1.24');
      await tester.pumpAndSettle();
      expect(find.text('1 of 8 devices'), findsOneWidget);
      await tester.tap(find.byType(DeviceCard).first);
      await tester.pumpAndSettle();
      expect(find.text('Device Details'), findsOneWidget);
      expect(find.text('Identity'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'does not exist');
      await tester.pumpAndSettle();
      expect(find.text('No matching devices'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Navigation and dark appearance work at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const WifiApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Saved Networks').last);
    await tester.pumpAndSettle();
    expect(find.text('A familiar place for every network'), findsOneWidget);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<ThemeMode>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(tester.takeException(), isNull);
  });
}
