import 'package:whos_on_my_wifi/models/network_info.dart';
import 'package:whos_on_my_wifi/models/upnp_description.dart';
import 'package:whos_on_my_wifi/services/network_discovery_service.dart';
import 'package:whos_on_my_wifi/services/ssdp_discovery_service.dart';

/// Other discovery-source tests must never send real SSDP traffic.
class NoSsdpDiscovery implements SsdpDiscovery {
  const NoSsdpDiscovery();
  @override
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function() verifyNetwork,
    required void Function(SsdpAdvertisement, UpnpDescription?, Uri?) onDevice,
  }) async => [];
}
