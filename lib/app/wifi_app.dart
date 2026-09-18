import 'package:flutter/material.dart';
import 'dart:async';
import '../services/network_info_service.dart';
import '../services/network_discovery_service.dart';
import '../services/local_network_permission_service.dart';
import 'current_network_controller.dart';
import '../repositories/device_repository.dart';
import '../repositories/persistent_device_repository.dart';
import '../repositories/local_device_store.dart';
import '../data/database/app_database.dart';
import 'app_shell.dart';
import 'app_theme.dart';

class WifiApp extends StatefulWidget {
  const WifiApp({
    super.key,
    this.repository,
    this.scanner,
    this.networkInfoService = const NetworkInfoService(),
    this.permissionService = const LocalNetworkPermissionService(),
  });

  final DeviceRepository? repository;
  final NetworkDiscoveryService? scanner;
  final NetworkInfoService networkInfoService;
  final LocalNetworkPermissionService permissionService;

  @override
  State<WifiApp> createState() => _WifiAppState();
}

class _WifiAppState extends State<WifiApp> {
  late final DeviceRepository _repository =
      widget.repository ?? PersistentDeviceRepository(AppDatabase());
  ThemeMode _themeMode = ThemeMode.system;
  late final CurrentNetworkController _network;

  @override
  void initState() {
    super.initState();
    _network = CurrentNetworkController(
      service: widget.networkInfoService,
      permissions: widget.permissionService,
    );
    unawaited(_network.refresh());
  }

  @override
  void dispose() {
    _network.dispose();
    if (widget.repository == null && _repository is LocalDeviceStore) {
      unawaited(_repository.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "Who's on My WiFi",
    debugShowCheckedModeBanner: false,
    theme: AppTheme.build(Brightness.light),
    darkTheme: AppTheme.build(Brightness.dark),
    themeMode: _themeMode,
    home: AppShell(
      network: _network,
      scanner: widget.scanner,
      repository: _repository,
      themeMode: _themeMode,
      onThemeChanged: (mode) => setState(() => _themeMode = mode),
    ),
  );
}
