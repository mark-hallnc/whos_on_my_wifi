import 'package:flutter/material.dart';
import '../repositories/device_repository.dart';
import '../repositories/mock_device_repository.dart';
import 'app_shell.dart';
import 'app_theme.dart';

class WifiApp extends StatefulWidget {
  const WifiApp({super.key, this.repository});

  final DeviceRepository? repository;

  @override
  State<WifiApp> createState() => _WifiAppState();
}

class _WifiAppState extends State<WifiApp> {
  late final DeviceRepository _repository =
      widget.repository ?? MockDeviceRepository();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "Who's on My WiFi",
    debugShowCheckedModeBanner: false,
    theme: AppTheme.build(Brightness.light),
    darkTheme: AppTheme.build(Brightness.dark),
    themeMode: _themeMode,
    home: AppShell(
      repository: _repository,
      themeMode: _themeMode,
      onThemeChanged: (mode) => setState(() => _themeMode = mode),
    ),
  );
}
