import 'package:flutter/material.dart';
import '../services/network_scanner.dart';
import '../utils/network_presentation.dart';
import '../services/network_discovery_service.dart';
import '../app/current_network_controller.dart';
import '../models/network_info.dart';
import '../widgets/current_network_card.dart';
import '../widgets/ad_banner_slot.dart';
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
    this.scanner,
    this.showAdBanner = true,
  });
  final bool showAdBanner;
  final NetworkDiscoveryService? scanner;
  final DeviceRepository repository;
  final CurrentNetworkController network;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Future<ScanResult> _snapshot = widget.repository.loadSnapshot();
  ScanResult? _liveResult;
  final _searchController = TextEditingController();
  _DeviceFilter _filter = _DeviceFilter.all;
  _DeviceSort _sort = _DeviceSort.name;
  bool _scanBusy = false;
  bool _disposed = false;
  ScanCancellation? _cancellation;
  NetworkInfo? _scanNetworkInfo;
  late final NetworkDiscoveryService _scanner =
      widget.scanner ??
      NetworkScanner(networkInfoService: widget.network.service);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.network.addListener(_networkUpdated);
  }

  void _networkUpdated() {
    final initial = _scanNetworkInfo;
    if (!_scanBusy || initial == null || widget.network.isRefreshing) return;
    final reason =
        NetworkScanner.networkChangeReason(initial, widget.network.info) ??
        (widget.network.permission.allowsAccess
            ? null
            : 'Local network permission unavailable. Scan stopped.');
    if (reason != null) _cancelScan(reason);
  }

  void _cancelScan([String reason = 'Scan cancelled.']) {
    final token = _cancellation;
    if (token == null || token.isCancelled) return;
    token.cancel(reason);
    if (mounted && !_disposed) {
      setState(
        () => _liveResult = _liveResult?.withState(
          ScanState.cancelled,
          message: token.reason,
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Inactive also occurs for Android permission dialogs; hidden/paused means
    // backgrounded. The shared controller refreshes on resume without scanning.
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cancelScan('App moved to the background. Scan cancelled.');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    widget.network.removeListener(_networkUpdated);
    _cancellation?.cancel('Scan cancelled.');
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

  Future<void> _scanNetwork() async {
    if (_scanBusy) return;
    final token = ScanCancellation();
    _cancellation = token;
    setState(() {
      _scanBusy = true;
      _liveResult =
          (_liveResult ?? ScanResult(network: widget.network.info, devices: []))
              .withState(ScanState.preparing, resetProgress: true);
    });
    try {
      await widget.network.refresh();
      if (!mounted || token.isCancelled) return;
      final type = widget.network.info.connectionType;
      if (type == NetworkConnectionType.wifi ||
          type == NetworkConnectionType.ethernet) {
        final allowed = await LocalNetworkPermissionFlow.ensureAccess(
          context,
          widget.network,
        );
        if (!mounted || token.isCancelled) return;
        if (!allowed) {
          _cancelScan('Local network access not granted. Scan cancelled.');
          return;
        }
      }
      if (!mounted || token.isCancelled) return;
      _scanNetworkInfo = widget.network.info;
      await _scanner.discover(
        network: _scanNetworkInfo,
        cancellation: token,
        verifyNetwork: (initial) async {
          if (token.isCancelled) return token.reason;
          await widget.network.refresh(silently: true);
          if (token.isCancelled) return token.reason;
          return NetworkScanner.networkChangeReason(
                initial,
                widget.network.info,
              ) ??
              (widget.network.permission.allowsAccess
                  ? null
                  : 'Local network permission unavailable. Scan stopped.');
        },
        onProgress: (result) {
          if (mounted && !_disposed) setState(() => _liveResult = result);
        },
      );
    } finally {
      _scanNetworkInfo = null;
      _cancellation = null;
      if (mounted && !_disposed) setState(() => _scanBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: AdBannerSlot(enabled: widget.showAdBanner),
    body: SafeArea(
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
              final result = _liveResult ?? snapshot.data!;
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
                          CurrentNetworkCard(
                            network: widget.network,
                            scanBusy: _scanBusy,
                            result: result,
                            onScan: _scanNetwork,
                            onCancel: _cancelScan,
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
