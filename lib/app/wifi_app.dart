import 'package:flutter/material.dart';
import 'dart:async';
import '../services/network_info_service.dart';
import '../services/local_network_permission_service.dart';
import 'current_network_controller.dart';
import '../repositories/device_repository.dart';
import '../repositories/session_device_repository.dart';
import 'app_shell.dart';
import 'app_theme.dart';

class WifiApp extends StatefulWidget {
  const WifiApp({
    super.key,
    this.repository,
    this.networkInfoService = const NetworkInfoService(),
    this.permissionService = const LocalNetworkPermissionService(),
  });

  final DeviceRepository? repository;
  final NetworkInfoService networkInfoService;
  final LocalNetworkPermissionService permissionService;

  @override
  State<WifiApp> createState() => _WifiAppState();
}

class _WifiAppState extends State<WifiApp> {
  late final DeviceRepository _repository =
      widget.repository ?? SessionDeviceRepository();
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
      repository: _repository,
      themeMode: _themeMode,
      onThemeChanged: (mode) => setState(() => _themeMode = mode),
    ),
  );
}
