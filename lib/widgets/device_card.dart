import 'package:flutter/material.dart';
import '../models/network_device.dart';
import '../utils/device_presentation.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key, required this.device, required this.onTap});
  final NetworkDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  device.type.icon,
                  color: colors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (device.identitySummary.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        device.identitySummary,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      device.ipAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (device.isNew)
                          Semantics(
                            label: 'First discovered in the latest scan',
                            child: _StatusLabel(
                              label: 'NEW',
                              foreground: colors.onTertiaryContainer,
                              background: colors.tertiaryContainer,
                            ),
                          ),
                        _StatusLabel(
                          label: device.isOnline ? 'Online' : 'Offline',
                          icon: device.isOnline
                              ? Icons.check_circle_outline
                              : Icons.schedule,
                          foreground: device.isOnline
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          background: device.isOnline
                              ? colors.primaryContainer
                              : colors.surfaceContainerHighest,
                        ),
                        _StatusLabel(
                          label: device.classification.label,
                          foreground: colors.onSecondaryContainer,
                          background: colors.secondaryContainer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });
  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: foreground),
        ),
      ],
    ),
  );
}
