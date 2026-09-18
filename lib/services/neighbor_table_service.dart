import 'dart:async';
import 'package:flutter/services.dart';
import '../models/mac_address.dart';
import '../models/network_info.dart';
import '../models/upnp_description.dart';
import 'network_discovery_service.dart';

class NeighborObservation {
  const NeighborObservation(this.ip, this.mac, this.source);
  final String ip;
  final MacAddress mac;
  final String source;
}

class NeighborTableService {
  const NeighborTableService({
    this.channel = const MethodChannel('whos_on_my_wifi/neighbors'),
  });
  final MethodChannel channel;
  static int _nextId = 0;
  static const timeout = Duration(milliseconds: 1500);

  Future<List<NeighborObservation>> read(
    NetworkInfo network,
    ScanCancellation token,
  ) async {
    if (token.isCancelled) return [];
    final id = ++_nextId;
    final stopped = Completer<void>();
    Future<void> stopNative() async {
      try {
        await channel.invokeMethod<void>('cancel', {'id': id});
      } on Exception {
        /* Platform absent or already disposed. */
      }
    }

    void cancel() {
      if (!stopped.isCompleted) stopped.complete();
      unawaited(stopNative());
    }

    token.addListener(cancel);
    try {
      final raw = await Future.any<Object?>([
        channel.invokeMethod<Object?>('read', {
          'id': id,
          'localIp': network.localIpAddress,
        }),
        stopped.future.then((_) => null),
      ]).timeout(timeout);
      return token.isCancelled ? [] : parse(raw, network);
    } on Exception {
      return [];
    } finally {
      token.removeListener(cancel);
      unawaited(stopNative());
    }
  }

  /// Parse only complete, unicast neighbors on the captured interface/subnet.
  /// Conflicting MACs for one IPv4 are discarded rather than guessed.
  static List<NeighborObservation> parse(Object? raw, NetworkInfo network) {
    if (raw is! Map ||
        raw['interface'] is! String ||
        raw['localIp'] != network.localIpAddress) {
      return [];
    }
    final interface = raw['interface'] as String;
    if (interface.isEmpty) return [];
    final policy = LocalDescriptionPolicy(network);
    final found = <String, NeighborObservation>{};
    final conflicts = <String>{};
    void add(String ip, String value, String source) {
      final mac = MacAddress.parse(value);
      if (mac == null || !policy.isLocal(ip) || conflicts.contains(ip)) return;
      if (found[ip] case final previous? when previous.mac.value != mac.value) {
        found.remove(ip);
        conflicts.add(ip);
        return;
      }
      found.putIfAbsent(ip, () => NeighborObservation(ip, mac, source));
    }

    Iterable<List<String>> rows(String key) {
      final text = raw[key];
      if (text is! String || text.length > 262144) return const [];
      return text
          .split('\n')
          .take(2048)
          .map((line) => line.trim().split(RegExp(r'\s+')));
    }

    for (final row in rows('arp')) {
      if (row.length != 6 ||
          row[5] != interface ||
          row[0] == network.localIpAddress) {
        continue;
      }
      final flags = int.tryParse(row[2].replaceFirst('0x', ''), radix: 16) ?? 0;
      if (row[1].toLowerCase() == '0x1' && flags & 2 != 0) {
        add(row[0], row[3], '/proc/net/arp');
      }
    }
    for (final row in rows('neighbors')) {
      final dev = row.indexOf('dev');
      final lladdr = row.indexOf('lladdr');
      if (dev < 0 ||
          dev + 1 >= row.length ||
          row[dev + 1] != interface ||
          lladdr < 0 ||
          lladdr + 1 >= row.length ||
          row[0] == network.localIpAddress ||
          !row.any(
            (v) => const [
              'REACHABLE',
              'STALE',
              'DELAY',
              'PROBE',
              'PERMANENT',
            ].contains(v),
          ) ||
          row.any((v) => const ['FAILED', 'INCOMPLETE', 'NOARP'].contains(v))) {
        continue;
      }
      add(row[0], row[lladdr + 1], 'Android neighbor table');
    }
    if (raw['localMac'] is String && network.localIpAddress != null) {
      add(
        network.localIpAddress!,
        raw['localMac'] as String,
        'NetworkInterface',
      );
    }
    return found.values.toList();
  }
}
