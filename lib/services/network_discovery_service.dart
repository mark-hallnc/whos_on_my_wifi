import '../models/scan_result.dart';
import '../models/network_info.dart';

/// Discovery publishes immutable progress snapshots and a final result.
/// A token belongs to one scan, including its permission/preparation phase.
class ScanCancellation {
  String? _reason;
  final _listeners = <void Function()>{};
  bool get isCancelled => _reason != null;
  String get reason => _reason ?? 'Scan cancelled.';

  void cancel([String reason = 'Scan cancelled.']) {
    if (isCancelled) return;
    _reason = reason;
    for (final listener in _listeners.toList()) {
      listener();
    }
  }

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);
}

/// Returns a friendly cancellation reason, or null if it is safe to continue.
typedef VerifyScanNetwork = Future<String?> Function(NetworkInfo initial);

abstract interface class NetworkDiscoveryService {
  Future<ScanResult> discover({
    NetworkInfo? network,
    ScanCancellation? cancellation,
    VerifyScanNetwork? verifyNetwork,
    void Function(ScanResult)? onProgress,
  });
}
