import 'dart:convert';
import 'package:drift/drift.dart';
import '../data/database/app_database.dart' show AppDatabase;
import '../data/device_record_codec.dart';
import '../models/discovered_service.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../models/saved_network.dart';
import '../models/scan_result.dart';
import '../models/scan_reconciliation.dart';
import '../services/device_identity_service.dart';
import '../services/device_identification_service.dart';
import 'local_device_store.dart';

class PersistentDeviceRepository extends LocalDeviceStore {
  PersistentDeviceRepository(this.database);
  final AppDatabase database;
  final _online = <int, Set<int>>{};
  final _new = <int, Set<int>>{};
  bool _closed = false;

  Future<List<Map<String, dynamic>>> _rows(
    String sql, [
    List<Object> args = const [],
  ]) async =>
      (await database
              .customSelect(
                sql,
                variables: args
                    .map(
                      (v) => switch (v) {
                        int() => Variable<int>(v),
                        String() => Variable<String>(v),
                        _ => throw ArgumentError('Unsupported query argument'),
                      },
                    )
                    .toList(),
              )
              .get())
          .map((r) => r.data)
          .toList();
  Future<int> _insert(String table, Map<String, Object?> fields) async {
    await database.customStatement(
      'INSERT INTO $table (${fields.keys.join(',')}) VALUES (${List.filled(fields.length, '?').join(',')})',
      fields.values.toList(),
    );
    return (await _rows('SELECT last_insert_rowid() AS id')).single['id']
        as int;
  }

  Future<void> _update(
    String table,
    int id,
    Map<String, Object?> fields,
  ) => database.customStatement(
    'UPDATE $table SET ${fields.keys.map((k) => '$k = ?').join(',')} WHERE id = ?',
    [...fields.values, id],
  );
  static int _time(DateTime date) => date.toUtc().millisecondsSinceEpoch;
  static int _id(String id) => int.parse(id.replaceFirst('device:', ''));

  @override
  Future<ScanResult> loadSnapshot() async => ScanResult(
    network: const NetworkInfo(id: 'not-scanned'),
    devices: [],
  );

  Future<int?> _networkId(NetworkInfo network) async {
    final key = DeviceIdentityService.networkKey(network);
    if (key == null) return null;
    final rows = await _rows(
      'SELECT id FROM saved_networks WHERE stable_key = ?',
      [key],
    );
    return rows.firstOrNull?['id'] as int?;
  }

  @override
  Future<ScanResult> loadCurrentNetworkSnapshot(NetworkInfo network) async {
    final id = await _networkId(network);
    return ScanResult(
      network: network,
      devices: id == null ? [] : await _devices(id, live: true),
    );
  }

  @override
  Future<List<SavedNetwork>> getSavedNetworks() async =>
      (await _rows('''
    SELECT n.*, (SELECT COUNT(*) FROM stored_devices d WHERE d.network_id=n.id) AS device_count
    FROM saved_networks n ORDER BY MAX(COALESCE(last_scanned,0),last_seen) DESC, id DESC
  '''))
          .map(
            (r) => SavedNetwork(
              id: r['id'] as int,
              key: r['stable_key'] as String,
              network: NetworkInfo(
                id: 'saved:${r['id']}',
                name: (r['user_name'] ?? r['name']) as String?,
                networkAddress: r['network_address'] as String,
                ipv4PrefixLength: r['prefix_length'] as int,
                subnet: '${r['network_address']}/${r['prefix_length']}',
                gatewayAddress: r['gateway_address'] as String?,
                connectionType: enumValue(
                  NetworkConnectionType.values,
                  r['connection_type'],
                  NetworkConnectionType.unknown,
                ),
              ),
              firstSeen: DateTime.fromMillisecondsSinceEpoch(
                r['first_seen'] as int,
                isUtc: true,
              ),
              lastSeen: DateTime.fromMillisecondsSinceEpoch(
                r['last_seen'] as int,
                isUtc: true,
              ),
              lastScanned: r['last_scanned'] == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(
                      r['last_scanned'] as int,
                      isUtc: true,
                    ),
              deviceCount: r['device_count'] as int,
              scanCount: r['scan_count'] as int,
            ),
          )
          .toList();

  Future<List<NetworkDevice>> _devices(
    int networkId, {
    bool live = false,
  }) async {
    final rows = await _rows(
      'SELECT * FROM stored_devices WHERE network_id = ? ORDER BY id',
      [networkId],
    );
    final ips = await _rows(
      'SELECT h.* FROM device_ip_history h JOIN stored_devices d ON d.id=h.device_id WHERE d.network_id = ? ORDER BY h.last_seen DESC',
      [networkId],
    );
    final services = await _rows(
      'SELECT s.* FROM device_services s JOIN stored_devices d ON d.id=s.device_id WHERE d.network_id = ? ORDER BY s.id',
      [networkId],
    );
    final serviceMap = <int, List<DiscoveredService>>{};
    for (final r in services) {
      final extra = DeviceRecordCodec.decode(r['details_json'] as String);
      (serviceMap[r['device_id'] as int] ??= []).add(
        DiscoveredService(
          name: r['service_name'] as String,
          type: r['service_type'] as String,
          discoveryMethod: r['discovery_method'] as String,
          host: r['host'] as String?,
          port: r['port'] as int?,
          transport: r['transport'] as String,
          hostname: extra['hostname'] as String?,
          addresses: DeviceRecordCodec.list(extra['addresses']),
          attributes: DeviceRecordCodec.strings(extra['attributes']),
        ),
      );
    }
    final ipMap = <int, List<String>>{};
    for (final r in ips) {
      (ipMap[r['device_id'] as int] ??= []).add(r['ip_address'] as String);
    }
    return rows.map((r) {
      final id = r['id'] as int;
      return DeviceIdentificationService.identify(
        DeviceRecordCodec.device(
          r,
          serviceMap[id] ?? [],
          (ipMap[id] ?? []).where((ip) => ip != r['ip_address']).toList(),
          online: live && (_online[networkId]?.contains(id) ?? false),
          isNew: live && (_new[networkId]?.contains(id) ?? false),
        ),
      );
    }).toList();
  }

  @override
  Future<List<NetworkDevice>> getDevicesForNetwork(int networkId) =>
      _devices(networkId);
  @override
  Future<NetworkDevice?> getDevice(String id) async {
    final rows = await _rows(
      'SELECT network_id FROM stored_devices WHERE id = ?',
      [_id(id)],
    );
    if (rows.isEmpty) return null;
    return (await _devices(
      rows.single['network_id'] as int,
      live: true,
    )).where((d) => d.id == id).firstOrNull;
  }

  @override
  Future<List<DeviceIpVisit>> getDeviceHistory(String id) async =>
      (await _rows(
            'SELECT * FROM device_ip_history WHERE device_id = ? ORDER BY last_seen DESC',
            [_id(id)],
          ))
          .map(
            (r) => DeviceIpVisit(
              r['ip_address'] as String,
              DateTime.fromMillisecondsSinceEpoch(
                r['first_seen'] as int,
                isUtc: true,
              ),
              DateTime.fromMillisecondsSinceEpoch(
                r['last_seen'] as int,
                isUtc: true,
              ),
            ),
          )
          .toList();

  @override
  Future<void> updateDevice(
    String id, {
    required String? customName,
    required DeviceClassification classification,
    required String notes,
  }) async {
    final name = customName?.trim();
    if ((name?.length ?? 0) > 120 || notes.length > 4000) {
      throw ArgumentError('Text too long');
    }
    await _update('stored_devices', _id(id), {
      'custom_name': name == null || name.isEmpty ? null : name,
      'classification': classification.name,
      'notes': notes,
    });
    if (!_closed) notifyListeners();
  }

  @override
  Future<ScanResult> saveScan(ScanResult result) async {
    final key = DeviceIdentityService.networkKey(result.network);
    final terminal = [
      ScanState.completed,
      ScanState.cancelled,
      ScanState.failed,
      ScanState.subnetTooLarge,
    ];
    if (key == null ||
        result.isMock ||
        !terminal.contains(result.state) ||
        result.startedAt == null) {
      return result;
    }
    var networkId = 0;
    var duplicate = false;
    var baseline = false;
    final seen = <int>{};
    final inserted = <int>{};
    final matched = <int>{};
    final offline = <int>{};
    final external = <int>{};
    await database.transaction(() async {
      final now = _time(result.completedAt ?? DateTime.now());
      final start = _time(result.startedAt!);
      final network = result.network;
      final existing = await _rows(
        'SELECT * FROM saved_networks WHERE stable_key = ?',
        [key],
      );
      if (existing.isEmpty) {
        final parts = jsonDecode(key) as List;
        networkId = await _insert('saved_networks', {
          'stable_key': key,
          'name': network.name,
          'network_address': parts[1],
          'prefix_length': network.ipv4PrefixLength,
          'gateway_address': network.gatewayAddress,
          'interface_name': network.interfaceName,
          'connection_type': network.connectionType.name,
          'first_seen': start,
          'last_seen': now,
        });
      } else {
        networkId = existing.single['id'] as int;
      }
      if ((await _rows(
        'SELECT id FROM network_scans WHERE network_id = ? AND started_at = ?',
        [networkId, start],
      )).isNotEmpty) {
        duplicate = true;
        return;
      }
      // last_scanned survives scan-history pruning and is set only on success.
      baseline =
          result.state == ScanState.completed &&
          (existing.isEmpty || existing.single['last_scanned'] == null);
      await database.customStatement(
        '''UPDATE saved_networks SET last_seen=MAX(last_seen,?),
        first_seen=MIN(first_seen,?), scan_count=scan_count+1,
        last_scanned=CASE WHEN ? THEN MAX(COALESCE(last_scanned,0),?) ELSE last_scanned END WHERE id=?''',
        [
          now,
          start,
          result.state == ScanState.completed ? 1 : 0,
          now,
          networkId,
        ],
      );
      final known = await _devices(networkId);
      final aliases = <String, int>{
        for (final r in await _rows(
          'SELECT identity_key,device_id FROM device_identities WHERE network_id=?',
          [networkId],
        ))
          r['identity_key'] as String: r['device_id'] as int,
      };
      final observedIps = <String>{};
      for (final fresh in result.devices) {
        if (!observedIps.add(fresh.ipAddress)) continue;
        final keys = DeviceIdentityService.strongKeys(fresh);
        final hits = keys.map((k) => aliases[k]).nonNulls.toSet();
        if (hits.length > 1) {
          continue; // Do not merge two established identities by guesswork.
        }
        NetworkDevice? old;
        if (hits.length == 1) {
          final candidate = known
              .where((d) => _id(d.id) == hits.single)
              .firstOrNull;
          if (candidate != null &&
              !DeviceIdentityService.conflicts(candidate, fresh)) {
            old = candidate;
          }
        }
        if (hits.isEmpty) {
          final candidates = known
              .where(
                (d) =>
                    !seen.contains(_id(d.id)) &&
                    DeviceIdentityService.fallbackMatch(d, fresh),
              )
              .toList();
          if (candidates.length == 1) old = candidates.single;
        }
        // Conflicting/ambiguous strong IDs are not allowed to steal an identity.
        final available = keys
            .where(
              (k) =>
                  aliases[k] == null ||
                  (old != null && aliases[k] == _id(old.id)),
            )
            .toList();
        final oldKeys = old == null
            ? <String>[]
            : DeviceIdentityService.strongKeys(old);
        final strongest = [...oldKeys, ...available]
          ..sort((a, b) => _rank(a).compareTo(_rank(b)));
        final fallback = 'observation:$start:${fresh.ipAddress}';
        final identity =
            strongest.firstOrNull ??
            (old == null
                ? fallback
                : (await _rows(
                        'SELECT identity_key FROM stored_devices WHERE id=?',
                        [_id(old.id)],
                      )).single['identity_key']
                      as String);
        final identified = DeviceIdentificationService.identify(
          fresh,
          previous: old,
        );
        final fields = <String, Object?>{
          'identity_key': identity,
          'ip_address': fresh.ipAddress,
          'mac_address': fresh.macAddress ?? old?.macAddress,
          'private_mac':
              (fresh.macAddress == null
                  ? old?.isPrivateMac ?? false
                  : fresh.isPrivateMac)
              ? 1
              : 0,
          'hostname': identified.hostname,
          'discovered_name': identified.discoveredName,
          'manufacturer': identified.reportedManufacturer,
          'mac_vendor': identified.macVendor,
          'model_name': identified.modelName,
          'model_number': identified.modelNumber,
          'model_description': identified.modelDescription,
          'device_type': identified.type.name,
          'confidence': identified.confidence.name,
          'is_gateway': fresh.isGateway ? 1 : 0,
          'is_current_device': fresh.isCurrentDevice ? 1 : 0,
          'first_seen': old != null && old.firstSeen.isBefore(fresh.firstSeen)
              ? _time(old.firstSeen)
              : _time(fresh.firstSeen),
          'last_seen': old != null && old.lastSeen.isAfter(fresh.lastSeen)
              ? _time(old.lastSeen)
              : _time(fresh.lastSeen),
          'online': 1,
          'details_json': DeviceRecordCodec.details(identified),
        };
        final int id;
        if (old == null) {
          id = await _insert('stored_devices', {
            'network_id': networkId,
            ...fields,
          });
          inserted.add(id);
        } else {
          id = _id(old.id);
          if (!inserted.contains(id)) matched.add(id);
          await _update('stored_devices', id, fields);
        }
        if (!fresh.isCurrentDevice) {
          external.add(id);
        } else {
          external.remove(id);
        }
        seen.add(id);
        for (final alias in available) {
          await database.customStatement(
            'INSERT OR IGNORE INTO device_identities(network_id,identity_key,device_id) VALUES(?,?,?)',
            [networkId, alias, id],
          );
          aliases[alias] = id;
        }
        await database.customStatement(
          '''INSERT INTO device_ip_history(device_id,ip_address,first_seen,last_seen) VALUES(?,?,?,?)
          ON CONFLICT(device_id,ip_address) DO UPDATE SET first_seen=MIN(first_seen,excluded.first_seen),last_seen=MAX(last_seen,excluded.last_seen)''',
          [id, fresh.ipAddress, _time(fresh.firstSeen), _time(fresh.lastSeen)],
        );
        for (final service in fresh.services) {
          final serviceKey = jsonEncode([
            service.type.toLowerCase(),
            service.name.toLowerCase(),
            service.port,
            service.transport,
            service.discoveryMethod,
          ]);
          await database.customStatement(
            '''INSERT INTO device_services(device_id,service_key,service_type,service_name,
            discovery_method,host,port,transport,first_seen,last_seen,details_json) VALUES(?,?,?,?,?,?,?,?,?,?,?)
            ON CONFLICT(device_id,service_key) DO UPDATE SET host=excluded.host,
            first_seen=MIN(first_seen,excluded.first_seen),last_seen=MAX(last_seen,excluded.last_seen),details_json=excluded.details_json''',
            [
              id,
              serviceKey,
              service.type,
              service.name,
              service.discoveryMethod,
              service.host,
              service.port,
              service.transport,
              _time(fresh.firstSeen),
              _time(fresh.lastSeen),
              DeviceRecordCodec.serviceDetails(service),
            ],
          );
        }
        // Allow repeated strong sightings in this transaction to share the record.
        known.removeWhere((d) => _id(d.id) == id);
        known.add(
          DeviceRecordCodec.device(
            {
              ...fields,
              'id': id,
              'custom_name': old?.customName,
              'classification': old?.classification.name ?? 'unknown',
              'notes': old?.notes ?? '',
            },
            [...?old?.services, ...fresh.services],
            old?.previousIpAddresses ?? [],
          ),
        );
      }
      if (result.state == ScanState.completed) {
        final previouslyOnline = await _rows(
          'SELECT id FROM stored_devices WHERE network_id=? AND online=1',
          [networkId],
        );
        offline.addAll(
          previouslyOnline
              .map((r) => r['id'] as int)
              .where((id) => !seen.contains(id)),
        );
        await database.customStatement(
          'UPDATE stored_devices SET online=0 WHERE network_id=?${seen.isEmpty ? '' : ' AND id NOT IN (${List.filled(seen.length, '?').join(',')})'}',
          [networkId, ...seen],
        );
      }
      await _insert('network_scans', {
        'network_id': networkId,
        'started_at': start,
        'completed_at': result.completedAt == null
            ? null
            : _time(result.completedAt!),
        'status': result.state.name,
        'devices_found': result.devicesFound,
        'addresses_checked': result.addressesChecked,
        'total_candidates': result.totalCandidates,
        'discovery_methods': jsonEncode(
          result.discoveryMethods.take(16).toList(),
        ),
        'message': result.message?.substring(
          0,
          result.message!.length.clamp(0, 512),
        ),
      });
      await database.customStatement(
        'DELETE FROM network_scans WHERE network_id=? AND id NOT IN (SELECT id FROM network_scans WHERE network_id=? ORDER BY started_at DESC,id DESC LIMIT 100)',
        [networkId, networkId],
      );
    });
    final newIds =
        result.state == ScanState.completed && !baseline && !duplicate
        ? inserted.intersection(external)
        : <int>{};
    if (!duplicate) {
      if (result.state == ScanState.completed) {
        _online[networkId] = seen;
        _new[networkId] = newIds;
      } else {
        (_online[networkId] ??= {}).addAll(seen);
        _new.remove(networkId);
      }
    }
    final devices = await _devices(networkId, live: true);
    if (!_closed) notifyListeners();
    return ScanResult(
      network: result.network,
      devices: devices,
      startedAt: result.startedAt,
      completedAt: result.completedAt,
      state: result.state,
      totalCandidates: result.totalCandidates,
      addressesChecked: result.addressesChecked,
      message: result.message,
      discoveryMethods: result.discoveryMethods,
      limitations: result.limitations,
      foundCount: result.devicesFound,
      reconciliation: ScanReconciliation(
        networkId: networkId,
        scanKey: '$networkId:${_time(result.startedAt!)}',
        isBaseline: baseline,
        isSuccessful: result.state == ScanState.completed,
        isDuplicate: duplicate,
        insertedDeviceIds: {for (final id in inserted) 'device:$id'},
        matchedDeviceIds: {for (final id in matched) 'device:$id'},
        updatedDeviceIds: {for (final id in matched) 'device:$id'},
        offlineDeviceIds: {for (final id in offline) 'device:$id'},
        newDeviceIds: {for (final id in newIds) 'device:$id'},
      ),
    );
  }

  static int _rank(String key) => key.startsWith('mac:')
      ? 0
      : key.startsWith('udn:')
      ? 1
      : 2;

  @override
  void clearPresence() {
    _online.clear();
    _new.clear();
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    dispose();
    await database.close();
  }
}
