import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import '../models/discovered_service.dart';
import '../models/mac_address.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../models/upnp_description.dart';
import '../utils/identity_text.dart';
import 'device_identification_service.dart';
import 'identity_datagrams.dart';
import 'llmnr_resolver.dart';
import 'nbns_discovery_service.dart';
import 'network_discovery_service.dart';
import 'ws_discovery_service.dart';

class IdentityObservation {
  const IdentityObservation(this.ip, this.service, this.evidence, {this.mac});
  final String ip;
  final DiscoveredService service;
  final String evidence;
  final MacAddress? mac;
  static void merge(
    Map<String, NetworkDevice> devices,
    IdentityObservation found,
    NetworkInfo network,
  ) {
    if (!LocalDescriptionPolicy(network).isLocal(found.ip)) return;
    final old = devices[found.ip];
    // Targeted name protocols enrich only previously confirmed addresses.
    if (old == null && found.service.discoveryMethod != 'WS-Discovery') return;
    final now = DateTime.now();
    var device =
        (old ??
                NetworkDevice(
                  id: found.ip,
                  ipAddress: found.ip,
                  firstSeen: now,
                  lastSeen: now,
                  isCurrentDevice: found.ip == network.localIpAddress,
                  isGateway: found.ip == network.gatewayAddress,
                ))
            .withPresentation(
              online: true,
              lastSeen: now,
              hostname: IdentityText.name(old?.hostname) == null
                  ? found.service.hostname
                  : null,
              services: {
                for (final s in old?.services ?? <DiscoveredService>[])
                  s.identity: s,
                found.service.identity: found.service,
              }.values.toList(),
              discoveryEvidence: {
                ...?old?.discoveryEvidence,
                found.evidence,
              }.toList(),
            );
    // NBSTAT unit IDs are reported evidence, weaker than a neighbor-table MAC.
    // Never replace a conflicting existing MAC or derive a vendor here.
    if (device.macAddress == null && found.mac != null) {
      device = device.withMac(found.mac!, 'NBNS node status (reported)', null);
    }
    devices[found.ip] = DeviceIdentificationService.identify(
      device,
      previous: old,
    );
  }
}

/// Android foreground discovery. Injection enables deterministic off-LAN tests;
/// unsupported desktop previews do not send multicast traffic by default.
class LocalIdentityDiscovery {
  LocalIdentityDiscovery({IdentityDatagrams? transport, bool? enabled})
    : transport = transport ?? const LocalIdentityDatagrams(),
      enabled = enabled ?? Platform.isAndroid;
  final IdentityDatagrams transport;
  final bool enabled;
  static const maxTargets = 16;
  static const maxLlmnrTargets = 12;
  static const concurrency = 8;
  static const enrichmentWindow = Duration(seconds: 1);
  final _random = Random.secure();
  int _id() => _random.nextInt(65536);
  String _uuid() {
    final b = List.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 15) | 64;
    b[8] = (b[8] & 63) | 128;
    final h = b.map((n) => n.toRadixString(16).padLeft(2, '0')).join();
    return 'urn:uuid:${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function() verifyNetwork,
    required void Function(IdentityObservation) onDevice,
  }) async {
    if (!enabled || cancellation.isCancelled) return [];
    final id = _uuid(), found = <String>{};
    Future<void> processing = Future.value();
    try {
      await transport.exchange(
        network: network,
        destination: WsDiscoveryService.multicast,
        port: WsDiscoveryService.port,
        request: utf8.encode(WsDiscoveryService.probe(id)),
        duration: WsDiscoveryService.duration,
        cancellation: cancellation,
        onPacket: (packet) {
          if (cancellation.isCancelled || found.length >= 64) return true;
          for (final result in WsDiscoveryService.parse(
            packet.data,
            packet.address,
            network,
            id,
          )) {
            if (found.length >= 64) break;
            final key = '${result.ip}|${result.endpoint}';
            if (!found.add(key)) continue;
            final observation = IdentityObservation(
              result.ip,
              DiscoveredService(
                name: 'Web Services device',
                type: 'ws-discovery',
                discoveryMethod: 'WS-Discovery',
                transport: 'UDP',
                host: result.ip,
                attributes: {
                  'endpoint': result.endpoint,
                  'types': result.types.join('\n'),
                  'scopes': result.scopes.join('\n'),
                  'XAddrs': result.xaddrs.join('\n'),
                },
              ),
              'Discovered via WS-Discovery',
            );
            processing = processing
                .then((_) async {
                  if (cancellation.isCancelled) return;
                  await verifyNetwork();
                  if (!cancellation.isCancelled) onDevice(observation);
                })
                .catchError((Object error) {
                  cancellation.cancel(
                    'Network access unavailable. Scan stopped.',
                  );
                });
          }
          // Bounded serialized delivery verifies the network and publishes early.
          return false;
        },
      );
      return [];
    } on SocketException catch (error) {
      return _error(error, cancellation);
    } on Exception {
      return ['Some local identity discovery was unavailable.'];
    } finally {
      await processing;
    }
  }

  List<String> _error(SocketException error, ScanCancellation token) {
    if (error.osError?.errorCode == 1 || error.osError?.errorCode == 13) {
      token.cancel('Local network permission unavailable. Scan stopped.');
    }
    return ['Some local identity discovery was unavailable.'];
  }

  Future<List<String>> enrich({
    required NetworkInfo network,
    required List<NetworkDevice> devices,
    required ScanCancellation cancellation,
    required Future<void> Function() verifyNetwork,
    required void Function(IdentityObservation) onDevice,
  }) async {
    if (!enabled || cancellation.isCancelled) return [];
    final targets =
        devices
            .where(
              (d) =>
                  d.isOnline &&
                  !d.isGateway &&
                  !d.isCurrentDevice &&
                  LocalDescriptionPolicy(network).isLocal(d.ipAddress) &&
                  (NbnsDiscoveryService.relevant(d) ||
                      (IdentityText.name(d.hostname) == null &&
                          IdentityText.name(d.discoveredName) == null)),
            )
            .toList()
          ..sort(
            (a, b) => (NbnsDiscoveryService.relevant(b) ? 1 : 0).compareTo(
              NbnsDiscoveryService.relevant(a) ? 1 : 0,
            ),
          );
    final work = ScanCancellation();
    void stop() => work.cancel(cancellation.reason);
    cancellation.addListener(stop);
    final timer = Timer(
      enrichmentWindow,
      () => work.cancel('Enrichment window ended.'),
    );
    var index = 0, llmnrCount = 0;
    final warnings = <String>{};
    Future<void> query(NetworkDevice d, bool nbns) async {
      final id = _id();
      IdentityObservation? result;
      try {
        await transport.exchange(
          network: network,
          destination: nbns ? d.ipAddress : LlmnrResolver.multicast,
          port: nbns ? NbnsDiscoveryService.port : LlmnrResolver.port,
          request: nbns
              ? NbnsDiscoveryService.query(id)
              : LlmnrResolver.query(d.ipAddress, id),
          duration: nbns ? NbnsDiscoveryService.timeout : LlmnrResolver.timeout,
          cancellation: work,
          hops: nbns ? 1 : 255,
          onPacket: (packet) {
            if (work.isCancelled) return true;
            if (packet.address != d.ipAddress ||
                packet.port != (nbns ? 137 : 5355)) {
              return false;
            }
            final node = nbns
                ? NbnsDiscoveryService.parse(packet.data, id)
                : null;
            final name = nbns
                ? node?.name
                : LlmnrResolver.parse(packet.data, d.ipAddress, id);
            if (name == null) return false;
            result = IdentityObservation(
              d.ipAddress,
              DiscoveredService(
                name: name,
                hostname: name,
                type: nbns ? 'nbns:node-status' : 'llmnr:ptr',
                discoveryMethod: nbns ? 'NBNS' : 'LLMNR',
                host: d.ipAddress,
                transport: 'UDP',
                attributes: {
                  if (node?.workgroup != null) 'workgroup': node!.workgroup!,
                  if (node?.mac != null) 'reportedMac': node!.mac!.value,
                },
              ),
              '${nbns ? 'NetBIOS name' : 'LLMNR hostname'}: $name',
              mac: node?.mac,
            );
            return true;
          },
        );
        if (work.isCancelled || cancellation.isCancelled) return;
        await verifyNetwork();
        if (!work.isCancelled && !cancellation.isCancelled && result != null) {
          onDevice(result!);
        }
      } on SocketException catch (error) {
        warnings.addAll(_error(error, cancellation));
      } on Exception {
        warnings.add('Some local names could not be read.');
      }
    }

    Future<void> worker() async {
      while (!work.isCancelled &&
          index < targets.length &&
          index < maxTargets) {
        final d = targets[index++];
        await verifyNetwork();
        if (work.isCancelled || cancellation.isCancelled) break;
        final nbns = NbnsDiscoveryService.relevant(d);
        final llmnr =
            IdentityText.name(d.hostname) == null &&
            IdentityText.name(d.discoveredName) == null &&
            llmnrCount < maxLlmnrTargets;
        if (llmnr) llmnrCount++;
        await Future.wait([
          if (nbns) query(d, true),
          if (llmnr) query(d, false),
        ]);
      }
    }

    try {
      await Future.wait(
        List.generate(min(concurrency, targets.length), (_) => worker()),
      );
    } finally {
      timer.cancel();
      cancellation.removeListener(stop);
      work.cancel();
    }
    return warnings.toList();
  }
}
