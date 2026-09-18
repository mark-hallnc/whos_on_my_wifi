import 'package:flutter/material.dart';
import '../models/network_device.dart';
import '../models/saved_network.dart';
import '../repositories/local_device_store.dart';
import '../utils/device_presentation.dart';
import '../widgets/device_card.dart';
import 'device_details_screen.dart';

class SavedNetworkDetailScreen extends StatefulWidget {
  const SavedNetworkDetailScreen({
    super.key,
    required this.saved,
    required this.store,
  });
  final SavedNetwork saved;
  final LocalDeviceStore store;
  @override
  State<SavedNetworkDetailScreen> createState() =>
      _SavedNetworkDetailScreenState();
}

class _SavedNetworkDetailScreenState extends State<SavedNetworkDetailScreen> {
  late Future<List<NetworkDevice>> devices = widget.store.getDevicesForNetwork(
    widget.saved.id,
  );
  @override
  void initState() {
    super.initState();
    widget.store.addListener(refresh);
  }

  void refresh() {
    if (mounted) {
      setState(
        () => devices = widget.store.getDevicesForNetwork(widget.saved.id),
      );
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.saved.network.name ?? 'Saved network')),
    body: FutureBuilder<List<NetworkDevice>>(
      future: devices,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: refresh,
              child: const Text('Could not load history. Retry'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.saved.network.subnet ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Last scanned: ${formatTimestamp(widget.saved.lastScanned)}'),
            const Text(
              'Saved history. Devices are shown offline until a scan confirms them on the current network.',
            ),
            const SizedBox(height: 16),
            for (final device in snapshot.data!) ...[
              DeviceCard(
                device: device,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DeviceDetailsScreen(
                      device: device,
                      network: widget.saved.network,
                      store: widget.store,
                      historical: true,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 12),
                child: Text('Last seen: ${formatTimestamp(device.lastSeen)}'),
              ),
            ],
          ],
        );
      },
    ),
  );
}
