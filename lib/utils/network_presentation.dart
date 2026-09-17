import '../models/network_info.dart';
import '../services/local_network_permission_service.dart';

extension NetworkPresentation on NetworkInfo {
  String get title => switch (connectionType) {
    NetworkConnectionType.wifi => name ?? 'SSID unavailable',
    NetworkConnectionType.vpn => 'VPN connection',
    NetworkConnectionType.cellular => 'Cellular connection',
    NetworkConnectionType.ethernet => 'Ethernet connection',
    NetworkConnectionType.none => 'No network connection',
    NetworkConnectionType.other => 'Other connection',
    NetworkConnectionType.unknown => 'Network unavailable',
  };

  String get statusLabel => switch (connectionType) {
    NetworkConnectionType.wifi =>
      internetValidated
          ? 'Connected to Wi-Fi'
          : 'Wi-Fi • Internet not confirmed',
    NetworkConnectionType.vpn =>
      isWifiConnected
          ? 'VPN active over Wi-Fi'
          : 'VPN active • Wi-Fi status unavailable',
    NetworkConnectionType.ethernet => 'Connected by Ethernet',
    NetworkConnectionType.cellular ||
    NetworkConnectionType.none => 'Not connected to Wi-Fi',
    _ => 'Wi-Fi status unavailable',
  };
}

extension PermissionPresentation on LocalNetworkPermissionStatus {
  bool get allowsAccess =>
      this == LocalNetworkPermissionStatus.granted ||
      this == LocalNetworkPermissionStatus.notRequired;
  String get label => switch (this) {
    LocalNetworkPermissionStatus.notRequired =>
      'No runtime permission needed on this configuration.',
    LocalNetworkPermissionStatus.granted => 'Local network access is allowed.',
    LocalNetworkPermissionStatus.notRequested =>
      'Local network access has not been requested.',
    LocalNetworkPermissionStatus.denied =>
      'Local network access was denied. You can keep using the app and try again when ready.',
    LocalNetworkPermissionStatus.permanentlyDenied =>
      'Local network access is off. You can enable it in Android app settings.',
    LocalNetworkPermissionStatus.unavailable =>
      'Local network permission status is unavailable.',
  };
}
