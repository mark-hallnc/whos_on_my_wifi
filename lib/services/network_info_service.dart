import 'package:flutter/services.dart';
import '../models/network_info.dart';
import '../utils/ipv4_subnet.dart';

/// Reads OS connection metadata only. This service never discovers devices.
class NetworkInfoService {
  const NetworkInfoService({
    this.channel = const MethodChannel('whos_on_my_wifi/network'),
  });
  final MethodChannel channel;

  Future<NetworkInfo> getCurrentNetwork() async {
    try {
      final data = await channel.invokeMapMethod<String, dynamic>(
        'getNetworkInfo',
      );
      if (data == null) return unavailable();
      return fromPlatform(data);
    } on MissingPluginException {
      return unavailable('Network information is available on Android.');
    } on PlatformException catch (error) {
      return unavailable(
        error.code == 'permission_denied'
            ? 'Android did not allow access to network information.'
            : 'Could not read the current network. Please refresh.',
      );
    }
  }

  static NetworkInfo unavailable([String? notice]) => NetworkInfo(
    id: 'unavailable',
    notice: notice ?? 'Network information is unavailable.',
  );

  static NetworkInfo fromPlatform(Map<String, dynamic> data) {
    final type = NetworkConnectionType.values.firstWhere(
      (type) => type.name == data['connectionType'],
      orElse: () => NetworkConnectionType.unknown,
    );
    final address = data['ipv4Address'] as String?;
    final prefix = data['ipv4PrefixLength'] as int?;
    Ipv4Subnet? subnet;
    if (address != null && prefix != null) {
      try {
        subnet = Ipv4Subnet(address, prefix);
      } on FormatException {
        // Keep other OS metadata if an address is incomplete or unavailable.
      } on ArgumentError {
        // Never silently substitute an assumed prefix.
      }
    }
    final rawSsid = (data['ssid'] as String?)?.trim();
    final ssid =
        rawSsid == null || rawSsid.isEmpty || rawSsid == '<unknown ssid>'
        ? null
        : rawSsid;
    final canBroadcast =
        type == NetworkConnectionType.wifi ||
        type == NetworkConnectionType.ethernet;
    return NetworkInfo(
      id: data['networkId'] as String? ?? 'unavailable',
      name: ssid,
      connectionType: type,
      isWifiConnected: data['isWifiConnected'] == true,
      localIpAddress: address,
      ipv4PrefixLength: subnet?.prefixLength,
      subnetMask: subnet?.subnetMask,
      networkAddress: subnet?.networkAddress,
      subnet: subnet?.cidr,
      broadcastAddress: canBroadcast ? subnet?.broadcastAddress : null,
      gatewayAddress: data['gateway'] as String?,
      dnsServers: List<String>.unmodifiable(
        (data['dnsServers'] as List? ?? []).cast<String>(),
      ),
      ipv6Addresses: List<NetworkAddress>.unmodifiable(
        (data['ipv6Addresses'] as List? ?? []).map(
          (value) => NetworkAddress(
            address: value['address'] as String,
            prefixLength: value['prefixLength'] as int,
          ),
        ),
      ),
      interfaceName: data['interfaceName'] as String?,
      internetValidated: data['internetValidated'] == true,
      notice: data['notice'] as String?,
    );
  }
}
