import 'package:flutter/material.dart';
import '../app/current_network_controller.dart';
import '../models/scan_result.dart';
import '../screens/network_information_screen.dart';
import '../utils/device_presentation.dart';
import '../utils/network_presentation.dart';

class CurrentNetworkCard extends StatelessWidget {
  const CurrentNetworkCard({
    super.key,
    required this.network,
    required this.result,
    required this.onScan,
    this.scanBusy = false,
  });
  final CurrentNetworkController network;
  final ScanResult result;
  final VoidCallback onScan;
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
                Text(info.statusLabel),
                const SizedBox(height: 6),
                Text('Local IPv4  ${info.localIpAddress ?? 'Unavailable'}'),
                if (info.subnet != null) Text('Subnet  ${info.subnet}'),
                if (info.gatewayAddress != null)
                  Text('Gateway  ${info.gatewayAddress}'),
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
                      builder: (_) =>
                          NetworkInformationScreen(network: network),
                    ),
                  ),
                  child: const Text('Network details'),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 32,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result.devices.length}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        result.isMock
                            ? 'Example devices'
                            : 'Discovered devices',
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last scan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(formatTimestamp(result.completedAt)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: network.isRefreshing || scanBusy ? null : onScan,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.radar_rounded),
                label: const Text('Scan Network'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
