import 'discovered_service.dart';
import 'upnp_description.dart';
import 'mac_address.dart';

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
    String? macAddress,
    String? manufacturer,
    this.macVendor,
    this.macSource,
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
  }) : macAddress = MacAddress.parse(macAddress)?.value,
       reportedManufacturer = manufacturer,
       ssdpAdvertisements = List.unmodifiable(ssdpAdvertisements),
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
  final String? reportedManufacturer;
  final String? macVendor;
  final String? macSource;
  bool get isPrivateMac =>
      MacAddress.parse(macAddress)?.isLocallyAdministered ?? false;
  String? get manufacturer =>
      reportedManufacturer ?? (isPrivateMac ? null : macVendor);
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

  /// Retain the session ID; a MAC observation may later inform persistent identity.
  NetworkDevice withMac(MacAddress mac, String source, String? vendor) =>
      NetworkDevice(
        id: id,
        ipAddress: ipAddress,
        firstSeen: firstSeen,
        lastSeen: lastSeen,
        customName: customName,
        hostname: hostname,
        discoveredName: discoveredName,
        modelName: modelName,
        modelNumber: modelNumber,
        modelDescription: modelDescription,
        upnpDescription: upnpDescription,
        ssdpAdvertisements: ssdpAdvertisements,
        macAddress: mac.value,
        manufacturer: reportedManufacturer,
        macVendor: mac.isLocallyAdministered ? null : vendor,
        macSource: source,
        type: type,
        isOnline: isOnline,
        classification: classification,
        confidence: confidence,
        notes: notes,
        isCurrentDevice: isCurrentDevice,
        isGateway: isGateway,
        discoveryEvidence: {
          ...discoveryEvidence,
          'MAC observed in $source',
        }.toList(),
        services: services,
        openPorts: openPorts,
        previousIpAddresses: previousIpAddresses,
      );

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
