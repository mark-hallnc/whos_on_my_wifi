import 'dart:io';
import '../models/discovered_service.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../utils/ipv4_subnet.dart';
import '../utils/identity_text.dart';
import 'device_identification_service.dart';

/// Parses untrusted LAN metadata without reverse DNS or additional traffic.
class ResolvedLocalService {
  ResolvedLocalService({
    required this.name,
    required this.type,
    required this.port,
    required this.addresses,
    this.hostname,
    this.attributes = const {},
  });
  final String name;
  final String type;
  final int port;
  final List<String> addresses;
  final String? hostname;
  final Map<String, String> attributes;

  static const serviceTypes = [
    '_http._tcp.',
    '_https._tcp.',
    '_googlecast._tcp.',
    '_airplay._tcp.',
    '_raop._tcp.',
    '_ipp._tcp.',
    '_ipps._tcp.',
    '_printer._tcp.',
    '_smb._tcp.',
    '_workstation._tcp.',
    '_device-info._tcp.',
  ];

  static ResolvedLocalService? fromPlatform(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['name'];
    final rawType = raw['type'];
    final port = raw['port'];
    if (name is! String ||
        name.trim().isEmpty ||
        name.length > 255 ||
        rawType is! String ||
        port is! int ||
        port < 1 ||
        port > 65535) {
      return null;
    }
    var type = rawType.toLowerCase();
    if (type.endsWith('.local.')) type = type.substring(0, type.length - 6);
    if (!type.endsWith('.')) type = '$type.';
    if (!serviceTypes.contains(type)) return null;
    final addresses =
        (raw['addresses'] is List ? raw['addresses'] as List : const [])
            .whereType<String>()
            .where((a) => InternetAddress.tryParse(a) != null)
            .take(16)
            .toSet()
            .toList();
    if (addresses.isEmpty) return null;
    final attributes = <String, String>{};
    if (raw['attributes'] case final Map values) {
      for (final entry in values.entries.take(24)) {
        if (entry.key is String && entry.value is String) {
          attributes[(entry.key as String).substring(
            0,
            (entry.key as String).length.clamp(0, 64),
          )] = (entry.value as String).substring(
            0,
            (entry.value as String).length.clamp(0, 256),
          );
        }
      }
    }
    return ResolvedLocalService(
      name: name.trim(),
      type: type,
      port: port,
      addresses: List.unmodifiable(addresses),
      hostname: raw['hostname'] is String ? raw['hostname'] as String : null,
      attributes: Map.unmodifiable(attributes),
    );
  }

  static String? usefulName(String? value) => IdentityText.name(value);
}

/// Only local usable IPv4 hosts become rows; IPv6 remains service metadata.
class ServiceDeviceMerger {
  static void merge(
    Map<String, NetworkDevice> devices,
    ResolvedLocalService found,
    NetworkInfo network, {
    DateTime? observedAt,
  }) {
    final local = network.localIpAddress;
    final prefix = network.ipv4PrefixLength;
    if (local == null || prefix == null) return;
    final subnet = Ipv4Subnet(local, prefix);
    final now = observedAt ?? DateTime.now();
    for (final ip in found.addresses.toSet()) {
      final parsed = InternetAddress.tryParse(ip);
      if (parsed == null ||
          parsed.type != InternetAddressType.IPv4 ||
          parsed.isLoopback ||
          parsed.isMulticast ||
          ip == '0.0.0.0') {
        continue;
      }
      final hostSubnet = Ipv4Subnet(ip, prefix);
      if (hostSubnet.networkAddress != subnet.networkAddress ||
          (prefix < 31 &&
              (ip == subnet.networkAddress || ip == subnet.broadcastAddress))) {
        continue;
      }
      final old = devices[ip];
      final service = DiscoveredService(
        name: found.name,
        type: found.type,
        port: found.port,
        host: ip,
        hostname: found.hostname,
        addresses: found.addresses,
        attributes: found.attributes,
        discoveryMethod: 'mDNS / Android NSD',
      );
      final services = {
        for (final item in old?.services ?? <DiscoveredService>[])
          item.identity: item,
      };
      final prior = services[service.identity];
      services[service.identity] = DiscoveredService(
        name: service.name,
        type: service.type,
        port: service.port,
        host: ip,
        hostname: service.hostname ?? prior?.hostname,
        discoveryMethod: service.discoveryMethod,
        addresses: List.unmodifiable({
          ...?prior?.addresses,
          ...service.addresses,
        }),
        attributes: Map.unmodifiable({
          ...?prior?.attributes,
          ...service.attributes,
        }),
      );
      devices[ip] = DeviceIdentificationService.identify(
        NetworkDevice(
          id: old?.id ?? ip,
          ipAddress: ip,
          firstSeen: old == null || now.isBefore(old.firstSeen)
              ? now
              : old.firstSeen,
          lastSeen: old != null && old.lastSeen.isAfter(now)
              ? old.lastSeen
              : now,
          customName: old?.customName,
          upnpDescription: old?.upnpDescription,
          ssdpAdvertisements: old?.ssdpAdvertisements ?? [],
          hostname: old?.hostname ?? found.hostname,
          macAddress: old?.macAddress,
          macVendor: old?.macVendor,
          macSource: old?.macSource,
          isOnline: true,
          classification: old?.classification ?? DeviceClassification.unknown,
          notes: old?.notes ?? '',
          previousIpAddresses: old?.previousIpAddresses ?? [],
          isCurrentDevice: old?.isCurrentDevice ?? ip == local,
          isGateway: old?.isGateway ?? ip == network.gatewayAddress,
          services: services.values.toList(),
          openPorts: {...?old?.openPorts, found.port}.toList()..sort(),
          discoveryEvidence: {
            ...?old?.discoveryEvidence,
            'Discovered via mDNS / Android NSD',
            'Advertises ${found.type}',
          }.toList(),
        ),
        previous: old,
      );
    }
  }
}
