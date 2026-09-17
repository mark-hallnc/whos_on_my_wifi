import 'package:flutter/material.dart';
import 'current_network_controller.dart';
import '../repositories/device_repository.dart';
import '../screens/home_screen.dart';
import '../screens/saved_networks_screen.dart';
import '../screens/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.repository,
    required this.network,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final DeviceRepository repository;
  final CurrentNetworkController network;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _selectedIndex,
      children: [
        HomeScreen(repository: widget.repository, network: widget.network),
        const SavedNetworksScreen(),
        SettingsScreen(
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
