import 'dart:async';
import 'package:flutter/widgets.dart';
import '../models/network_info.dart';
import '../services/local_network_permission_service.dart';
import '../services/network_info_service.dart';

/// Shared, session-only connection state; independent of mock device snapshots.
class CurrentNetworkController extends ChangeNotifier
    with WidgetsBindingObserver {
  CurrentNetworkController({required this.service, required this.permissions}) {
    WidgetsBinding.instance.addObserver(this);
  }

  final NetworkInfoService service;
  final LocalNetworkPermissionService permissions;
  NetworkInfo info = const NetworkInfo(id: 'loading');
  LocalNetworkPermissionStatus permission =
      LocalNetworkPermissionStatus.unavailable;
  bool isRefreshing = false;
  bool _disposed = false;
  int _generation = 0;

  Future<void>? _pendingRefresh;

  Future<void> refresh({bool silently = false}) => _pendingRefresh ??= _refresh(
    silently: silently,
  ).whenComplete(() => _pendingRefresh = null);

  Future<void> _refresh({required bool silently}) async {
    if (_disposed) return;
    final generation = ++_generation;
    isRefreshing = !silently;
    if (!silently) notifyListeners();
    NetworkInfo next;
    LocalNetworkPermissionStatus nextPermission;
    try {
      next = await service.getCurrentNetwork();
      nextPermission = await permissions.getStatus();
    } catch (_) {
      next = NetworkInfoService.unavailable(
        'Could not refresh the network. Please try again.',
      );
      nextPermission = LocalNetworkPermissionStatus.unavailable;
    }
    if (_disposed || generation != _generation) return;
    info = next;
    permission = nextPermission;
    isRefreshing = false;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
