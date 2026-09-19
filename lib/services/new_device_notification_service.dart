import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/network_device.dart';
import '../models/scan_result.dart';
import '../utils/device_presentation.dart';
import 'service_device_merger.dart';

abstract interface class NotificationPreferenceStore {
  Future<bool> readEnabled();
  Future<void> writeEnabled(bool enabled);
}

class LocalNotificationPreferences implements NotificationPreferenceStore {
  // Defer plugin construction into the guarded async initialization path too.
  late final _preferences = SharedPreferencesAsync();
  static const key = 'new_device_notifications';
  @override
  Future<bool> readEnabled() async => await _preferences.getBool(key) ?? true;
  @override
  Future<void> writeEnabled(bool enabled) => _preferences.setBool(key, enabled);
}

class NewDeviceAlert {
  const NewDeviceAlert(this.title, this.body);
  final String title;
  final String body;
}

/// OS operations isolated from persistent identity and easy to mock in tests.
abstract interface class NotificationDelivery {
  Future<void> initialize(VoidCallback onTap);
  Future<bool> isAllowed();
  Future<void> requestPermission();
  Future<void> show(NewDeviceAlert alert);
}

class AndroidNotificationDelivery implements NotificationDelivery {
  final _plugin = FlutterLocalNotificationsPlugin();
  static const channel = AndroidNotificationChannel(
    'new_devices',
    'New devices',
    description:
        'Notifications when a previously unseen device is discovered on a scanned network.',
    importance: Importance.defaultImportance,
  );
  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize(VoidCallback onTap) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
      onDidReceiveNotificationResponse: (_) => onTap(),
    );
    await _android?.createNotificationChannel(channel);
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) onTap();
  }

  @override
  Future<bool> isAllowed() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    if (!(await _android?.areNotificationsEnabled() ?? false)) return false;
    final channels = await _android?.getNotificationChannels();
    return channels
            ?.where((c) => c.id == channel.id)
            .every((c) => c.importance != Importance.none) ??
        true;
  }

  @override
  Future<void> requestPermission() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _android?.requestNotificationsPermission();
    }
  }

  @override
  Future<void> show(NewDeviceAlert alert) => _plugin.show(
    // One informational slot; later scans replace it instead of piling up alerts.
    id: 1,
    title: alert.title,
    body: alert.body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: 'ic_notification',
        category: AndroidNotificationCategory.status,
      ),
    ),
  );
}

class NewDeviceNotificationService extends ChangeNotifier
    with WidgetsBindingObserver {
  NewDeviceNotificationService({
    NotificationDelivery? delivery,
    NotificationPreferenceStore? preferences,
  }) : _delivery = delivery ?? AndroidNotificationDelivery(),
       _preferences = preferences ?? LocalNotificationPreferences();
  final NotificationDelivery _delivery;
  final NotificationPreferenceStore _preferences;
  Future<void>? _initialization;
  bool _disposed = false;
  bool _observing = false;
  bool _ready = false;
  bool enabled = true;
  bool allowed = false;
  bool busy = false;
  String? error;
  int tapRevision = 0;
  final _handledScans = <String>{};

  Future<void> initialize() => _initialization ??= _initialize();
  Future<void> _initialize() async {
    try {
      enabled = await _preferences.readEnabled();
      if (_disposed) return;
      await _delivery.initialize(() {
        if (_disposed) return;
        tapRevision++;
        notifyListeners();
      });
      _ready = true;
      allowed = await _delivery.isAllowed();
    } catch (_) {
      error =
          'Notifications are unavailable. Scanning and in-app badges still work.';
      debugPrint('Local notification initialization unavailable.');
    }
    if (!_disposed) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refreshPermission());
  }

  Future<void> refreshPermission() async {
    await initialize();
    if (_disposed || !_ready) return;
    try {
      allowed = await _delivery.isAllowed();
    } catch (_) {
      allowed = false;
    }
    if (!_disposed) notifyListeners();
  }

  /// Called only by an explicit Settings interaction, never by scan/startup.
  Future<void> setEnabled(bool value, {bool requestPermission = true}) async {
    if (busy || _disposed) return;
    busy = true;
    notifyListeners();
    try {
      await initialize();
      if (_disposed) return;
      await _preferences.writeEnabled(value);
      enabled = value;
      if (value &&
          requestPermission &&
          _ready &&
          !await _delivery.isAllowed()) {
        await _delivery.requestPermission();
      }
      await refreshPermission();
      error = _ready ? null : 'Notifications are unavailable on this device.';
    } catch (_) {
      error =
          'Could not update notifications. Scanning and in-app badges still work.';
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> notifyCompletedScan(ScanResult result) async {
    final outcome = result.reconciliation;
    if (result.state != ScanState.completed ||
        result.isMock ||
        outcome == null ||
        !outcome.isSuccessful ||
        outcome.isBaseline ||
        outcome.isDuplicate ||
        outcome.newDeviceIds.isEmpty ||
        _disposed) {
      return;
    }
    // Reserve before any await so concurrent calls cannot deliver twice.
    if (!_handledScans.add(outcome.scanKey)) return;
    if (_handledScans.length > 100) _handledScans.remove(_handledScans.first);
    final devices = result.devices
        .where((d) => outcome.newDeviceIds.contains(d.id) && !d.isCurrentDevice)
        .toList();
    if (devices.isEmpty) return;
    await initialize();
    if (_disposed || !_ready || !enabled || busy) return;
    try {
      await refreshPermission(); // No permission prompt on a scan.
      if (!allowed || !enabled || busy || _disposed) return;
      final network = _text(
        result.network.name ?? result.network.subnet ?? 'this network',
      );
      await _delivery.show(
        devices.length == 1
            ? NewDeviceAlert(
                'New device found',
                '${identityLabel(devices.single)} was discovered on $network',
              )
            : NewDeviceAlert(
                '${devices.length} new devices found',
                'New devices were discovered on $network',
              ),
      );
    } catch (_) {
      error =
          'Notification could not be shown. New devices are still marked in the app.';
      if (!_disposed) notifyListeners();
      debugPrint('Local notification delivery unavailable.');
    }
  }

  static String identityLabel(NetworkDevice device) {
    final custom = device.customName?.trim();
    if (custom != null && custom.isNotEmpty) return _text(custom);
    for (final name in [device.discoveredName, device.hostname]) {
      final useful = ResolvedLocalService.usefulName(name);
      if (useful != null) return _text(useful);
    }
    final vendor = device.manufacturer?.trim();
    if (vendor != null && vendor.isNotEmpty) {
      final type = device.type == DeviceType.unknown
          ? 'device'
          : device.type.label.toLowerCase();
      return _text('$vendor $type');
    }
    return device.ipAddress;
  }

  static String _text(String value) {
    final clean = value.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ').trim();
    return clean.substring(0, clean.length.clamp(0, 120));
  }

  @override
  void dispose() {
    _disposed = true;
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
