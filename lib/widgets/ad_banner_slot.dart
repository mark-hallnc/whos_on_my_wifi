import 'package:flutter/material.dart';

/// Provider-independent space for a future banner. No ad is loaded or tracked.
/// Disabled slots collapse completely, including their padding and safe area.
class AdBannerSlot extends StatelessWidget {
  const AdBannerSlot({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Center(
          heightFactor: 1,
          child: Semantics(
            label: 'Advertisement space. Development placeholder.',
            excludeSemantics: true,
            child: Container(
              width: 320,
              constraints: const BoxConstraints(minHeight: 50),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Advertisement\nDevelopment placeholder',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
