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
              : updated.withPresentation(online: device.isOnline),
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
  Widget build(BuildContext context) {
    String timestamp(DateTime value) {
      final date = value.toLocal(), now = DateTime.now();
      final local = MaterialLocalizations.of(context);
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return 'Today, ${local.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
      }
      return local.formatMediumDate(date);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Details'),
        actions: [
          if (editable) TextButton(onPressed: edit, child: const Text('Edit')),
        ],
      ),
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
                if (device.classification != DeviceClassification.unknown)
                  Text(
                    device.classification.label,
                    textAlign: TextAlign.center,
                  ),
                if (device.isNew && !widget.historical)
                  const Text(
                    'First discovered in the latest scan',
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                InfoSection(
                  title: 'Identification',
                  children: [
                    if (device.manufacturer?.isNotEmpty ?? false)
                      InfoRow('Manufacturer', device.manufacturer!),
                    if (device.modelName?.isNotEmpty ?? false)
                      InfoRow('Model', device.modelName!),
                    if (device.normalizedHostname != null &&
                        device.normalizedHostname != device.displayName)
                      InfoRow('Hostname', device.normalizedHostname!),
                    InfoRow('Type', device.type.label),
                    InfoRow('Confidence', switch (device.confidence) {
                      IdentificationConfidence.low => 'Low',
                      IdentificationConfidence.medium => 'Medium',
                      IdentificationConfidence.high => 'High',
                    }),
                  ],
                ),
                InfoSection(
                  title: 'Network',
                  children: [
                    InfoRow('IP', device.ipAddress),
                    if (device.macAddress != null)
                      InfoRow('MAC', device.macAddress!),
                    if (device.isPrivateMac)
                      const InfoRow('MAC vendor', 'Private/randomized address'),
                    InfoRow('Status', device.isOnline ? 'Online' : 'Offline'),
                  ],
                ),
                if (device.services.isNotEmpty)
                  InfoSection(
                    title: 'Services',
                    children: [
                      for (final service in device.services)
                        InfoRow(
                          service.label,
                          [
                            if (service.name.isNotEmpty &&
                                service.name != service.label)
                              service.name,
                            if (service.port != null) 'Port ${service.port}',
                          ].join(' • '),
                        ),
                    ],
                  ),
                if (device.openPorts.isNotEmpty)
                  InfoSection(
                    title: 'Ports',
                    children: [Text(device.openPorts.join(', '))],
                  ),
                InfoSection(
                  title: 'History',
                  children: [
                    InfoRow(
                      'Network',
                      network.name ?? network.subnet ?? 'Saved network',
                    ),
                    InfoRow('First seen', timestamp(device.firstSeen)),
                    InfoRow('Last seen', timestamp(device.lastSeen)),
                    if (device.previousIpAddresses.isNotEmpty)
                      InfoRow(
                        'Previous IPs',
                        device.previousIpAddresses.join(', '),
                      ),
                  ],
                ),
                if (device.notes.trim().isNotEmpty)
                  InfoSection(title: 'Notes', children: [Text(device.notes)])
                else if (editable)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: edit,
                      icon: const Icon(Icons.note_add_outlined),
                      label: const Text('Add note'),
                    ),
                  ),
                ExpansionTile(
                  title: const Text('Technical details'),
                  children: [
                    InfoRow('Local device ID', device.id),
                    if (device.hostname != null)
                      InfoRow('Raw hostname', device.hostname!),
                    if (device.discoveredName != null)
                      InfoRow('Discovered name', device.discoveredName!),
                    if (device.reportedManufacturer != null)
                      InfoRow(
                        'Reported manufacturer',
                        device.reportedManufacturer!,
                      ),
                    if (device.modelNumber != null)
                      InfoRow('Model number', device.modelNumber!),
                    if (device.modelDescription != null)
                      InfoRow('Model description', device.modelDescription!),
                    if (device.macVendor != null && !device.isPrivateMac)
                      InfoRow('Raw MAC vendor', device.macVendor!),
                    if (device.macSource != null)
                      InfoRow('MAC source', device.macSource!),
                    if (device.isPrivateMac)
                      const Text(
                        'Private/randomized MAC address. Manufacturer cannot be determined reliably from this address.',
                      ),
                    for (final note in device.identificationNotes) Text(note),
                    if (device.discoveryEvidence.isNotEmpty)
                      InfoRow(
                        'Discovery evidence',
                        device.discoveryEvidence.join('\n'),
                      ),
                    if (device.upnpDescription != null)
                      for (final entry
                          in device.upnpDescription!.fields.entries)
                        InfoRow(entry.key, entry.value),
                    for (final ad in device.ssdpAdvertisements)
                      for (final entry in ad.headers.entries)
                        InfoRow(entry.key.toUpperCase(), entry.value),
                    for (final service in device.services) ...[
                      InfoRow('Service type', service.type),
                      InfoRow('Discovery method', service.discoveryMethod),
                      if (service.hostname != null)
                        InfoRow('Hostname', service.hostname!),
                      if (service.addresses.isNotEmpty)
                        InfoRow('Addresses', service.addresses.join(', ')),
                      for (final entry in service.attributes.entries)
                        if (entry.value.isNotEmpty)
                          InfoRow(entry.key, entry.value),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
