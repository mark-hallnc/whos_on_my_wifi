import 'package:flutter/services.dart';

enum LocalNetworkPermissionStatus {
  notRequired,
  granted,
  notRequested,
  denied,
  permanentlyDenied,
  unavailable,
}

class LocalNetworkPermissionService {
  const LocalNetworkPermissionService({
    this.channel = const MethodChannel('whos_on_my_wifi/network'),
  });
  final MethodChannel channel;

  Future<LocalNetworkPermissionStatus> getStatus() =>
      _invoke('getLocalNetworkPermission');

  /// Call only after an in-app explanation and explicit user agreement.
  Future<LocalNetworkPermissionStatus> request() =>
      _invoke('requestLocalNetworkPermission');

  Future<LocalNetworkPermissionStatus> _invoke(String method) async {
    try {
      final value = await channel.invokeMethod<String>(method);
      return LocalNetworkPermissionStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => LocalNetworkPermissionStatus.unavailable,
      );
    } on MissingPluginException {
      return LocalNetworkPermissionStatus.unavailable;
    } on PlatformException {
      return LocalNetworkPermissionStatus.unavailable;
    }
  }

  Future<bool> openSettings() async {
    try {
      return await channel.invokeMethod<bool>('openAppSettings') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
