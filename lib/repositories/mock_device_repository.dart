import '../models/discovered_service.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../models/scan_result.dart';
import 'device_repository.dart';

/// Entirely fictional fixtures. Loading this repository performs no networking.
class MockDeviceRepository implements DeviceRepository {
  @override
  Future<ScanResult> loadSnapshot() async {
    final now = DateTime.now();
    NetworkDevice device(
      String id,
      String? name,
      String? hostname,
      int address,
      String? vendor,
      DeviceType type,
      DeviceClassification classification, {
      bool online = true,
      List<DiscoveredService> services = const [],
      List<int> ports = const [],
    }) => NetworkDevice(
      id: 'sample-$id',
      customName: name,
      hostname: hostname,
      ipAddress: '192.168.1.$address',
      manufacturer: vendor,
      type: type,
      classification: classification,
      confidence: type == DeviceType.unknown
          ? IdentificationConfidence.low
          : IdentificationConfidence.medium,
      isOnline: online,
      firstSeen: now.subtract(const Duration(days: 12)),
      lastSeen: online ? now : now.subtract(const Duration(hours: 3)),
      services: services,
      openPorts: ports,
      notes: id == 'phone' ? 'Example note: my everyday phone.' : '',
      previousIpAddresses: id == 'phone' ? ['192.168.1.18'] : const [],
    );

    return ScanResult(
      isMock: true,
      network: const NetworkInfo(
        id: 'sample-network',
        name: 'Home Wi-Fi',
        localIpAddress: '192.168.1.24',
        gatewayAddress: '192.168.1.1',
        subnet: '192.168.1.0/24',
      ),
      limitations: const [
        'Sample data only. No network scan has been performed.',
      ],
      devices: [
        device(
          'phone',
          'My Android phone',
          'pixel.local',
          24,
          'Google',
          DeviceType.phone,
          DeviceClassification.mine,
        ),
        device(
          'pc',
          'Office PC',
          'desktop.local',
          10,
          'Microsoft',
          DeviceType.computer,
          DeviceClassification.known,
          ports: [445],
        ),
        device(
          'tv',
          'Living room TV',
          'samsung-tv.local',
          32,
          'Samsung',
          DeviceType.television,
          DeviceClassification.known,
          services: const [
            DiscoveredService(
              name: 'Media renderer',
              type: 'UPnP',
              discoveryMethod: 'Sample SSDP',
            ),
          ],
        ),
        device(
          'thermostat',
          'Nest thermostat',
          'nest.local',
          45,
          'Google Nest',
          DeviceType.thermostat,
          DeviceClassification.known,
        ),
        device(
          'printer',
          'Home printer',
          'printer.local',
          50,
          'HP',
          DeviceType.printer,
          DeviceClassification.known,
          online: false,
          ports: [631],
          services: const [
            DiscoveredService(
              name: 'AirPrint',
              type: '_ipp._tcp',
              discoveryMethod: 'Sample mDNS',
              port: 631,
            ),
          ],
        ),
        device(
          'router',
          'Wi-Fi router',
          'router.local',
          1,
          'TP-Link',
          DeviceType.router,
          DeviceClassification.known,
          ports: [80, 443],
        ),
        device(
          'iot',
          'ESP32 sensor',
          'esp32.local',
          67,
          'Espressif',
          DeviceType.iot,
          DeviceClassification.guest,
        ),
        device(
          'unknown',
          null,
          null,
          83,
          null,
          DeviceType.unknown,
          DeviceClassification.unknown,
        ),
      ],
    );
  }
}
