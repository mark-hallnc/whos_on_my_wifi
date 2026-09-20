import '../models/network_device.dart';
import 'neighbor_table_service.dart';
import 'vendor_lookup_service.dart';
import 'device_identification_service.dart';

class MacDeviceEnricher {
  static void merge(
    Map<String, NetworkDevice> devices,
    Iterable<NeighborObservation> observations,
    VendorLookupService vendors,
  ) {
    for (final observation in observations) {
      final old = devices[observation.ip];
      if (old == null) {
        continue; // A cached neighbor is not proof of online status.
      }
      devices[observation.ip] = DeviceIdentificationService.identify(
        old.withMac(
          observation.mac,
          observation.source,
          vendors.lookup(observation.mac.value),
        ),
      );
    }
  }
}
