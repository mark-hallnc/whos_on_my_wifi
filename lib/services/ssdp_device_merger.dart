import '../models/discovered_service.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../models/upnp_description.dart';
import 'service_device_merger.dart';

class SsdpDeviceMerger {
  static DeviceType typeHint(String? urn) {
    final parts = urn?.split(':');
    if (parts == null ||
        parts.length != 5 ||
        parts[0] != 'urn' ||
        parts[1] != 'schemas-upnp-org' ||
        parts[2] != 'device' ||
        int.tryParse(parts[4]) == null) {
      return DeviceType.unknown;
    }
    return switch (parts[3]) {
      'MediaRenderer' || 'MediaServer' => DeviceType.mediaDevice,
      'InternetGatewayDevice' => DeviceType.router,
      'Printer' || 'PrinterDevice' => DeviceType.printer,
      'DigitalSecurityCamera' ||
      'DigitalSecurityCameraStillImage' ||
      'DigitalSecurityCameraMotionImage' => DeviceType.camera,
      _ => DeviceType.unknown,
    };
  }

  static void merge(
    Map<String, NetworkDevice> devices,
    SsdpAdvertisement advertisement,
    NetworkInfo network, {
    UpnpDescription? description,
    Uri? location,
    DateTime? observedAt,
  }) {
    final ip = advertisement.address;
    final policy = LocalDescriptionPolicy(network);
    if (!policy.isLocal(ip)) return;
    final old = devices[ip];
    final now = observedAt ?? DateTime.now();
    final data = description ?? old?.upnpDescription;
    final discoveredName =
        ResolvedLocalService.usefulName(old?.discoveredName) ??
        ResolvedLocalService.usefulName(data?.friendlyName);
    final hint = typeHint(data?.deviceType);
    final type = old != null && old.type != DeviceType.unknown
        ? old.type
        : hint;
    final confidence = description != null
        ? IdentificationConfidence.medium
        : IdentificationConfidence.low;
    final services = {
      for (final s in old?.services ?? <DiscoveredService>[]) s.identity: s,
    };
    final safeLocation = location == null
        ? null
        : policy.location(location.toString(), ip);
    if (description != null && safeLocation != null) {
      for (final entry in description.services) {
        final urn = entry['serviceType']!;
        final name = urn.split(':').length >= 4 ? urn.split(':')[3] : urn;
        // Endpoints stay inert metadata. No control/event/SCPD requests are sent.
        final service = DiscoveredService(
          name: name,
          type: urn,
          discoveryMethod: 'SSDP / UPnP',
          host: ip,
          attributes: entry,
          addresses: [ip],
        );
        services[service.identity] = service;
      }
    }
    final ads = {
      for (final ad in old?.ssdpAdvertisements ?? <SsdpAdvertisement>[])
        ad.identity: ad,
    };
    if (ads.length < 128 || ads.containsKey(advertisement.identity)) {
      ads[advertisement.identity] = advertisement;
    }
    devices[ip] = NetworkDevice(
      id: old?.id ?? ip,
      ipAddress: ip,
      firstSeen: old == null || now.isBefore(old.firstSeen)
          ? now
          : old.firstSeen,
      lastSeen: old != null && old.lastSeen.isAfter(now) ? old.lastSeen : now,
      customName: old?.customName,
      hostname: old?.hostname,
      discoveredName: discoveredName,
      manufacturer: old?.manufacturer ?? data?.manufacturer,
      modelName: old?.modelName ?? data?.modelName,
      modelNumber: old?.modelNumber ?? data?.modelNumber,
      modelDescription: old?.modelDescription ?? data?.modelDescription,
      upnpDescription: data,
      ssdpAdvertisements: ads.values.toList(),
      type: type,
      confidence: old != null && old.confidence.index > confidence.index
          ? old.confidence
          : confidence,
      classification: old?.classification ?? DeviceClassification.unknown,
      isOnline: true,
      isCurrentDevice: old?.isCurrentDevice ?? ip == network.localIpAddress,
      isGateway: old?.isGateway ?? ip == network.gatewayAddress,
      macAddress: old?.macAddress,
      notes: old?.notes ?? '',
      previousIpAddresses: old?.previousIpAddresses ?? [],
      services: services.values.toList(),
      openPorts: {
        ...?old?.openPorts,
        if (description != null && safeLocation != null) safeLocation.port,
      }.toList()..sort(),
      discoveryEvidence: {
        ...?old?.discoveryEvidence,
        'Discovered via SSDP',
        if (data?.deviceType != null) 'UPnP device type: ${data!.deviceType}',
        if (data?.manufacturer != null)
          'UPnP manufacturer: ${data!.manufacturer}',
        if (data?.modelName != null) 'UPnP model: ${data!.modelName}',
      }.toList(),
    );
  }
}
