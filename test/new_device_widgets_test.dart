import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/services/new_device_notification_service.dart';
import 'package:whos_on_my_wifi/widgets/device_card.dart';
import 'package:whos_on_my_wifi/widgets/notification_settings.dart';
import 'package:whos_on_my_wifi/screens/device_details_screen.dart';
import 'new_device_notification_service_test.dart'
    show FakeDelivery, FakePreferences;
import 'persistent_device_repository_test.dart' show network, start;

void main() {
  testWidgets('new badge and latest-scan explanation are scan-scoped', (
    tester,
  ) async {
    final device = NetworkDevice(
      id: 'device:1',
      ipAddress: '192.168.1.42',
      firstSeen: start,
      lastSeen: start,
      isNew: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeviceCard(device: device, onTap: () {}),
        ),
      ),
    );
    expect(find.text('NEW'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: DeviceDetailsScreen(device: device, network: network),
      ),
    );
    expect(find.text('First discovered in the latest scan'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeviceCard(
            device: device.withPresentation(isNew: false),
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('NEW'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings reflect denial and only request on user interaction', (
    tester,
  ) async {
    final delivery = FakeDelivery()..allowed = false;
    final preferences = FakePreferences();
    final service = NewDeviceNotificationService(
      delivery: delivery,
      preferences: preferences,
    );
    await service.initialize();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NotificationSettings(service: service)),
      ),
    );
    expect(delivery.requests, 0);
    expect(find.textContaining('not allowed by Android'), findsOneWidget);
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();
    expect(delivery.requests, 1);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(preferences.enabled, isFalse);
    expect(find.text('Allow notifications'), findsNothing);
    expect(delivery.requests, 1);
    await tester.pumpWidget(const SizedBox());
    service.dispose();
  });
}
