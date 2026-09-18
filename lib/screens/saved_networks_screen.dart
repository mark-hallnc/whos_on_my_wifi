import 'package:flutter/material.dart';
import '../models/saved_network.dart';
import '../repositories/device_repository.dart';
import '../repositories/local_device_store.dart';
import '../utils/device_presentation.dart';
import 'saved_network_detail_screen.dart';

class SavedNetworksScreen extends StatefulWidget {
  const SavedNetworksScreen({super.key, required this.repository});
  final DeviceRepository repository;
  @override
  State<SavedNetworksScreen> createState() => _SavedNetworksScreenState();
}

class _SavedNetworksScreenState extends State<SavedNetworksScreen> {
  LocalDeviceStore? get store => widget.repository is LocalDeviceStore
      ? widget.repository as LocalDeviceStore
      : null;
  late Future<List<SavedNetwork>> networks = load();
  Future<List<SavedNetwork>> load() =>
      store?.getSavedNetworks() ?? Future.value([]);
  @override
  void initState() {
    super.initState();
    store?.addListener(refresh);
  }

  void refresh() {
    if (mounted) setState(() => networks = load());
  }

  @override
  void dispose() {
    store?.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Saved Networks')),
    body: FutureBuilder<List<SavedNetwork>>(
      future: networks,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: refresh,
              child: const Text('Could not load saved networks. Retry'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No saved networks yet. Scan your current network to remember its devices.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final saved = snapshot.data![index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.wifi_rounded),
                title: Text(saved.network.name ?? 'Saved network'),
                subtitle: Text(
                  '${saved.network.subnet}\n${saved.deviceCount} known devices\nLast scanned: ${formatTimestamp(saved.lastScanned)}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        SavedNetworkDetailScreen(saved: saved, store: store!),
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
