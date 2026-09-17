import 'package:flutter/material.dart';
import '../app/current_network_controller.dart';
import '../services/local_network_permission_service.dart';
import '../utils/network_presentation.dart';

/// Reusable, user-initiated gateway for future local discovery operations.
abstract final class LocalNetworkPermissionFlow {
  static Future<bool> ensureAccess(
    BuildContext context,
    CurrentNetworkController network,
  ) async {
    final status = await network.permissions.getStatus();
    if (!context.mounted) return false;
    if (status.allowsAccess) return true;
    if (status == LocalNetworkPermissionStatus.unavailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(status.label)));
      return false;
    }
    final needsSettings =
        status == LocalNetworkPermissionStatus.permanentlyDenied;
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.wifi_rounded),
        title: const Text('Local network access'),
        content: Text(
          needsSettings
              ? '${status.label}\n\nScanning stays on your device.'
              : "Who's on My WiFi needs local network access to find devices connected to your network. "
                    'Scanning stays on your device.\n\nDevice scanning is coming in a future update; '
                    'you can prepare access now or continue without it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(needsSettings ? 'Open settings' : 'Continue'),
          ),
        ],
      ),
    );
    if (agreed != true || !context.mounted) return false;
    if (needsSettings) {
      final opened = await network.permissions.openSettings();
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Open Android Settings, then Apps → Who\'s on My WiFi → Permissions.',
            ),
          ),
        );
      }
      return false;
    }
    final result = await network.permissions.request();
    await network.refresh();
    if (!context.mounted) return false;
    if (!result.allowsAccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.label)));
    }
    return result.allowsAccess;
  }
}
