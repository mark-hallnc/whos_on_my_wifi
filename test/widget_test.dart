import 'package:flutter/material.dart';
import 'package:whos_on_my_wifi/repositories/mock_device_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/app/wifi_app.dart';
import 'package:whos_on_my_wifi/widgets/device_card.dart';
import 'package:whos_on_my_wifi/widgets/ad_banner_slot.dart';

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
  testWidgets('Explicit preview supports search and details', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(WifiApp(repository: MockDeviceRepository()));
    await tester.pumpAndSettle();
    expect(find.text("Who's on My WiFi"), findsNothing);
    expect(find.text('Meet your network'), findsNothing);
    expect(
      find.text('A little clarity about your connected home.'),
      findsNothing,
    );
    final banner = find.byType(AdBannerSlot);
    final bannerPosition = tester.getRect(banner);
    expect(
      bannerPosition.bottom,
      lessThanOrEqualTo(tester.getTopLeft(find.byType(NavigationBar)).dy),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getRect(banner), bannerPosition);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text('8 of 8 devices'), findsOneWidget);
    expect(find.text('Not scanned yet'), findsOneWidget);
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
  });

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
