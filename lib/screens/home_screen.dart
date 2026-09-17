import 'package:flutter/material.dart';
import '../app/current_network_controller.dart';
import '../models/network_info.dart';
import '../widgets/current_network_card.dart';
import '../widgets/local_network_permission_flow.dart';
import '../models/network_device.dart';
import '../models/scan_result.dart';
import '../repositories/device_repository.dart';
import '../utils/device_presentation.dart';
import '../widgets/device_card.dart';
import '../widgets/mock_data_banner.dart';
import 'device_details_screen.dart';

enum _DeviceFilter { all, online, known, unknown, mine, guest }

enum _DeviceSort { name, address, lastSeen }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.network,
  });
  final DeviceRepository repository;
  final CurrentNetworkController network;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ScanResult> _snapshot = widget.repository.loadSnapshot();
  final _searchController = TextEditingController();
  _DeviceFilter _filter = _DeviceFilter.all;
  _DeviceSort _sort = _DeviceSort.name;
  bool _scanBusy = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NetworkDevice> _visibleDevices(ScanResult result) {
    final query = _searchController.text.trim().toLowerCase();
    final devices = result.devices.where((device) {
      final matchesFilter = switch (_filter) {
        _DeviceFilter.all => true,
        _DeviceFilter.online => device.isOnline,
        _DeviceFilter.known =>
          device.classification != DeviceClassification.unknown,
        _DeviceFilter.unknown =>
          device.classification == DeviceClassification.unknown,
        _DeviceFilter.mine =>
          device.classification == DeviceClassification.mine,
        _DeviceFilter.guest =>
          device.classification == DeviceClassification.guest,
      };
      final searchable = [
        device.displayName,
        device.hostname ?? '',
        device.ipAddress,
        device.manufacturer ?? '',
        device.type.label,
      ].join(' ').toLowerCase();
      return matchesFilter && searchable.contains(query);
    }).toList();
    devices.sort(
      (a, b) => switch (_sort) {
        _DeviceSort.name => a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        ),
        _DeviceSort.address => compareIpAddresses(a.ipAddress, b.ipAddress),
        _DeviceSort.lastSeen => b.lastSeen.compareTo(a.lastSeen),
      },
    );
    return devices;
  }

  Future<void> _showScanPreview() async {
    if (_scanBusy) return;
    setState(() => _scanBusy = true);
    try {
      await widget.network.refresh();
      if (!mounted) return;
      final type = widget.network.info.connectionType;
      if (type == NetworkConnectionType.wifi ||
          type == NetworkConnectionType.ethernet) {
        final allowed = await LocalNetworkPermissionFlow.ensureAccess(
          context,
          widget.network,
        );
        if (!mounted || !allowed) return;
      }
      if (!mounted) return;
      await _showComingSoon();
    } finally {
      if (mounted) setState(() => _scanBusy = false);
    }
  }

  Future<void> _showComingSoon() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.wifi_find_rounded),
      title: const Text('Network scanning is coming'),
      content: const Text(
        'This preview uses mock devices so you can explore the app. '
        'No network traffic is sent and no scan has been performed.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Who's on My WiFi")),
    body: SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: FutureBuilder<ScanResult>(
            future: _snapshot,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Could not load devices.'),
                      TextButton(
                        onPressed: () => setState(() {
                          _snapshot = widget.repository.loadSnapshot();
                        }),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final result = snapshot.data!;
              final devices = _visibleDevices(result);
              return CustomScrollView(
                key: const PageStorageKey('devices-scroll'),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Meet your network',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A little clarity about your connected home.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CurrentNetworkCard(
                            network: widget.network,
                            scanBusy: _scanBusy,
                            result: result,
                            onScan: _showScanPreview,
                          ),
                          if (result.isMock) ...[
                            const SizedBox(height: 16),
                            const MockDataBanner(),
                          ],
                          const SizedBox(height: 24),
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search devices',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      icon: const Icon(Icons.close),
                                      onPressed: () =>
                                          setState(_searchController.clear),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _DeviceFilter.values
                                .map(
                                  (filter) => FilterChip(
                                    label: Text(switch (filter) {
                                      _DeviceFilter.all => 'All',
                                      _DeviceFilter.online => 'Online',
                                      _DeviceFilter.known => 'Known',
                                      _DeviceFilter.unknown => 'Unknown',
                                      _DeviceFilter.mine => 'Mine',
                                      _DeviceFilter.guest => 'Guest',
                                    }),
                                    selected: _filter == filter,
                                    onSelected: (_) =>
                                        setState(() => _filter = filter),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            children: [
                              Text(
                                '${devices.length} of ${result.devices.length} devices',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              PopupMenuButton<_DeviceSort>(
                                initialValue: _sort,
                                tooltip: 'Sort devices',
                                onSelected: (sort) =>
                                    setState(() => _sort = sort),
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: _DeviceSort.name,
                                    child: Text('Name'),
                                  ),
                                  PopupMenuItem(
                                    value: _DeviceSort.address,
                                    child: Text('IP address'),
                                  ),
                                  PopupMenuItem(
                                    value: _DeviceSort.lastSeen,
                                    child: Text('Last seen'),
                                  ),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.sort_rounded, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Sort: ${switch (_sort) {
                                          _DeviceSort.name => 'Name',
                                          _DeviceSort.address => 'IP address',
                                          _DeviceSort.lastSeen => 'Last seen',
                                        }}',
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  if (devices.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded, size: 40),
                            const SizedBox(height: 12),
                            const Text('No matching devices'),
                            TextButton(
                              onPressed: () => setState(() {
                                _searchController.clear();
                                _filter = _DeviceFilter.all;
                              }),
                              child: const Text('Clear search and filters'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) => DeviceCard(
                          device: devices[index],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DeviceDetailsScreen(
                                device: devices[index],
                                network: result.network,
                                isMock: result.isMock,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
