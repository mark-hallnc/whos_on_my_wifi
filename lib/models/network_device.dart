import 'discovered_service.dart';
import 'upnp_description.dart';

enum DeviceType {
  phone,
  computer,
  television,
  thermostat,
  printer,
  router,
  iot,
  mediaDevice,
  camera,
  unknown,
}

enum DeviceClassification { known, unknown, mine, guest }

enum IdentificationConfidence { low, medium, high }

/// Identity is independent of IP/MAC: addresses can change or be unavailable.
class NetworkDevice {
  NetworkDevice({
    required this.id,
    required this.ipAddress,
    required this.firstSeen,
    required this.lastSeen,
    this.customName,
    this.hostname,
    this.discoveredName,
    this.modelName,
    this.modelNumber,
    this.modelDescription,
    this.upnpDescription,
    List<SsdpAdvertisement> ssdpAdvertisements = const [],
    this.macAddress,
    this.manufacturer,
    this.type = DeviceType.unknown,
    this.isOnline = false,
    this.classification = DeviceClassification.unknown,
    this.confidence = IdentificationConfidence.low,
    this.notes = '',
    this.isCurrentDevice = false,
    this.isGateway = false,
    List<String> discoveryEvidence = const [],
    List<DiscoveredService> services = const [],
    List<int> openPorts = const [],
    List<String> previousIpAddresses = const [],
  }) : ssdpAdvertisements = List.unmodifiable(ssdpAdvertisements),
       discoveryEvidence = List.unmodifiable(discoveryEvidence),
       services = List.unmodifiable(services),
       openPorts = List.unmodifiable(openPorts),
       previousIpAddresses = List.unmodifiable(previousIpAddresses);

  final String id;
  final bool isCurrentDevice;
  final bool isGateway;
  final List<String> discoveryEvidence;
  final String? customName;
  final String? hostname;
  final String? discoveredName;
  final String? modelName;
  final String? modelNumber;
  final String? modelDescription;
  final UpnpDescription? upnpDescription;
  final List<SsdpAdvertisement> ssdpAdvertisements;
  final String ipAddress;
  final String? macAddress;
  final String? manufacturer;
  final DeviceType type;
  final bool isOnline;
  final DeviceClassification classification;
  final IdentificationConfidence confidence;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final String notes;
  final List<DiscoveredService> services;
  final List<int> openPorts;
  final List<String> previousIpAddresses;

  String get displayName {
    if (isCurrentDevice) return 'This device';
    if (isGateway) return 'Router / Gateway';
    if (customName?.trim().isNotEmpty ?? false) return customName!.trim();
    if (discoveredName?.trim().isNotEmpty ?? false) {
      return discoveredName!.trim();
    }
    if (hostname?.trim().isNotEmpty ?? false) return hostname!.trim();
    return 'Unknown device';
  }
}
