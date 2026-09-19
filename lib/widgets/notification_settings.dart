import 'package:flutter/material.dart';
import '../services/new_device_notification_service.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key, required this.service});
  final NewDeviceNotificationService service;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: service,
    builder: (context, _) => Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('New device notifications'),
            subtitle: const Text(
              'Notify me when a scan discovers a device this app has not seen on this network before.',
            ),
            value: service.enabled,
            onChanged: service.busy
                ? null
                : (value) => service.setEnabled(value),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.error ??
                      (!service.enabled
                          ? 'Off. New devices are still marked in the app.'
                          : service.allowed
                          ? 'On. Notifications follow completed scans only.'
                          : 'Notifications are not allowed by Android. New badges and scan summaries still work. You can allow notifications here or in Android app settings.'),
                ),
                if (service.enabled && !service.allowed)
                  TextButton(
                    onPressed: service.busy
                        ? null
                        : () => service.setEnabled(true),
                    child: const Text('Allow notifications'),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
