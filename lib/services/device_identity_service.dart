import 'dart:convert';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../utils/ipv4_subnet.dart';
import 'service_device_merger.dart';

class DeviceIdentityService {
  static const fallbackWindow = Duration(hours: 24);

  /// Android netId is a connection handle, not durable across reconnect/reboot.
  /// SSID supplements topology; it is never the sole key.
  static String? networkKey(NetworkInfo network) {
    final ip = network.localIpAddress;
    final prefix = network.ipv4PrefixLength;
    if (ip == null ||
        prefix == null ||
        ![
          NetworkConnectionType.wifi,
          NetworkConnectionType.ethernet,
        ].contains(network.connectionType)) {
      return null;
    }
    try {
      return jsonEncode([
        network.connectionType.name,
        Ipv4Subnet(ip, prefix).networkAddress,
        prefix,
        network.gatewayAddress ?? '',
        network.name?.trim() ?? '',
      ]);
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  static List<String> strongKeys(NetworkDevice device) {
    final keys = <String>[];
    if (device.macAddress != null && !device.isPrivateMac) {
      keys.add('mac:${device.macAddress}');
    }
    final udn = device.upnpDescription?.fields['UDN']?.trim().toLowerCase();
    if (udn != null &&
        RegExp(
          r'^uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ).hasMatch(udn)) {
      keys.add('udn:$udn');
    }
    for (final service in device.services) {
      final endpoint = service.attributes['endpoint']?.trim().toLowerCase();
      if (service.type == 'ws-discovery' &&
          endpoint != null &&
          RegExp(
            r'^urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          ).hasMatch(endpoint)) {
        keys.add('wsd:$endpoint');
      }
      final id = service.attributes['id']?.toLowerCase();
      if (service.type == '_googlecast._tcp.' &&
          id != null &&
          RegExp(r'^[0-9a-f]{32}$').hasMatch(id)) {
        keys.add('cast:$id');
      }
    }
    if (device.isCurrentDevice) keys.add('self');
    return keys.toSet().toList();
  }

  static bool conflicts(NetworkDevice old, NetworkDevice fresh) {
    for (final prefix in ['mac:', 'udn:', 'cast:', 'wsd:']) {
      final a = strongKeys(old).where((k) => k.startsWith(prefix)).toSet();
      final b = strongKeys(fresh).where((k) => k.startsWith(prefix)).toSet();
      if (a.isNotEmpty && b.isNotEmpty && a.intersection(b).isEmpty) {
        return true;
      }
    }
    final sharedProtocol = strongKeys(old)
        .where((k) => !k.startsWith('mac:'))
        .toSet()
        .intersection(strongKeys(fresh).toSet())
        .isNotEmpty;
    return !(old.isCurrentDevice && fresh.isCurrentDevice) &&
        !sharedProtocol &&
        old.macAddress != null &&
        fresh.macAddress != null &&
        old.macAddress != fresh.macAddress;
  }

  static bool sameName(NetworkDevice a, NetworkDevice b) {
    final old = [a.hostname, a.discoveredName]
        .map(ResolvedLocalService.usefulName)
        .nonNulls
        .map((n) => n.toLowerCase())
        .toSet();
    final fresh = [b.hostname, b.discoveredName]
        .map(ResolvedLocalService.usefulName)
        .nonNulls
        .map((n) => n.toLowerCase())
        .toSet();
    return old.intersection(fresh).isNotEmpty;
  }

  static bool fallbackMatch(NetworkDevice old, NetworkDevice fresh) {
    if (conflicts(old, fresh)) return false;
    final age = fresh.lastSeen.difference(old.lastSeen);
    if (age.isNegative || age > fallbackWindow) return false;
    if (old.ipAddress != fresh.ipAddress) {
      // Private MAC continuity is network-scoped, brief and corroborated.
      return old.isPrivateMac &&
          fresh.isPrivateMac &&
          old.macAddress == fresh.macAddress &&
          sameName(old, fresh);
    }
    if (sameName(old, fresh)) return true;
    if (old.isCurrentDevice && fresh.isCurrentDevice) return true;
    // Anonymous IP-only sightings are temporary continuity, never permanent ID.
    return strongKeys(old).isEmpty &&
        strongKeys(fresh).isEmpty &&
        old.macAddress == null &&
        fresh.macAddress == null &&
        old.hostname == null &&
        fresh.hostname == null &&
        old.discoveredName == null &&
        fresh.discoveredName == null;
  }
}
