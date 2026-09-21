import 'dart:async';
import 'dart:io';

import 'network_discovery_service.dart';

typedef TcpAttempt =
    Future<void> Function(String address, int port, Duration timeout);

/// Reachability only: stop at the first response; never enumerate open ports.
class TcpHostProbe {
  static const primaryPorts = [80, 443, 22, 445];
  // Two targeted fallbacks for printers and Cast endpoints that filter tier 1.
  static const secondaryPorts = [631, 8009];
  static const primaryTimeout = Duration(milliseconds: 250);
  static const secondaryTimeout = Duration(milliseconds: 150);

  static bool isRefused(SocketException error, {String? operatingSystem}) {
    final os = operatingSystem ?? Platform.operatingSystem;
    final expected = switch (os) {
      'android' || 'linux' => 111,
      'macos' || 'ios' => 61,
      'windows' => 10061,
      _ => null,
    };
    // Never infer reachability from translated error messages or generic errors.
    return expected != null && error.osError?.errorCode == expected;
  }

  static Future<void> _connect(
    String address,
    int port,
    Duration timeout,
  ) async {
    final socket = await Socket.connect(
      InternetAddress(address),
      port,
      timeout: timeout,
    );
    socket.destroy();
  }

  static Future<List<String>> probe(
    String address, {
    ScanCancellation? cancellation,
    bool Function()? knownLive,
    TcpAttempt? attempt,
    String? operatingSystem,
  }) async {
    for (final tier in [primaryPorts, secondaryPorts]) {
      final timeout = identical(tier, primaryPorts)
          ? primaryTimeout
          : secondaryTimeout;
      for (final port in tier) {
        if ((cancellation?.isCancelled ?? false) ||
            (knownLive?.call() ?? false)) {
          return [];
        }
        try {
          await (attempt ?? _connect)(address, port, timeout);
          if (cancellation?.isCancelled ?? false) return [];
          return ['TCP connection succeeded on port $port'];
        } on SocketException catch (error) {
          if (cancellation?.isCancelled ?? false) return [];
          if (error.osError?.errorCode == 1 || error.osError?.errorCode == 13) {
            rethrow;
          }
          if (isRefused(error, operatingSystem: operatingSystem)) {
            return ['TCP connection refused on port $port (host responded)'];
          }
        } on TimeoutException {
          // Injected transports may use TimeoutException; neither timeout is evidence.
        }
      }
    }
    return [];
  }
}
