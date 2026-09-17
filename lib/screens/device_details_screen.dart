import 'package:flutter/material.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../utils/device_presentation.dart';
import '../widgets/info_section.dart';
import '../widgets/mock_data_banner.dart';

class DeviceDetailsScreen extends StatelessWidget {
  const DeviceDetailsScreen({
    super.key,
    required this.device,
    required this.network,
    this.isMock = false,
  });
  final NetworkDevice device;
  final NetworkInfo network;
  final bool isMock;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Device Details')),
    body: SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (isMock) ...[
                const MockDataBanner(),
                const SizedBox(height: 24),
              ],
              Icon(
                device.type.icon,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                device.displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                '${device.isOnline ? 'Online' : 'Offline'} • ${device.classification.label}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              InfoSection(
                title: 'Identity',
                children: [
                  InfoRow(
                    'Friendly name',
                    device.customName ?? 'No custom name',
                  ),
                  InfoRow(
                    'Discovered hostname',
                    device.hostname ?? 'Unavailable',
                  ),
                  InfoRow('Classification', device.classification.label),
                  const Text(
                    'Naming and classification editing will be available in a future update.',
                  ),
                ],
              ),
              InfoSection(
                title: 'Network information',
                children: [
                  InfoRow(
                    isMock ? 'Network (example)' : 'Network',
                    network.name ?? 'Unavailable',
                  ),
                  InfoRow('IP address', device.ipAddress),
                  InfoRow('MAC address', device.macAddress ?? 'Unavailable'),
                  const Text(
                    'MAC addresses may be unavailable on Android or randomized by devices.',
                  ),
                  InfoRow('Connection', device.isOnline ? 'Online' : 'Offline'),
                  InfoRow(
                    'Network isolation',
                    switch (network.isolationStatus) {
                      NetworkIsolationStatus.notChecked => 'Not checked',
                      NetworkIsolationStatus.suspected => 'Suspected',
                      NetworkIsolationStatus.notDetected => 'Not detected',
                    },
                  ),
                ],
              ),
              InfoSection(
                title: 'Device identification',
                children: [
                  InfoRow(
                    'Manufacturer / vendor',
                    device.manufacturer ?? 'Unavailable',
                  ),
                  InfoRow('Likely device type', device.type.label),
                  InfoRow('Confidence', switch (device.confidence) {
                    IdentificationConfidence.low => 'Low',
                    IdentificationConfidence.medium => 'Medium',
                    IdentificationConfidence.high => 'High',
                  }),
                  const Text(
                    'Device identification is an estimate based on available evidence.',
                  ),
                ],
              ),
              InfoSection(
                title: 'Discovered services',
                children: [
                  if (device.services.isEmpty)
                    const Text(
                      'No services in this example. Service discovery is not implemented.',
                    )
                  else
                    ...device.services.map(
                      (service) => InfoRow(
                        service.name,
                        '${service.type} • ${service.discoveryMethod}'
                        '${service.port == null ? '' : ' • ${service.transport} ${service.port}'}',
                      ),
                    ),
                ],
              ),
              InfoSection(
                title: 'Ports',
                children: [
                  Text(
                    device.openPorts.isEmpty
                        ? 'No port information in this example.'
                        : 'Example open ports: ${device.openPorts.join(', ')}',
                  ),
                  const SizedBox(height: 8),
                  const Text('Port detection has not been performed.'),
                ],
              ),
              InfoSection(
                title: 'History',
                children: [
                  InfoRow(
                    'First seen${isMock ? ' (example)' : ''}',
                    formatTimestamp(device.firstSeen),
                  ),
                  InfoRow(
                    'Last seen${isMock ? ' (example)' : ''}',
                    formatTimestamp(device.lastSeen),
                  ),
                  InfoRow(
                    'Previous IP addresses',
                    device.previousIpAddresses.isEmpty
                        ? 'None recorded'
                        : device.previousIpAddresses.join(', '),
                  ),
                ],
              ),
              InfoSection(
                title: 'Notes',
                children: [
                  Text(
                    device.notes.isEmpty
                        ? 'No notes for this device.'
                        : device.notes,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Adding and editing notes is coming in a future update.',
                  ),
                ],
              ),
              InfoSection(
                title: 'Technical details',
                children: [
                  InfoRow('Local device ID', device.id),
                  InfoRow(
                    'Data source',
                    isMock ? 'Mock device repository' : 'Device repository',
                  ),
                  const InfoRow('Discovery methods', 'Not run'),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
