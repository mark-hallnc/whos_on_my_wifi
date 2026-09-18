import 'dart:convert';
import '../models/network_device.dart';
import '../models/discovered_service.dart';
import '../models/upnp_description.dart';

T enumValue<T extends Enum>(Iterable<T> values, Object? name, T fallback) =>
    values.where((v) => v.name == name).firstOrNull ?? fallback;

class DeviceRecordCodec {
  static Map<String, String> strings(Object? value) => value is Map
      ? {
          for (final entry in value.entries)
            if (entry.key is String && entry.value is String)
              entry.key as String: entry.value as String,
        }
      : {};
  static List<String> list(Object? value) =>
      value is List ? value.whereType<String>().toList() : [];
  static Map<String, dynamic> decode(String value) =>
      jsonDecode(value) as Map<String, dynamic>;

  static String details(NetworkDevice d) => jsonEncode({
    'evidence': d.discoveryEvidence
        .take(32)
        .map((e) => e.length > 256 ? e.substring(0, 256) : e)
        .toList(),
    'ports': d.openPorts.toSet().take(128).toList(),
    'macSource': d.macSource,
    'upnp': d.upnpDescription?.fields,
    'ads': d.ssdpAdvertisements.take(8).map((a) => a.headers).toList(),
  });
  static String serviceDetails(DiscoveredService s) => jsonEncode({
    'hostname': s.hostname,
    'addresses': s.addresses.take(16).toList(),
    'attributes': Map.fromEntries(
      s.attributes.entries
          .take(24)
          .map(
            (e) => MapEntry(
              e.key.substring(0, e.key.length.clamp(0, 64)),
              e.value.substring(0, e.value.length.clamp(0, 1024)),
            ),
          ),
    ),
  });

  static NetworkDevice device(
    Map<String, dynamic> r,
    List<DiscoveredService> services,
    List<String> previousIps, {
    bool online = false,
    bool isNew = false,
  }) {
    final extra = decode(r['details_json'] as String);
    return NetworkDevice(
      id: 'device:${r['id']}',
      ipAddress: r['ip_address'] as String,
      firstSeen: DateTime.fromMillisecondsSinceEpoch(
        r['first_seen'] as int,
        isUtc: true,
      ),
      lastSeen: DateTime.fromMillisecondsSinceEpoch(
        r['last_seen'] as int,
        isUtc: true,
      ),
      customName: r['custom_name'] as String?,
      notes: r['notes'] as String,
      classification: enumValue(
        DeviceClassification.values,
        r['classification'],
        DeviceClassification.unknown,
      ),
      discoveredName: r['discovered_name'] as String?,
      hostname: r['hostname'] as String?,
      macAddress: r['mac_address'] as String?,
      macVendor: r['mac_vendor'] as String?,
      macSource: extra['macSource'] as String?,
      manufacturer: r['manufacturer'] as String?,
      modelName: r['model_name'] as String?,
      modelNumber: r['model_number'] as String?,
      modelDescription: r['model_description'] as String?,
      type: enumValue(DeviceType.values, r['device_type'], DeviceType.unknown),
      confidence: enumValue(
        IdentificationConfidence.values,
        r['confidence'],
        IdentificationConfidence.low,
      ),
      isGateway: r['is_gateway'] == 1,
      isCurrentDevice: r['is_current_device'] == 1,
      isOnline: online,
      isNew: isNew,
      services: services,
      previousIpAddresses: previousIps,
      discoveryEvidence: list(extra['evidence']),
      openPorts: (extra['ports'] as List? ?? []).whereType<int>().toList(),
      upnpDescription: extra['upnp'] == null
          ? null
          : UpnpDescription(strings(extra['upnp']), []),
      ssdpAdvertisements: (extra['ads'] as List? ?? [])
          .map((a) => SsdpAdvertisement(r['ip_address'] as String, strings(a)))
          .toList(),
    );
  }
}
