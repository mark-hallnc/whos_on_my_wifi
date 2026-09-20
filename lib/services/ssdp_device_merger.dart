import '../models/discovered_service.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../models/upnp_description.dart';
import 'device_identification_service.dart';

class SsdpDeviceMerger {
  static DeviceType typeHint(String? urn) =>
      DeviceIdentificationService.upnpType(urn);

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
    devices[ip] = DeviceIdentificationService.identify(
      NetworkDevice(
        id: old?.id ?? ip,
        ipAddress: ip,
        firstSeen: old == null || now.isBefore(old.firstSeen)
            ? now
            : old.firstSeen,
        lastSeen: old != null && old.lastSeen.isAfter(now) ? old.lastSeen : now,
        customName: old?.customName,
        hostname: old?.hostname,
        macVendor: old?.macVendor,
        macSource: old?.macSource,
        upnpDescription: data,
        ssdpAdvertisements: ads.values.toList(),
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
      ),
      previous: old,
    );
  }
}
