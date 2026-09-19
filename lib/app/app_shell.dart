import 'package:flutter/material.dart';
import 'current_network_controller.dart';
import '../services/network_discovery_service.dart';
import '../repositories/device_repository.dart';
import '../screens/home_screen.dart';
import '../screens/saved_networks_screen.dart';
import '../screens/settings_screen.dart';
import '../services/new_device_notification_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.repository,
    this.scanner,
    this.notifications,
    required this.network,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final DeviceRepository repository;
  final NetworkDiscoveryService? scanner;
  final NewDeviceNotificationService? notifications;
  final CurrentNetworkController network;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  int _tapRevision = 0;

  @override
  void initState() {
    super.initState();
    _tapRevision = widget.notifications?.tapRevision ?? 0;
    widget.notifications?.addListener(_notificationChanged);
  }

  void _notificationChanged() {
    final revision = widget.notifications?.tapRevision ?? 0;
    if (revision == _tapRevision || !mounted) return;
    _tapRevision = revision;
    // Opening the existing Devices tab is intentional: no brittle deep links
    // and no automatic scan is started by tapping a notification.
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _selectedIndex = 0);
  }

  @override
  void dispose() {
    widget.notifications?.removeListener(_notificationChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _selectedIndex,
      children: [
        HomeScreen(
          repository: widget.repository,
          network: widget.network,
          scanner: widget.scanner,
          notifications: widget.notifications,
        ),
        SavedNetworksScreen(repository: widget.repository),
        SettingsScreen(
          notifications: widget.notifications,
          network: widget.network,
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (value) => setState(() => _selectedIndex = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.radar_rounded),
          label: 'Devices',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_outline_rounded),
          selectedIcon: Icon(Icons.bookmark_rounded),
          label: 'Saved Networks',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    ),
  );
}
