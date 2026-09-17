import 'package:flutter/material.dart';
import '../app/current_network_controller.dart';
import 'network_information_screen.dart';
import '../widgets/info_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.network,
    required this.onThemeChanged,
  });
  final ThemeMode themeMode;
  final CurrentNetworkController network;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.wifi_rounded),
                title: const Text('Network Information'),
                subtitle: const Text(
                  'Connection details and local network access',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NetworkInformationScreen(network: network),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InfoSection(
              title: 'Appearance',
              children: [
                const Text('Choose a look that feels at home.'),
                const SizedBox(height: 12),
                DropdownButtonFormField<ThemeMode>(
                  isExpanded: true,
                  initialValue: themeMode,
                  decoration: const InputDecoration(labelText: 'Theme'),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Use device setting'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) onThemeChanged(mode);
                  },
                ),
                const SizedBox(height: 12),
                const Text('Your choice applies for this session.'),
              ],
            ),
            const InfoSection(
              title: 'About this preview',
              children: [
                InfoRow('App', "Who's on My WiFi"),
                Text(
                  'Explore example devices and their details. Network discovery, '
                  'saved history, and device editing are planned for future updates.',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
