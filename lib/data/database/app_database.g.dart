// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class SavedNetworks extends Table with TableInfo<SavedNetworks, SavedNetwork> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SavedNetworks(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _stableKeyMeta = const VerificationMeta(
    'stableKey',
  );
  late final GeneratedColumn<String> stableKey = GeneratedColumn<String>(
    'stable_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _networkAddressMeta = const VerificationMeta(
    'networkAddress',
  );
  late final GeneratedColumn<String> networkAddress = GeneratedColumn<String>(
    'network_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _prefixLengthMeta = const VerificationMeta(
    'prefixLength',
  );
  late final GeneratedColumn<int> prefixLength = GeneratedColumn<int>(
    'prefix_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _gatewayAddressMeta = const VerificationMeta(
    'gatewayAddress',
  );
  late final GeneratedColumn<String> gatewayAddress = GeneratedColumn<String>(
    'gateway_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _interfaceNameMeta = const VerificationMeta(
    'interfaceName',
  );
  late final GeneratedColumn<String> interfaceName = GeneratedColumn<String>(
    'interface_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _connectionTypeMeta = const VerificationMeta(
    'connectionType',
  );
  late final GeneratedColumn<String> connectionType = GeneratedColumn<String>(
    'connection_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  late final GeneratedColumn<int> firstSeen = GeneratedColumn<int>(
    'first_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  late final GeneratedColumn<int> lastSeen = GeneratedColumn<int>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastScannedMeta = const VerificationMeta(
    'lastScanned',
  );
  late final GeneratedColumn<int> lastScanned = GeneratedColumn<int>(
    'last_scanned',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _scanCountMeta = const VerificationMeta(
    'scanCount',
  );
  late final GeneratedColumn<int> scanCount = GeneratedColumn<int>(
    'scan_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stableKey,
    name,
    userName,
    networkAddress,
    prefixLength,
    gatewayAddress,
    interfaceName,
    connectionType,
    firstSeen,
    lastSeen,
    lastScanned,
    scanCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_networks';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedNetwork> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stable_key')) {
      context.handle(
        _stableKeyMeta,
        stableKey.isAcceptableOrUnknown(data['stable_key']!, _stableKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_stableKeyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    if (data.containsKey('network_address')) {
      context.handle(
        _networkAddressMeta,
        networkAddress.isAcceptableOrUnknown(
          data['network_address']!,
          _networkAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_networkAddressMeta);
    }
    if (data.containsKey('prefix_length')) {
      context.handle(
        _prefixLengthMeta,
        prefixLength.isAcceptableOrUnknown(
          data['prefix_length']!,
          _prefixLengthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prefixLengthMeta);
    }
    if (data.containsKey('gateway_address')) {
      context.handle(
        _gatewayAddressMeta,
        gatewayAddress.isAcceptableOrUnknown(
          data['gateway_address']!,
          _gatewayAddressMeta,
        ),
      );
    }
    if (data.containsKey('interface_name')) {
      context.handle(
        _interfaceNameMeta,
        interfaceName.isAcceptableOrUnknown(
          data['interface_name']!,
          _interfaceNameMeta,
        ),
      );
    }
    if (data.containsKey('connection_type')) {
      context.handle(
        _connectionTypeMeta,
        connectionType.isAcceptableOrUnknown(
          data['connection_type']!,
          _connectionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionTypeMeta);
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_firstSeenMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    if (data.containsKey('last_scanned')) {
      context.handle(
        _lastScannedMeta,
        lastScanned.isAcceptableOrUnknown(
          data['last_scanned']!,
          _lastScannedMeta,
        ),
      );
    }
    if (data.containsKey('scan_count')) {
      context.handle(
        _scanCountMeta,
        scanCount.isAcceptableOrUnknown(data['scan_count']!, _scanCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedNetwork map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedNetwork(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stableKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      ),
      networkAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network_address'],
      )!,
      prefixLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prefix_length'],
      )!,
      gatewayAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gateway_address'],
      ),
      interfaceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interface_name'],
      ),
      connectionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_type'],
      )!,
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen'],
      )!,
      lastScanned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_scanned'],
      ),
      scanCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_count'],
      )!,
    );
  }

  @override
  SavedNetworks createAlias(String alias) {
    return SavedNetworks(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SavedNetwork extends DataClass implements Insertable<SavedNetwork> {
  final int id;
  final String stableKey;
  final String? name;
  final String? userName;
  final String networkAddress;
  final int prefixLength;
  final String? gatewayAddress;
  final String? interfaceName;
  final String connectionType;
  final int firstSeen;
  final int lastSeen;
  final int? lastScanned;
  final int scanCount;
  const SavedNetwork({
    required this.id,
    required this.stableKey,
    this.name,
    this.userName,
    required this.networkAddress,
    required this.prefixLength,
    this.gatewayAddress,
    this.interfaceName,
    required this.connectionType,
    required this.firstSeen,
    required this.lastSeen,
    this.lastScanned,
    required this.scanCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['stable_key'] = Variable<String>(stableKey);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    map['network_address'] = Variable<String>(networkAddress);
    map['prefix_length'] = Variable<int>(prefixLength);
    if (!nullToAbsent || gatewayAddress != null) {
      map['gateway_address'] = Variable<String>(gatewayAddress);
    }
    if (!nullToAbsent || interfaceName != null) {
      map['interface_name'] = Variable<String>(interfaceName);
    }
    map['connection_type'] = Variable<String>(connectionType);
    map['first_seen'] = Variable<int>(firstSeen);
    map['last_seen'] = Variable<int>(lastSeen);
    if (!nullToAbsent || lastScanned != null) {
      map['last_scanned'] = Variable<int>(lastScanned);
    }
    map['scan_count'] = Variable<int>(scanCount);
    return map;
  }

  SavedNetworksCompanion toCompanion(bool nullToAbsent) {
    return SavedNetworksCompanion(
      id: Value(id),
      stableKey: Value(stableKey),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
      networkAddress: Value(networkAddress),
      prefixLength: Value(prefixLength),
      gatewayAddress: gatewayAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(gatewayAddress),
      interfaceName: interfaceName == null && nullToAbsent
          ? const Value.absent()
          : Value(interfaceName),
      connectionType: Value(connectionType),
      firstSeen: Value(firstSeen),
      lastSeen: Value(lastSeen),
      lastScanned: lastScanned == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScanned),
      scanCount: Value(scanCount),
    );
  }

  factory SavedNetwork.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedNetwork(
      id: serializer.fromJson<int>(json['id']),
      stableKey: serializer.fromJson<String>(json['stable_key']),
      name: serializer.fromJson<String?>(json['name']),
      userName: serializer.fromJson<String?>(json['user_name']),
      networkAddress: serializer.fromJson<String>(json['network_address']),
      prefixLength: serializer.fromJson<int>(json['prefix_length']),
      gatewayAddress: serializer.fromJson<String?>(json['gateway_address']),
      interfaceName: serializer.fromJson<String?>(json['interface_name']),
      connectionType: serializer.fromJson<String>(json['connection_type']),
      firstSeen: serializer.fromJson<int>(json['first_seen']),
      lastSeen: serializer.fromJson<int>(json['last_seen']),
      lastScanned: serializer.fromJson<int?>(json['last_scanned']),
      scanCount: serializer.fromJson<int>(json['scan_count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stable_key': serializer.toJson<String>(stableKey),
      'name': serializer.toJson<String?>(name),
      'user_name': serializer.toJson<String?>(userName),
      'network_address': serializer.toJson<String>(networkAddress),
      'prefix_length': serializer.toJson<int>(prefixLength),
      'gateway_address': serializer.toJson<String?>(gatewayAddress),
      'interface_name': serializer.toJson<String?>(interfaceName),
      'connection_type': serializer.toJson<String>(connectionType),
      'first_seen': serializer.toJson<int>(firstSeen),
      'last_seen': serializer.toJson<int>(lastSeen),
      'last_scanned': serializer.toJson<int?>(lastScanned),
      'scan_count': serializer.toJson<int>(scanCount),
    };
  }

  SavedNetwork copyWith({
    int? id,
    String? stableKey,
    Value<String?> name = const Value.absent(),
    Value<String?> userName = const Value.absent(),
    String? networkAddress,
    int? prefixLength,
    Value<String?> gatewayAddress = const Value.absent(),
    Value<String?> interfaceName = const Value.absent(),
    String? connectionType,
    int? firstSeen,
    int? lastSeen,
    Value<int?> lastScanned = const Value.absent(),
    int? scanCount,
  }) => SavedNetwork(
    id: id ?? this.id,
    stableKey: stableKey ?? this.stableKey,
    name: name.present ? name.value : this.name,
    userName: userName.present ? userName.value : this.userName,
    networkAddress: networkAddress ?? this.networkAddress,
    prefixLength: prefixLength ?? this.prefixLength,
    gatewayAddress: gatewayAddress.present
        ? gatewayAddress.value
        : this.gatewayAddress,
    interfaceName: interfaceName.present
        ? interfaceName.value
        : this.interfaceName,
    connectionType: connectionType ?? this.connectionType,
    firstSeen: firstSeen ?? this.firstSeen,
    lastSeen: lastSeen ?? this.lastSeen,
    lastScanned: lastScanned.present ? lastScanned.value : this.lastScanned,
    scanCount: scanCount ?? this.scanCount,
  );
  SavedNetwork copyWithCompanion(SavedNetworksCompanion data) {
    return SavedNetwork(
      id: data.id.present ? data.id.value : this.id,
      stableKey: data.stableKey.present ? data.stableKey.value : this.stableKey,
      name: data.name.present ? data.name.value : this.name,
      userName: data.userName.present ? data.userName.value : this.userName,
      networkAddress: data.networkAddress.present
          ? data.networkAddress.value
          : this.networkAddress,
      prefixLength: data.prefixLength.present
          ? data.prefixLength.value
          : this.prefixLength,
      gatewayAddress: data.gatewayAddress.present
          ? data.gatewayAddress.value
          : this.gatewayAddress,
      interfaceName: data.interfaceName.present
          ? data.interfaceName.value
          : this.interfaceName,
      connectionType: data.connectionType.present
          ? data.connectionType.value
          : this.connectionType,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      lastScanned: data.lastScanned.present
          ? data.lastScanned.value
          : this.lastScanned,
      scanCount: data.scanCount.present ? data.scanCount.value : this.scanCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedNetwork(')
          ..write('id: $id, ')
          ..write('stableKey: $stableKey, ')
          ..write('name: $name, ')
          ..write('userName: $userName, ')
          ..write('networkAddress: $networkAddress, ')
          ..write('prefixLength: $prefixLength, ')
          ..write('gatewayAddress: $gatewayAddress, ')
          ..write('interfaceName: $interfaceName, ')
          ..write('connectionType: $connectionType, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('lastScanned: $lastScanned, ')
          ..write('scanCount: $scanCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stableKey,
    name,
    userName,
    networkAddress,
    prefixLength,
    gatewayAddress,
    interfaceName,
    connectionType,
    firstSeen,
    lastSeen,
    lastScanned,
    scanCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedNetwork &&
          other.id == this.id &&
          other.stableKey == this.stableKey &&
          other.name == this.name &&
          other.userName == this.userName &&
          other.networkAddress == this.networkAddress &&
          other.prefixLength == this.prefixLength &&
          other.gatewayAddress == this.gatewayAddress &&
          other.interfaceName == this.interfaceName &&
          other.connectionType == this.connectionType &&
          other.firstSeen == this.firstSeen &&
          other.lastSeen == this.lastSeen &&
          other.lastScanned == this.lastScanned &&
          other.scanCount == this.scanCount);
}

class SavedNetworksCompanion extends UpdateCompanion<SavedNetwork> {
  final Value<int> id;
  final Value<String> stableKey;
  final Value<String?> name;
  final Value<String?> userName;
  final Value<String> networkAddress;
  final Value<int> prefixLength;
  final Value<String?> gatewayAddress;
  final Value<String?> interfaceName;
  final Value<String> connectionType;
  final Value<int> firstSeen;
  final Value<int> lastSeen;
  final Value<int?> lastScanned;
  final Value<int> scanCount;
  const SavedNetworksCompanion({
    this.id = const Value.absent(),
    this.stableKey = const Value.absent(),
    this.name = const Value.absent(),
    this.userName = const Value.absent(),
    this.networkAddress = const Value.absent(),
    this.prefixLength = const Value.absent(),
    this.gatewayAddress = const Value.absent(),
    this.interfaceName = const Value.absent(),
    this.connectionType = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.lastScanned = const Value.absent(),
    this.scanCount = const Value.absent(),
  });
  SavedNetworksCompanion.insert({
    this.id = const Value.absent(),
    required String stableKey,
    this.name = const Value.absent(),
    this.userName = const Value.absent(),
    required String networkAddress,
    required int prefixLength,
    this.gatewayAddress = const Value.absent(),
    this.interfaceName = const Value.absent(),
    required String connectionType,
    required int firstSeen,
    required int lastSeen,
    this.lastScanned = const Value.absent(),
    this.scanCount = const Value.absent(),
  }) : stableKey = Value(stableKey),
       networkAddress = Value(networkAddress),
       prefixLength = Value(prefixLength),
       connectionType = Value(connectionType),
       firstSeen = Value(firstSeen),
       lastSeen = Value(lastSeen);
  static Insertable<SavedNetwork> custom({
    Expression<int>? id,
    Expression<String>? stableKey,
    Expression<String>? name,
    Expression<String>? userName,
    Expression<String>? networkAddress,
    Expression<int>? prefixLength,
    Expression<String>? gatewayAddress,
    Expression<String>? interfaceName,
    Expression<String>? connectionType,
    Expression<int>? firstSeen,
    Expression<int>? lastSeen,
    Expression<int>? lastScanned,
    Expression<int>? scanCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stableKey != null) 'stable_key': stableKey,
      if (name != null) 'name': name,
      if (userName != null) 'user_name': userName,
      if (networkAddress != null) 'network_address': networkAddress,
      if (prefixLength != null) 'prefix_length': prefixLength,
      if (gatewayAddress != null) 'gateway_address': gatewayAddress,
      if (interfaceName != null) 'interface_name': interfaceName,
      if (connectionType != null) 'connection_type': connectionType,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (lastScanned != null) 'last_scanned': lastScanned,
      if (scanCount != null) 'scan_count': scanCount,
    });
  }

  SavedNetworksCompanion copyWith({
    Value<int>? id,
    Value<String>? stableKey,
    Value<String?>? name,
    Value<String?>? userName,
    Value<String>? networkAddress,
    Value<int>? prefixLength,
    Value<String?>? gatewayAddress,
    Value<String?>? interfaceName,
    Value<String>? connectionType,
    Value<int>? firstSeen,
    Value<int>? lastSeen,
    Value<int?>? lastScanned,
    Value<int>? scanCount,
  }) {
    return SavedNetworksCompanion(
      id: id ?? this.id,
      stableKey: stableKey ?? this.stableKey,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      networkAddress: networkAddress ?? this.networkAddress,
      prefixLength: prefixLength ?? this.prefixLength,
      gatewayAddress: gatewayAddress ?? this.gatewayAddress,
      interfaceName: interfaceName ?? this.interfaceName,
      connectionType: connectionType ?? this.connectionType,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      lastScanned: lastScanned ?? this.lastScanned,
      scanCount: scanCount ?? this.scanCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stableKey.present) {
      map['stable_key'] = Variable<String>(stableKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (networkAddress.present) {
      map['network_address'] = Variable<String>(networkAddress.value);
    }
    if (prefixLength.present) {
      map['prefix_length'] = Variable<int>(prefixLength.value);
    }
    if (gatewayAddress.present) {
      map['gateway_address'] = Variable<String>(gatewayAddress.value);
    }
    if (interfaceName.present) {
      map['interface_name'] = Variable<String>(interfaceName.value);
    }
    if (connectionType.present) {
      map['connection_type'] = Variable<String>(connectionType.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<int>(firstSeen.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<int>(lastSeen.value);
    }
    if (lastScanned.present) {
      map['last_scanned'] = Variable<int>(lastScanned.value);
    }
    if (scanCount.present) {
      map['scan_count'] = Variable<int>(scanCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedNetworksCompanion(')
          ..write('id: $id, ')
          ..write('stableKey: $stableKey, ')
          ..write('name: $name, ')
          ..write('userName: $userName, ')
          ..write('networkAddress: $networkAddress, ')
          ..write('prefixLength: $prefixLength, ')
          ..write('gatewayAddress: $gatewayAddress, ')
          ..write('interfaceName: $interfaceName, ')
          ..write('connectionType: $connectionType, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('lastScanned: $lastScanned, ')
          ..write('scanCount: $scanCount')
          ..write(')'))
        .toString();
  }
}

class StoredDevices extends Table with TableInfo<StoredDevices, StoredDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  StoredDevices(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _networkIdMeta = const VerificationMeta(
    'networkId',
  );
  late final GeneratedColumn<int> networkId = GeneratedColumn<int>(
    'network_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES saved_networks(id)',
  );
  static const VerificationMeta _identityKeyMeta = const VerificationMeta(
    'identityKey',
  );
  late final GeneratedColumn<String> identityKey = GeneratedColumn<String>(
    'identity_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _classificationMeta = const VerificationMeta(
    'classification',
  );
  late final GeneratedColumn<String> classification = GeneratedColumn<String>(
    'classification',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'unknown\'',
    defaultValue: const CustomExpression('\'unknown\''),
  );
  static const VerificationMeta _ipAddressMeta = const VerificationMeta(
    'ipAddress',
  );
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
    'ip_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _macAddressMeta = const VerificationMeta(
    'macAddress',
  );
  late final GeneratedColumn<String> macAddress = GeneratedColumn<String>(
    'mac_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _privateMacMeta = const VerificationMeta(
    'privateMac',
  );
  late final GeneratedColumn<int> privateMac = GeneratedColumn<int>(
    'private_mac',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _discoveredNameMeta = const VerificationMeta(
    'discoveredName',
  );
  late final GeneratedColumn<String> discoveredName = GeneratedColumn<String>(
    'discovered_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _hostnameMeta = const VerificationMeta(
    'hostname',
  );
  late final GeneratedColumn<String> hostname = GeneratedColumn<String>(
    'hostname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _macVendorMeta = const VerificationMeta(
    'macVendor',
  );
  late final GeneratedColumn<String> macVendor = GeneratedColumn<String>(
    'mac_vendor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _modelNumberMeta = const VerificationMeta(
    'modelNumber',
  );
  late final GeneratedColumn<String> modelNumber = GeneratedColumn<String>(
    'model_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _modelDescriptionMeta = const VerificationMeta(
    'modelDescription',
  );
  late final GeneratedColumn<String> modelDescription = GeneratedColumn<String>(
    'model_description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _deviceTypeMeta = const VerificationMeta(
    'deviceType',
  );
  late final GeneratedColumn<String> deviceType = GeneratedColumn<String>(
    'device_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isGatewayMeta = const VerificationMeta(
    'isGateway',
  );
  late final GeneratedColumn<int> isGateway = GeneratedColumn<int>(
    'is_gateway',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isCurrentDeviceMeta = const VerificationMeta(
    'isCurrentDevice',
  );
  late final GeneratedColumn<int> isCurrentDevice = GeneratedColumn<int>(
    'is_current_device',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  late final GeneratedColumn<int> firstSeen = GeneratedColumn<int>(
    'first_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  late final GeneratedColumn<int> lastSeen = GeneratedColumn<int>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _onlineMeta = const VerificationMeta('online');
  late final GeneratedColumn<int> online = GeneratedColumn<int>(
    'online',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    networkId,
    identityKey,
    customName,
    notes,
    classification,
    ipAddress,
    macAddress,
    privateMac,
    discoveredName,
    hostname,
    manufacturer,
    macVendor,
    modelName,
    modelNumber,
    modelDescription,
    deviceType,
    confidence,
    isGateway,
    isCurrentDevice,
    firstSeen,
    lastSeen,
    online,
    detailsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('network_id')) {
      context.handle(
        _networkIdMeta,
        networkId.isAcceptableOrUnknown(data['network_id']!, _networkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_networkIdMeta);
    }
    if (data.containsKey('identity_key')) {
      context.handle(
        _identityKeyMeta,
        identityKey.isAcceptableOrUnknown(
          data['identity_key']!,
          _identityKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_identityKeyMeta);
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('classification')) {
      context.handle(
        _classificationMeta,
        classification.isAcceptableOrUnknown(
          data['classification']!,
          _classificationMeta,
        ),
      );
    }
    if (data.containsKey('ip_address')) {
      context.handle(
        _ipAddressMeta,
        ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta),
      );
    } else if (isInserting) {
      context.missing(_ipAddressMeta);
    }
    if (data.containsKey('mac_address')) {
      context.handle(
        _macAddressMeta,
        macAddress.isAcceptableOrUnknown(data['mac_address']!, _macAddressMeta),
      );
    }
    if (data.containsKey('private_mac')) {
      context.handle(
        _privateMacMeta,
        privateMac.isAcceptableOrUnknown(data['private_mac']!, _privateMacMeta),
      );
    }
    if (data.containsKey('discovered_name')) {
      context.handle(
        _discoveredNameMeta,
        discoveredName.isAcceptableOrUnknown(
          data['discovered_name']!,
          _discoveredNameMeta,
        ),
      );
    }
    if (data.containsKey('hostname')) {
      context.handle(
        _hostnameMeta,
        hostname.isAcceptableOrUnknown(data['hostname']!, _hostnameMeta),
      );
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('mac_vendor')) {
      context.handle(
        _macVendorMeta,
        macVendor.isAcceptableOrUnknown(data['mac_vendor']!, _macVendorMeta),
      );
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    }
    if (data.containsKey('model_number')) {
      context.handle(
        _modelNumberMeta,
        modelNumber.isAcceptableOrUnknown(
          data['model_number']!,
          _modelNumberMeta,
        ),
      );
    }
    if (data.containsKey('model_description')) {
      context.handle(
        _modelDescriptionMeta,
        modelDescription.isAcceptableOrUnknown(
          data['model_description']!,
          _modelDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('device_type')) {
      context.handle(
        _deviceTypeMeta,
        deviceType.isAcceptableOrUnknown(data['device_type']!, _deviceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceTypeMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('is_gateway')) {
      context.handle(
        _isGatewayMeta,
        isGateway.isAcceptableOrUnknown(data['is_gateway']!, _isGatewayMeta),
      );
    } else if (isInserting) {
      context.missing(_isGatewayMeta);
    }
    if (data.containsKey('is_current_device')) {
      context.handle(
        _isCurrentDeviceMeta,
        isCurrentDevice.isAcceptableOrUnknown(
          data['is_current_device']!,
          _isCurrentDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isCurrentDeviceMeta);
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_firstSeenMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    if (data.containsKey('online')) {
      context.handle(
        _onlineMeta,
        online.isAcceptableOrUnknown(data['online']!, _onlineMeta),
      );
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detailsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {networkId, identityKey},
  ];
  @override
  StoredDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredDevice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      networkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}network_id'],
      )!,
      identityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_key'],
      )!,
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      classification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification'],
      )!,
      ipAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip_address'],
      )!,
      macAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mac_address'],
      ),
      privateMac: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}private_mac'],
      )!,
      discoveredName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discovered_name'],
      ),
      hostname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hostname'],
      ),
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      macVendor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mac_vendor'],
      ),
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      ),
      modelNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_number'],
      ),
      modelDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_description'],
      ),
      deviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_type'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      )!,
      isGateway: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_gateway'],
      )!,
      isCurrentDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_current_device'],
      )!,
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen'],
      )!,
      online: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}online'],
      )!,
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      )!,
    );
  }

  @override
  StoredDevices createAlias(String alias) {
    return StoredDevices(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'UNIQUE(network_id, identity_key)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class StoredDevice extends DataClass implements Insertable<StoredDevice> {
  final int id;
  final int networkId;
  final String identityKey;
  final String? customName;
  final String notes;
  final String classification;
  final String ipAddress;
  final String? macAddress;
  final int privateMac;
  final String? discoveredName;
  final String? hostname;
  final String? manufacturer;
  final String? macVendor;
  final String? modelName;
  final String? modelNumber;
  final String? modelDescription;
  final String deviceType;
  final String confidence;
  final int isGateway;
  final int isCurrentDevice;
  final int firstSeen;
  final int lastSeen;
  final int online;
  final String detailsJson;
  const StoredDevice({
    required this.id,
    required this.networkId,
    required this.identityKey,
    this.customName,
    required this.notes,
    required this.classification,
    required this.ipAddress,
    this.macAddress,
    required this.privateMac,
    this.discoveredName,
    this.hostname,
    this.manufacturer,
    this.macVendor,
    this.modelName,
    this.modelNumber,
    this.modelDescription,
    required this.deviceType,
    required this.confidence,
    required this.isGateway,
    required this.isCurrentDevice,
    required this.firstSeen,
    required this.lastSeen,
    required this.online,
    required this.detailsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['network_id'] = Variable<int>(networkId);
    map['identity_key'] = Variable<String>(identityKey);
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['notes'] = Variable<String>(notes);
    map['classification'] = Variable<String>(classification);
    map['ip_address'] = Variable<String>(ipAddress);
    if (!nullToAbsent || macAddress != null) {
      map['mac_address'] = Variable<String>(macAddress);
    }
    map['private_mac'] = Variable<int>(privateMac);
    if (!nullToAbsent || discoveredName != null) {
      map['discovered_name'] = Variable<String>(discoveredName);
    }
    if (!nullToAbsent || hostname != null) {
      map['hostname'] = Variable<String>(hostname);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || macVendor != null) {
      map['mac_vendor'] = Variable<String>(macVendor);
    }
    if (!nullToAbsent || modelName != null) {
      map['model_name'] = Variable<String>(modelName);
    }
    if (!nullToAbsent || modelNumber != null) {
      map['model_number'] = Variable<String>(modelNumber);
    }
    if (!nullToAbsent || modelDescription != null) {
      map['model_description'] = Variable<String>(modelDescription);
    }
    map['device_type'] = Variable<String>(deviceType);
    map['confidence'] = Variable<String>(confidence);
    map['is_gateway'] = Variable<int>(isGateway);
    map['is_current_device'] = Variable<int>(isCurrentDevice);
    map['first_seen'] = Variable<int>(firstSeen);
    map['last_seen'] = Variable<int>(lastSeen);
    map['online'] = Variable<int>(online);
    map['details_json'] = Variable<String>(detailsJson);
    return map;
  }

  StoredDevicesCompanion toCompanion(bool nullToAbsent) {
    return StoredDevicesCompanion(
      id: Value(id),
      networkId: Value(networkId),
      identityKey: Value(identityKey),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      notes: Value(notes),
      classification: Value(classification),
      ipAddress: Value(ipAddress),
      macAddress: macAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(macAddress),
      privateMac: Value(privateMac),
      discoveredName: discoveredName == null && nullToAbsent
          ? const Value.absent()
          : Value(discoveredName),
      hostname: hostname == null && nullToAbsent
          ? const Value.absent()
          : Value(hostname),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      macVendor: macVendor == null && nullToAbsent
          ? const Value.absent()
          : Value(macVendor),
      modelName: modelName == null && nullToAbsent
          ? const Value.absent()
          : Value(modelName),
      modelNumber: modelNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(modelNumber),
      modelDescription: modelDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(modelDescription),
      deviceType: Value(deviceType),
      confidence: Value(confidence),
      isGateway: Value(isGateway),
      isCurrentDevice: Value(isCurrentDevice),
      firstSeen: Value(firstSeen),
      lastSeen: Value(lastSeen),
      online: Value(online),
      detailsJson: Value(detailsJson),
    );
  }

  factory StoredDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredDevice(
      id: serializer.fromJson<int>(json['id']),
      networkId: serializer.fromJson<int>(json['network_id']),
      identityKey: serializer.fromJson<String>(json['identity_key']),
      customName: serializer.fromJson<String?>(json['custom_name']),
      notes: serializer.fromJson<String>(json['notes']),
      classification: serializer.fromJson<String>(json['classification']),
      ipAddress: serializer.fromJson<String>(json['ip_address']),
      macAddress: serializer.fromJson<String?>(json['mac_address']),
      privateMac: serializer.fromJson<int>(json['private_mac']),
      discoveredName: serializer.fromJson<String?>(json['discovered_name']),
      hostname: serializer.fromJson<String?>(json['hostname']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      macVendor: serializer.fromJson<String?>(json['mac_vendor']),
      modelName: serializer.fromJson<String?>(json['model_name']),
      modelNumber: serializer.fromJson<String?>(json['model_number']),
      modelDescription: serializer.fromJson<String?>(json['model_description']),
      deviceType: serializer.fromJson<String>(json['device_type']),
      confidence: serializer.fromJson<String>(json['confidence']),
      isGateway: serializer.fromJson<int>(json['is_gateway']),
      isCurrentDevice: serializer.fromJson<int>(json['is_current_device']),
      firstSeen: serializer.fromJson<int>(json['first_seen']),
      lastSeen: serializer.fromJson<int>(json['last_seen']),
      online: serializer.fromJson<int>(json['online']),
      detailsJson: serializer.fromJson<String>(json['details_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'network_id': serializer.toJson<int>(networkId),
      'identity_key': serializer.toJson<String>(identityKey),
      'custom_name': serializer.toJson<String?>(customName),
      'notes': serializer.toJson<String>(notes),
      'classification': serializer.toJson<String>(classification),
      'ip_address': serializer.toJson<String>(ipAddress),
      'mac_address': serializer.toJson<String?>(macAddress),
      'private_mac': serializer.toJson<int>(privateMac),
      'discovered_name': serializer.toJson<String?>(discoveredName),
      'hostname': serializer.toJson<String?>(hostname),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'mac_vendor': serializer.toJson<String?>(macVendor),
      'model_name': serializer.toJson<String?>(modelName),
      'model_number': serializer.toJson<String?>(modelNumber),
      'model_description': serializer.toJson<String?>(modelDescription),
      'device_type': serializer.toJson<String>(deviceType),
      'confidence': serializer.toJson<String>(confidence),
      'is_gateway': serializer.toJson<int>(isGateway),
      'is_current_device': serializer.toJson<int>(isCurrentDevice),
      'first_seen': serializer.toJson<int>(firstSeen),
      'last_seen': serializer.toJson<int>(lastSeen),
      'online': serializer.toJson<int>(online),
      'details_json': serializer.toJson<String>(detailsJson),
    };
  }

  StoredDevice copyWith({
    int? id,
    int? networkId,
    String? identityKey,
    Value<String?> customName = const Value.absent(),
    String? notes,
    String? classification,
    String? ipAddress,
    Value<String?> macAddress = const Value.absent(),
    int? privateMac,
    Value<String?> discoveredName = const Value.absent(),
    Value<String?> hostname = const Value.absent(),
    Value<String?> manufacturer = const Value.absent(),
    Value<String?> macVendor = const Value.absent(),
    Value<String?> modelName = const Value.absent(),
    Value<String?> modelNumber = const Value.absent(),
    Value<String?> modelDescription = const Value.absent(),
    String? deviceType,
    String? confidence,
    int? isGateway,
    int? isCurrentDevice,
    int? firstSeen,
    int? lastSeen,
    int? online,
    String? detailsJson,
  }) => StoredDevice(
    id: id ?? this.id,
    networkId: networkId ?? this.networkId,
    identityKey: identityKey ?? this.identityKey,
    customName: customName.present ? customName.value : this.customName,
    notes: notes ?? this.notes,
    classification: classification ?? this.classification,
    ipAddress: ipAddress ?? this.ipAddress,
    macAddress: macAddress.present ? macAddress.value : this.macAddress,
    privateMac: privateMac ?? this.privateMac,
    discoveredName: discoveredName.present
        ? discoveredName.value
        : this.discoveredName,
    hostname: hostname.present ? hostname.value : this.hostname,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    macVendor: macVendor.present ? macVendor.value : this.macVendor,
    modelName: modelName.present ? modelName.value : this.modelName,
    modelNumber: modelNumber.present ? modelNumber.value : this.modelNumber,
    modelDescription: modelDescription.present
        ? modelDescription.value
        : this.modelDescription,
    deviceType: deviceType ?? this.deviceType,
    confidence: confidence ?? this.confidence,
    isGateway: isGateway ?? this.isGateway,
    isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
    firstSeen: firstSeen ?? this.firstSeen,
    lastSeen: lastSeen ?? this.lastSeen,
    online: online ?? this.online,
    detailsJson: detailsJson ?? this.detailsJson,
  );
  StoredDevice copyWithCompanion(StoredDevicesCompanion data) {
    return StoredDevice(
      id: data.id.present ? data.id.value : this.id,
      networkId: data.networkId.present ? data.networkId.value : this.networkId,
      identityKey: data.identityKey.present
          ? data.identityKey.value
          : this.identityKey,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      notes: data.notes.present ? data.notes.value : this.notes,
      classification: data.classification.present
          ? data.classification.value
          : this.classification,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      macAddress: data.macAddress.present
          ? data.macAddress.value
          : this.macAddress,
      privateMac: data.privateMac.present
          ? data.privateMac.value
          : this.privateMac,
      discoveredName: data.discoveredName.present
          ? data.discoveredName.value
          : this.discoveredName,
      hostname: data.hostname.present ? data.hostname.value : this.hostname,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      macVendor: data.macVendor.present ? data.macVendor.value : this.macVendor,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      modelNumber: data.modelNumber.present
          ? data.modelNumber.value
          : this.modelNumber,
      modelDescription: data.modelDescription.present
          ? data.modelDescription.value
          : this.modelDescription,
      deviceType: data.deviceType.present
          ? data.deviceType.value
          : this.deviceType,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      isGateway: data.isGateway.present ? data.isGateway.value : this.isGateway,
      isCurrentDevice: data.isCurrentDevice.present
          ? data.isCurrentDevice.value
          : this.isCurrentDevice,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      online: data.online.present ? data.online.value : this.online,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredDevice(')
          ..write('id: $id, ')
          ..write('networkId: $networkId, ')
          ..write('identityKey: $identityKey, ')
          ..write('customName: $customName, ')
          ..write('notes: $notes, ')
          ..write('classification: $classification, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('macAddress: $macAddress, ')
          ..write('privateMac: $privateMac, ')
          ..write('discoveredName: $discoveredName, ')
          ..write('hostname: $hostname, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('macVendor: $macVendor, ')
          ..write('modelName: $modelName, ')
          ..write('modelNumber: $modelNumber, ')
          ..write('modelDescription: $modelDescription, ')
          ..write('deviceType: $deviceType, ')
          ..write('confidence: $confidence, ')
          ..write('isGateway: $isGateway, ')
          ..write('isCurrentDevice: $isCurrentDevice, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('online: $online, ')
          ..write('detailsJson: $detailsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    networkId,
    identityKey,
    customName,
    notes,
    classification,
    ipAddress,
    macAddress,
    privateMac,
    discoveredName,
    hostname,
    manufacturer,
    macVendor,
    modelName,
    modelNumber,
    modelDescription,
    deviceType,
    confidence,
    isGateway,
    isCurrentDevice,
    firstSeen,
    lastSeen,
    online,
    detailsJson,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredDevice &&
          other.id == this.id &&
          other.networkId == this.networkId &&
          other.identityKey == this.identityKey &&
          other.customName == this.customName &&
          other.notes == this.notes &&
          other.classification == this.classification &&
          other.ipAddress == this.ipAddress &&
          other.macAddress == this.macAddress &&
          other.privateMac == this.privateMac &&
          other.discoveredName == this.discoveredName &&
          other.hostname == this.hostname &&
          other.manufacturer == this.manufacturer &&
          other.macVendor == this.macVendor &&
          other.modelName == this.modelName &&
          other.modelNumber == this.modelNumber &&
          other.modelDescription == this.modelDescription &&
          other.deviceType == this.deviceType &&
          other.confidence == this.confidence &&
          other.isGateway == this.isGateway &&
          other.isCurrentDevice == this.isCurrentDevice &&
          other.firstSeen == this.firstSeen &&
          other.lastSeen == this.lastSeen &&
          other.online == this.online &&
          other.detailsJson == this.detailsJson);
}

class StoredDevicesCompanion extends UpdateCompanion<StoredDevice> {
  final Value<int> id;
  final Value<int> networkId;
  final Value<String> identityKey;
  final Value<String?> customName;
  final Value<String> notes;
  final Value<String> classification;
  final Value<String> ipAddress;
  final Value<String?> macAddress;
  final Value<int> privateMac;
  final Value<String?> discoveredName;
  final Value<String?> hostname;
  final Value<String?> manufacturer;
  final Value<String?> macVendor;
  final Value<String?> modelName;
  final Value<String?> modelNumber;
  final Value<String?> modelDescription;
  final Value<String> deviceType;
  final Value<String> confidence;
  final Value<int> isGateway;
  final Value<int> isCurrentDevice;
  final Value<int> firstSeen;
  final Value<int> lastSeen;
  final Value<int> online;
  final Value<String> detailsJson;
  const StoredDevicesCompanion({
    this.id = const Value.absent(),
    this.networkId = const Value.absent(),
    this.identityKey = const Value.absent(),
    this.customName = const Value.absent(),
    this.notes = const Value.absent(),
    this.classification = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.macAddress = const Value.absent(),
    this.privateMac = const Value.absent(),
    this.discoveredName = const Value.absent(),
    this.hostname = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.macVendor = const Value.absent(),
    this.modelName = const Value.absent(),
    this.modelNumber = const Value.absent(),
    this.modelDescription = const Value.absent(),
    this.deviceType = const Value.absent(),
    this.confidence = const Value.absent(),
    this.isGateway = const Value.absent(),
    this.isCurrentDevice = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.online = const Value.absent(),
    this.detailsJson = const Value.absent(),
  });
  StoredDevicesCompanion.insert({
    this.id = const Value.absent(),
    required int networkId,
    required String identityKey,
    this.customName = const Value.absent(),
    this.notes = const Value.absent(),
    this.classification = const Value.absent(),
    required String ipAddress,
    this.macAddress = const Value.absent(),
    this.privateMac = const Value.absent(),
    this.discoveredName = const Value.absent(),
    this.hostname = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.macVendor = const Value.absent(),
    this.modelName = const Value.absent(),
    this.modelNumber = const Value.absent(),
    this.modelDescription = const Value.absent(),
    required String deviceType,
    required String confidence,
    required int isGateway,
    required int isCurrentDevice,
    required int firstSeen,
    required int lastSeen,
    this.online = const Value.absent(),
    required String detailsJson,
  }) : networkId = Value(networkId),
       identityKey = Value(identityKey),
       ipAddress = Value(ipAddress),
       deviceType = Value(deviceType),
       confidence = Value(confidence),
       isGateway = Value(isGateway),
       isCurrentDevice = Value(isCurrentDevice),
       firstSeen = Value(firstSeen),
       lastSeen = Value(lastSeen),
       detailsJson = Value(detailsJson);
  static Insertable<StoredDevice> custom({
    Expression<int>? id,
    Expression<int>? networkId,
    Expression<String>? identityKey,
    Expression<String>? customName,
    Expression<String>? notes,
    Expression<String>? classification,
    Expression<String>? ipAddress,
    Expression<String>? macAddress,
    Expression<int>? privateMac,
    Expression<String>? discoveredName,
    Expression<String>? hostname,
    Expression<String>? manufacturer,
    Expression<String>? macVendor,
    Expression<String>? modelName,
    Expression<String>? modelNumber,
    Expression<String>? modelDescription,
    Expression<String>? deviceType,
    Expression<String>? confidence,
    Expression<int>? isGateway,
    Expression<int>? isCurrentDevice,
    Expression<int>? firstSeen,
    Expression<int>? lastSeen,
    Expression<int>? online,
    Expression<String>? detailsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (networkId != null) 'network_id': networkId,
      if (identityKey != null) 'identity_key': identityKey,
      if (customName != null) 'custom_name': customName,
      if (notes != null) 'notes': notes,
      if (classification != null) 'classification': classification,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (macAddress != null) 'mac_address': macAddress,
      if (privateMac != null) 'private_mac': privateMac,
      if (discoveredName != null) 'discovered_name': discoveredName,
      if (hostname != null) 'hostname': hostname,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (macVendor != null) 'mac_vendor': macVendor,
      if (modelName != null) 'model_name': modelName,
      if (modelNumber != null) 'model_number': modelNumber,
      if (modelDescription != null) 'model_description': modelDescription,
      if (deviceType != null) 'device_type': deviceType,
      if (confidence != null) 'confidence': confidence,
      if (isGateway != null) 'is_gateway': isGateway,
      if (isCurrentDevice != null) 'is_current_device': isCurrentDevice,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (online != null) 'online': online,
      if (detailsJson != null) 'details_json': detailsJson,
    });
  }

  StoredDevicesCompanion copyWith({
    Value<int>? id,
    Value<int>? networkId,
    Value<String>? identityKey,
    Value<String?>? customName,
    Value<String>? notes,
    Value<String>? classification,
    Value<String>? ipAddress,
    Value<String?>? macAddress,
    Value<int>? privateMac,
    Value<String?>? discoveredName,
    Value<String?>? hostname,
    Value<String?>? manufacturer,
    Value<String?>? macVendor,
    Value<String?>? modelName,
    Value<String?>? modelNumber,
    Value<String?>? modelDescription,
    Value<String>? deviceType,
    Value<String>? confidence,
    Value<int>? isGateway,
    Value<int>? isCurrentDevice,
    Value<int>? firstSeen,
    Value<int>? lastSeen,
    Value<int>? online,
    Value<String>? detailsJson,
  }) {
    return StoredDevicesCompanion(
      id: id ?? this.id,
      networkId: networkId ?? this.networkId,
      identityKey: identityKey ?? this.identityKey,
      customName: customName ?? this.customName,
      notes: notes ?? this.notes,
      classification: classification ?? this.classification,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      privateMac: privateMac ?? this.privateMac,
      discoveredName: discoveredName ?? this.discoveredName,
      hostname: hostname ?? this.hostname,
      manufacturer: manufacturer ?? this.manufacturer,
      macVendor: macVendor ?? this.macVendor,
      modelName: modelName ?? this.modelName,
      modelNumber: modelNumber ?? this.modelNumber,
      modelDescription: modelDescription ?? this.modelDescription,
      deviceType: deviceType ?? this.deviceType,
      confidence: confidence ?? this.confidence,
      isGateway: isGateway ?? this.isGateway,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      online: online ?? this.online,
      detailsJson: detailsJson ?? this.detailsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (networkId.present) {
      map['network_id'] = Variable<int>(networkId.value);
    }
    if (identityKey.present) {
      map['identity_key'] = Variable<String>(identityKey.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (classification.present) {
      map['classification'] = Variable<String>(classification.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (macAddress.present) {
      map['mac_address'] = Variable<String>(macAddress.value);
    }
    if (privateMac.present) {
      map['private_mac'] = Variable<int>(privateMac.value);
    }
    if (discoveredName.present) {
      map['discovered_name'] = Variable<String>(discoveredName.value);
    }
    if (hostname.present) {
      map['hostname'] = Variable<String>(hostname.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (macVendor.present) {
      map['mac_vendor'] = Variable<String>(macVendor.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (modelNumber.present) {
      map['model_number'] = Variable<String>(modelNumber.value);
    }
    if (modelDescription.present) {
      map['model_description'] = Variable<String>(modelDescription.value);
    }
    if (deviceType.present) {
      map['device_type'] = Variable<String>(deviceType.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (isGateway.present) {
      map['is_gateway'] = Variable<int>(isGateway.value);
    }
    if (isCurrentDevice.present) {
      map['is_current_device'] = Variable<int>(isCurrentDevice.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<int>(firstSeen.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<int>(lastSeen.value);
    }
    if (online.present) {
      map['online'] = Variable<int>(online.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredDevicesCompanion(')
          ..write('id: $id, ')
          ..write('networkId: $networkId, ')
          ..write('identityKey: $identityKey, ')
          ..write('customName: $customName, ')
          ..write('notes: $notes, ')
          ..write('classification: $classification, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('macAddress: $macAddress, ')
          ..write('privateMac: $privateMac, ')
          ..write('discoveredName: $discoveredName, ')
          ..write('hostname: $hostname, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('macVendor: $macVendor, ')
          ..write('modelName: $modelName, ')
          ..write('modelNumber: $modelNumber, ')
          ..write('modelDescription: $modelDescription, ')
          ..write('deviceType: $deviceType, ')
          ..write('confidence: $confidence, ')
          ..write('isGateway: $isGateway, ')
          ..write('isCurrentDevice: $isCurrentDevice, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('online: $online, ')
          ..write('detailsJson: $detailsJson')
          ..write(')'))
        .toString();
  }
}

class DeviceIdentities extends Table
    with TableInfo<DeviceIdentities, DeviceIdentity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DeviceIdentities(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _networkIdMeta = const VerificationMeta(
    'networkId',
  );
  late final GeneratedColumn<int> networkId = GeneratedColumn<int>(
    'network_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES saved_networks(id)',
  );
  static const VerificationMeta _identityKeyMeta = const VerificationMeta(
    'identityKey',
  );
  late final GeneratedColumn<String> identityKey = GeneratedColumn<String>(
    'identity_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES stored_devices(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [networkId, identityKey, deviceId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_identities';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceIdentity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('network_id')) {
      context.handle(
        _networkIdMeta,
        networkId.isAcceptableOrUnknown(data['network_id']!, _networkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_networkIdMeta);
    }
    if (data.containsKey('identity_key')) {
      context.handle(
        _identityKeyMeta,
        identityKey.isAcceptableOrUnknown(
          data['identity_key']!,
          _identityKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_identityKeyMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {networkId, identityKey};
  @override
  DeviceIdentity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceIdentity(
      networkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}network_id'],
      )!,
      identityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_key'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  DeviceIdentities createAlias(String alias) {
    return DeviceIdentities(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(network_id, identity_key)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class DeviceIdentity extends DataClass implements Insertable<DeviceIdentity> {
  final int networkId;
  final String identityKey;
  final int deviceId;
  const DeviceIdentity({
    required this.networkId,
    required this.identityKey,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['network_id'] = Variable<int>(networkId);
    map['identity_key'] = Variable<String>(identityKey);
    map['device_id'] = Variable<int>(deviceId);
    return map;
  }

  DeviceIdentitiesCompanion toCompanion(bool nullToAbsent) {
    return DeviceIdentitiesCompanion(
      networkId: Value(networkId),
      identityKey: Value(identityKey),
      deviceId: Value(deviceId),
    );
  }

  factory DeviceIdentity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceIdentity(
      networkId: serializer.fromJson<int>(json['network_id']),
      identityKey: serializer.fromJson<String>(json['identity_key']),
      deviceId: serializer.fromJson<int>(json['device_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'network_id': serializer.toJson<int>(networkId),
      'identity_key': serializer.toJson<String>(identityKey),
      'device_id': serializer.toJson<int>(deviceId),
    };
  }

  DeviceIdentity copyWith({
    int? networkId,
    String? identityKey,
    int? deviceId,
  }) => DeviceIdentity(
    networkId: networkId ?? this.networkId,
    identityKey: identityKey ?? this.identityKey,
    deviceId: deviceId ?? this.deviceId,
  );
  DeviceIdentity copyWithCompanion(DeviceIdentitiesCompanion data) {
    return DeviceIdentity(
      networkId: data.networkId.present ? data.networkId.value : this.networkId,
      identityKey: data.identityKey.present
          ? data.identityKey.value
          : this.identityKey,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceIdentity(')
          ..write('networkId: $networkId, ')
          ..write('identityKey: $identityKey, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(networkId, identityKey, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceIdentity &&
          other.networkId == this.networkId &&
          other.identityKey == this.identityKey &&
          other.deviceId == this.deviceId);
}

class DeviceIdentitiesCompanion extends UpdateCompanion<DeviceIdentity> {
  final Value<int> networkId;
  final Value<String> identityKey;
  final Value<int> deviceId;
  final Value<int> rowid;
  const DeviceIdentitiesCompanion({
    this.networkId = const Value.absent(),
    this.identityKey = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceIdentitiesCompanion.insert({
    required int networkId,
    required String identityKey,
    required int deviceId,
    this.rowid = const Value.absent(),
  }) : networkId = Value(networkId),
       identityKey = Value(identityKey),
       deviceId = Value(deviceId);
  static Insertable<DeviceIdentity> custom({
    Expression<int>? networkId,
    Expression<String>? identityKey,
    Expression<int>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (networkId != null) 'network_id': networkId,
      if (identityKey != null) 'identity_key': identityKey,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceIdentitiesCompanion copyWith({
    Value<int>? networkId,
    Value<String>? identityKey,
    Value<int>? deviceId,
    Value<int>? rowid,
  }) {
    return DeviceIdentitiesCompanion(
      networkId: networkId ?? this.networkId,
      identityKey: identityKey ?? this.identityKey,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (networkId.present) {
      map['network_id'] = Variable<int>(networkId.value);
    }
    if (identityKey.present) {
      map['identity_key'] = Variable<String>(identityKey.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceIdentitiesCompanion(')
          ..write('networkId: $networkId, ')
          ..write('identityKey: $identityKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DeviceIpHistory extends Table
    with TableInfo<DeviceIpHistory, DeviceIpHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DeviceIpHistory(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES stored_devices(id)',
  );
  static const VerificationMeta _ipAddressMeta = const VerificationMeta(
    'ipAddress',
  );
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
    'ip_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  late final GeneratedColumn<int> firstSeen = GeneratedColumn<int>(
    'first_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  late final GeneratedColumn<int> lastSeen = GeneratedColumn<int>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    ipAddress,
    firstSeen,
    lastSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_ip_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceIpHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('ip_address')) {
      context.handle(
        _ipAddressMeta,
        ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta),
      );
    } else if (isInserting) {
      context.missing(_ipAddressMeta);
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_firstSeenMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId, ipAddress};
  @override
  DeviceIpHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceIpHistoryData(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
      ipAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip_address'],
      )!,
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen'],
      )!,
    );
  }

  @override
  DeviceIpHistory createAlias(String alias) {
    return DeviceIpHistory(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(device_id, ip_address)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class DeviceIpHistoryData extends DataClass
    implements Insertable<DeviceIpHistoryData> {
  final int deviceId;
  final String ipAddress;
  final int firstSeen;
  final int lastSeen;
  const DeviceIpHistoryData({
    required this.deviceId,
    required this.ipAddress,
    required this.firstSeen,
    required this.lastSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<int>(deviceId);
    map['ip_address'] = Variable<String>(ipAddress);
    map['first_seen'] = Variable<int>(firstSeen);
    map['last_seen'] = Variable<int>(lastSeen);
    return map;
  }

  DeviceIpHistoryCompanion toCompanion(bool nullToAbsent) {
    return DeviceIpHistoryCompanion(
      deviceId: Value(deviceId),
      ipAddress: Value(ipAddress),
      firstSeen: Value(firstSeen),
      lastSeen: Value(lastSeen),
    );
  }

  factory DeviceIpHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceIpHistoryData(
      deviceId: serializer.fromJson<int>(json['device_id']),
      ipAddress: serializer.fromJson<String>(json['ip_address']),
      firstSeen: serializer.fromJson<int>(json['first_seen']),
      lastSeen: serializer.fromJson<int>(json['last_seen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'device_id': serializer.toJson<int>(deviceId),
      'ip_address': serializer.toJson<String>(ipAddress),
      'first_seen': serializer.toJson<int>(firstSeen),
      'last_seen': serializer.toJson<int>(lastSeen),
    };
  }

  DeviceIpHistoryData copyWith({
    int? deviceId,
    String? ipAddress,
    int? firstSeen,
    int? lastSeen,
  }) => DeviceIpHistoryData(
    deviceId: deviceId ?? this.deviceId,
    ipAddress: ipAddress ?? this.ipAddress,
    firstSeen: firstSeen ?? this.firstSeen,
    lastSeen: lastSeen ?? this.lastSeen,
  );
  DeviceIpHistoryData copyWithCompanion(DeviceIpHistoryCompanion data) {
    return DeviceIpHistoryData(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceIpHistoryData(')
          ..write('deviceId: $deviceId, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, ipAddress, firstSeen, lastSeen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceIpHistoryData &&
          other.deviceId == this.deviceId &&
          other.ipAddress == this.ipAddress &&
          other.firstSeen == this.firstSeen &&
          other.lastSeen == this.lastSeen);
}

class DeviceIpHistoryCompanion extends UpdateCompanion<DeviceIpHistoryData> {
  final Value<int> deviceId;
  final Value<String> ipAddress;
  final Value<int> firstSeen;
  final Value<int> lastSeen;
  final Value<int> rowid;
  const DeviceIpHistoryCompanion({
    this.deviceId = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceIpHistoryCompanion.insert({
    required int deviceId,
    required String ipAddress,
    required int firstSeen,
    required int lastSeen,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       ipAddress = Value(ipAddress),
       firstSeen = Value(firstSeen),
       lastSeen = Value(lastSeen);
  static Insertable<DeviceIpHistoryData> custom({
    Expression<int>? deviceId,
    Expression<String>? ipAddress,
    Expression<int>? firstSeen,
    Expression<int>? lastSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceIpHistoryCompanion copyWith({
    Value<int>? deviceId,
    Value<String>? ipAddress,
    Value<int>? firstSeen,
    Value<int>? lastSeen,
    Value<int>? rowid,
  }) {
    return DeviceIpHistoryCompanion(
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<int>(firstSeen.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<int>(lastSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceIpHistoryCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DeviceServices extends Table
    with TableInfo<DeviceServices, DeviceService> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DeviceServices(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES stored_devices(id)',
  );
  static const VerificationMeta _serviceKeyMeta = const VerificationMeta(
    'serviceKey',
  );
  late final GeneratedColumn<String> serviceKey = GeneratedColumn<String>(
    'service_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _serviceTypeMeta = const VerificationMeta(
    'serviceType',
  );
  late final GeneratedColumn<String> serviceType = GeneratedColumn<String>(
    'service_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _serviceNameMeta = const VerificationMeta(
    'serviceName',
  );
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
    'service_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _discoveryMethodMeta = const VerificationMeta(
    'discoveryMethod',
  );
  late final GeneratedColumn<String> discoveryMethod = GeneratedColumn<String>(
    'discovery_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _transportMeta = const VerificationMeta(
    'transport',
  );
  late final GeneratedColumn<String> transport = GeneratedColumn<String>(
    'transport',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  late final GeneratedColumn<int> firstSeen = GeneratedColumn<int>(
    'first_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  late final GeneratedColumn<int> lastSeen = GeneratedColumn<int>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    serviceKey,
    serviceType,
    serviceName,
    discoveryMethod,
    host,
    port,
    transport,
    firstSeen,
    lastSeen,
    detailsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_services';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceService> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('service_key')) {
      context.handle(
        _serviceKeyMeta,
        serviceKey.isAcceptableOrUnknown(data['service_key']!, _serviceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceKeyMeta);
    }
    if (data.containsKey('service_type')) {
      context.handle(
        _serviceTypeMeta,
        serviceType.isAcceptableOrUnknown(
          data['service_type']!,
          _serviceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceTypeMeta);
    }
    if (data.containsKey('service_name')) {
      context.handle(
        _serviceNameMeta,
        serviceName.isAcceptableOrUnknown(
          data['service_name']!,
          _serviceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceNameMeta);
    }
    if (data.containsKey('discovery_method')) {
      context.handle(
        _discoveryMethodMeta,
        discoveryMethod.isAcceptableOrUnknown(
          data['discovery_method']!,
          _discoveryMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discoveryMethodMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    }
    if (data.containsKey('transport')) {
      context.handle(
        _transportMeta,
        transport.isAcceptableOrUnknown(data['transport']!, _transportMeta),
      );
    } else if (isInserting) {
      context.missing(_transportMeta);
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_firstSeenMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detailsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {deviceId, serviceKey},
  ];
  @override
  DeviceService map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceService(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
      serviceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_key'],
      )!,
      serviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_type'],
      )!,
      serviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_name'],
      )!,
      discoveryMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discovery_method'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      ),
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      ),
      transport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transport'],
      )!,
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen'],
      )!,
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      )!,
    );
  }

  @override
  DeviceServices createAlias(String alias) {
    return DeviceServices(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'UNIQUE(device_id, service_key)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class DeviceService extends DataClass implements Insertable<DeviceService> {
  final int id;
  final int deviceId;
  final String serviceKey;
  final String serviceType;
  final String serviceName;
  final String discoveryMethod;
  final String? host;
  final int? port;
  final String transport;
  final int firstSeen;
  final int lastSeen;
  final String detailsJson;
  const DeviceService({
    required this.id,
    required this.deviceId,
    required this.serviceKey,
    required this.serviceType,
    required this.serviceName,
    required this.discoveryMethod,
    this.host,
    this.port,
    required this.transport,
    required this.firstSeen,
    required this.lastSeen,
    required this.detailsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<int>(deviceId);
    map['service_key'] = Variable<String>(serviceKey);
    map['service_type'] = Variable<String>(serviceType);
    map['service_name'] = Variable<String>(serviceName);
    map['discovery_method'] = Variable<String>(discoveryMethod);
    if (!nullToAbsent || host != null) {
      map['host'] = Variable<String>(host);
    }
    if (!nullToAbsent || port != null) {
      map['port'] = Variable<int>(port);
    }
    map['transport'] = Variable<String>(transport);
    map['first_seen'] = Variable<int>(firstSeen);
    map['last_seen'] = Variable<int>(lastSeen);
    map['details_json'] = Variable<String>(detailsJson);
    return map;
  }

  DeviceServicesCompanion toCompanion(bool nullToAbsent) {
    return DeviceServicesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      serviceKey: Value(serviceKey),
      serviceType: Value(serviceType),
      serviceName: Value(serviceName),
      discoveryMethod: Value(discoveryMethod),
      host: host == null && nullToAbsent ? const Value.absent() : Value(host),
      port: port == null && nullToAbsent ? const Value.absent() : Value(port),
      transport: Value(transport),
      firstSeen: Value(firstSeen),
      lastSeen: Value(lastSeen),
      detailsJson: Value(detailsJson),
    );
  }

  factory DeviceService.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceService(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<int>(json['device_id']),
      serviceKey: serializer.fromJson<String>(json['service_key']),
      serviceType: serializer.fromJson<String>(json['service_type']),
      serviceName: serializer.fromJson<String>(json['service_name']),
      discoveryMethod: serializer.fromJson<String>(json['discovery_method']),
      host: serializer.fromJson<String?>(json['host']),
      port: serializer.fromJson<int?>(json['port']),
      transport: serializer.fromJson<String>(json['transport']),
      firstSeen: serializer.fromJson<int>(json['first_seen']),
      lastSeen: serializer.fromJson<int>(json['last_seen']),
      detailsJson: serializer.fromJson<String>(json['details_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'device_id': serializer.toJson<int>(deviceId),
      'service_key': serializer.toJson<String>(serviceKey),
      'service_type': serializer.toJson<String>(serviceType),
      'service_name': serializer.toJson<String>(serviceName),
      'discovery_method': serializer.toJson<String>(discoveryMethod),
      'host': serializer.toJson<String?>(host),
      'port': serializer.toJson<int?>(port),
      'transport': serializer.toJson<String>(transport),
      'first_seen': serializer.toJson<int>(firstSeen),
      'last_seen': serializer.toJson<int>(lastSeen),
      'details_json': serializer.toJson<String>(detailsJson),
    };
  }

  DeviceService copyWith({
    int? id,
    int? deviceId,
    String? serviceKey,
    String? serviceType,
    String? serviceName,
    String? discoveryMethod,
    Value<String?> host = const Value.absent(),
    Value<int?> port = const Value.absent(),
    String? transport,
    int? firstSeen,
    int? lastSeen,
    String? detailsJson,
  }) => DeviceService(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    serviceKey: serviceKey ?? this.serviceKey,
    serviceType: serviceType ?? this.serviceType,
    serviceName: serviceName ?? this.serviceName,
    discoveryMethod: discoveryMethod ?? this.discoveryMethod,
    host: host.present ? host.value : this.host,
    port: port.present ? port.value : this.port,
    transport: transport ?? this.transport,
    firstSeen: firstSeen ?? this.firstSeen,
    lastSeen: lastSeen ?? this.lastSeen,
    detailsJson: detailsJson ?? this.detailsJson,
  );
  DeviceService copyWithCompanion(DeviceServicesCompanion data) {
    return DeviceService(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      serviceKey: data.serviceKey.present
          ? data.serviceKey.value
          : this.serviceKey,
      serviceType: data.serviceType.present
          ? data.serviceType.value
          : this.serviceType,
      serviceName: data.serviceName.present
          ? data.serviceName.value
          : this.serviceName,
      discoveryMethod: data.discoveryMethod.present
          ? data.discoveryMethod.value
          : this.discoveryMethod,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      transport: data.transport.present ? data.transport.value : this.transport,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceService(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('serviceKey: $serviceKey, ')
          ..write('serviceType: $serviceType, ')
          ..write('serviceName: $serviceName, ')
          ..write('discoveryMethod: $discoveryMethod, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('transport: $transport, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('detailsJson: $detailsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    serviceKey,
    serviceType,
    serviceName,
    discoveryMethod,
    host,
    port,
    transport,
    firstSeen,
    lastSeen,
    detailsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceService &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.serviceKey == this.serviceKey &&
          other.serviceType == this.serviceType &&
          other.serviceName == this.serviceName &&
          other.discoveryMethod == this.discoveryMethod &&
          other.host == this.host &&
          other.port == this.port &&
          other.transport == this.transport &&
          other.firstSeen == this.firstSeen &&
          other.lastSeen == this.lastSeen &&
          other.detailsJson == this.detailsJson);
}

class DeviceServicesCompanion extends UpdateCompanion<DeviceService> {
  final Value<int> id;
  final Value<int> deviceId;
  final Value<String> serviceKey;
  final Value<String> serviceType;
  final Value<String> serviceName;
  final Value<String> discoveryMethod;
  final Value<String?> host;
  final Value<int?> port;
  final Value<String> transport;
  final Value<int> firstSeen;
  final Value<int> lastSeen;
  final Value<String> detailsJson;
  const DeviceServicesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.serviceKey = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.discoveryMethod = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.transport = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.detailsJson = const Value.absent(),
  });
  DeviceServicesCompanion.insert({
    this.id = const Value.absent(),
    required int deviceId,
    required String serviceKey,
    required String serviceType,
    required String serviceName,
    required String discoveryMethod,
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    required String transport,
    required int firstSeen,
    required int lastSeen,
    required String detailsJson,
  }) : deviceId = Value(deviceId),
       serviceKey = Value(serviceKey),
       serviceType = Value(serviceType),
       serviceName = Value(serviceName),
       discoveryMethod = Value(discoveryMethod),
       transport = Value(transport),
       firstSeen = Value(firstSeen),
       lastSeen = Value(lastSeen),
       detailsJson = Value(detailsJson);
  static Insertable<DeviceService> custom({
    Expression<int>? id,
    Expression<int>? deviceId,
    Expression<String>? serviceKey,
    Expression<String>? serviceType,
    Expression<String>? serviceName,
    Expression<String>? discoveryMethod,
    Expression<String>? host,
    Expression<int>? port,
    Expression<String>? transport,
    Expression<int>? firstSeen,
    Expression<int>? lastSeen,
    Expression<String>? detailsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (serviceKey != null) 'service_key': serviceKey,
      if (serviceType != null) 'service_type': serviceType,
      if (serviceName != null) 'service_name': serviceName,
      if (discoveryMethod != null) 'discovery_method': discoveryMethod,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (transport != null) 'transport': transport,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (detailsJson != null) 'details_json': detailsJson,
    });
  }

  DeviceServicesCompanion copyWith({
    Value<int>? id,
    Value<int>? deviceId,
    Value<String>? serviceKey,
    Value<String>? serviceType,
    Value<String>? serviceName,
    Value<String>? discoveryMethod,
    Value<String?>? host,
    Value<int?>? port,
    Value<String>? transport,
    Value<int>? firstSeen,
    Value<int>? lastSeen,
    Value<String>? detailsJson,
  }) {
    return DeviceServicesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      serviceKey: serviceKey ?? this.serviceKey,
      serviceType: serviceType ?? this.serviceType,
      serviceName: serviceName ?? this.serviceName,
      discoveryMethod: discoveryMethod ?? this.discoveryMethod,
      host: host ?? this.host,
      port: port ?? this.port,
      transport: transport ?? this.transport,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      detailsJson: detailsJson ?? this.detailsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (serviceKey.present) {
      map['service_key'] = Variable<String>(serviceKey.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(serviceType.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    if (discoveryMethod.present) {
      map['discovery_method'] = Variable<String>(discoveryMethod.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (transport.present) {
      map['transport'] = Variable<String>(transport.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<int>(firstSeen.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<int>(lastSeen.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceServicesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('serviceKey: $serviceKey, ')
          ..write('serviceType: $serviceType, ')
          ..write('serviceName: $serviceName, ')
          ..write('discoveryMethod: $discoveryMethod, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('transport: $transport, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('detailsJson: $detailsJson')
          ..write(')'))
        .toString();
  }
}

class NetworkScans extends Table with TableInfo<NetworkScans, NetworkScan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  NetworkScans(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _networkIdMeta = const VerificationMeta(
    'networkId',
  );
  late final GeneratedColumn<int> networkId = GeneratedColumn<int>(
    'network_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES saved_networks(id)',
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _devicesFoundMeta = const VerificationMeta(
    'devicesFound',
  );
  late final GeneratedColumn<int> devicesFound = GeneratedColumn<int>(
    'devices_found',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _addressesCheckedMeta = const VerificationMeta(
    'addressesChecked',
  );
  late final GeneratedColumn<int> addressesChecked = GeneratedColumn<int>(
    'addresses_checked',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _totalCandidatesMeta = const VerificationMeta(
    'totalCandidates',
  );
  late final GeneratedColumn<int> totalCandidates = GeneratedColumn<int>(
    'total_candidates',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _discoveryMethodsMeta = const VerificationMeta(
    'discoveryMethods',
  );
  late final GeneratedColumn<String> discoveryMethods = GeneratedColumn<String>(
    'discovery_methods',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    networkId,
    startedAt,
    completedAt,
    status,
    devicesFound,
    addressesChecked,
    totalCandidates,
    discoveryMethods,
    message,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'network_scans';
  @override
  VerificationContext validateIntegrity(
    Insertable<NetworkScan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('network_id')) {
      context.handle(
        _networkIdMeta,
        networkId.isAcceptableOrUnknown(data['network_id']!, _networkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_networkIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('devices_found')) {
      context.handle(
        _devicesFoundMeta,
        devicesFound.isAcceptableOrUnknown(
          data['devices_found']!,
          _devicesFoundMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_devicesFoundMeta);
    }
    if (data.containsKey('addresses_checked')) {
      context.handle(
        _addressesCheckedMeta,
        addressesChecked.isAcceptableOrUnknown(
          data['addresses_checked']!,
          _addressesCheckedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addressesCheckedMeta);
    }
    if (data.containsKey('total_candidates')) {
      context.handle(
        _totalCandidatesMeta,
        totalCandidates.isAcceptableOrUnknown(
          data['total_candidates']!,
          _totalCandidatesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalCandidatesMeta);
    }
    if (data.containsKey('discovery_methods')) {
      context.handle(
        _discoveryMethodsMeta,
        discoveryMethods.isAcceptableOrUnknown(
          data['discovery_methods']!,
          _discoveryMethodsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discoveryMethodsMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {networkId, startedAt},
  ];
  @override
  NetworkScan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetworkScan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      networkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}network_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      devicesFound: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}devices_found'],
      )!,
      addressesChecked: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}addresses_checked'],
      )!,
      totalCandidates: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_candidates'],
      )!,
      discoveryMethods: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discovery_methods'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
    );
  }

  @override
  NetworkScans createAlias(String alias) {
    return NetworkScans(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'UNIQUE(network_id, started_at)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class NetworkScan extends DataClass implements Insertable<NetworkScan> {
  final int id;
  final int networkId;
  final int startedAt;
  final int? completedAt;
  final String status;
  final int devicesFound;
  final int addressesChecked;
  final int totalCandidates;
  final String discoveryMethods;
  final String? message;
  const NetworkScan({
    required this.id,
    required this.networkId,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.devicesFound,
    required this.addressesChecked,
    required this.totalCandidates,
    required this.discoveryMethods,
    this.message,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['network_id'] = Variable<int>(networkId);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['status'] = Variable<String>(status);
    map['devices_found'] = Variable<int>(devicesFound);
    map['addresses_checked'] = Variable<int>(addressesChecked);
    map['total_candidates'] = Variable<int>(totalCandidates);
    map['discovery_methods'] = Variable<String>(discoveryMethods);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    return map;
  }

  NetworkScansCompanion toCompanion(bool nullToAbsent) {
    return NetworkScansCompanion(
      id: Value(id),
      networkId: Value(networkId),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      status: Value(status),
      devicesFound: Value(devicesFound),
      addressesChecked: Value(addressesChecked),
      totalCandidates: Value(totalCandidates),
      discoveryMethods: Value(discoveryMethods),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
    );
  }

  factory NetworkScan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetworkScan(
      id: serializer.fromJson<int>(json['id']),
      networkId: serializer.fromJson<int>(json['network_id']),
      startedAt: serializer.fromJson<int>(json['started_at']),
      completedAt: serializer.fromJson<int?>(json['completed_at']),
      status: serializer.fromJson<String>(json['status']),
      devicesFound: serializer.fromJson<int>(json['devices_found']),
      addressesChecked: serializer.fromJson<int>(json['addresses_checked']),
      totalCandidates: serializer.fromJson<int>(json['total_candidates']),
      discoveryMethods: serializer.fromJson<String>(json['discovery_methods']),
      message: serializer.fromJson<String?>(json['message']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'network_id': serializer.toJson<int>(networkId),
      'started_at': serializer.toJson<int>(startedAt),
      'completed_at': serializer.toJson<int?>(completedAt),
      'status': serializer.toJson<String>(status),
      'devices_found': serializer.toJson<int>(devicesFound),
      'addresses_checked': serializer.toJson<int>(addressesChecked),
      'total_candidates': serializer.toJson<int>(totalCandidates),
      'discovery_methods': serializer.toJson<String>(discoveryMethods),
      'message': serializer.toJson<String?>(message),
    };
  }

  NetworkScan copyWith({
    int? id,
    int? networkId,
    int? startedAt,
    Value<int?> completedAt = const Value.absent(),
    String? status,
    int? devicesFound,
    int? addressesChecked,
    int? totalCandidates,
    String? discoveryMethods,
    Value<String?> message = const Value.absent(),
  }) => NetworkScan(
    id: id ?? this.id,
    networkId: networkId ?? this.networkId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    status: status ?? this.status,
    devicesFound: devicesFound ?? this.devicesFound,
    addressesChecked: addressesChecked ?? this.addressesChecked,
    totalCandidates: totalCandidates ?? this.totalCandidates,
    discoveryMethods: discoveryMethods ?? this.discoveryMethods,
    message: message.present ? message.value : this.message,
  );
  NetworkScan copyWithCompanion(NetworkScansCompanion data) {
    return NetworkScan(
      id: data.id.present ? data.id.value : this.id,
      networkId: data.networkId.present ? data.networkId.value : this.networkId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      status: data.status.present ? data.status.value : this.status,
      devicesFound: data.devicesFound.present
          ? data.devicesFound.value
          : this.devicesFound,
      addressesChecked: data.addressesChecked.present
          ? data.addressesChecked.value
          : this.addressesChecked,
      totalCandidates: data.totalCandidates.present
          ? data.totalCandidates.value
          : this.totalCandidates,
      discoveryMethods: data.discoveryMethods.present
          ? data.discoveryMethods.value
          : this.discoveryMethods,
      message: data.message.present ? data.message.value : this.message,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetworkScan(')
          ..write('id: $id, ')
          ..write('networkId: $networkId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('devicesFound: $devicesFound, ')
          ..write('addressesChecked: $addressesChecked, ')
          ..write('totalCandidates: $totalCandidates, ')
          ..write('discoveryMethods: $discoveryMethods, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    networkId,
    startedAt,
    completedAt,
    status,
    devicesFound,
    addressesChecked,
    totalCandidates,
    discoveryMethods,
    message,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetworkScan &&
          other.id == this.id &&
          other.networkId == this.networkId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.status == this.status &&
          other.devicesFound == this.devicesFound &&
          other.addressesChecked == this.addressesChecked &&
          other.totalCandidates == this.totalCandidates &&
          other.discoveryMethods == this.discoveryMethods &&
          other.message == this.message);
}

class NetworkScansCompanion extends UpdateCompanion<NetworkScan> {
  final Value<int> id;
  final Value<int> networkId;
  final Value<int> startedAt;
  final Value<int?> completedAt;
  final Value<String> status;
  final Value<int> devicesFound;
  final Value<int> addressesChecked;
  final Value<int> totalCandidates;
  final Value<String> discoveryMethods;
  final Value<String?> message;
  const NetworkScansCompanion({
    this.id = const Value.absent(),
    this.networkId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.devicesFound = const Value.absent(),
    this.addressesChecked = const Value.absent(),
    this.totalCandidates = const Value.absent(),
    this.discoveryMethods = const Value.absent(),
    this.message = const Value.absent(),
  });
  NetworkScansCompanion.insert({
    this.id = const Value.absent(),
    required int networkId,
    required int startedAt,
    this.completedAt = const Value.absent(),
    required String status,
    required int devicesFound,
    required int addressesChecked,
    required int totalCandidates,
    required String discoveryMethods,
    this.message = const Value.absent(),
  }) : networkId = Value(networkId),
       startedAt = Value(startedAt),
       status = Value(status),
       devicesFound = Value(devicesFound),
       addressesChecked = Value(addressesChecked),
       totalCandidates = Value(totalCandidates),
       discoveryMethods = Value(discoveryMethods);
  static Insertable<NetworkScan> custom({
    Expression<int>? id,
    Expression<int>? networkId,
    Expression<int>? startedAt,
    Expression<int>? completedAt,
    Expression<String>? status,
    Expression<int>? devicesFound,
    Expression<int>? addressesChecked,
    Expression<int>? totalCandidates,
    Expression<String>? discoveryMethods,
    Expression<String>? message,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (networkId != null) 'network_id': networkId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (status != null) 'status': status,
      if (devicesFound != null) 'devices_found': devicesFound,
      if (addressesChecked != null) 'addresses_checked': addressesChecked,
      if (totalCandidates != null) 'total_candidates': totalCandidates,
      if (discoveryMethods != null) 'discovery_methods': discoveryMethods,
      if (message != null) 'message': message,
    });
  }

  NetworkScansCompanion copyWith({
    Value<int>? id,
    Value<int>? networkId,
    Value<int>? startedAt,
    Value<int?>? completedAt,
    Value<String>? status,
    Value<int>? devicesFound,
    Value<int>? addressesChecked,
    Value<int>? totalCandidates,
    Value<String>? discoveryMethods,
    Value<String?>? message,
  }) {
    return NetworkScansCompanion(
      id: id ?? this.id,
      networkId: networkId ?? this.networkId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      devicesFound: devicesFound ?? this.devicesFound,
      addressesChecked: addressesChecked ?? this.addressesChecked,
      totalCandidates: totalCandidates ?? this.totalCandidates,
      discoveryMethods: discoveryMethods ?? this.discoveryMethods,
      message: message ?? this.message,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (networkId.present) {
      map['network_id'] = Variable<int>(networkId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (devicesFound.present) {
      map['devices_found'] = Variable<int>(devicesFound.value);
    }
    if (addressesChecked.present) {
      map['addresses_checked'] = Variable<int>(addressesChecked.value);
    }
    if (totalCandidates.present) {
      map['total_candidates'] = Variable<int>(totalCandidates.value);
    }
    if (discoveryMethods.present) {
      map['discovery_methods'] = Variable<String>(discoveryMethods.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetworkScansCompanion(')
          ..write('id: $id, ')
          ..write('networkId: $networkId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('devicesFound: $devicesFound, ')
          ..write('addressesChecked: $addressesChecked, ')
          ..write('totalCandidates: $totalCandidates, ')
          ..write('discoveryMethods: $discoveryMethods, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final SavedNetworks savedNetworks = SavedNetworks(this);
  late final StoredDevices storedDevices = StoredDevices(this);
  late final Index devicesByNetwork = Index(
    'devices_by_network',
    'CREATE INDEX devices_by_network ON stored_devices (network_id)',
  );
  late final DeviceIdentities deviceIdentities = DeviceIdentities(this);
  late final DeviceIpHistory deviceIpHistory = DeviceIpHistory(this);
  late final DeviceServices deviceServices = DeviceServices(this);
  late final NetworkScans networkScans = NetworkScans(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    savedNetworks,
    storedDevices,
    devicesByNetwork,
    deviceIdentities,
    deviceIpHistory,
    deviceServices,
    networkScans,
  ];
}

typedef $SavedNetworksCreateCompanionBuilder =
    SavedNetworksCompanion Function({
      Value<int> id,
      required String stableKey,
      Value<String?> name,
      Value<String?> userName,
      required String networkAddress,
      required int prefixLength,
      Value<String?> gatewayAddress,
      Value<String?> interfaceName,
      required String connectionType,
      required int firstSeen,
      required int lastSeen,
      Value<int?> lastScanned,
      Value<int> scanCount,
    });
typedef $SavedNetworksUpdateCompanionBuilder =
    SavedNetworksCompanion Function({
      Value<int> id,
      Value<String> stableKey,
      Value<String?> name,
      Value<String?> userName,
      Value<String> networkAddress,
      Value<int> prefixLength,
      Value<String?> gatewayAddress,
      Value<String?> interfaceName,
      Value<String> connectionType,
      Value<int> firstSeen,
      Value<int> lastSeen,
      Value<int?> lastScanned,
      Value<int> scanCount,
    });

final class $SavedNetworksReferences
    extends BaseReferences<_$AppDatabase, SavedNetworks, SavedNetwork> {
  $SavedNetworksReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<StoredDevices, List<StoredDevice>>
  _storedDevicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.storedDevices,
    aliasName: 'saved_networks__id__stored_devices__network_id',
  );

  $StoredDevicesProcessedTableManager get storedDevicesRefs {
    final manager = $StoredDevicesTableManager(
      $_db,
      $_db.storedDevices,
    ).filter((f) => f.networkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_storedDevicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<DeviceIdentities, List<DeviceIdentity>>
  _deviceIdentitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deviceIdentities,
    aliasName: 'saved_networks__id__device_identities__network_id',
  );

  $DeviceIdentitiesProcessedTableManager get deviceIdentitiesRefs {
    final manager = $DeviceIdentitiesTableManager(
      $_db,
      $_db.deviceIdentities,
    ).filter((f) => f.networkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deviceIdentitiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<NetworkScans, List<NetworkScan>>
  _networkScansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.networkScans,
    aliasName: 'saved_networks__id__network_scans__network_id',
  );

  $NetworkScansProcessedTableManager get networkScansRefs {
    final manager = $NetworkScansTableManager(
      $_db,
      $_db.networkScans,
    ).filter((f) => f.networkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_networkScansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SavedNetworksFilterComposer
    extends Composer<_$AppDatabase, SavedNetworks> {
  $SavedNetworksFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get networkAddress => $composableBuilder(
    column: $table.networkAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prefixLength => $composableBuilder(
    column: $table.prefixLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gatewayAddress => $composableBuilder(
    column: $table.gatewayAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interfaceName => $composableBuilder(
    column: $table.interfaceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectionType => $composableBuilder(
    column: $table.connectionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastScanned => $composableBuilder(
    column: $table.lastScanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scanCount => $composableBuilder(
    column: $table.scanCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> storedDevicesRefs(
    Expression<bool> Function($StoredDevicesFilterComposer f) f,
  ) {
    final $StoredDevicesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.networkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesFilterComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deviceIdentitiesRefs(
    Expression<bool> Function($DeviceIdentitiesFilterComposer f) f,
  ) {
    final $DeviceIdentitiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.networkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeviceIdentitiesFilterComposer(
            $db: $db,
            $table: $db.deviceIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> networkScansRefs(
    Expression<bool> Function($NetworkScansFilterComposer f) f,
  ) {
    final $NetworkScansFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.networkScans,
      getReferencedColumn: (t) => t.networkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $NetworkScansFilterComposer(
            $db: $db,
            $table: $db.networkScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SavedNetworksOrderingComposer
    extends Composer<_$AppDatabase, SavedNetworks> {
  $SavedNetworksOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get networkAddress => $composableBuilder(
    column: $table.networkAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prefixLength => $composableBuilder(
    column: $table.prefixLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gatewayAddress => $composableBuilder(
    column: $table.gatewayAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interfaceName => $composableBuilder(
    column: $table.interfaceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectionType => $composableBuilder(
    column: $table.connectionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastScanned => $composableBuilder(
    column: $table.lastScanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scanCount => $composableBuilder(
    column: $table.scanCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SavedNetworksAnnotationComposer
    extends Composer<_$AppDatabase, SavedNetworks> {
  $SavedNetworksAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stableKey =>
      $composableBuilder(column: $table.stableKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get networkAddress => $composableBuilder(
    column: $table.networkAddress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get prefixLength => $composableBuilder(
    column: $table.prefixLength,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gatewayAddress => $composableBuilder(
    column: $table.gatewayAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interfaceName => $composableBuilder(
    column: $table.interfaceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get connectionType => $composableBuilder(
    column: $table.connectionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  GeneratedColumn<int> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<int> get lastScanned => $composableBuilder(
    column: $table.lastScanned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scanCount =>
      $composableBuilder(column: $table.scanCount, builder: (column) => column);

  Expression<T> storedDevicesRefs<T extends Object>(
    Expression<T> Function($StoredDevicesAnnotationComposer a) f,
  ) {
    final $StoredDevicesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.networkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesAnnotationComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deviceIdentitiesRefs<T extends Object>(
    Expression<T> Function($DeviceIdentitiesAnnotationComposer a) f,
  ) {
    final $DeviceIdentitiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.networkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeviceIdentitiesAnnotationComposer(
            $db: $db,
            $table: $db.deviceIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> networkScansRefs<T extends Object>(
    Expression<T> Function($NetworkScansAnnotationComposer a) f,
  ) {
    final $NetworkScansAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.networkScans,
      getReferencedColumn: (t) => t.networkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $NetworkScansAnnotationComposer(
            $db: $db,
            $table: $db.networkScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SavedNetworksTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SavedNetworks,
          SavedNetwork,
          $SavedNetworksFilterComposer,
          $SavedNetworksOrderingComposer,
          $SavedNetworksAnnotationComposer,
          $SavedNetworksCreateCompanionBuilder,
          $SavedNetworksUpdateCompanionBuilder,
          (SavedNetwork, $SavedNetworksReferences),
          SavedNetwork,
          PrefetchHooks Function({
            bool storedDevicesRefs,
            bool deviceIdentitiesRefs,
            bool networkScansRefs,
          })
        > {
  $SavedNetworksTableManager(_$AppDatabase db, SavedNetworks table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SavedNetworksFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SavedNetworksOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SavedNetworksAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> stableKey = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<String> networkAddress = const Value.absent(),
                Value<int> prefixLength = const Value.absent(),
                Value<String?> gatewayAddress = const Value.absent(),
                Value<String?> interfaceName = const Value.absent(),
                Value<String> connectionType = const Value.absent(),
                Value<int> firstSeen = const Value.absent(),
                Value<int> lastSeen = const Value.absent(),
                Value<int?> lastScanned = const Value.absent(),
                Value<int> scanCount = const Value.absent(),
              }) => SavedNetworksCompanion(
                id: id,
                stableKey: stableKey,
                name: name,
                userName: userName,
                networkAddress: networkAddress,
                prefixLength: prefixLength,
                gatewayAddress: gatewayAddress,
                interfaceName: interfaceName,
                connectionType: connectionType,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                lastScanned: lastScanned,
                scanCount: scanCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String stableKey,
                Value<String?> name = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                required String networkAddress,
                required int prefixLength,
                Value<String?> gatewayAddress = const Value.absent(),
                Value<String?> interfaceName = const Value.absent(),
                required String connectionType,
                required int firstSeen,
                required int lastSeen,
                Value<int?> lastScanned = const Value.absent(),
                Value<int> scanCount = const Value.absent(),
              }) => SavedNetworksCompanion.insert(
                id: id,
                stableKey: stableKey,
                name: name,
                userName: userName,
                networkAddress: networkAddress,
                prefixLength: prefixLength,
                gatewayAddress: gatewayAddress,
                interfaceName: interfaceName,
                connectionType: connectionType,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                lastScanned: lastScanned,
                scanCount: scanCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SavedNetworks, SavedNetwork>(table),
                  $SavedNetworksReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                storedDevicesRefs = false,
                deviceIdentitiesRefs = false,
                networkScansRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (storedDevicesRefs) db.storedDevices,
                    if (deviceIdentitiesRefs) db.deviceIdentities,
                    if (networkScansRefs) db.networkScans,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (storedDevicesRefs)
                        await $_getPrefetchedData<
                          SavedNetwork,
                          SavedNetworks,
                          StoredDevice
                        >(
                          currentTable: table,
                          referencedTable: $SavedNetworksReferences
                              ._storedDevicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $SavedNetworksReferences(
                                db,
                                table,
                                p0,
                              ).storedDevicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.networkId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deviceIdentitiesRefs)
                        await $_getPrefetchedData<
                          SavedNetwork,
                          SavedNetworks,
                          DeviceIdentity
                        >(
                          currentTable: table,
                          referencedTable: $SavedNetworksReferences
                              ._deviceIdentitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $SavedNetworksReferences(
                                db,
                                table,
                                p0,
                              ).deviceIdentitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.networkId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (networkScansRefs)
                        await $_getPrefetchedData<
                          SavedNetwork,
                          SavedNetworks,
                          NetworkScan
                        >(
                          currentTable: table,
                          referencedTable: $SavedNetworksReferences
                              ._networkScansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $SavedNetworksReferences(
                                db,
                                table,
                                p0,
                              ).networkScansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.networkId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $SavedNetworksProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SavedNetworks,
      SavedNetwork,
      $SavedNetworksFilterComposer,
      $SavedNetworksOrderingComposer,
      $SavedNetworksAnnotationComposer,
      $SavedNetworksCreateCompanionBuilder,
      $SavedNetworksUpdateCompanionBuilder,
      (SavedNetwork, $SavedNetworksReferences),
      SavedNetwork,
      PrefetchHooks Function({
        bool storedDevicesRefs,
        bool deviceIdentitiesRefs,
        bool networkScansRefs,
      })
    >;
typedef $StoredDevicesCreateCompanionBuilder =
    StoredDevicesCompanion Function({
      Value<int> id,
      required int networkId,
      required String identityKey,
      Value<String?> customName,
      Value<String> notes,
      Value<String> classification,
      required String ipAddress,
      Value<String?> macAddress,
      Value<int> privateMac,
      Value<String?> discoveredName,
      Value<String?> hostname,
      Value<String?> manufacturer,
      Value<String?> macVendor,
      Value<String?> modelName,
      Value<String?> modelNumber,
      Value<String?> modelDescription,
      required String deviceType,
      required String confidence,
      required int isGateway,
      required int isCurrentDevice,
      required int firstSeen,
      required int lastSeen,
      Value<int> online,
      required String detailsJson,
    });
typedef $StoredDevicesUpdateCompanionBuilder =
    StoredDevicesCompanion Function({
      Value<int> id,
      Value<int> networkId,
      Value<String> identityKey,
      Value<String?> customName,
      Value<String> notes,
      Value<String> classification,
      Value<String> ipAddress,
      Value<String?> macAddress,
      Value<int> privateMac,
      Value<String?> discoveredName,
      Value<String?> hostname,
      Value<String?> manufacturer,
      Value<String?> macVendor,
      Value<String?> modelName,
      Value<String?> modelNumber,
      Value<String?> modelDescription,
      Value<String> deviceType,
      Value<String> confidence,
      Value<int> isGateway,
      Value<int> isCurrentDevice,
      Value<int> firstSeen,
      Value<int> lastSeen,
      Value<int> online,
      Value<String> detailsJson,
    });

final class $StoredDevicesReferences
    extends BaseReferences<_$AppDatabase, StoredDevices, StoredDevice> {
  $StoredDevicesReferences(super.$_db, super.$_table, super.$_typedResult);

  static SavedNetworks _networkIdTable(_$AppDatabase db) => db.savedNetworks
      .createAlias('stored_devices__network_id__saved_networks__id');

  $SavedNetworksProcessedTableManager get networkId {
    final $_column = $_itemColumn<int>('network_id')!;

    final manager = $SavedNetworksTableManager(
      $_db,
      $_db.savedNetworks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_networkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<DeviceIdentities, List<DeviceIdentity>>
  _deviceIdentitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deviceIdentities,
    aliasName: 'stored_devices__id__device_identities__device_id',
  );

  $DeviceIdentitiesProcessedTableManager get deviceIdentitiesRefs {
    final manager = $DeviceIdentitiesTableManager(
      $_db,
      $_db.deviceIdentities,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deviceIdentitiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<DeviceIpHistory, List<DeviceIpHistoryData>>
  _deviceIpHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deviceIpHistory,
    aliasName: 'stored_devices__id__device_ip_history__device_id',
  );

  $DeviceIpHistoryProcessedTableManager get deviceIpHistoryRefs {
    final manager = $DeviceIpHistoryTableManager(
      $_db,
      $_db.deviceIpHistory,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deviceIpHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<DeviceServices, List<DeviceService>>
  _deviceServicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deviceServices,
    aliasName: 'stored_devices__id__device_services__device_id',
  );

  $DeviceServicesProcessedTableManager get deviceServicesRefs {
    final manager = $DeviceServicesTableManager(
      $_db,
      $_db.deviceServices,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_deviceServicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $StoredDevicesFilterComposer
    extends Composer<_$AppDatabase, StoredDevices> {
  $StoredDevicesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identityKey => $composableBuilder(
    column: $table.identityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get macAddress => $composableBuilder(
    column: $table.macAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get privateMac => $composableBuilder(
    column: $table.privateMac,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discoveredName => $composableBuilder(
    column: $table.discoveredName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostname => $composableBuilder(
    column: $table.hostname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get macVendor => $composableBuilder(
    column: $table.macVendor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelNumber => $composableBuilder(
    column: $table.modelNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelDescription => $composableBuilder(
    column: $table.modelDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isGateway => $composableBuilder(
    column: $table.isGateway,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isCurrentDevice => $composableBuilder(
    column: $table.isCurrentDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get online => $composableBuilder(
    column: $table.online,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  $SavedNetworksFilterComposer get networkId {
    final $SavedNetworksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.savedNetworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SavedNetworksFilterComposer(
            $db: $db,
            $table: $db.savedNetworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> deviceIdentitiesRefs(
    Expression<bool> Function($DeviceIdentitiesFilterComposer f) f,
  ) {
    final $DeviceIdentitiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeviceIdentitiesFilterComposer(
            $db: $db,
            $table: $db.deviceIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deviceIpHistoryRefs(
    Expression<bool> Function($DeviceIpHistoryFilterComposer f) f,
  ) {
    final $DeviceIpHistoryFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceIpHistory,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeviceIpHistoryFilterComposer(
            $db: $db,
            $table: $db.deviceIpHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deviceServicesRefs(
    Expression<bool> Function($DeviceServicesFilterComposer f) f,
  ) {
    final $DeviceServicesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceServices,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeviceServicesFilterComposer(
            $db: $db,
            $table: $db.deviceServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $StoredDevicesOrderingComposer
    extends Composer<_$AppDatabase, StoredDevices> {
  $StoredDevicesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identityKey => $composableBuilder(
    column: $table.identityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get macAddress => $composableBuilder(
    column: $table.macAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get privateMac => $composableBuilder(
    column: $table.privateMac,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discoveredName => $composableBuilder(
    column: $table.discoveredName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostname => $composableBuilder(
    column: $table.hostname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get macVendor => $composableBuilder(
    column: $table.macVendor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelNumber => $composableBuilder(
    column: $table.modelNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelDescription => $composableBuilder(
    column: $table.modelDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isGateway => $composableBuilder(
    column: $table.isGateway,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isCurrentDevice => $composableBuilder(
    column: $table.isCurrentDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get online => $composableBuilder(
    column: $table.online,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $SavedNetworksOrderingComposer get networkId {
    final $SavedNetworksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.savedNetworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SavedNetworksOrderingComposer(
            $db: $db,
            $table: $db.savedNetworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $StoredDevicesAnnotationComposer
    extends Composer<_$AppDatabase, StoredDevices> {
  $StoredDevicesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get identityKey => $composableBuilder(
    column: $table.identityKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<String> get macAddress => $composableBuilder(
    column: $table.macAddress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get privateMac => $composableBuilder(
    column: $table.privateMac,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discoveredName => $composableBuilder(
    column: $table.discoveredName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hostname =>
      $composableBuilder(column: $table.hostname, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get macVendor =>
      $composableBuilder(column: $table.macVendor, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get modelNumber => $composableBuilder(
    column: $table.modelNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelDescription => $composableBuilder(
    column: $table.modelDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isGateway =>
      $composableBuilder(column: $table.isGateway, builder: (column) => column);

  GeneratedColumn<int> get isCurrentDevice => $composableBuilder(
    column: $table.isCurrentDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  GeneratedColumn<int> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<int> get online =>
      $composableBuilder(column: $table.online, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  $SavedNetworksAnnotationComposer get networkId {
    final $SavedNetworksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.savedNetworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SavedNetworksAnnotationComposer(
            $db: $db,
            $table: $db.savedNetworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> deviceIdentitiesRefs<T extends Object>(
    Expression<T> Function($DeviceIdentitiesAnnotationComposer a) f,
  ) {
    final $DeviceIdentitiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeviceIdentitiesAnnotationComposer(
            $db: $db,
            $table: $db.deviceIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deviceIpHistoryRefs<T extends Object>(
    Expression<T> Function($DeviceIpHistoryAnnotationComposer a) f,
  ) {
    final $DeviceIpHistoryAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceIpHistory,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeviceIpHistoryAnnotationComposer(
            $db: $db,
            $table: $db.deviceIpHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deviceServicesRefs<T extends Object>(
    Expression<T> Function($DeviceServicesAnnotationComposer a) f,
  ) {
    final $DeviceServicesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceServices,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeviceServicesAnnotationComposer(
            $db: $db,
            $table: $db.deviceServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $StoredDevicesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          StoredDevices,
          StoredDevice,
          $StoredDevicesFilterComposer,
          $StoredDevicesOrderingComposer,
          $StoredDevicesAnnotationComposer,
          $StoredDevicesCreateCompanionBuilder,
          $StoredDevicesUpdateCompanionBuilder,
          (StoredDevice, $StoredDevicesReferences),
          StoredDevice,
          PrefetchHooks Function({
            bool networkId,
            bool deviceIdentitiesRefs,
            bool deviceIpHistoryRefs,
            bool deviceServicesRefs,
          })
        > {
  $StoredDevicesTableManager(_$AppDatabase db, StoredDevices table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $StoredDevicesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $StoredDevicesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $StoredDevicesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> networkId = const Value.absent(),
                Value<String> identityKey = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> classification = const Value.absent(),
                Value<String> ipAddress = const Value.absent(),
                Value<String?> macAddress = const Value.absent(),
                Value<int> privateMac = const Value.absent(),
                Value<String?> discoveredName = const Value.absent(),
                Value<String?> hostname = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> macVendor = const Value.absent(),
                Value<String?> modelName = const Value.absent(),
                Value<String?> modelNumber = const Value.absent(),
                Value<String?> modelDescription = const Value.absent(),
                Value<String> deviceType = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<int> isGateway = const Value.absent(),
                Value<int> isCurrentDevice = const Value.absent(),
                Value<int> firstSeen = const Value.absent(),
                Value<int> lastSeen = const Value.absent(),
                Value<int> online = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
              }) => StoredDevicesCompanion(
                id: id,
                networkId: networkId,
                identityKey: identityKey,
                customName: customName,
                notes: notes,
                classification: classification,
                ipAddress: ipAddress,
                macAddress: macAddress,
                privateMac: privateMac,
                discoveredName: discoveredName,
                hostname: hostname,
                manufacturer: manufacturer,
                macVendor: macVendor,
                modelName: modelName,
                modelNumber: modelNumber,
                modelDescription: modelDescription,
                deviceType: deviceType,
                confidence: confidence,
                isGateway: isGateway,
                isCurrentDevice: isCurrentDevice,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                online: online,
                detailsJson: detailsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int networkId,
                required String identityKey,
                Value<String?> customName = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> classification = const Value.absent(),
                required String ipAddress,
                Value<String?> macAddress = const Value.absent(),
                Value<int> privateMac = const Value.absent(),
                Value<String?> discoveredName = const Value.absent(),
                Value<String?> hostname = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> macVendor = const Value.absent(),
                Value<String?> modelName = const Value.absent(),
                Value<String?> modelNumber = const Value.absent(),
                Value<String?> modelDescription = const Value.absent(),
                required String deviceType,
                required String confidence,
                required int isGateway,
                required int isCurrentDevice,
                required int firstSeen,
                required int lastSeen,
                Value<int> online = const Value.absent(),
                required String detailsJson,
              }) => StoredDevicesCompanion.insert(
                id: id,
                networkId: networkId,
                identityKey: identityKey,
                customName: customName,
                notes: notes,
                classification: classification,
                ipAddress: ipAddress,
                macAddress: macAddress,
                privateMac: privateMac,
                discoveredName: discoveredName,
                hostname: hostname,
                manufacturer: manufacturer,
                macVendor: macVendor,
                modelName: modelName,
                modelNumber: modelNumber,
                modelDescription: modelDescription,
                deviceType: deviceType,
                confidence: confidence,
                isGateway: isGateway,
                isCurrentDevice: isCurrentDevice,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                online: online,
                detailsJson: detailsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<StoredDevices, StoredDevice>(table),
                  $StoredDevicesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                networkId = false,
                deviceIdentitiesRefs = false,
                deviceIpHistoryRefs = false,
                deviceServicesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (deviceIdentitiesRefs) db.deviceIdentities,
                    if (deviceIpHistoryRefs) db.deviceIpHistory,
                    if (deviceServicesRefs) db.deviceServices,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (networkId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.networkId,
                                    referencedTable: $StoredDevicesReferences
                                        ._networkIdTable(db),
                                    referencedColumn: $StoredDevicesReferences
                                        ._networkIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (deviceIdentitiesRefs)
                        await $_getPrefetchedData<
                          StoredDevice,
                          StoredDevices,
                          DeviceIdentity
                        >(
                          currentTable: table,
                          referencedTable: $StoredDevicesReferences
                              ._deviceIdentitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $StoredDevicesReferences(
                                db,
                                table,
                                p0,
                              ).deviceIdentitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deviceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deviceIpHistoryRefs)
                        await $_getPrefetchedData<
                          StoredDevice,
                          StoredDevices,
                          DeviceIpHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $StoredDevicesReferences
                              ._deviceIpHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $StoredDevicesReferences(
                                db,
                                table,
                                p0,
                              ).deviceIpHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deviceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deviceServicesRefs)
                        await $_getPrefetchedData<
                          StoredDevice,
                          StoredDevices,
                          DeviceService
                        >(
                          currentTable: table,
                          referencedTable: $StoredDevicesReferences
                              ._deviceServicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $StoredDevicesReferences(
                                db,
                                table,
                                p0,
                              ).deviceServicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deviceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $StoredDevicesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      StoredDevices,
      StoredDevice,
      $StoredDevicesFilterComposer,
      $StoredDevicesOrderingComposer,
      $StoredDevicesAnnotationComposer,
      $StoredDevicesCreateCompanionBuilder,
      $StoredDevicesUpdateCompanionBuilder,
      (StoredDevice, $StoredDevicesReferences),
      StoredDevice,
      PrefetchHooks Function({
        bool networkId,
        bool deviceIdentitiesRefs,
        bool deviceIpHistoryRefs,
        bool deviceServicesRefs,
      })
    >;
typedef $DeviceIdentitiesCreateCompanionBuilder =
    DeviceIdentitiesCompanion Function({
      required int networkId,
      required String identityKey,
      required int deviceId,
      Value<int> rowid,
    });
typedef $DeviceIdentitiesUpdateCompanionBuilder =
    DeviceIdentitiesCompanion Function({
      Value<int> networkId,
      Value<String> identityKey,
      Value<int> deviceId,
      Value<int> rowid,
    });

final class $DeviceIdentitiesReferences
    extends BaseReferences<_$AppDatabase, DeviceIdentities, DeviceIdentity> {
  $DeviceIdentitiesReferences(super.$_db, super.$_table, super.$_typedResult);

  static SavedNetworks _networkIdTable(_$AppDatabase db) => db.savedNetworks
      .createAlias('device_identities__network_id__saved_networks__id');

  $SavedNetworksProcessedTableManager get networkId {
    final $_column = $_itemColumn<int>('network_id')!;

    final manager = $SavedNetworksTableManager(
      $_db,
      $_db.savedNetworks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_networkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static StoredDevices _deviceIdTable(_$AppDatabase db) => db.storedDevices
      .createAlias('device_identities__device_id__stored_devices__id');

  $StoredDevicesProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $StoredDevicesTableManager(
      $_db,
      $_db.storedDevices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $DeviceIdentitiesFilterComposer
    extends Composer<_$AppDatabase, DeviceIdentities> {
  $DeviceIdentitiesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get identityKey => $composableBuilder(
    column: $table.identityKey,
    builder: (column) => ColumnFilters(column),
  );

  $SavedNetworksFilterComposer get networkId {
    final $SavedNetworksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.savedNetworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SavedNetworksFilterComposer(
            $db: $db,
            $table: $db.savedNetworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StoredDevicesFilterComposer get deviceId {
    final $StoredDevicesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesFilterComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DeviceIdentitiesOrderingComposer
    extends Composer<_$AppDatabase, DeviceIdentities> {
  $DeviceIdentitiesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get identityKey => $composableBuilder(
    column: $table.identityKey,
    builder: (column) => ColumnOrderings(column),
  );

  $SavedNetworksOrderingComposer get networkId {
    final $SavedNetworksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.savedNetworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SavedNetworksOrderingComposer(
            $db: $db,
            $table: $db.savedNetworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StoredDevicesOrderingComposer get deviceId {
    final $StoredDevicesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesOrderingComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DeviceIdentitiesAnnotationComposer
    extends Composer<_$AppDatabase, DeviceIdentities> {
  $DeviceIdentitiesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get identityKey => $composableBuilder(
    column: $table.identityKey,
    builder: (column) => column,
  );

  $SavedNetworksAnnotationComposer get networkId {
    final $SavedNetworksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.savedNetworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SavedNetworksAnnotationComposer(
            $db: $db,
            $table: $db.savedNetworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StoredDevicesAnnotationComposer get deviceId {
    final $StoredDevicesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesAnnotationComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DeviceIdentitiesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          DeviceIdentities,
          DeviceIdentity,
          $DeviceIdentitiesFilterComposer,
          $DeviceIdentitiesOrderingComposer,
          $DeviceIdentitiesAnnotationComposer,
          $DeviceIdentitiesCreateCompanionBuilder,
          $DeviceIdentitiesUpdateCompanionBuilder,
          (DeviceIdentity, $DeviceIdentitiesReferences),
          DeviceIdentity,
          PrefetchHooks Function({bool networkId, bool deviceId})
        > {
  $DeviceIdentitiesTableManager(_$AppDatabase db, DeviceIdentities table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DeviceIdentitiesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DeviceIdentitiesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DeviceIdentitiesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> networkId = const Value.absent(),
                Value<String> identityKey = const Value.absent(),
                Value<int> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceIdentitiesCompanion(
                networkId: networkId,
                identityKey: identityKey,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int networkId,
                required String identityKey,
                required int deviceId,
                Value<int> rowid = const Value.absent(),
              }) => DeviceIdentitiesCompanion.insert(
                networkId: networkId,
                identityKey: identityKey,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<DeviceIdentities, DeviceIdentity>(table),
                  $DeviceIdentitiesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({networkId = false, deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (networkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.networkId,
                                referencedTable: $DeviceIdentitiesReferences
                                    ._networkIdTable(db),
                                referencedColumn: $DeviceIdentitiesReferences
                                    ._networkIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (deviceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deviceId,
                                referencedTable: $DeviceIdentitiesReferences
                                    ._deviceIdTable(db),
                                referencedColumn: $DeviceIdentitiesReferences
                                    ._deviceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $DeviceIdentitiesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      DeviceIdentities,
      DeviceIdentity,
      $DeviceIdentitiesFilterComposer,
      $DeviceIdentitiesOrderingComposer,
      $DeviceIdentitiesAnnotationComposer,
      $DeviceIdentitiesCreateCompanionBuilder,
      $DeviceIdentitiesUpdateCompanionBuilder,
      (DeviceIdentity, $DeviceIdentitiesReferences),
      DeviceIdentity,
      PrefetchHooks Function({bool networkId, bool deviceId})
    >;
typedef $DeviceIpHistoryCreateCompanionBuilder =
    DeviceIpHistoryCompanion Function({
      required int deviceId,
      required String ipAddress,
      required int firstSeen,
      required int lastSeen,
      Value<int> rowid,
    });
typedef $DeviceIpHistoryUpdateCompanionBuilder =
    DeviceIpHistoryCompanion Function({
      Value<int> deviceId,
      Value<String> ipAddress,
      Value<int> firstSeen,
      Value<int> lastSeen,
      Value<int> rowid,
    });

final class $DeviceIpHistoryReferences
    extends
        BaseReferences<_$AppDatabase, DeviceIpHistory, DeviceIpHistoryData> {
  $DeviceIpHistoryReferences(super.$_db, super.$_table, super.$_typedResult);

  static StoredDevices _deviceIdTable(_$AppDatabase db) => db.storedDevices
      .createAlias('device_ip_history__device_id__stored_devices__id');

  $StoredDevicesProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $StoredDevicesTableManager(
      $_db,
      $_db.storedDevices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $DeviceIpHistoryFilterComposer
    extends Composer<_$AppDatabase, DeviceIpHistory> {
  $DeviceIpHistoryFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  $StoredDevicesFilterComposer get deviceId {
    final $StoredDevicesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesFilterComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DeviceIpHistoryOrderingComposer
    extends Composer<_$AppDatabase, DeviceIpHistory> {
  $DeviceIpHistoryOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  $StoredDevicesOrderingComposer get deviceId {
    final $StoredDevicesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesOrderingComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DeviceIpHistoryAnnotationComposer
    extends Composer<_$AppDatabase, DeviceIpHistory> {
  $DeviceIpHistoryAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<int> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  GeneratedColumn<int> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  $StoredDevicesAnnotationComposer get deviceId {
    final $StoredDevicesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesAnnotationComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DeviceIpHistoryTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          DeviceIpHistory,
          DeviceIpHistoryData,
          $DeviceIpHistoryFilterComposer,
          $DeviceIpHistoryOrderingComposer,
          $DeviceIpHistoryAnnotationComposer,
          $DeviceIpHistoryCreateCompanionBuilder,
          $DeviceIpHistoryUpdateCompanionBuilder,
          (DeviceIpHistoryData, $DeviceIpHistoryReferences),
          DeviceIpHistoryData,
          PrefetchHooks Function({bool deviceId})
        > {
  $DeviceIpHistoryTableManager(_$AppDatabase db, DeviceIpHistory table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DeviceIpHistoryFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DeviceIpHistoryOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DeviceIpHistoryAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> deviceId = const Value.absent(),
                Value<String> ipAddress = const Value.absent(),
                Value<int> firstSeen = const Value.absent(),
                Value<int> lastSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceIpHistoryCompanion(
                deviceId: deviceId,
                ipAddress: ipAddress,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int deviceId,
                required String ipAddress,
                required int firstSeen,
                required int lastSeen,
                Value<int> rowid = const Value.absent(),
              }) => DeviceIpHistoryCompanion.insert(
                deviceId: deviceId,
                ipAddress: ipAddress,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<DeviceIpHistory, DeviceIpHistoryData>(table),
                  $DeviceIpHistoryReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deviceId,
                                referencedTable: $DeviceIpHistoryReferences
                                    ._deviceIdTable(db),
                                referencedColumn: $DeviceIpHistoryReferences
                                    ._deviceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $DeviceIpHistoryProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      DeviceIpHistory,
      DeviceIpHistoryData,
      $DeviceIpHistoryFilterComposer,
      $DeviceIpHistoryOrderingComposer,
      $DeviceIpHistoryAnnotationComposer,
      $DeviceIpHistoryCreateCompanionBuilder,
      $DeviceIpHistoryUpdateCompanionBuilder,
      (DeviceIpHistoryData, $DeviceIpHistoryReferences),
      DeviceIpHistoryData,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $DeviceServicesCreateCompanionBuilder =
    DeviceServicesCompanion Function({
      Value<int> id,
      required int deviceId,
      required String serviceKey,
      required String serviceType,
      required String serviceName,
      required String discoveryMethod,
      Value<String?> host,
      Value<int?> port,
      required String transport,
      required int firstSeen,
      required int lastSeen,
      required String detailsJson,
    });
typedef $DeviceServicesUpdateCompanionBuilder =
    DeviceServicesCompanion Function({
      Value<int> id,
      Value<int> deviceId,
      Value<String> serviceKey,
      Value<String> serviceType,
      Value<String> serviceName,
      Value<String> discoveryMethod,
      Value<String?> host,
      Value<int?> port,
      Value<String> transport,
      Value<int> firstSeen,
      Value<int> lastSeen,
      Value<String> detailsJson,
    });

final class $DeviceServicesReferences
    extends BaseReferences<_$AppDatabase, DeviceServices, DeviceService> {
  $DeviceServicesReferences(super.$_db, super.$_table, super.$_typedResult);

  static StoredDevices _deviceIdTable(_$AppDatabase db) => db.storedDevices
      .createAlias('device_services__device_id__stored_devices__id');

  $StoredDevicesProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $StoredDevicesTableManager(
      $_db,
      $_db.storedDevices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $DeviceServicesFilterComposer
    extends Composer<_$AppDatabase, DeviceServices> {
  $DeviceServicesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceKey => $composableBuilder(
    column: $table.serviceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discoveryMethod => $composableBuilder(
    column: $table.discoveryMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transport => $composableBuilder(
    column: $table.transport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  $StoredDevicesFilterComposer get deviceId {
    final $StoredDevicesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesFilterComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DeviceServicesOrderingComposer
    extends Composer<_$AppDatabase, DeviceServices> {
  $DeviceServicesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceKey => $composableBuilder(
    column: $table.serviceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discoveryMethod => $composableBuilder(
    column: $table.discoveryMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transport => $composableBuilder(
    column: $table.transport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $StoredDevicesOrderingComposer get deviceId {
    final $StoredDevicesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesOrderingComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DeviceServicesAnnotationComposer
    extends Composer<_$AppDatabase, DeviceServices> {
  $DeviceServicesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceKey => $composableBuilder(
    column: $table.serviceKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discoveryMethod => $composableBuilder(
    column: $table.discoveryMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get transport =>
      $composableBuilder(column: $table.transport, builder: (column) => column);

  GeneratedColumn<int> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  GeneratedColumn<int> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  $StoredDevicesAnnotationComposer get deviceId {
    final $StoredDevicesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.storedDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StoredDevicesAnnotationComposer(
            $db: $db,
            $table: $db.storedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DeviceServicesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          DeviceServices,
          DeviceService,
          $DeviceServicesFilterComposer,
          $DeviceServicesOrderingComposer,
          $DeviceServicesAnnotationComposer,
          $DeviceServicesCreateCompanionBuilder,
          $DeviceServicesUpdateCompanionBuilder,
          (DeviceService, $DeviceServicesReferences),
          DeviceService,
          PrefetchHooks Function({bool deviceId})
        > {
  $DeviceServicesTableManager(_$AppDatabase db, DeviceServices table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DeviceServicesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DeviceServicesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DeviceServicesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deviceId = const Value.absent(),
                Value<String> serviceKey = const Value.absent(),
                Value<String> serviceType = const Value.absent(),
                Value<String> serviceName = const Value.absent(),
                Value<String> discoveryMethod = const Value.absent(),
                Value<String?> host = const Value.absent(),
                Value<int?> port = const Value.absent(),
                Value<String> transport = const Value.absent(),
                Value<int> firstSeen = const Value.absent(),
                Value<int> lastSeen = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
              }) => DeviceServicesCompanion(
                id: id,
                deviceId: deviceId,
                serviceKey: serviceKey,
                serviceType: serviceType,
                serviceName: serviceName,
                discoveryMethod: discoveryMethod,
                host: host,
                port: port,
                transport: transport,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                detailsJson: detailsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deviceId,
                required String serviceKey,
                required String serviceType,
                required String serviceName,
                required String discoveryMethod,
                Value<String?> host = const Value.absent(),
                Value<int?> port = const Value.absent(),
                required String transport,
                required int firstSeen,
                required int lastSeen,
                required String detailsJson,
              }) => DeviceServicesCompanion.insert(
                id: id,
                deviceId: deviceId,
                serviceKey: serviceKey,
                serviceType: serviceType,
                serviceName: serviceName,
                discoveryMethod: discoveryMethod,
                host: host,
                port: port,
                transport: transport,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                detailsJson: detailsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<DeviceServices, DeviceService>(table),
                  $DeviceServicesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deviceId,
                                referencedTable: $DeviceServicesReferences
                                    ._deviceIdTable(db),
                                referencedColumn: $DeviceServicesReferences
                                    ._deviceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $DeviceServicesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      DeviceServices,
      DeviceService,
      $DeviceServicesFilterComposer,
      $DeviceServicesOrderingComposer,
      $DeviceServicesAnnotationComposer,
      $DeviceServicesCreateCompanionBuilder,
      $DeviceServicesUpdateCompanionBuilder,
      (DeviceService, $DeviceServicesReferences),
      DeviceService,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $NetworkScansCreateCompanionBuilder =
    NetworkScansCompanion Function({
      Value<int> id,
      required int networkId,
      required int startedAt,
      Value<int?> completedAt,
      required String status,
      required int devicesFound,
      required int addressesChecked,
      required int totalCandidates,
      required String discoveryMethods,
      Value<String?> message,
    });
typedef $NetworkScansUpdateCompanionBuilder =
    NetworkScansCompanion Function({
      Value<int> id,
      Value<int> networkId,
      Value<int> startedAt,
      Value<int?> completedAt,
      Value<String> status,
      Value<int> devicesFound,
      Value<int> addressesChecked,
      Value<int> totalCandidates,
      Value<String> discoveryMethods,
      Value<String?> message,
    });

final class $NetworkScansReferences
    extends BaseReferences<_$AppDatabase, NetworkScans, NetworkScan> {
  $NetworkScansReferences(super.$_db, super.$_table, super.$_typedResult);

  static SavedNetworks _networkIdTable(_$AppDatabase db) => db.savedNetworks
      .createAlias('network_scans__network_id__saved_networks__id');

  $SavedNetworksProcessedTableManager get networkId {
    final $_column = $_itemColumn<int>('network_id')!;

    final manager = $SavedNetworksTableManager(
      $_db,
      $_db.savedNetworks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_networkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $NetworkScansFilterComposer
    extends Composer<_$AppDatabase, NetworkScans> {
  $NetworkScansFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get devicesFound => $composableBuilder(
    column: $table.devicesFound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addressesChecked => $composableBuilder(
    column: $table.addressesChecked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCandidates => $composableBuilder(
    column: $table.totalCandidates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discoveryMethods => $composableBuilder(
    column: $table.discoveryMethods,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  $SavedNetworksFilterComposer get networkId {
    final $SavedNetworksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.savedNetworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SavedNetworksFilterComposer(
            $db: $db,
            $table: $db.savedNetworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $NetworkScansOrderingComposer
    extends Composer<_$AppDatabase, NetworkScans> {
  $NetworkScansOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get devicesFound => $composableBuilder(
    column: $table.devicesFound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addressesChecked => $composableBuilder(
    column: $table.addressesChecked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCandidates => $composableBuilder(
    column: $table.totalCandidates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discoveryMethods => $composableBuilder(
    column: $table.discoveryMethods,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  $SavedNetworksOrderingComposer get networkId {
    final $SavedNetworksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.savedNetworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SavedNetworksOrderingComposer(
            $db: $db,
            $table: $db.savedNetworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $NetworkScansAnnotationComposer
    extends Composer<_$AppDatabase, NetworkScans> {
  $NetworkScansAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get devicesFound => $composableBuilder(
    column: $table.devicesFound,
    builder: (column) => column,
  );

  GeneratedColumn<int> get addressesChecked => $composableBuilder(
    column: $table.addressesChecked,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCandidates => $composableBuilder(
    column: $table.totalCandidates,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discoveryMethods => $composableBuilder(
    column: $table.discoveryMethods,
    builder: (column) => column,
  );

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  $SavedNetworksAnnotationComposer get networkId {
    final $SavedNetworksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.savedNetworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SavedNetworksAnnotationComposer(
            $db: $db,
            $table: $db.savedNetworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $NetworkScansTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          NetworkScans,
          NetworkScan,
          $NetworkScansFilterComposer,
          $NetworkScansOrderingComposer,
          $NetworkScansAnnotationComposer,
          $NetworkScansCreateCompanionBuilder,
          $NetworkScansUpdateCompanionBuilder,
          (NetworkScan, $NetworkScansReferences),
          NetworkScan,
          PrefetchHooks Function({bool networkId})
        > {
  $NetworkScansTableManager(_$AppDatabase db, NetworkScans table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $NetworkScansFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $NetworkScansOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $NetworkScansAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> networkId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> devicesFound = const Value.absent(),
                Value<int> addressesChecked = const Value.absent(),
                Value<int> totalCandidates = const Value.absent(),
                Value<String> discoveryMethods = const Value.absent(),
                Value<String?> message = const Value.absent(),
              }) => NetworkScansCompanion(
                id: id,
                networkId: networkId,
                startedAt: startedAt,
                completedAt: completedAt,
                status: status,
                devicesFound: devicesFound,
                addressesChecked: addressesChecked,
                totalCandidates: totalCandidates,
                discoveryMethods: discoveryMethods,
                message: message,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int networkId,
                required int startedAt,
                Value<int?> completedAt = const Value.absent(),
                required String status,
                required int devicesFound,
                required int addressesChecked,
                required int totalCandidates,
                required String discoveryMethods,
                Value<String?> message = const Value.absent(),
              }) => NetworkScansCompanion.insert(
                id: id,
                networkId: networkId,
                startedAt: startedAt,
                completedAt: completedAt,
                status: status,
                devicesFound: devicesFound,
                addressesChecked: addressesChecked,
                totalCandidates: totalCandidates,
                discoveryMethods: discoveryMethods,
                message: message,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<NetworkScans, NetworkScan>(table),
                  $NetworkScansReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({networkId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (networkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.networkId,
                                referencedTable: $NetworkScansReferences
                                    ._networkIdTable(db),
                                referencedColumn: $NetworkScansReferences
                                    ._networkIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $NetworkScansProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      NetworkScans,
      NetworkScan,
      $NetworkScansFilterComposer,
      $NetworkScansOrderingComposer,
      $NetworkScansAnnotationComposer,
      $NetworkScansCreateCompanionBuilder,
      $NetworkScansUpdateCompanionBuilder,
      (NetworkScan, $NetworkScansReferences),
      NetworkScan,
      PrefetchHooks Function({bool networkId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $SavedNetworksTableManager get savedNetworks =>
      $SavedNetworksTableManager(_db, _db.savedNetworks);
  $StoredDevicesTableManager get storedDevices =>
      $StoredDevicesTableManager(_db, _db.storedDevices);
  $DeviceIdentitiesTableManager get deviceIdentities =>
      $DeviceIdentitiesTableManager(_db, _db.deviceIdentities);
  $DeviceIpHistoryTableManager get deviceIpHistory =>
      $DeviceIpHistoryTableManager(_db, _db.deviceIpHistory);
  $DeviceServicesTableManager get deviceServices =>
      $DeviceServicesTableManager(_db, _db.deviceServices);
  $NetworkScansTableManager get networkScans =>
      $NetworkScansTableManager(_db, _db.networkScans);
}
