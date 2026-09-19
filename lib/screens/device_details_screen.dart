import 'package:flutter/material.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../utils/device_presentation.dart';
import '../widgets/info_section.dart';
import '../widgets/mock_data_banner.dart';
import '../repositories/local_device_store.dart';
import '../widgets/device_edit_dialog.dart';

class DeviceDetailsScreen extends StatefulWidget {
  const DeviceDetailsScreen({
    super.key,
    required this.device,
    required this.network,
    this.isMock = false,
    this.store,
    this.historical = false,
  });
  final NetworkDevice device;
  final NetworkInfo network;
  final bool isMock;
  final LocalDeviceStore? store;
  final bool historical;

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  late NetworkDevice device = widget.device;
  NetworkInfo get network => widget.network;
  bool get isMock => widget.isMock;
  bool get editable => widget.store != null && device.id.startsWith('device:');

  Future<void> edit() async {
    final edits = await showDialog<DeviceEdits>(
      context: context,
      builder: (_) => DeviceEditDialog(device: device),
    );
    if (edits == null || !mounted) return;
    try {
      await widget.store!.updateDevice(
        device.id,
        customName: edits.name,
        classification: edits.classification,
        notes: edits.notes,
      );
      final updated = await widget.store!.getDevice(device.id);
      if (mounted && updated != null) {
        setState(
          () => device = widget.historical
              ? updated.withPresentation(online: false, isNew: false)
              : updated,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save device changes. Please try again.'),
          ),
        );
      }
    }
  }

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
              if (device.isNew && !widget.historical)
                const Text(
                  'First discovered in the latest scan',
                  textAlign: TextAlign.center,
                ),
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
                  if (device.discoveredName != null)
                    InfoRow('Discovered name', device.discoveredName!),
                  InfoRow('Classification', device.classification.label),
                  if (editable)
                    TextButton.icon(
                      onPressed: edit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit device'),
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
                  if (device.macAddress != null)
                    InfoRow(
                      'MAC vendor',
                      device.isPrivateMac
                          ? 'Private/randomized address'
                          : device.macVendor ?? 'Unknown',
                    ),
                  if (device.isPrivateMac)
                    const Text(
                      'Private/randomized MAC address. Manufacturer cannot be determined reliably from this address.',
                    ),
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
                  if (device.modelName != null)
                    InfoRow('Model', device.modelName!),
                  if (device.modelNumber != null)
                    InfoRow('Model number', device.modelNumber!),
                  if (device.modelDescription != null)
                    InfoRow('Model description', device.modelDescription!),
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
                    const Text('No local services discovered.')
                  else
                    ...device.services.map(
                      (service) => InfoRow(
                        service.label,
                        '${service.name}\n${service.type} • ${service.discoveryMethod}'
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
                        ? 'No port information recorded.'
                        : 'Observed / advertised ports: ${device.openPorts.join(', ')}',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Advertised ports come from service announcements and are not additional TCP probes.',
                  ),
                ],
              ),
              InfoSection(
                title: 'History',
                children: [
                  InfoRow(
                    'Known on',
                    network.name ?? network.subnet ?? 'Saved network',
                  ),
                  InfoRow('Current IP', device.ipAddress),
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
                  if (editable)
                    TextButton(
                      onPressed: edit,
                      child: const Text('Edit notes'),
                    ),
                ],
              ),
              InfoSection(
                title: 'Technical details',
                children: [
                  InfoRow('Local device ID', device.id),
                  if (device.macSource != null)
                    InfoRow('MAC source', device.macSource!),
                  if (device.ssdpAdvertisements.isNotEmpty)
                    ExpansionTile(
                      title: const Text('Smart-device technical details'),
                      children: [
                        if (device.upnpDescription != null)
                          for (final entry
                              in device.upnpDescription!.fields.entries)
                            InfoRow(entry.key, entry.value),
                        for (final ad in device.ssdpAdvertisements)
                          for (final entry in ad.headers.entries)
                            InfoRow(entry.key.toUpperCase(), entry.value),
                      ],
                    ),
                  for (final service in device.services)
                    if (service.attributes.isNotEmpty ||
                        service.addresses.isNotEmpty)
                      ExpansionTile(
                        title: Text('${service.label}: technical attributes'),
                        children: [
                          if (service.hostname != null)
                            InfoRow('Hostname', service.hostname!),
                          if (service.addresses.isNotEmpty)
                            InfoRow('Addresses', service.addresses.join(', ')),
                          for (final entry in service.attributes.entries)
                            InfoRow(entry.key, entry.value),
                        ],
                      ),
                  InfoRow(
                    'Data source',
                    isMock ? 'Mock device repository' : 'Device repository',
                  ),
                  InfoRow(
                    'Discovery evidence',
                    device.discoveryEvidence.isEmpty
                        ? 'Not recorded'
                        : device.discoveryEvidence.join('; '),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
