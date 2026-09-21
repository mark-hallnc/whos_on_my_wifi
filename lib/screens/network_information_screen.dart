import 'package:flutter/material.dart';
import '../app/current_network_controller.dart';
import '../models/network_info.dart';
import '../models/scan_result.dart';
import '../services/local_network_permission_service.dart';
import '../utils/network_presentation.dart';
import '../widgets/info_section.dart';
import '../widgets/local_network_permission_flow.dart';

class NetworkInformationScreen extends StatefulWidget {
  const NetworkInformationScreen({super.key, required this.network, this.scan});
  final CurrentNetworkController network;
  final ScanResult? scan;
  @override
  State<NetworkInformationScreen> createState() =>
      _NetworkInformationScreenState();
}

class _NetworkInformationScreenState extends State<NetworkInformationScreen> {
  bool _permissionBusy = false;

  Future<void> _prepareAccess() async {
    setState(() => _permissionBusy = true);
    try {
      await LocalNetworkPermissionFlow.ensureAccess(context, widget.network);
    } finally {
      if (mounted) setState(() => _permissionBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.network,
    builder: (context, _) {
      final controller = widget.network;
      final info = controller.info;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Network Information'),
          actions: [
            IconButton(
              tooltip: 'Refresh network',
              onPressed: controller.isRefreshing ? null : controller.refresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
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
                  if (controller.isRefreshing) const LinearProgressIndicator(),
                  if (widget.scan?.diagnostics case final diagnostics?)
                    ExpansionTile(
                      title: const Text('Scan diagnostics'),
                      children: [
                        InfoRow(
                          'Candidates / checked',
                          '${widget.scan!.totalCandidates} / ${widget.scan!.addressesChecked}',
                        ),
                        InfoRow(
                          'TCP responding hosts',
                          '${diagnostics.tcpHosts}',
                        ),
                        InfoRow(
                          'NSD only / SSDP only',
                          '${diagnostics.nsdOnlyHosts} / ${diagnostics.ssdpOnlyHosts}',
                        ),
                        InfoRow(
                          'Service-only hosts (including shared)',
                          '${diagnostics.serviceOnlyHosts}',
                        ),
                        InfoRow(
                          'Unnecessary probes skipped',
                          '${diagnostics.skippedProbes}',
                        ),
                        InfoRow(
                          'MAC / identified devices',
                          '${diagnostics.devicesWithMac} / ${diagnostics.identifiedDevices}',
                        ),
                        InfoRow(
                          'Total discovery time',
                          '${diagnostics.elapsed.inMilliseconds} ms',
                        ),
                        for (final entry in diagnostics.durations.entries)
                          InfoRow(
                            entry.key,
                            '${entry.value.inMilliseconds} ms',
                          ),
                        const Text(
                          'Discovery methods run concurrently; durations overlap. Persistence time is not included.',
                        ),
                      ],
                    ),
                  InfoSection(
                    title: 'Current connection',
                    children: [
                      InfoRow('Network', info.title),
                      InfoRow('Status', info.statusLabel),
                      if (info.notice != null) Text(info.notice!),
                      if (info.connectionType == NetworkConnectionType.wifi &&
                          info.name == null)
                        const Text(
                          'Android may hide the Wi-Fi name. No location permission is requested.',
                        ),
                      const Text(
                        'These details describe Android’s active connection. No devices have been scanned.',
                      ),
                    ],
                  ),
                  InfoSection(
                    title: 'Network information',
                    children: [
                      InfoRow(
                        'Local IPv4',
                        info.localIpAddress ?? 'Unavailable',
                      ),
                      InfoRow('Subnet mask', info.subnetMask ?? 'Unavailable'),
                      InfoRow('CIDR', info.subnet ?? 'Unavailable'),
                      InfoRow(
                        'IPv4 prefix length',
                        info.ipv4PrefixLength?.toString() ?? 'Unavailable',
                      ),
                      InfoRow(
                        'Network address',
                        info.networkAddress ?? 'Unavailable',
                      ),
                      InfoRow(
                        'Gateway',
                        info.gatewayAddress ?? 'Not provided by Android',
                      ),
                      InfoRow(
                        'Broadcast',
                        info.broadcastAddress ??
                            'Unavailable or not applicable',
                      ),
                      InfoRow(
                        'DNS servers',
                        info.dnsServers.isEmpty
                            ? 'Not provided by Android'
                            : info.dnsServers.join('\n'),
                      ),
                      InfoRow(
                        'IPv6 addresses / prefixes',
                        info.ipv6Addresses.isEmpty
                            ? 'Not provided by Android'
                            : info.ipv6Addresses
                                  .map((address) => address.cidr)
                                  .join('\n'),
                      ),
                      InfoRow('Interface', info.interfaceName ?? 'Unavailable'),
                    ],
                  ),
                  InfoSection(
                    title: 'Local network access',
                    children: [
                      Text(controller.permission.label),
                      const SizedBox(height: 8),
                      const Text(
                        'Connection details do not require a discovery permission prompt. '
                        'Device scanning is not implemented yet.',
                      ),
                      if (!controller.permission.allowsAccess &&
                          controller.permission !=
                              LocalNetworkPermissionStatus.unavailable) ...[
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: _permissionBusy ? null : _prepareAccess,
                          child: Text(
                            controller.permission ==
                                    LocalNetworkPermissionStatus
                                        .permanentlyDenied
                                ? 'Open permission settings'
                                : controller.permission ==
                                      LocalNetworkPermissionStatus.denied
                                ? 'Retry local network access'
                                : 'Prepare local network access',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
