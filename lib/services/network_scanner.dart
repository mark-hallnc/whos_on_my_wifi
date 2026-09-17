import 'dart:async';
import 'dart:io';
import 'dart:math';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../models/scan_result.dart';
import '../utils/ipv4_subnet.dart';
import 'network_discovery_service.dart';
import 'network_info_service.dart';
import 'local_service_discovery_service.dart';
import 'service_device_merger.dart';

typedef HostProbe = Future<List<String>> Function(String address);

class NetworkScanner implements NetworkDiscoveryService {
  NetworkScanner({
    this.networkInfoService = const NetworkInfoService(),
    this.probe,
    LocalServiceDiscovery? serviceDiscovery,
  }) : serviceDiscovery = serviceDiscovery ?? AndroidNsdDiscoveryService();

  static const concurrency = 40;
  static const maxCandidates = 1024;
  static const tcpTimeout = Duration(milliseconds: 250);
  static const tcpPorts = [80, 443, 22, 445];
  final NetworkInfoService networkInfoService;
  final HostProbe? probe;
  final LocalServiceDiscovery serviceDiscovery;
  Future<ScanResult>? _active;

  /// Compare OS identity, not the display name/SSID (which can be unavailable).
  static String? networkChangeReason(NetworkInfo initial, NetworkInfo current) {
    if ((current.connectionType != NetworkConnectionType.wifi &&
            current.connectionType != NetworkConnectionType.ethernet) ||
        current.localIpAddress == null ||
        current.ipv4PrefixLength == null) {
      return 'Network connection lost. Scan stopped.';
    }
    if (initial.id != current.id ||
        initial.connectionType != current.connectionType ||
        initial.localIpAddress != current.localIpAddress ||
        initial.ipv4PrefixLength != current.ipv4PrefixLength ||
        initial.networkAddress != current.networkAddress ||
        initial.gatewayAddress != current.gatewayAddress) {
      return 'Network changed. Scan stopped.';
    }
    return null;
  }

  /// Sequential ports keep the socket count bounded by the worker count.
  /// Only successful connections count; timeouts and OS errors do not.
  static Future<List<String>> probeTcp(
    String address, {
    ScanCancellation? cancellation,
  }) async {
    for (final port in tcpPorts) {
      if (cancellation?.isCancelled ?? false) return [];
      try {
        final socket = await Socket.connect(
          InternetAddress(address),
          port,
          timeout: tcpTimeout,
        );
        socket.destroy();
        return ['TCP connection succeeded on port $port'];
      } on SocketException catch (error) {
        // Access denied is a scan failure, not an unresponsive host.
        if (error.osError?.errorCode == 13 || error.osError?.errorCode == 1) {
          rethrow;
        }
        // Closed, filtered and unreachable targets are not evidence.
      }
    }
    return [];
  }

  @override
  Future<ScanResult> discover({
    NetworkInfo? network,
    ScanCancellation? cancellation,
    VerifyScanNetwork? verifyNetwork,
    void Function(ScanResult)? onProgress,
  }) {
    // Keep the lock until all existing workers have drained, even on cancel.
    if (_active != null) return _active!;
    final completion = Completer<ScanResult>();
    _active = completion.future;
    final token = cancellation ?? ScanCancellation();
    unawaited(() async {
      try {
        completion.complete(
          await _discover(
            network: network,
            cancellation: token,
            verifyNetwork: verifyNetwork,
            onProgress: onProgress,
          ),
        );
      } catch (error, stack) {
        completion.completeError(error, stack);
      } finally {
        _active = null;
      }
    }());
    return completion.future;
  }

  Future<ScanResult> _discover({
    NetworkInfo? network,
    required ScanCancellation cancellation,
    VerifyScanNetwork? verifyNetwork,
    void Function(ScanResult)? onProgress,
  }) async {
    final started = DateTime.now();
    var info = network ?? const NetworkInfo(id: 'unavailable');
    final devices = <String, NetworkDevice>{};
    var total = 0;
    var checked = 0;
    final serviceLimitations = <String>[];
    var servicesStarted = false;
    ScanResult snapshot(ScanState state, [String? message]) => ScanResult(
      network: info,
      devices: devices.values.toList(),
      startedAt: started,
      completedAt: state == ScanState.completed ? DateTime.now() : null,
      state: state,
      totalCandidates: total,
      addressesChecked: checked,
      message: message,
      discoveryMethods: [
        'Local network metadata',
        'TCP connection',
        if (servicesStarted) 'mDNS / Android NSD',
      ],
      limitations: [
        ...serviceLimitations,
        'Devices with no TCP response or resolved service advertisement may be missed.',
        'The gateway is included from network metadata, not proof of a probe response.',
      ],
    );
    void publishCancellation() =>
        onProgress?.call(snapshot(ScanState.cancelled, cancellation.reason));
    cancellation.addListener(publishCancellation);
    ScanResult cancelled() =>
        snapshot(ScanState.cancelled, cancellation.reason);

    // Coalesce concurrent workers' OS reads. Checks happen before scheduling
    // and before accepting evidence, so a changed network's reply is discarded.
    Future<void>? checking;
    Future<void> verify() {
      if (cancellation.isCancelled || verifyNetwork == null) {
        return Future.value();
      }
      return checking ??= () async {
        try {
          final reason = await verifyNetwork(info);
          if (reason != null) cancellation.cancel(reason);
        } catch (_) {
          cancellation.cancel('Network access unavailable. Scan stopped.');
        } finally {
          checking = null;
        }
      }();
    }

    void add(
      String ip,
      List<String> evidence, {
      bool local = false,
      bool gateway = false,
    }) {
      final now = DateTime.now();
      devices[ip] = NetworkDevice(
        id: ip,
        ipAddress: ip,
        firstSeen: devices[ip]?.firstSeen ?? now,
        lastSeen: now,
        isOnline: true,
        isCurrentDevice: local,
        isGateway: gateway,
        discoveryEvidence: evidence,
      );
    }

    try {
      if (cancellation.isCancelled) return cancelled();
      info = network ?? await networkInfoService.getCurrentNetwork();
      if (cancellation.isCancelled) return cancelled();
      if ((info.connectionType != NetworkConnectionType.wifi &&
              info.connectionType != NetworkConnectionType.ethernet) ||
          info.localIpAddress == null ||
          info.ipv4PrefixLength == null) {
        final result = snapshot(
          ScanState.failed,
          'Connect to a Wi-Fi or Ethernet network with an IPv4 address to scan.',
        );
        onProgress?.call(result);
        return result;
      }
      final subnet = Ipv4Subnet(info.localIpAddress!, info.ipv4PrefixLength!);
      total = subnet.candidateCount;
      add(
        info.localIpAddress!,
        ['Current local IPv4 address'],
        local: true,
        gateway: info.gatewayAddress == info.localIpAddress,
      );
      final gateway = info.gatewayAddress;
      if (gateway != null &&
          gateway != info.localIpAddress &&
          InternetAddress.tryParse(gateway)?.type == InternetAddressType.IPv4) {
        add(gateway, ['Default gateway reported by Android'], gateway: true);
      }
      if (total > maxCandidates) {
        final result = snapshot(
          ScanState.subnetTooLarge,
          'This subnet has $total candidate addresses. Automatic scanning is limited to $maxCandidates addresses.',
        );
        onProgress?.call(result);
        return result;
      }
      await verify();
      if (cancellation.isCancelled) return cancelled();
      onProgress?.call(snapshot(ScanState.running));
      final candidates = subnet.candidates.iterator;
      var failed = false;
      Future<void> worker() async {
        try {
          while (!failed && !cancellation.isCancelled) {
            await verify();
            if (failed || cancellation.isCancelled || !candidates.moveNext()) {
              break;
            }
            final ip = candidates.current;
            final evidence = await (probe != null
                ? probe!(ip)
                : probeTcp(ip, cancellation: cancellation));
            await verify();
            if (failed || cancellation.isCancelled) break;
            if (evidence.isNotEmpty) {
              add(ip, [
                ...?devices[ip]?.discoveryEvidence,
                ...evidence,
              ], gateway: ip == gateway);
            }
            checked++;
            onProgress?.call(snapshot(ScanState.running));
          }
        } catch (error) {
          if (error is SocketException &&
              (error.osError?.errorCode == 13 ||
                  error.osError?.errorCode == 1)) {
            cancellation.cancel(
              'Local network permission unavailable. Scan stopped.',
            );
          }
          failed = true;
          rethrow;
        }
      }

      // Wait for all active workers before publishing the terminal state.
      await Future.wait(
        List.generate(min(concurrency, total), (_) => worker()),
      );
      if (cancellation.isCancelled) return cancelled();
      servicesStarted = true;
      onProgress?.call(
        snapshot(
          ScanState.discoveringServices,
          'Discovering local services...',
        ),
      );
      serviceLimitations.addAll(
        await serviceDiscovery.discover(
          network: info,
          cancellation: cancellation,
          verifyNetwork: verify,
          onService: (service) async {
            if (cancellation.isCancelled) return;
            ServiceDeviceMerger.merge(devices, service, info);
            onProgress?.call(
              snapshot(
                ScanState.discoveringServices,
                'Discovering local services...',
              ),
            );
          },
        ),
      );
      if (cancellation.isCancelled) return cancelled();
      final result = snapshot(ScanState.completed);
      onProgress?.call(result);
      return result;
    } catch (error) {
      if (error is SocketException &&
          (error.osError?.errorCode == 13 || error.osError?.errorCode == 1)) {
        cancellation.cancel(
          'Local network permission unavailable. Scan stopped.',
        );
      }
      if (cancellation.isCancelled) return cancelled();
      final result = snapshot(
        ScanState.failed,
        'Could not complete the scan. Check local network access and try again.',
      );
      onProgress?.call(result);
      return result;
    } finally {
      cancellation.removeListener(publishCancellation);
    }
  }
}
