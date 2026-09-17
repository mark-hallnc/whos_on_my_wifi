import 'package:flutter/material.dart';
import '../models/network_device.dart';

extension DeviceTypePresentation on DeviceType {
  String get label => switch (this) {
    DeviceType.phone => 'Android phone',
    DeviceType.computer => 'Windows PC',
    DeviceType.television => 'Smart TV',
    DeviceType.thermostat => 'Thermostat',
    DeviceType.printer => 'Printer',
    DeviceType.router => 'Router',
    DeviceType.iot => 'IoT device',
    DeviceType.unknown => 'Unknown type',
  };

  IconData get icon => switch (this) {
    DeviceType.phone => Icons.smartphone_rounded,
    DeviceType.computer => Icons.computer_rounded,
    DeviceType.television => Icons.tv_rounded,
    DeviceType.thermostat => Icons.thermostat_rounded,
    DeviceType.printer => Icons.print_rounded,
    DeviceType.router => Icons.router_rounded,
    DeviceType.iot => Icons.sensors_rounded,
    DeviceType.unknown => Icons.devices_other_rounded,
  };
}

extension ClassificationPresentation on DeviceClassification {
  String get label => switch (this) {
    DeviceClassification.known => 'Known',
    DeviceClassification.unknown => 'Unknown',
    DeviceClassification.mine => 'Mine',
    DeviceClassification.guest => 'Guest',
  };
}

String formatTimestamp(DateTime? value) {
  if (value == null) return 'Not scanned yet';
  final local = value.toLocal();
  final minutes = local.minute.toString().padLeft(2, '0');
  return '${local.month}/${local.day}/${local.year} • ${local.hour}:$minutes';
}

int compareIpAddresses(String a, String b) {
  final left = a.split('.').map(int.tryParse).toList();
  final right = b.split('.').map(int.tryParse).toList();
  if (left.length != 4 ||
      right.length != 4 ||
      left.contains(null) ||
      right.contains(null)) {
    return a.compareTo(b);
  }
  for (var i = 0; i < 4; i++) {
    final order = left[i]!.compareTo(right[i]!);
    if (order != 0) return order;
  }
  return 0;
}
