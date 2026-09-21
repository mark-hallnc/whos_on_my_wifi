import 'package:flutter/material.dart';
import '../app/current_network_controller.dart';
import '../models/scan_result.dart';
import '../models/network_info.dart';
import '../screens/network_information_screen.dart';
import '../utils/network_presentation.dart';

class CurrentNetworkCard extends StatelessWidget {
  const CurrentNetworkCard({
    super.key,
    required this.network,
    required this.result,
    required this.onScan,
    this.scanBusy = false,
    this.onCancel,
  });
  final CurrentNetworkController network;
  final ScanResult result;
  final VoidCallback onScan;
  final VoidCallback? onCancel;
  final bool scanBusy;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: network,
    builder: (context, _) {
      final colors = Theme.of(context).colorScheme;
      final info = network.info;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: colors.onPrimaryContainer),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.wifi_rounded, color: colors.onPrimaryContainer),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'CURRENT NETWORK',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh network',
                    onPressed: network.isRefreshing ? null : network.refresh,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                network.isRefreshing ? 'Checking connection…' : info.title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimaryContainer,
                ),
              ),
              if (!network.isRefreshing) ...[
                const SizedBox(height: 6),
                if (info.localIpAddress != null)
                  Text(
                    [
                      info.localIpAddress!,
                      if (info.subnet != null) info.subnet!,
                    ].join(' • '),
                  ),
                if (info.localIpAddress == null ||
                    ![
                      NetworkConnectionType.wifi,
                      NetworkConnectionType.ethernet,
                    ].contains(info.connectionType))
                  Text(info.statusLabel),
                if (info.notice != null) ...[
                  const SizedBox(height: 8),
                  Text(info.notice!),
                ],
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NetworkInformationScreen(
                        network: network,
                        scan: result,
                      ),
                    ),
                  ),
                  child: const Text('Network details'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${result.onlineDevices} online • ${result.knownDevices} known',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                result.completedAt == null
                    ? 'Not scanned yet'
                    : 'Last scan ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(result.completedAt!.toLocal()))}',
              ),
              if (result.state != ScanState.idle &&
                  result.state != ScanState.completed) ...[
                const SizedBox(height: 12),
                Text(
                  result.message ??
                      switch (result.state) {
                        ScanState.preparing => 'Preparing scan...',
                        ScanState.running => 'Scanning network...',
                        ScanState.discoveringServices =>
                          'Discovering local services...',
                        ScanState.cancelled => 'Scan cancelled.',
                        ScanState.failed => 'Scan failed.',
                        ScanState.subnetTooLarge => 'Subnet too large to scan.',
                        _ => 'Scan completed',
                      },
                ),
                Text(
                  '${result.addressesChecked} of ${result.totalCandidates} addresses checked; ${result.devicesFound} devices found',
                ),
                if (result.state == ScanState.running)
                  LinearProgressIndicator(
                    value: result.totalCandidates == 0
                        ? 0
                        : result.addressesChecked / result.totalCandidates,
                  ),
              ],
              if (result.state == ScanState.completed &&
                  result.possibleIsolation)
                Text(result.message ?? ''),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: scanBusy
                    ? (result.state == ScanState.cancelled ? null : onCancel)
                    : (network.isRefreshing ? null : onScan),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.radar_rounded),
                label: Text(
                  scanBusy
                      ? (result.state == ScanState.cancelled
                            ? 'Stopping scan...'
                            : 'Cancel Scan')
                      : 'Scan Network',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
