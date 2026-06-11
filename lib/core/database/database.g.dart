// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RoisTable extends Rois with TableInfo<$RoisTable, Roi> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSharedMeta = const VerificationMeta(
    'isShared',
  );
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
    'is_shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isOfflineCachedMeta = const VerificationMeta(
    'isOfflineCached',
  );
  @override
  late final GeneratedColumn<int> isOfflineCached = GeneratedColumn<int>(
    'is_offline_cached',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  static const VerificationMeta _cloudVersionMeta = const VerificationMeta(
    'cloudVersion',
  );
  @override
  late final GeneratedColumn<int> cloudVersion = GeneratedColumn<int>(
    'cloud_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncLockExpiresAtMeta = const VerificationMeta(
    'syncLockExpiresAt',
  );
  @override
  late final GeneratedColumn<int> syncLockExpiresAt = GeneratedColumn<int>(
    'sync_lock_expires_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    authorId,
    isShared,
    isOfflineCached,
    createdAt,
    cloudVersion,
    syncLockExpiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rois';
  @override
  VerificationContext validateIntegrity(
    Insertable<Roi> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('is_shared')) {
      context.handle(
        _isSharedMeta,
        isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta),
      );
    }
    if (data.containsKey('is_offline_cached')) {
      context.handle(
        _isOfflineCachedMeta,
        isOfflineCached.isAcceptableOrUnknown(
          data['is_offline_cached']!,
          _isOfflineCachedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('cloud_version')) {
      context.handle(
        _cloudVersionMeta,
        cloudVersion.isAcceptableOrUnknown(
          data['cloud_version']!,
          _cloudVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_lock_expires_at')) {
      context.handle(
        _syncLockExpiresAtMeta,
        syncLockExpiresAt.isAcceptableOrUnknown(
          data['sync_lock_expires_at']!,
          _syncLockExpiresAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Roi map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Roi(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      isShared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared'],
      )!,
      isOfflineCached: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_offline_cached'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      cloudVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cloud_version'],
      )!,
      syncLockExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_lock_expires_at'],
      ),
    );
  }

  @override
  $RoisTable createAlias(String alias) {
    return $RoisTable(attachedDatabase, alias);
  }
}

class Roi extends DataClass implements Insertable<Roi> {
  final String id;
  final String name;
  final String? description;
  final String authorId;
  final bool isShared;
  final int isOfflineCached;
  final int createdAt;
  final int cloudVersion;
  final int? syncLockExpiresAt;
  const Roi({
    required this.id,
    required this.name,
    this.description,
    required this.authorId,
    required this.isShared,
    required this.isOfflineCached,
    required this.createdAt,
    required this.cloudVersion,
    this.syncLockExpiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['author_id'] = Variable<String>(authorId);
    map['is_shared'] = Variable<bool>(isShared);
    map['is_offline_cached'] = Variable<int>(isOfflineCached);
    map['created_at'] = Variable<int>(createdAt);
    map['cloud_version'] = Variable<int>(cloudVersion);
    if (!nullToAbsent || syncLockExpiresAt != null) {
      map['sync_lock_expires_at'] = Variable<int>(syncLockExpiresAt);
    }
    return map;
  }

  RoisCompanion toCompanion(bool nullToAbsent) {
    return RoisCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      authorId: Value(authorId),
      isShared: Value(isShared),
      isOfflineCached: Value(isOfflineCached),
      createdAt: Value(createdAt),
      cloudVersion: Value(cloudVersion),
      syncLockExpiresAt: syncLockExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncLockExpiresAt),
    );
  }

  factory Roi.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Roi(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      authorId: serializer.fromJson<String>(json['authorId']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      isOfflineCached: serializer.fromJson<int>(json['isOfflineCached']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      cloudVersion: serializer.fromJson<int>(json['cloudVersion']),
      syncLockExpiresAt: serializer.fromJson<int?>(json['syncLockExpiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'authorId': serializer.toJson<String>(authorId),
      'isShared': serializer.toJson<bool>(isShared),
      'isOfflineCached': serializer.toJson<int>(isOfflineCached),
      'createdAt': serializer.toJson<int>(createdAt),
      'cloudVersion': serializer.toJson<int>(cloudVersion),
      'syncLockExpiresAt': serializer.toJson<int?>(syncLockExpiresAt),
    };
  }

  Roi copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? authorId,
    bool? isShared,
    int? isOfflineCached,
    int? createdAt,
    int? cloudVersion,
    Value<int?> syncLockExpiresAt = const Value.absent(),
  }) => Roi(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    authorId: authorId ?? this.authorId,
    isShared: isShared ?? this.isShared,
    isOfflineCached: isOfflineCached ?? this.isOfflineCached,
    createdAt: createdAt ?? this.createdAt,
    cloudVersion: cloudVersion ?? this.cloudVersion,
    syncLockExpiresAt: syncLockExpiresAt.present
        ? syncLockExpiresAt.value
        : this.syncLockExpiresAt,
  );
  Roi copyWithCompanion(RoisCompanion data) {
    return Roi(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      isOfflineCached: data.isOfflineCached.present
          ? data.isOfflineCached.value
          : this.isOfflineCached,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cloudVersion: data.cloudVersion.present
          ? data.cloudVersion.value
          : this.cloudVersion,
      syncLockExpiresAt: data.syncLockExpiresAt.present
          ? data.syncLockExpiresAt.value
          : this.syncLockExpiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Roi(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('authorId: $authorId, ')
          ..write('isShared: $isShared, ')
          ..write('isOfflineCached: $isOfflineCached, ')
          ..write('createdAt: $createdAt, ')
          ..write('cloudVersion: $cloudVersion, ')
          ..write('syncLockExpiresAt: $syncLockExpiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    authorId,
    isShared,
    isOfflineCached,
    createdAt,
    cloudVersion,
    syncLockExpiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Roi &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.authorId == this.authorId &&
          other.isShared == this.isShared &&
          other.isOfflineCached == this.isOfflineCached &&
          other.createdAt == this.createdAt &&
          other.cloudVersion == this.cloudVersion &&
          other.syncLockExpiresAt == this.syncLockExpiresAt);
}

class RoisCompanion extends UpdateCompanion<Roi> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> authorId;
  final Value<bool> isShared;
  final Value<int> isOfflineCached;
  final Value<int> createdAt;
  final Value<int> cloudVersion;
  final Value<int?> syncLockExpiresAt;
  final Value<int> rowid;
  const RoisCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.authorId = const Value.absent(),
    this.isShared = const Value.absent(),
    this.isOfflineCached = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cloudVersion = const Value.absent(),
    this.syncLockExpiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoisCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String authorId,
    this.isShared = const Value.absent(),
    this.isOfflineCached = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cloudVersion = const Value.absent(),
    this.syncLockExpiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       authorId = Value(authorId);
  static Insertable<Roi> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? authorId,
    Expression<bool>? isShared,
    Expression<int>? isOfflineCached,
    Expression<int>? createdAt,
    Expression<int>? cloudVersion,
    Expression<int>? syncLockExpiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (authorId != null) 'author_id': authorId,
      if (isShared != null) 'is_shared': isShared,
      if (isOfflineCached != null) 'is_offline_cached': isOfflineCached,
      if (createdAt != null) 'created_at': createdAt,
      if (cloudVersion != null) 'cloud_version': cloudVersion,
      if (syncLockExpiresAt != null) 'sync_lock_expires_at': syncLockExpiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoisCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? authorId,
    Value<bool>? isShared,
    Value<int>? isOfflineCached,
    Value<int>? createdAt,
    Value<int>? cloudVersion,
    Value<int?>? syncLockExpiresAt,
    Value<int>? rowid,
  }) {
    return RoisCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      isShared: isShared ?? this.isShared,
      isOfflineCached: isOfflineCached ?? this.isOfflineCached,
      createdAt: createdAt ?? this.createdAt,
      cloudVersion: cloudVersion ?? this.cloudVersion,
      syncLockExpiresAt: syncLockExpiresAt ?? this.syncLockExpiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (isOfflineCached.present) {
      map['is_offline_cached'] = Variable<int>(isOfflineCached.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (cloudVersion.present) {
      map['cloud_version'] = Variable<int>(cloudVersion.value);
    }
    if (syncLockExpiresAt.present) {
      map['sync_lock_expires_at'] = Variable<int>(syncLockExpiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoisCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('authorId: $authorId, ')
          ..write('isShared: $isShared, ')
          ..write('isOfflineCached: $isOfflineCached, ')
          ..write('createdAt: $createdAt, ')
          ..write('cloudVersion: $cloudVersion, ')
          ..write('syncLockExpiresAt: $syncLockExpiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PoisTable extends Pois with TableInfo<$PoisTable, Poi> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roiIdMeta = const VerificationMeta('roiId');
  @override
  late final GeneratedColumn<String> roiId = GeneratedColumn<String>(
    'roi_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rois (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessHoursMeta = const VerificationMeta(
    'businessHours',
  );
  @override
  late final GeneratedColumn<String> businessHours = GeneratedColumn<String>(
    'business_hours',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactInfoMeta = const VerificationMeta(
    'contactInfo',
  );
  @override
  late final GeneratedColumn<String> contactInfo = GeneratedColumn<String>(
    'contact_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localCoverImagePathMeta =
      const VerificationMeta('localCoverImagePath');
  @override
  late final GeneratedColumn<String> localCoverImagePath =
      GeneratedColumn<String>(
        'local_cover_image_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _remoteCoverImageUrlMeta =
      const VerificationMeta('remoteCoverImageUrl');
  @override
  late final GeneratedColumn<String> remoteCoverImageUrl =
      GeneratedColumn<String>(
        'remote_cover_image_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  static const VerificationMeta _isSharedMeta = const VerificationMeta(
    'isShared',
  );
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
    'is_shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roiId,
    authorId,
    name,
    description,
    address,
    lat,
    lng,
    businessHours,
    contactInfo,
    localCoverImagePath,
    remoteCoverImageUrl,
    createdAt,
    isShared,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pois';
  @override
  VerificationContext validateIntegrity(
    Insertable<Poi> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('roi_id')) {
      context.handle(
        _roiIdMeta,
        roiId.isAcceptableOrUnknown(data['roi_id']!, _roiIdMeta),
      );
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('business_hours')) {
      context.handle(
        _businessHoursMeta,
        businessHours.isAcceptableOrUnknown(
          data['business_hours']!,
          _businessHoursMeta,
        ),
      );
    }
    if (data.containsKey('contact_info')) {
      context.handle(
        _contactInfoMeta,
        contactInfo.isAcceptableOrUnknown(
          data['contact_info']!,
          _contactInfoMeta,
        ),
      );
    }
    if (data.containsKey('local_cover_image_path')) {
      context.handle(
        _localCoverImagePathMeta,
        localCoverImagePath.isAcceptableOrUnknown(
          data['local_cover_image_path']!,
          _localCoverImagePathMeta,
        ),
      );
    }
    if (data.containsKey('remote_cover_image_url')) {
      context.handle(
        _remoteCoverImageUrlMeta,
        remoteCoverImageUrl.isAcceptableOrUnknown(
          data['remote_cover_image_url']!,
          _remoteCoverImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_shared')) {
      context.handle(
        _isSharedMeta,
        isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Poi map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Poi(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      roiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}roi_id'],
      ),
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      businessHours: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_hours'],
      ),
      contactInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_info'],
      ),
      localCoverImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_cover_image_path'],
      ),
      remoteCoverImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_cover_image_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      isShared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PoisTable createAlias(String alias) {
    return $PoisTable(attachedDatabase, alias);
  }
}

class Poi extends DataClass implements Insertable<Poi> {
  final String id;
  final String? roiId;
  final String authorId;
  final String name;
  final String? description;
  final String? address;
  final double lat;
  final double lng;
  final String? businessHours;
  final String? contactInfo;
  final String? localCoverImagePath;
  final String? remoteCoverImageUrl;
  final int createdAt;
  final bool isShared;
  final int sortOrder;
  const Poi({
    required this.id,
    this.roiId,
    required this.authorId,
    required this.name,
    this.description,
    this.address,
    required this.lat,
    required this.lng,
    this.businessHours,
    this.contactInfo,
    this.localCoverImagePath,
    this.remoteCoverImageUrl,
    required this.createdAt,
    required this.isShared,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || roiId != null) {
      map['roi_id'] = Variable<String>(roiId);
    }
    map['author_id'] = Variable<String>(authorId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || businessHours != null) {
      map['business_hours'] = Variable<String>(businessHours);
    }
    if (!nullToAbsent || contactInfo != null) {
      map['contact_info'] = Variable<String>(contactInfo);
    }
    if (!nullToAbsent || localCoverImagePath != null) {
      map['local_cover_image_path'] = Variable<String>(localCoverImagePath);
    }
    if (!nullToAbsent || remoteCoverImageUrl != null) {
      map['remote_cover_image_url'] = Variable<String>(remoteCoverImageUrl);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['is_shared'] = Variable<bool>(isShared);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PoisCompanion toCompanion(bool nullToAbsent) {
    return PoisCompanion(
      id: Value(id),
      roiId: roiId == null && nullToAbsent
          ? const Value.absent()
          : Value(roiId),
      authorId: Value(authorId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      lat: Value(lat),
      lng: Value(lng),
      businessHours: businessHours == null && nullToAbsent
          ? const Value.absent()
          : Value(businessHours),
      contactInfo: contactInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(contactInfo),
      localCoverImagePath: localCoverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localCoverImagePath),
      remoteCoverImageUrl: remoteCoverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteCoverImageUrl),
      createdAt: Value(createdAt),
      isShared: Value(isShared),
      sortOrder: Value(sortOrder),
    );
  }

  factory Poi.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Poi(
      id: serializer.fromJson<String>(json['id']),
      roiId: serializer.fromJson<String?>(json['roiId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      address: serializer.fromJson<String?>(json['address']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      businessHours: serializer.fromJson<String?>(json['businessHours']),
      contactInfo: serializer.fromJson<String?>(json['contactInfo']),
      localCoverImagePath: serializer.fromJson<String?>(
        json['localCoverImagePath'],
      ),
      remoteCoverImageUrl: serializer.fromJson<String?>(
        json['remoteCoverImageUrl'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roiId': serializer.toJson<String?>(roiId),
      'authorId': serializer.toJson<String>(authorId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'address': serializer.toJson<String?>(address),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'businessHours': serializer.toJson<String?>(businessHours),
      'contactInfo': serializer.toJson<String?>(contactInfo),
      'localCoverImagePath': serializer.toJson<String?>(localCoverImagePath),
      'remoteCoverImageUrl': serializer.toJson<String?>(remoteCoverImageUrl),
      'createdAt': serializer.toJson<int>(createdAt),
      'isShared': serializer.toJson<bool>(isShared),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Poi copyWith({
    String? id,
    Value<String?> roiId = const Value.absent(),
    String? authorId,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> address = const Value.absent(),
    double? lat,
    double? lng,
    Value<String?> businessHours = const Value.absent(),
    Value<String?> contactInfo = const Value.absent(),
    Value<String?> localCoverImagePath = const Value.absent(),
    Value<String?> remoteCoverImageUrl = const Value.absent(),
    int? createdAt,
    bool? isShared,
    int? sortOrder,
  }) => Poi(
    id: id ?? this.id,
    roiId: roiId.present ? roiId.value : this.roiId,
    authorId: authorId ?? this.authorId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    address: address.present ? address.value : this.address,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    businessHours: businessHours.present
        ? businessHours.value
        : this.businessHours,
    contactInfo: contactInfo.present ? contactInfo.value : this.contactInfo,
    localCoverImagePath: localCoverImagePath.present
        ? localCoverImagePath.value
        : this.localCoverImagePath,
    remoteCoverImageUrl: remoteCoverImageUrl.present
        ? remoteCoverImageUrl.value
        : this.remoteCoverImageUrl,
    createdAt: createdAt ?? this.createdAt,
    isShared: isShared ?? this.isShared,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Poi copyWithCompanion(PoisCompanion data) {
    return Poi(
      id: data.id.present ? data.id.value : this.id,
      roiId: data.roiId.present ? data.roiId.value : this.roiId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      address: data.address.present ? data.address.value : this.address,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      businessHours: data.businessHours.present
          ? data.businessHours.value
          : this.businessHours,
      contactInfo: data.contactInfo.present
          ? data.contactInfo.value
          : this.contactInfo,
      localCoverImagePath: data.localCoverImagePath.present
          ? data.localCoverImagePath.value
          : this.localCoverImagePath,
      remoteCoverImageUrl: data.remoteCoverImageUrl.present
          ? data.remoteCoverImageUrl.value
          : this.remoteCoverImageUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Poi(')
          ..write('id: $id, ')
          ..write('roiId: $roiId, ')
          ..write('authorId: $authorId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('address: $address, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('businessHours: $businessHours, ')
          ..write('contactInfo: $contactInfo, ')
          ..write('localCoverImagePath: $localCoverImagePath, ')
          ..write('remoteCoverImageUrl: $remoteCoverImageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('isShared: $isShared, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roiId,
    authorId,
    name,
    description,
    address,
    lat,
    lng,
    businessHours,
    contactInfo,
    localCoverImagePath,
    remoteCoverImageUrl,
    createdAt,
    isShared,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Poi &&
          other.id == this.id &&
          other.roiId == this.roiId &&
          other.authorId == this.authorId &&
          other.name == this.name &&
          other.description == this.description &&
          other.address == this.address &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.businessHours == this.businessHours &&
          other.contactInfo == this.contactInfo &&
          other.localCoverImagePath == this.localCoverImagePath &&
          other.remoteCoverImageUrl == this.remoteCoverImageUrl &&
          other.createdAt == this.createdAt &&
          other.isShared == this.isShared &&
          other.sortOrder == this.sortOrder);
}

class PoisCompanion extends UpdateCompanion<Poi> {
  final Value<String> id;
  final Value<String?> roiId;
  final Value<String> authorId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> address;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String?> businessHours;
  final Value<String?> contactInfo;
  final Value<String?> localCoverImagePath;
  final Value<String?> remoteCoverImageUrl;
  final Value<int> createdAt;
  final Value<bool> isShared;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PoisCompanion({
    this.id = const Value.absent(),
    this.roiId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.address = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.businessHours = const Value.absent(),
    this.contactInfo = const Value.absent(),
    this.localCoverImagePath = const Value.absent(),
    this.remoteCoverImageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isShared = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PoisCompanion.insert({
    required String id,
    this.roiId = const Value.absent(),
    required String authorId,
    required String name,
    this.description = const Value.absent(),
    this.address = const Value.absent(),
    required double lat,
    required double lng,
    this.businessHours = const Value.absent(),
    this.contactInfo = const Value.absent(),
    this.localCoverImagePath = const Value.absent(),
    this.remoteCoverImageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isShared = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       authorId = Value(authorId),
       name = Value(name),
       lat = Value(lat),
       lng = Value(lng);
  static Insertable<Poi> custom({
    Expression<String>? id,
    Expression<String>? roiId,
    Expression<String>? authorId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? address,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? businessHours,
    Expression<String>? contactInfo,
    Expression<String>? localCoverImagePath,
    Expression<String>? remoteCoverImageUrl,
    Expression<int>? createdAt,
    Expression<bool>? isShared,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roiId != null) 'roi_id': roiId,
      if (authorId != null) 'author_id': authorId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (businessHours != null) 'business_hours': businessHours,
      if (contactInfo != null) 'contact_info': contactInfo,
      if (localCoverImagePath != null)
        'local_cover_image_path': localCoverImagePath,
      if (remoteCoverImageUrl != null)
        'remote_cover_image_url': remoteCoverImageUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (isShared != null) 'is_shared': isShared,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PoisCompanion copyWith({
    Value<String>? id,
    Value<String?>? roiId,
    Value<String>? authorId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? address,
    Value<double>? lat,
    Value<double>? lng,
    Value<String?>? businessHours,
    Value<String?>? contactInfo,
    Value<String?>? localCoverImagePath,
    Value<String?>? remoteCoverImageUrl,
    Value<int>? createdAt,
    Value<bool>? isShared,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return PoisCompanion(
      id: id ?? this.id,
      roiId: roiId ?? this.roiId,
      authorId: authorId ?? this.authorId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      businessHours: businessHours ?? this.businessHours,
      contactInfo: contactInfo ?? this.contactInfo,
      localCoverImagePath: localCoverImagePath ?? this.localCoverImagePath,
      remoteCoverImageUrl: remoteCoverImageUrl ?? this.remoteCoverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isShared: isShared ?? this.isShared,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roiId.present) {
      map['roi_id'] = Variable<String>(roiId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (businessHours.present) {
      map['business_hours'] = Variable<String>(businessHours.value);
    }
    if (contactInfo.present) {
      map['contact_info'] = Variable<String>(contactInfo.value);
    }
    if (localCoverImagePath.present) {
      map['local_cover_image_path'] = Variable<String>(
        localCoverImagePath.value,
      );
    }
    if (remoteCoverImageUrl.present) {
      map['remote_cover_image_url'] = Variable<String>(
        remoteCoverImageUrl.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoisCompanion(')
          ..write('id: $id, ')
          ..write('roiId: $roiId, ')
          ..write('authorId: $authorId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('address: $address, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('businessHours: $businessHours, ')
          ..write('contactInfo: $contactInfo, ')
          ..write('localCoverImagePath: $localCoverImagePath, ')
          ..write('remoteCoverImageUrl: $remoteCoverImageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('isShared: $isShared, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimesTable extends Animes with TableInfo<$AnimesTable, Anime> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bangumiIdMeta = const VerificationMeta(
    'bangumiId',
  );
  @override
  late final GeneratedColumn<String> bangumiId = GeneratedColumn<String>(
    'bangumi_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSharedMeta = const VerificationMeta(
    'isShared',
  );
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
    'is_shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    bangumiId,
    authorId,
    isShared,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Anime> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('bangumi_id')) {
      context.handle(
        _bangumiIdMeta,
        bangumiId.isAcceptableOrUnknown(data['bangumi_id']!, _bangumiIdMeta),
      );
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('is_shared')) {
      context.handle(
        _isSharedMeta,
        isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Anime map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Anime(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      bangumiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bangumi_id'],
      ),
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      isShared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AnimesTable createAlias(String alias) {
    return $AnimesTable(attachedDatabase, alias);
  }
}

class Anime extends DataClass implements Insertable<Anime> {
  final String id;
  final String name;
  final String? description;
  final String? bangumiId;
  final String authorId;
  final bool isShared;
  final int createdAt;
  const Anime({
    required this.id,
    required this.name,
    this.description,
    this.bangumiId,
    required this.authorId,
    required this.isShared,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || bangumiId != null) {
      map['bangumi_id'] = Variable<String>(bangumiId);
    }
    map['author_id'] = Variable<String>(authorId);
    map['is_shared'] = Variable<bool>(isShared);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AnimesCompanion toCompanion(bool nullToAbsent) {
    return AnimesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      bangumiId: bangumiId == null && nullToAbsent
          ? const Value.absent()
          : Value(bangumiId),
      authorId: Value(authorId),
      isShared: Value(isShared),
      createdAt: Value(createdAt),
    );
  }

  factory Anime.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Anime(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      bangumiId: serializer.fromJson<String?>(json['bangumiId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'bangumiId': serializer.toJson<String?>(bangumiId),
      'authorId': serializer.toJson<String>(authorId),
      'isShared': serializer.toJson<bool>(isShared),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Anime copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> bangumiId = const Value.absent(),
    String? authorId,
    bool? isShared,
    int? createdAt,
  }) => Anime(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    bangumiId: bangumiId.present ? bangumiId.value : this.bangumiId,
    authorId: authorId ?? this.authorId,
    isShared: isShared ?? this.isShared,
    createdAt: createdAt ?? this.createdAt,
  );
  Anime copyWithCompanion(AnimesCompanion data) {
    return Anime(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      bangumiId: data.bangumiId.present ? data.bangumiId.value : this.bangumiId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Anime(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('bangumiId: $bangumiId, ')
          ..write('authorId: $authorId, ')
          ..write('isShared: $isShared, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    bangumiId,
    authorId,
    isShared,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Anime &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.bangumiId == this.bangumiId &&
          other.authorId == this.authorId &&
          other.isShared == this.isShared &&
          other.createdAt == this.createdAt);
}

class AnimesCompanion extends UpdateCompanion<Anime> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> bangumiId;
  final Value<String> authorId;
  final Value<bool> isShared;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AnimesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.bangumiId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.isShared = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.bangumiId = const Value.absent(),
    required String authorId,
    this.isShared = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       authorId = Value(authorId);
  static Insertable<Anime> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? bangumiId,
    Expression<String>? authorId,
    Expression<bool>? isShared,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (bangumiId != null) 'bangumi_id': bangumiId,
      if (authorId != null) 'author_id': authorId,
      if (isShared != null) 'is_shared': isShared,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? bangumiId,
    Value<String>? authorId,
    Value<bool>? isShared,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AnimesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      bangumiId: bangumiId ?? this.bangumiId,
      authorId: authorId ?? this.authorId,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (bangumiId.present) {
      map['bangumi_id'] = Variable<String>(bangumiId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('bangumiId: $bangumiId, ')
          ..write('authorId: $authorId, ')
          ..write('isShared: $isShared, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSharedMeta = const VerificationMeta(
    'isShared',
  );
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
    'is_shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    authorId,
    isShared,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('is_shared')) {
      context.handle(
        _isSharedMeta,
        isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      isShared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final String? description;
  final String authorId;
  final bool isShared;
  final int createdAt;
  const Tag({
    required this.id,
    required this.name,
    this.description,
    required this.authorId,
    required this.isShared,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['author_id'] = Variable<String>(authorId);
    map['is_shared'] = Variable<bool>(isShared);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      authorId: Value(authorId),
      isShared: Value(isShared),
      createdAt: Value(createdAt),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      authorId: serializer.fromJson<String>(json['authorId']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'authorId': serializer.toJson<String>(authorId),
      'isShared': serializer.toJson<bool>(isShared),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? authorId,
    bool? isShared,
    int? createdAt,
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    authorId: authorId ?? this.authorId,
    isShared: isShared ?? this.isShared,
    createdAt: createdAt ?? this.createdAt,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('authorId: $authorId, ')
          ..write('isShared: $isShared, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, authorId, isShared, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.authorId == this.authorId &&
          other.isShared == this.isShared &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> authorId;
  final Value<bool> isShared;
  final Value<int> createdAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.authorId = const Value.absent(),
    this.isShared = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String authorId,
    this.isShared = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       authorId = Value(authorId);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? authorId,
    Expression<bool>? isShared,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (authorId != null) 'author_id': authorId,
      if (isShared != null) 'is_shared': isShared,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? authorId,
    Value<bool>? isShared,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('authorId: $authorId, ')
          ..write('isShared: $isShared, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PoiAnimesTable extends PoiAnimes
    with TableInfo<$PoiAnimesTable, PoiAnime> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoiAnimesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _poiIdMeta = const VerificationMeta('poiId');
  @override
  late final GeneratedColumn<String> poiId = GeneratedColumn<String>(
    'poi_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pois (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _animeIdMeta = const VerificationMeta(
    'animeId',
  );
  @override
  late final GeneratedColumn<String> animeId = GeneratedColumn<String>(
    'anime_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES animes (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [poiId, animeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'poi_animes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PoiAnime> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('poi_id')) {
      context.handle(
        _poiIdMeta,
        poiId.isAcceptableOrUnknown(data['poi_id']!, _poiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_poiIdMeta);
    }
    if (data.containsKey('anime_id')) {
      context.handle(
        _animeIdMeta,
        animeId.isAcceptableOrUnknown(data['anime_id']!, _animeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {poiId, animeId};
  @override
  PoiAnime map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoiAnime(
      poiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poi_id'],
      )!,
      animeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anime_id'],
      )!,
    );
  }

  @override
  $PoiAnimesTable createAlias(String alias) {
    return $PoiAnimesTable(attachedDatabase, alias);
  }
}

class PoiAnime extends DataClass implements Insertable<PoiAnime> {
  final String poiId;
  final String animeId;
  const PoiAnime({required this.poiId, required this.animeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['poi_id'] = Variable<String>(poiId);
    map['anime_id'] = Variable<String>(animeId);
    return map;
  }

  PoiAnimesCompanion toCompanion(bool nullToAbsent) {
    return PoiAnimesCompanion(poiId: Value(poiId), animeId: Value(animeId));
  }

  factory PoiAnime.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoiAnime(
      poiId: serializer.fromJson<String>(json['poiId']),
      animeId: serializer.fromJson<String>(json['animeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'poiId': serializer.toJson<String>(poiId),
      'animeId': serializer.toJson<String>(animeId),
    };
  }

  PoiAnime copyWith({String? poiId, String? animeId}) =>
      PoiAnime(poiId: poiId ?? this.poiId, animeId: animeId ?? this.animeId);
  PoiAnime copyWithCompanion(PoiAnimesCompanion data) {
    return PoiAnime(
      poiId: data.poiId.present ? data.poiId.value : this.poiId,
      animeId: data.animeId.present ? data.animeId.value : this.animeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PoiAnime(')
          ..write('poiId: $poiId, ')
          ..write('animeId: $animeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(poiId, animeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoiAnime &&
          other.poiId == this.poiId &&
          other.animeId == this.animeId);
}

class PoiAnimesCompanion extends UpdateCompanion<PoiAnime> {
  final Value<String> poiId;
  final Value<String> animeId;
  final Value<int> rowid;
  const PoiAnimesCompanion({
    this.poiId = const Value.absent(),
    this.animeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PoiAnimesCompanion.insert({
    required String poiId,
    required String animeId,
    this.rowid = const Value.absent(),
  }) : poiId = Value(poiId),
       animeId = Value(animeId);
  static Insertable<PoiAnime> custom({
    Expression<String>? poiId,
    Expression<String>? animeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (poiId != null) 'poi_id': poiId,
      if (animeId != null) 'anime_id': animeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PoiAnimesCompanion copyWith({
    Value<String>? poiId,
    Value<String>? animeId,
    Value<int>? rowid,
  }) {
    return PoiAnimesCompanion(
      poiId: poiId ?? this.poiId,
      animeId: animeId ?? this.animeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (poiId.present) {
      map['poi_id'] = Variable<String>(poiId.value);
    }
    if (animeId.present) {
      map['anime_id'] = Variable<String>(animeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoiAnimesCompanion(')
          ..write('poiId: $poiId, ')
          ..write('animeId: $animeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PoiTagsTable extends PoiTags with TableInfo<$PoiTagsTable, PoiTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoiTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _poiIdMeta = const VerificationMeta('poiId');
  @override
  late final GeneratedColumn<String> poiId = GeneratedColumn<String>(
    'poi_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pois (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [poiId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'poi_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<PoiTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('poi_id')) {
      context.handle(
        _poiIdMeta,
        poiId.isAcceptableOrUnknown(data['poi_id']!, _poiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_poiIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {poiId, tagId};
  @override
  PoiTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoiTag(
      poiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poi_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $PoiTagsTable createAlias(String alias) {
    return $PoiTagsTable(attachedDatabase, alias);
  }
}

class PoiTag extends DataClass implements Insertable<PoiTag> {
  final String poiId;
  final String tagId;
  const PoiTag({required this.poiId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['poi_id'] = Variable<String>(poiId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  PoiTagsCompanion toCompanion(bool nullToAbsent) {
    return PoiTagsCompanion(poiId: Value(poiId), tagId: Value(tagId));
  }

  factory PoiTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoiTag(
      poiId: serializer.fromJson<String>(json['poiId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'poiId': serializer.toJson<String>(poiId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  PoiTag copyWith({String? poiId, String? tagId}) =>
      PoiTag(poiId: poiId ?? this.poiId, tagId: tagId ?? this.tagId);
  PoiTag copyWithCompanion(PoiTagsCompanion data) {
    return PoiTag(
      poiId: data.poiId.present ? data.poiId.value : this.poiId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PoiTag(')
          ..write('poiId: $poiId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(poiId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoiTag &&
          other.poiId == this.poiId &&
          other.tagId == this.tagId);
}

class PoiTagsCompanion extends UpdateCompanion<PoiTag> {
  final Value<String> poiId;
  final Value<String> tagId;
  final Value<int> rowid;
  const PoiTagsCompanion({
    this.poiId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PoiTagsCompanion.insert({
    required String poiId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : poiId = Value(poiId),
       tagId = Value(tagId);
  static Insertable<PoiTag> custom({
    Expression<String>? poiId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (poiId != null) 'poi_id': poiId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PoiTagsCompanion copyWith({
    Value<String>? poiId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return PoiTagsCompanion(
      poiId: poiId ?? this.poiId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (poiId.present) {
      map['poi_id'] = Variable<String>(poiId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoiTagsCompanion(')
          ..write('poiId: $poiId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimeChunksTable extends TimeChunks
    with TableInfo<$TimeChunksTable, TimeChunk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeChunksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poiIdMeta = const VerificationMeta('poiId');
  @override
  late final GeneratedColumn<String> poiId = GeneratedColumn<String>(
    'poi_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pois (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('backlog'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _transitDurationMeta = const VerificationMeta(
    'transitDuration',
  );
  @override
  late final GeneratedColumn<int> transitDuration = GeneratedColumn<int>(
    'transit_duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isFixedTimeMeta = const VerificationMeta(
    'isFixedTime',
  );
  @override
  late final GeneratedColumn<bool> isFixedTime = GeneratedColumn<bool>(
    'is_fixed_time',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fixed_time" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSharedMeta = const VerificationMeta(
    'isShared',
  );
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
    'is_shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasEverSyncedMeta = const VerificationMeta(
    'hasEverSynced',
  );
  @override
  late final GeneratedColumn<bool> hasEverSynced = GeneratedColumn<bool>(
    'has_ever_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_ever_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _originalStartTimeMeta = const VerificationMeta(
    'originalStartTime',
  );
  @override
  late final GeneratedColumn<String> originalStartTime =
      GeneratedColumn<String>(
        'original_start_time',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originalEndTimeMeta = const VerificationMeta(
    'originalEndTime',
  );
  @override
  late final GeneratedColumn<String> originalEndTime = GeneratedColumn<String>(
    'original_end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    poiId,
    date,
    startTime,
    endTime,
    status,
    sortOrder,
    duration,
    transitDuration,
    isFixedTime,
    authorId,
    isShared,
    createdAt,
    syncStatus,
    isDeleted,
    hasEverSynced,
    originalStartTime,
    originalEndTime,
    lastModifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_chunks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeChunk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('poi_id')) {
      context.handle(
        _poiIdMeta,
        poiId.isAcceptableOrUnknown(data['poi_id']!, _poiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_poiIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('transit_duration')) {
      context.handle(
        _transitDurationMeta,
        transitDuration.isAcceptableOrUnknown(
          data['transit_duration']!,
          _transitDurationMeta,
        ),
      );
    }
    if (data.containsKey('is_fixed_time')) {
      context.handle(
        _isFixedTimeMeta,
        isFixedTime.isAcceptableOrUnknown(
          data['is_fixed_time']!,
          _isFixedTimeMeta,
        ),
      );
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('is_shared')) {
      context.handle(
        _isSharedMeta,
        isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('has_ever_synced')) {
      context.handle(
        _hasEverSyncedMeta,
        hasEverSynced.isAcceptableOrUnknown(
          data['has_ever_synced']!,
          _hasEverSyncedMeta,
        ),
      );
    }
    if (data.containsKey('original_start_time')) {
      context.handle(
        _originalStartTimeMeta,
        originalStartTime.isAcceptableOrUnknown(
          data['original_start_time']!,
          _originalStartTimeMeta,
        ),
      );
    }
    if (data.containsKey('original_end_time')) {
      context.handle(
        _originalEndTimeMeta,
        originalEndTime.isAcceptableOrUnknown(
          data['original_end_time']!,
          _originalEndTimeMeta,
        ),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeChunk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeChunk(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      poiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poi_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      transitDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transit_duration'],
      )!,
      isFixedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fixed_time'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      isShared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      hasEverSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_ever_synced'],
      )!,
      originalStartTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_start_time'],
      ),
      originalEndTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_end_time'],
      ),
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      ),
    );
  }

  @override
  $TimeChunksTable createAlias(String alias) {
    return $TimeChunksTable(attachedDatabase, alias);
  }
}

class TimeChunk extends DataClass implements Insertable<TimeChunk> {
  final String id;
  final String poiId;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String status;
  final int sortOrder;
  final int duration;
  final int transitDuration;
  final bool isFixedTime;
  final String authorId;
  final bool isShared;
  final int createdAt;
  final int syncStatus;
  final bool isDeleted;
  final bool hasEverSynced;
  final String? originalStartTime;
  final String? originalEndTime;
  final DateTime? lastModifiedAt;
  const TimeChunk({
    required this.id,
    required this.poiId,
    this.date,
    this.startTime,
    this.endTime,
    required this.status,
    required this.sortOrder,
    required this.duration,
    required this.transitDuration,
    required this.isFixedTime,
    required this.authorId,
    required this.isShared,
    required this.createdAt,
    required this.syncStatus,
    required this.isDeleted,
    required this.hasEverSynced,
    this.originalStartTime,
    this.originalEndTime,
    this.lastModifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['poi_id'] = Variable<String>(poiId);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    map['status'] = Variable<String>(status);
    map['sort_order'] = Variable<int>(sortOrder);
    map['duration'] = Variable<int>(duration);
    map['transit_duration'] = Variable<int>(transitDuration);
    map['is_fixed_time'] = Variable<bool>(isFixedTime);
    map['author_id'] = Variable<String>(authorId);
    map['is_shared'] = Variable<bool>(isShared);
    map['created_at'] = Variable<int>(createdAt);
    map['sync_status'] = Variable<int>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['has_ever_synced'] = Variable<bool>(hasEverSynced);
    if (!nullToAbsent || originalStartTime != null) {
      map['original_start_time'] = Variable<String>(originalStartTime);
    }
    if (!nullToAbsent || originalEndTime != null) {
      map['original_end_time'] = Variable<String>(originalEndTime);
    }
    if (!nullToAbsent || lastModifiedAt != null) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    }
    return map;
  }

  TimeChunksCompanion toCompanion(bool nullToAbsent) {
    return TimeChunksCompanion(
      id: Value(id),
      poiId: Value(poiId),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      status: Value(status),
      sortOrder: Value(sortOrder),
      duration: Value(duration),
      transitDuration: Value(transitDuration),
      isFixedTime: Value(isFixedTime),
      authorId: Value(authorId),
      isShared: Value(isShared),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      hasEverSynced: Value(hasEverSynced),
      originalStartTime: originalStartTime == null && nullToAbsent
          ? const Value.absent()
          : Value(originalStartTime),
      originalEndTime: originalEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(originalEndTime),
      lastModifiedAt: lastModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedAt),
    );
  }

  factory TimeChunk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeChunk(
      id: serializer.fromJson<String>(json['id']),
      poiId: serializer.fromJson<String>(json['poiId']),
      date: serializer.fromJson<String?>(json['date']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      status: serializer.fromJson<String>(json['status']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      duration: serializer.fromJson<int>(json['duration']),
      transitDuration: serializer.fromJson<int>(json['transitDuration']),
      isFixedTime: serializer.fromJson<bool>(json['isFixedTime']),
      authorId: serializer.fromJson<String>(json['authorId']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      hasEverSynced: serializer.fromJson<bool>(json['hasEverSynced']),
      originalStartTime: serializer.fromJson<String?>(
        json['originalStartTime'],
      ),
      originalEndTime: serializer.fromJson<String?>(json['originalEndTime']),
      lastModifiedAt: serializer.fromJson<DateTime?>(json['lastModifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poiId': serializer.toJson<String>(poiId),
      'date': serializer.toJson<String?>(date),
      'startTime': serializer.toJson<String?>(startTime),
      'endTime': serializer.toJson<String?>(endTime),
      'status': serializer.toJson<String>(status),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'duration': serializer.toJson<int>(duration),
      'transitDuration': serializer.toJson<int>(transitDuration),
      'isFixedTime': serializer.toJson<bool>(isFixedTime),
      'authorId': serializer.toJson<String>(authorId),
      'isShared': serializer.toJson<bool>(isShared),
      'createdAt': serializer.toJson<int>(createdAt),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'hasEverSynced': serializer.toJson<bool>(hasEverSynced),
      'originalStartTime': serializer.toJson<String?>(originalStartTime),
      'originalEndTime': serializer.toJson<String?>(originalEndTime),
      'lastModifiedAt': serializer.toJson<DateTime?>(lastModifiedAt),
    };
  }

  TimeChunk copyWith({
    String? id,
    String? poiId,
    Value<String?> date = const Value.absent(),
    Value<String?> startTime = const Value.absent(),
    Value<String?> endTime = const Value.absent(),
    String? status,
    int? sortOrder,
    int? duration,
    int? transitDuration,
    bool? isFixedTime,
    String? authorId,
    bool? isShared,
    int? createdAt,
    int? syncStatus,
    bool? isDeleted,
    bool? hasEverSynced,
    Value<String?> originalStartTime = const Value.absent(),
    Value<String?> originalEndTime = const Value.absent(),
    Value<DateTime?> lastModifiedAt = const Value.absent(),
  }) => TimeChunk(
    id: id ?? this.id,
    poiId: poiId ?? this.poiId,
    date: date.present ? date.value : this.date,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    status: status ?? this.status,
    sortOrder: sortOrder ?? this.sortOrder,
    duration: duration ?? this.duration,
    transitDuration: transitDuration ?? this.transitDuration,
    isFixedTime: isFixedTime ?? this.isFixedTime,
    authorId: authorId ?? this.authorId,
    isShared: isShared ?? this.isShared,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    hasEverSynced: hasEverSynced ?? this.hasEverSynced,
    originalStartTime: originalStartTime.present
        ? originalStartTime.value
        : this.originalStartTime,
    originalEndTime: originalEndTime.present
        ? originalEndTime.value
        : this.originalEndTime,
    lastModifiedAt: lastModifiedAt.present
        ? lastModifiedAt.value
        : this.lastModifiedAt,
  );
  TimeChunk copyWithCompanion(TimeChunksCompanion data) {
    return TimeChunk(
      id: data.id.present ? data.id.value : this.id,
      poiId: data.poiId.present ? data.poiId.value : this.poiId,
      date: data.date.present ? data.date.value : this.date,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      status: data.status.present ? data.status.value : this.status,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      duration: data.duration.present ? data.duration.value : this.duration,
      transitDuration: data.transitDuration.present
          ? data.transitDuration.value
          : this.transitDuration,
      isFixedTime: data.isFixedTime.present
          ? data.isFixedTime.value
          : this.isFixedTime,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      hasEverSynced: data.hasEverSynced.present
          ? data.hasEverSynced.value
          : this.hasEverSynced,
      originalStartTime: data.originalStartTime.present
          ? data.originalStartTime.value
          : this.originalStartTime,
      originalEndTime: data.originalEndTime.present
          ? data.originalEndTime.value
          : this.originalEndTime,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeChunk(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('duration: $duration, ')
          ..write('transitDuration: $transitDuration, ')
          ..write('isFixedTime: $isFixedTime, ')
          ..write('authorId: $authorId, ')
          ..write('isShared: $isShared, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('hasEverSynced: $hasEverSynced, ')
          ..write('originalStartTime: $originalStartTime, ')
          ..write('originalEndTime: $originalEndTime, ')
          ..write('lastModifiedAt: $lastModifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    poiId,
    date,
    startTime,
    endTime,
    status,
    sortOrder,
    duration,
    transitDuration,
    isFixedTime,
    authorId,
    isShared,
    createdAt,
    syncStatus,
    isDeleted,
    hasEverSynced,
    originalStartTime,
    originalEndTime,
    lastModifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeChunk &&
          other.id == this.id &&
          other.poiId == this.poiId &&
          other.date == this.date &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.status == this.status &&
          other.sortOrder == this.sortOrder &&
          other.duration == this.duration &&
          other.transitDuration == this.transitDuration &&
          other.isFixedTime == this.isFixedTime &&
          other.authorId == this.authorId &&
          other.isShared == this.isShared &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.hasEverSynced == this.hasEverSynced &&
          other.originalStartTime == this.originalStartTime &&
          other.originalEndTime == this.originalEndTime &&
          other.lastModifiedAt == this.lastModifiedAt);
}

class TimeChunksCompanion extends UpdateCompanion<TimeChunk> {
  final Value<String> id;
  final Value<String> poiId;
  final Value<String?> date;
  final Value<String?> startTime;
  final Value<String?> endTime;
  final Value<String> status;
  final Value<int> sortOrder;
  final Value<int> duration;
  final Value<int> transitDuration;
  final Value<bool> isFixedTime;
  final Value<String> authorId;
  final Value<bool> isShared;
  final Value<int> createdAt;
  final Value<int> syncStatus;
  final Value<bool> isDeleted;
  final Value<bool> hasEverSynced;
  final Value<String?> originalStartTime;
  final Value<String?> originalEndTime;
  final Value<DateTime?> lastModifiedAt;
  final Value<int> rowid;
  const TimeChunksCompanion({
    this.id = const Value.absent(),
    this.poiId = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.status = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.duration = const Value.absent(),
    this.transitDuration = const Value.absent(),
    this.isFixedTime = const Value.absent(),
    this.authorId = const Value.absent(),
    this.isShared = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.hasEverSynced = const Value.absent(),
    this.originalStartTime = const Value.absent(),
    this.originalEndTime = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimeChunksCompanion.insert({
    required String id,
    required String poiId,
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.status = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.duration = const Value.absent(),
    this.transitDuration = const Value.absent(),
    this.isFixedTime = const Value.absent(),
    required String authorId,
    this.isShared = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.hasEverSynced = const Value.absent(),
    this.originalStartTime = const Value.absent(),
    this.originalEndTime = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       poiId = Value(poiId),
       authorId = Value(authorId);
  static Insertable<TimeChunk> custom({
    Expression<String>? id,
    Expression<String>? poiId,
    Expression<String>? date,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? status,
    Expression<int>? sortOrder,
    Expression<int>? duration,
    Expression<int>? transitDuration,
    Expression<bool>? isFixedTime,
    Expression<String>? authorId,
    Expression<bool>? isShared,
    Expression<int>? createdAt,
    Expression<int>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<bool>? hasEverSynced,
    Expression<String>? originalStartTime,
    Expression<String>? originalEndTime,
    Expression<DateTime>? lastModifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poiId != null) 'poi_id': poiId,
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (status != null) 'status': status,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (duration != null) 'duration': duration,
      if (transitDuration != null) 'transit_duration': transitDuration,
      if (isFixedTime != null) 'is_fixed_time': isFixedTime,
      if (authorId != null) 'author_id': authorId,
      if (isShared != null) 'is_shared': isShared,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (hasEverSynced != null) 'has_ever_synced': hasEverSynced,
      if (originalStartTime != null) 'original_start_time': originalStartTime,
      if (originalEndTime != null) 'original_end_time': originalEndTime,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimeChunksCompanion copyWith({
    Value<String>? id,
    Value<String>? poiId,
    Value<String?>? date,
    Value<String?>? startTime,
    Value<String?>? endTime,
    Value<String>? status,
    Value<int>? sortOrder,
    Value<int>? duration,
    Value<int>? transitDuration,
    Value<bool>? isFixedTime,
    Value<String>? authorId,
    Value<bool>? isShared,
    Value<int>? createdAt,
    Value<int>? syncStatus,
    Value<bool>? isDeleted,
    Value<bool>? hasEverSynced,
    Value<String?>? originalStartTime,
    Value<String?>? originalEndTime,
    Value<DateTime?>? lastModifiedAt,
    Value<int>? rowid,
  }) {
    return TimeChunksCompanion(
      id: id ?? this.id,
      poiId: poiId ?? this.poiId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      duration: duration ?? this.duration,
      transitDuration: transitDuration ?? this.transitDuration,
      isFixedTime: isFixedTime ?? this.isFixedTime,
      authorId: authorId ?? this.authorId,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      hasEverSynced: hasEverSynced ?? this.hasEverSynced,
      originalStartTime: originalStartTime ?? this.originalStartTime,
      originalEndTime: originalEndTime ?? this.originalEndTime,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poiId.present) {
      map['poi_id'] = Variable<String>(poiId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (transitDuration.present) {
      map['transit_duration'] = Variable<int>(transitDuration.value);
    }
    if (isFixedTime.present) {
      map['is_fixed_time'] = Variable<bool>(isFixedTime.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (hasEverSynced.present) {
      map['has_ever_synced'] = Variable<bool>(hasEverSynced.value);
    }
    if (originalStartTime.present) {
      map['original_start_time'] = Variable<String>(originalStartTime.value);
    }
    if (originalEndTime.present) {
      map['original_end_time'] = Variable<String>(originalEndTime.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeChunksCompanion(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('duration: $duration, ')
          ..write('transitDuration: $transitDuration, ')
          ..write('isFixedTime: $isFixedTime, ')
          ..write('authorId: $authorId, ')
          ..write('isShared: $isShared, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('hasEverSynced: $hasEverSynced, ')
          ..write('originalStartTime: $originalStartTime, ')
          ..write('originalEndTime: $originalEndTime, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferenceImagesTable extends ReferenceImages
    with TableInfo<$ReferenceImagesTable, ReferenceImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferenceImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poiIdMeta = const VerificationMeta('poiId');
  @override
  late final GeneratedColumn<String> poiId = GeneratedColumn<String>(
    'poi_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pois (id)',
    ),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    poiId,
    authorId,
    localPath,
    remoteUrl,
    metadata,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReferenceImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('poi_id')) {
      context.handle(
        _poiIdMeta,
        poiId.isAcceptableOrUnknown(data['poi_id']!, _poiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_poiIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReferenceImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferenceImage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      poiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poi_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReferenceImagesTable createAlias(String alias) {
    return $ReferenceImagesTable(attachedDatabase, alias);
  }
}

class ReferenceImage extends DataClass implements Insertable<ReferenceImage> {
  final String id;
  final String poiId;
  final String authorId;
  final String? localPath;
  final String? remoteUrl;
  final String? metadata;
  final int createdAt;
  const ReferenceImage({
    required this.id,
    required this.poiId,
    required this.authorId,
    this.localPath,
    this.remoteUrl,
    this.metadata,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['poi_id'] = Variable<String>(poiId);
    map['author_id'] = Variable<String>(authorId);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ReferenceImagesCompanion toCompanion(bool nullToAbsent) {
    return ReferenceImagesCompanion(
      id: Value(id),
      poiId: Value(poiId),
      authorId: Value(authorId),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      createdAt: Value(createdAt),
    );
  }

  factory ReferenceImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferenceImage(
      id: serializer.fromJson<String>(json['id']),
      poiId: serializer.fromJson<String>(json['poiId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poiId': serializer.toJson<String>(poiId),
      'authorId': serializer.toJson<String>(authorId),
      'localPath': serializer.toJson<String?>(localPath),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'metadata': serializer.toJson<String?>(metadata),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ReferenceImage copyWith({
    String? id,
    String? poiId,
    String? authorId,
    Value<String?> localPath = const Value.absent(),
    Value<String?> remoteUrl = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    int? createdAt,
  }) => ReferenceImage(
    id: id ?? this.id,
    poiId: poiId ?? this.poiId,
    authorId: authorId ?? this.authorId,
    localPath: localPath.present ? localPath.value : this.localPath,
    remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
    metadata: metadata.present ? metadata.value : this.metadata,
    createdAt: createdAt ?? this.createdAt,
  );
  ReferenceImage copyWithCompanion(ReferenceImagesCompanion data) {
    return ReferenceImage(
      id: data.id.present ? data.id.value : this.id,
      poiId: data.poiId.present ? data.poiId.value : this.poiId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceImage(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('authorId: $authorId, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    poiId,
    authorId,
    localPath,
    remoteUrl,
    metadata,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferenceImage &&
          other.id == this.id &&
          other.poiId == this.poiId &&
          other.authorId == this.authorId &&
          other.localPath == this.localPath &&
          other.remoteUrl == this.remoteUrl &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt);
}

class ReferenceImagesCompanion extends UpdateCompanion<ReferenceImage> {
  final Value<String> id;
  final Value<String> poiId;
  final Value<String> authorId;
  final Value<String?> localPath;
  final Value<String?> remoteUrl;
  final Value<String?> metadata;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ReferenceImagesCompanion({
    this.id = const Value.absent(),
    this.poiId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferenceImagesCompanion.insert({
    required String id,
    required String poiId,
    required String authorId,
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       poiId = Value(poiId),
       authorId = Value(authorId);
  static Insertable<ReferenceImage> custom({
    Expression<String>? id,
    Expression<String>? poiId,
    Expression<String>? authorId,
    Expression<String>? localPath,
    Expression<String>? remoteUrl,
    Expression<String>? metadata,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poiId != null) 'poi_id': poiId,
      if (authorId != null) 'author_id': authorId,
      if (localPath != null) 'local_path': localPath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferenceImagesCompanion copyWith({
    Value<String>? id,
    Value<String>? poiId,
    Value<String>? authorId,
    Value<String?>? localPath,
    Value<String?>? remoteUrl,
    Value<String?>? metadata,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ReferenceImagesCompanion(
      id: id ?? this.id,
      poiId: poiId ?? this.poiId,
      authorId: authorId ?? this.authorId,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poiId.present) {
      map['poi_id'] = Variable<String>(poiId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceImagesCompanion(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('authorId: $authorId, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaAssetsTable extends MediaAssets
    with TableInfo<$MediaAssetsTable, MediaAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poiIdMeta = const VerificationMeta('poiId');
  @override
  late final GeneratedColumn<String> poiId = GeneratedColumn<String>(
    'poi_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pois (id)',
    ),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceImageIdMeta = const VerificationMeta(
    'referenceImageId',
  );
  @override
  late final GeneratedColumn<String> referenceImageId = GeneratedColumn<String>(
    'reference_image_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reference_images (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    poiId,
    authorId,
    type,
    localPath,
    remoteUrl,
    metadata,
    referenceImageId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('poi_id')) {
      context.handle(
        _poiIdMeta,
        poiId.isAcceptableOrUnknown(data['poi_id']!, _poiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_poiIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('reference_image_id')) {
      context.handle(
        _referenceImageIdMeta,
        referenceImageId.isAcceptableOrUnknown(
          data['reference_image_id']!,
          _referenceImageIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      poiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poi_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      referenceImageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_image_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MediaAssetsTable createAlias(String alias) {
    return $MediaAssetsTable(attachedDatabase, alias);
  }
}

class MediaAsset extends DataClass implements Insertable<MediaAsset> {
  final String id;
  final String poiId;
  final String authorId;
  final String type;
  final String? localPath;
  final String? remoteUrl;
  final String? metadata;
  final String? referenceImageId;
  final int createdAt;
  const MediaAsset({
    required this.id,
    required this.poiId,
    required this.authorId,
    required this.type,
    this.localPath,
    this.remoteUrl,
    this.metadata,
    this.referenceImageId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['poi_id'] = Variable<String>(poiId);
    map['author_id'] = Variable<String>(authorId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    if (!nullToAbsent || referenceImageId != null) {
      map['reference_image_id'] = Variable<String>(referenceImageId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  MediaAssetsCompanion toCompanion(bool nullToAbsent) {
    return MediaAssetsCompanion(
      id: Value(id),
      poiId: Value(poiId),
      authorId: Value(authorId),
      type: Value(type),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      referenceImageId: referenceImageId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceImageId),
      createdAt: Value(createdAt),
    );
  }

  factory MediaAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaAsset(
      id: serializer.fromJson<String>(json['id']),
      poiId: serializer.fromJson<String>(json['poiId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      type: serializer.fromJson<String>(json['type']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      referenceImageId: serializer.fromJson<String?>(json['referenceImageId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poiId': serializer.toJson<String>(poiId),
      'authorId': serializer.toJson<String>(authorId),
      'type': serializer.toJson<String>(type),
      'localPath': serializer.toJson<String?>(localPath),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'metadata': serializer.toJson<String?>(metadata),
      'referenceImageId': serializer.toJson<String?>(referenceImageId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  MediaAsset copyWith({
    String? id,
    String? poiId,
    String? authorId,
    String? type,
    Value<String?> localPath = const Value.absent(),
    Value<String?> remoteUrl = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    Value<String?> referenceImageId = const Value.absent(),
    int? createdAt,
  }) => MediaAsset(
    id: id ?? this.id,
    poiId: poiId ?? this.poiId,
    authorId: authorId ?? this.authorId,
    type: type ?? this.type,
    localPath: localPath.present ? localPath.value : this.localPath,
    remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
    metadata: metadata.present ? metadata.value : this.metadata,
    referenceImageId: referenceImageId.present
        ? referenceImageId.value
        : this.referenceImageId,
    createdAt: createdAt ?? this.createdAt,
  );
  MediaAsset copyWithCompanion(MediaAssetsCompanion data) {
    return MediaAsset(
      id: data.id.present ? data.id.value : this.id,
      poiId: data.poiId.present ? data.poiId.value : this.poiId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      type: data.type.present ? data.type.value : this.type,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      referenceImageId: data.referenceImageId.present
          ? data.referenceImageId.value
          : this.referenceImageId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaAsset(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('authorId: $authorId, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('metadata: $metadata, ')
          ..write('referenceImageId: $referenceImageId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    poiId,
    authorId,
    type,
    localPath,
    remoteUrl,
    metadata,
    referenceImageId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaAsset &&
          other.id == this.id &&
          other.poiId == this.poiId &&
          other.authorId == this.authorId &&
          other.type == this.type &&
          other.localPath == this.localPath &&
          other.remoteUrl == this.remoteUrl &&
          other.metadata == this.metadata &&
          other.referenceImageId == this.referenceImageId &&
          other.createdAt == this.createdAt);
}

class MediaAssetsCompanion extends UpdateCompanion<MediaAsset> {
  final Value<String> id;
  final Value<String> poiId;
  final Value<String> authorId;
  final Value<String> type;
  final Value<String?> localPath;
  final Value<String?> remoteUrl;
  final Value<String?> metadata;
  final Value<String?> referenceImageId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const MediaAssetsCompanion({
    this.id = const Value.absent(),
    this.poiId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.type = const Value.absent(),
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.metadata = const Value.absent(),
    this.referenceImageId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaAssetsCompanion.insert({
    required String id,
    required String poiId,
    required String authorId,
    required String type,
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.metadata = const Value.absent(),
    this.referenceImageId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       poiId = Value(poiId),
       authorId = Value(authorId),
       type = Value(type);
  static Insertable<MediaAsset> custom({
    Expression<String>? id,
    Expression<String>? poiId,
    Expression<String>? authorId,
    Expression<String>? type,
    Expression<String>? localPath,
    Expression<String>? remoteUrl,
    Expression<String>? metadata,
    Expression<String>? referenceImageId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poiId != null) 'poi_id': poiId,
      if (authorId != null) 'author_id': authorId,
      if (type != null) 'type': type,
      if (localPath != null) 'local_path': localPath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (metadata != null) 'metadata': metadata,
      if (referenceImageId != null) 'reference_image_id': referenceImageId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? poiId,
    Value<String>? authorId,
    Value<String>? type,
    Value<String?>? localPath,
    Value<String?>? remoteUrl,
    Value<String?>? metadata,
    Value<String?>? referenceImageId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return MediaAssetsCompanion(
      id: id ?? this.id,
      poiId: poiId ?? this.poiId,
      authorId: authorId ?? this.authorId,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      metadata: metadata ?? this.metadata,
      referenceImageId: referenceImageId ?? this.referenceImageId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poiId.present) {
      map['poi_id'] = Variable<String>(poiId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (referenceImageId.present) {
      map['reference_image_id'] = Variable<String>(referenceImageId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetsCompanion(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('authorId: $authorId, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('metadata: $metadata, ')
          ..write('referenceImageId: $referenceImageId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoisTable rois = $RoisTable(this);
  late final $PoisTable pois = $PoisTable(this);
  late final $AnimesTable animes = $AnimesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $PoiAnimesTable poiAnimes = $PoiAnimesTable(this);
  late final $PoiTagsTable poiTags = $PoiTagsTable(this);
  late final $TimeChunksTable timeChunks = $TimeChunksTable(this);
  late final $ReferenceImagesTable referenceImages = $ReferenceImagesTable(
    this,
  );
  late final $MediaAssetsTable mediaAssets = $MediaAssetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    rois,
    pois,
    animes,
    tags,
    poiAnimes,
    poiTags,
    timeChunks,
    referenceImages,
    mediaAssets,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rois',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pois', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pois',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('poi_animes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'animes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('poi_animes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pois',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('poi_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('poi_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'reference_images',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('media_assets', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$RoisTableCreateCompanionBuilder =
    RoisCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required String authorId,
      Value<bool> isShared,
      Value<int> isOfflineCached,
      Value<int> createdAt,
      Value<int> cloudVersion,
      Value<int?> syncLockExpiresAt,
      Value<int> rowid,
    });
typedef $$RoisTableUpdateCompanionBuilder =
    RoisCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> authorId,
      Value<bool> isShared,
      Value<int> isOfflineCached,
      Value<int> createdAt,
      Value<int> cloudVersion,
      Value<int?> syncLockExpiresAt,
      Value<int> rowid,
    });

final class $$RoisTableReferences
    extends BaseReferences<_$AppDatabase, $RoisTable, Roi> {
  $$RoisTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PoisTable, List<Poi>> _poisRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pois,
    aliasName: $_aliasNameGenerator(db.rois.id, db.pois.roiId),
  );

  $$PoisTableProcessedTableManager get poisRefs {
    final manager = $$PoisTableTableManager(
      $_db,
      $_db.pois,
    ).filter((f) => f.roiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_poisRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoisTableFilterComposer extends Composer<_$AppDatabase, $RoisTable> {
  $$RoisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isOfflineCached => $composableBuilder(
    column: $table.isOfflineCached,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cloudVersion => $composableBuilder(
    column: $table.cloudVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncLockExpiresAt => $composableBuilder(
    column: $table.syncLockExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> poisRefs(
    Expression<bool> Function($$PoisTableFilterComposer f) f,
  ) {
    final $$PoisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.roiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableFilterComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoisTableOrderingComposer extends Composer<_$AppDatabase, $RoisTable> {
  $$RoisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isOfflineCached => $composableBuilder(
    column: $table.isOfflineCached,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cloudVersion => $composableBuilder(
    column: $table.cloudVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncLockExpiresAt => $composableBuilder(
    column: $table.syncLockExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoisTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoisTable> {
  $$RoisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<int> get isOfflineCached => $composableBuilder(
    column: $table.isOfflineCached,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get cloudVersion => $composableBuilder(
    column: $table.cloudVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncLockExpiresAt => $composableBuilder(
    column: $table.syncLockExpiresAt,
    builder: (column) => column,
  );

  Expression<T> poisRefs<T extends Object>(
    Expression<T> Function($$PoisTableAnnotationComposer a) f,
  ) {
    final $$PoisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.roiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableAnnotationComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoisTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoisTable,
          Roi,
          $$RoisTableFilterComposer,
          $$RoisTableOrderingComposer,
          $$RoisTableAnnotationComposer,
          $$RoisTableCreateCompanionBuilder,
          $$RoisTableUpdateCompanionBuilder,
          (Roi, $$RoisTableReferences),
          Roi,
          PrefetchHooks Function({bool poisRefs})
        > {
  $$RoisTableTableManager(_$AppDatabase db, $RoisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> isOfflineCached = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> cloudVersion = const Value.absent(),
                Value<int?> syncLockExpiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoisCompanion(
                id: id,
                name: name,
                description: description,
                authorId: authorId,
                isShared: isShared,
                isOfflineCached: isOfflineCached,
                createdAt: createdAt,
                cloudVersion: cloudVersion,
                syncLockExpiresAt: syncLockExpiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required String authorId,
                Value<bool> isShared = const Value.absent(),
                Value<int> isOfflineCached = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> cloudVersion = const Value.absent(),
                Value<int?> syncLockExpiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoisCompanion.insert(
                id: id,
                name: name,
                description: description,
                authorId: authorId,
                isShared: isShared,
                isOfflineCached: isOfflineCached,
                createdAt: createdAt,
                cloudVersion: cloudVersion,
                syncLockExpiresAt: syncLockExpiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RoisTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({poisRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (poisRefs) db.pois],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (poisRefs)
                    await $_getPrefetchedData<Roi, $RoisTable, Poi>(
                      currentTable: table,
                      referencedTable: $$RoisTableReferences._poisRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoisTableReferences(db, table, p0).poisRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.roiId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoisTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoisTable,
      Roi,
      $$RoisTableFilterComposer,
      $$RoisTableOrderingComposer,
      $$RoisTableAnnotationComposer,
      $$RoisTableCreateCompanionBuilder,
      $$RoisTableUpdateCompanionBuilder,
      (Roi, $$RoisTableReferences),
      Roi,
      PrefetchHooks Function({bool poisRefs})
    >;
typedef $$PoisTableCreateCompanionBuilder =
    PoisCompanion Function({
      required String id,
      Value<String?> roiId,
      required String authorId,
      required String name,
      Value<String?> description,
      Value<String?> address,
      required double lat,
      required double lng,
      Value<String?> businessHours,
      Value<String?> contactInfo,
      Value<String?> localCoverImagePath,
      Value<String?> remoteCoverImageUrl,
      Value<int> createdAt,
      Value<bool> isShared,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$PoisTableUpdateCompanionBuilder =
    PoisCompanion Function({
      Value<String> id,
      Value<String?> roiId,
      Value<String> authorId,
      Value<String> name,
      Value<String?> description,
      Value<String?> address,
      Value<double> lat,
      Value<double> lng,
      Value<String?> businessHours,
      Value<String?> contactInfo,
      Value<String?> localCoverImagePath,
      Value<String?> remoteCoverImageUrl,
      Value<int> createdAt,
      Value<bool> isShared,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$PoisTableReferences
    extends BaseReferences<_$AppDatabase, $PoisTable, Poi> {
  $$PoisTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoisTable _roiIdTable(_$AppDatabase db) =>
      db.rois.createAlias($_aliasNameGenerator(db.pois.roiId, db.rois.id));

  $$RoisTableProcessedTableManager? get roiId {
    final $_column = $_itemColumn<String>('roi_id');
    if ($_column == null) return null;
    final manager = $$RoisTableTableManager(
      $_db,
      $_db.rois,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PoiAnimesTable, List<PoiAnime>>
  _poiAnimesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.poiAnimes,
    aliasName: $_aliasNameGenerator(db.pois.id, db.poiAnimes.poiId),
  );

  $$PoiAnimesTableProcessedTableManager get poiAnimesRefs {
    final manager = $$PoiAnimesTableTableManager(
      $_db,
      $_db.poiAnimes,
    ).filter((f) => f.poiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_poiAnimesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PoiTagsTable, List<PoiTag>> _poiTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.poiTags,
    aliasName: $_aliasNameGenerator(db.pois.id, db.poiTags.poiId),
  );

  $$PoiTagsTableProcessedTableManager get poiTagsRefs {
    final manager = $$PoiTagsTableTableManager(
      $_db,
      $_db.poiTags,
    ).filter((f) => f.poiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_poiTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TimeChunksTable, List<TimeChunk>>
  _timeChunksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timeChunks,
    aliasName: $_aliasNameGenerator(db.pois.id, db.timeChunks.poiId),
  );

  $$TimeChunksTableProcessedTableManager get timeChunksRefs {
    final manager = $$TimeChunksTableTableManager(
      $_db,
      $_db.timeChunks,
    ).filter((f) => f.poiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_timeChunksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReferenceImagesTable, List<ReferenceImage>>
  _referenceImagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.referenceImages,
    aliasName: $_aliasNameGenerator(db.pois.id, db.referenceImages.poiId),
  );

  $$ReferenceImagesTableProcessedTableManager get referenceImagesRefs {
    final manager = $$ReferenceImagesTableTableManager(
      $_db,
      $_db.referenceImages,
    ).filter((f) => f.poiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _referenceImagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MediaAssetsTable, List<MediaAsset>>
  _mediaAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mediaAssets,
    aliasName: $_aliasNameGenerator(db.pois.id, db.mediaAssets.poiId),
  );

  $$MediaAssetsTableProcessedTableManager get mediaAssetsRefs {
    final manager = $$MediaAssetsTableTableManager(
      $_db,
      $_db.mediaAssets,
    ).filter((f) => f.poiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PoisTableFilterComposer extends Composer<_$AppDatabase, $PoisTable> {
  $$PoisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessHours => $composableBuilder(
    column: $table.businessHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactInfo => $composableBuilder(
    column: $table.contactInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localCoverImagePath => $composableBuilder(
    column: $table.localCoverImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteCoverImageUrl => $composableBuilder(
    column: $table.remoteCoverImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$RoisTableFilterComposer get roiId {
    final $$RoisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roiId,
      referencedTable: $db.rois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoisTableFilterComposer(
            $db: $db,
            $table: $db.rois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> poiAnimesRefs(
    Expression<bool> Function($$PoiAnimesTableFilterComposer f) f,
  ) {
    final $$PoiAnimesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.poiAnimes,
      getReferencedColumn: (t) => t.poiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoiAnimesTableFilterComposer(
            $db: $db,
            $table: $db.poiAnimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> poiTagsRefs(
    Expression<bool> Function($$PoiTagsTableFilterComposer f) f,
  ) {
    final $$PoiTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.poiTags,
      getReferencedColumn: (t) => t.poiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoiTagsTableFilterComposer(
            $db: $db,
            $table: $db.poiTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> timeChunksRefs(
    Expression<bool> Function($$TimeChunksTableFilterComposer f) f,
  ) {
    final $$TimeChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timeChunks,
      getReferencedColumn: (t) => t.poiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeChunksTableFilterComposer(
            $db: $db,
            $table: $db.timeChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> referenceImagesRefs(
    Expression<bool> Function($$ReferenceImagesTableFilterComposer f) f,
  ) {
    final $$ReferenceImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.referenceImages,
      getReferencedColumn: (t) => t.poiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceImagesTableFilterComposer(
            $db: $db,
            $table: $db.referenceImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mediaAssetsRefs(
    Expression<bool> Function($$MediaAssetsTableFilterComposer f) f,
  ) {
    final $$MediaAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.poiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableFilterComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PoisTableOrderingComposer extends Composer<_$AppDatabase, $PoisTable> {
  $$PoisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessHours => $composableBuilder(
    column: $table.businessHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactInfo => $composableBuilder(
    column: $table.contactInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localCoverImagePath => $composableBuilder(
    column: $table.localCoverImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteCoverImageUrl => $composableBuilder(
    column: $table.remoteCoverImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoisTableOrderingComposer get roiId {
    final $$RoisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roiId,
      referencedTable: $db.rois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoisTableOrderingComposer(
            $db: $db,
            $table: $db.rois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PoisTableAnnotationComposer
    extends Composer<_$AppDatabase, $PoisTable> {
  $$PoisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get businessHours => $composableBuilder(
    column: $table.businessHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactInfo => $composableBuilder(
    column: $table.contactInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localCoverImagePath => $composableBuilder(
    column: $table.localCoverImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteCoverImageUrl => $composableBuilder(
    column: $table.remoteCoverImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$RoisTableAnnotationComposer get roiId {
    final $$RoisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roiId,
      referencedTable: $db.rois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoisTableAnnotationComposer(
            $db: $db,
            $table: $db.rois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> poiAnimesRefs<T extends Object>(
    Expression<T> Function($$PoiAnimesTableAnnotationComposer a) f,
  ) {
    final $$PoiAnimesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.poiAnimes,
      getReferencedColumn: (t) => t.poiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoiAnimesTableAnnotationComposer(
            $db: $db,
            $table: $db.poiAnimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> poiTagsRefs<T extends Object>(
    Expression<T> Function($$PoiTagsTableAnnotationComposer a) f,
  ) {
    final $$PoiTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.poiTags,
      getReferencedColumn: (t) => t.poiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoiTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.poiTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> timeChunksRefs<T extends Object>(
    Expression<T> Function($$TimeChunksTableAnnotationComposer a) f,
  ) {
    final $$TimeChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timeChunks,
      getReferencedColumn: (t) => t.poiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.timeChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> referenceImagesRefs<T extends Object>(
    Expression<T> Function($$ReferenceImagesTableAnnotationComposer a) f,
  ) {
    final $$ReferenceImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.referenceImages,
      getReferencedColumn: (t) => t.poiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.referenceImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mediaAssetsRefs<T extends Object>(
    Expression<T> Function($$MediaAssetsTableAnnotationComposer a) f,
  ) {
    final $$MediaAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.poiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PoisTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PoisTable,
          Poi,
          $$PoisTableFilterComposer,
          $$PoisTableOrderingComposer,
          $$PoisTableAnnotationComposer,
          $$PoisTableCreateCompanionBuilder,
          $$PoisTableUpdateCompanionBuilder,
          (Poi, $$PoisTableReferences),
          Poi,
          PrefetchHooks Function({
            bool roiId,
            bool poiAnimesRefs,
            bool poiTagsRefs,
            bool timeChunksRefs,
            bool referenceImagesRefs,
            bool mediaAssetsRefs,
          })
        > {
  $$PoisTableTableManager(_$AppDatabase db, $PoisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> roiId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<String?> businessHours = const Value.absent(),
                Value<String?> contactInfo = const Value.absent(),
                Value<String?> localCoverImagePath = const Value.absent(),
                Value<String?> remoteCoverImageUrl = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PoisCompanion(
                id: id,
                roiId: roiId,
                authorId: authorId,
                name: name,
                description: description,
                address: address,
                lat: lat,
                lng: lng,
                businessHours: businessHours,
                contactInfo: contactInfo,
                localCoverImagePath: localCoverImagePath,
                remoteCoverImageUrl: remoteCoverImageUrl,
                createdAt: createdAt,
                isShared: isShared,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> roiId = const Value.absent(),
                required String authorId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> address = const Value.absent(),
                required double lat,
                required double lng,
                Value<String?> businessHours = const Value.absent(),
                Value<String?> contactInfo = const Value.absent(),
                Value<String?> localCoverImagePath = const Value.absent(),
                Value<String?> remoteCoverImageUrl = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PoisCompanion.insert(
                id: id,
                roiId: roiId,
                authorId: authorId,
                name: name,
                description: description,
                address: address,
                lat: lat,
                lng: lng,
                businessHours: businessHours,
                contactInfo: contactInfo,
                localCoverImagePath: localCoverImagePath,
                remoteCoverImageUrl: remoteCoverImageUrl,
                createdAt: createdAt,
                isShared: isShared,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PoisTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                roiId = false,
                poiAnimesRefs = false,
                poiTagsRefs = false,
                timeChunksRefs = false,
                referenceImagesRefs = false,
                mediaAssetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (poiAnimesRefs) db.poiAnimes,
                    if (poiTagsRefs) db.poiTags,
                    if (timeChunksRefs) db.timeChunks,
                    if (referenceImagesRefs) db.referenceImages,
                    if (mediaAssetsRefs) db.mediaAssets,
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
                        if (roiId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.roiId,
                                    referencedTable: $$PoisTableReferences
                                        ._roiIdTable(db),
                                    referencedColumn: $$PoisTableReferences
                                        ._roiIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (poiAnimesRefs)
                        await $_getPrefetchedData<Poi, $PoisTable, PoiAnime>(
                          currentTable: table,
                          referencedTable: $$PoisTableReferences
                              ._poiAnimesRefsTable(db),
                          managerFromTypedResult: (p0) => $$PoisTableReferences(
                            db,
                            table,
                            p0,
                          ).poiAnimesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.poiId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (poiTagsRefs)
                        await $_getPrefetchedData<Poi, $PoisTable, PoiTag>(
                          currentTable: table,
                          referencedTable: $$PoisTableReferences
                              ._poiTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PoisTableReferences(db, table, p0).poiTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.poiId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (timeChunksRefs)
                        await $_getPrefetchedData<Poi, $PoisTable, TimeChunk>(
                          currentTable: table,
                          referencedTable: $$PoisTableReferences
                              ._timeChunksRefsTable(db),
                          managerFromTypedResult: (p0) => $$PoisTableReferences(
                            db,
                            table,
                            p0,
                          ).timeChunksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.poiId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (referenceImagesRefs)
                        await $_getPrefetchedData<
                          Poi,
                          $PoisTable,
                          ReferenceImage
                        >(
                          currentTable: table,
                          referencedTable: $$PoisTableReferences
                              ._referenceImagesRefsTable(db),
                          managerFromTypedResult: (p0) => $$PoisTableReferences(
                            db,
                            table,
                            p0,
                          ).referenceImagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.poiId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mediaAssetsRefs)
                        await $_getPrefetchedData<Poi, $PoisTable, MediaAsset>(
                          currentTable: table,
                          referencedTable: $$PoisTableReferences
                              ._mediaAssetsRefsTable(db),
                          managerFromTypedResult: (p0) => $$PoisTableReferences(
                            db,
                            table,
                            p0,
                          ).mediaAssetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.poiId == item.id,
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

typedef $$PoisTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PoisTable,
      Poi,
      $$PoisTableFilterComposer,
      $$PoisTableOrderingComposer,
      $$PoisTableAnnotationComposer,
      $$PoisTableCreateCompanionBuilder,
      $$PoisTableUpdateCompanionBuilder,
      (Poi, $$PoisTableReferences),
      Poi,
      PrefetchHooks Function({
        bool roiId,
        bool poiAnimesRefs,
        bool poiTagsRefs,
        bool timeChunksRefs,
        bool referenceImagesRefs,
        bool mediaAssetsRefs,
      })
    >;
typedef $$AnimesTableCreateCompanionBuilder =
    AnimesCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String?> bangumiId,
      required String authorId,
      Value<bool> isShared,
      Value<int> createdAt,
      Value<int> rowid,
    });
typedef $$AnimesTableUpdateCompanionBuilder =
    AnimesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> bangumiId,
      Value<String> authorId,
      Value<bool> isShared,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$AnimesTableReferences
    extends BaseReferences<_$AppDatabase, $AnimesTable, Anime> {
  $$AnimesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PoiAnimesTable, List<PoiAnime>>
  _poiAnimesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.poiAnimes,
    aliasName: $_aliasNameGenerator(db.animes.id, db.poiAnimes.animeId),
  );

  $$PoiAnimesTableProcessedTableManager get poiAnimesRefs {
    final manager = $$PoiAnimesTableTableManager(
      $_db,
      $_db.poiAnimes,
    ).filter((f) => f.animeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_poiAnimesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AnimesTableFilterComposer
    extends Composer<_$AppDatabase, $AnimesTable> {
  $$AnimesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bangumiId => $composableBuilder(
    column: $table.bangumiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> poiAnimesRefs(
    Expression<bool> Function($$PoiAnimesTableFilterComposer f) f,
  ) {
    final $$PoiAnimesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.poiAnimes,
      getReferencedColumn: (t) => t.animeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoiAnimesTableFilterComposer(
            $db: $db,
            $table: $db.poiAnimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AnimesTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimesTable> {
  $$AnimesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bangumiId => $composableBuilder(
    column: $table.bangumiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnimesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimesTable> {
  $$AnimesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bangumiId =>
      $composableBuilder(column: $table.bangumiId, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> poiAnimesRefs<T extends Object>(
    Expression<T> Function($$PoiAnimesTableAnnotationComposer a) f,
  ) {
    final $$PoiAnimesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.poiAnimes,
      getReferencedColumn: (t) => t.animeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoiAnimesTableAnnotationComposer(
            $db: $db,
            $table: $db.poiAnimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AnimesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnimesTable,
          Anime,
          $$AnimesTableFilterComposer,
          $$AnimesTableOrderingComposer,
          $$AnimesTableAnnotationComposer,
          $$AnimesTableCreateCompanionBuilder,
          $$AnimesTableUpdateCompanionBuilder,
          (Anime, $$AnimesTableReferences),
          Anime,
          PrefetchHooks Function({bool poiAnimesRefs})
        > {
  $$AnimesTableTableManager(_$AppDatabase db, $AnimesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> bangumiId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimesCompanion(
                id: id,
                name: name,
                description: description,
                bangumiId: bangumiId,
                authorId: authorId,
                isShared: isShared,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> bangumiId = const Value.absent(),
                required String authorId,
                Value<bool> isShared = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimesCompanion.insert(
                id: id,
                name: name,
                description: description,
                bangumiId: bangumiId,
                authorId: authorId,
                isShared: isShared,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AnimesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({poiAnimesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (poiAnimesRefs) db.poiAnimes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (poiAnimesRefs)
                    await $_getPrefetchedData<Anime, $AnimesTable, PoiAnime>(
                      currentTable: table,
                      referencedTable: $$AnimesTableReferences
                          ._poiAnimesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AnimesTableReferences(db, table, p0).poiAnimesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.animeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AnimesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnimesTable,
      Anime,
      $$AnimesTableFilterComposer,
      $$AnimesTableOrderingComposer,
      $$AnimesTableAnnotationComposer,
      $$AnimesTableCreateCompanionBuilder,
      $$AnimesTableUpdateCompanionBuilder,
      (Anime, $$AnimesTableReferences),
      Anime,
      PrefetchHooks Function({bool poiAnimesRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required String authorId,
      Value<bool> isShared,
      Value<int> createdAt,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> authorId,
      Value<bool> isShared,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PoiTagsTable, List<PoiTag>> _poiTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.poiTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.poiTags.tagId),
  );

  $$PoiTagsTableProcessedTableManager get poiTagsRefs {
    final manager = $$PoiTagsTableTableManager(
      $_db,
      $_db.poiTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_poiTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> poiTagsRefs(
    Expression<bool> Function($$PoiTagsTableFilterComposer f) f,
  ) {
    final $$PoiTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.poiTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoiTagsTableFilterComposer(
            $db: $db,
            $table: $db.poiTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> poiTagsRefs<T extends Object>(
    Expression<T> Function($$PoiTagsTableAnnotationComposer a) f,
  ) {
    final $$PoiTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.poiTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoiTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.poiTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool poiTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                description: description,
                authorId: authorId,
                isShared: isShared,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required String authorId,
                Value<bool> isShared = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                description: description,
                authorId: authorId,
                isShared: isShared,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({poiTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (poiTagsRefs) db.poiTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (poiTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, PoiTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._poiTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).poiTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool poiTagsRefs})
    >;
typedef $$PoiAnimesTableCreateCompanionBuilder =
    PoiAnimesCompanion Function({
      required String poiId,
      required String animeId,
      Value<int> rowid,
    });
typedef $$PoiAnimesTableUpdateCompanionBuilder =
    PoiAnimesCompanion Function({
      Value<String> poiId,
      Value<String> animeId,
      Value<int> rowid,
    });

final class $$PoiAnimesTableReferences
    extends BaseReferences<_$AppDatabase, $PoiAnimesTable, PoiAnime> {
  $$PoiAnimesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PoisTable _poiIdTable(_$AppDatabase db) =>
      db.pois.createAlias($_aliasNameGenerator(db.poiAnimes.poiId, db.pois.id));

  $$PoisTableProcessedTableManager get poiId {
    final $_column = $_itemColumn<String>('poi_id')!;

    final manager = $$PoisTableTableManager(
      $_db,
      $_db.pois,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AnimesTable _animeIdTable(_$AppDatabase db) => db.animes.createAlias(
    $_aliasNameGenerator(db.poiAnimes.animeId, db.animes.id),
  );

  $$AnimesTableProcessedTableManager get animeId {
    final $_column = $_itemColumn<String>('anime_id')!;

    final manager = $$AnimesTableTableManager(
      $_db,
      $_db.animes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_animeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PoiAnimesTableFilterComposer
    extends Composer<_$AppDatabase, $PoiAnimesTable> {
  $$PoiAnimesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PoisTableFilterComposer get poiId {
    final $$PoisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableFilterComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AnimesTableFilterComposer get animeId {
    final $$AnimesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.animeId,
      referencedTable: $db.animes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnimesTableFilterComposer(
            $db: $db,
            $table: $db.animes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PoiAnimesTableOrderingComposer
    extends Composer<_$AppDatabase, $PoiAnimesTable> {
  $$PoiAnimesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PoisTableOrderingComposer get poiId {
    final $$PoisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableOrderingComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AnimesTableOrderingComposer get animeId {
    final $$AnimesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.animeId,
      referencedTable: $db.animes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnimesTableOrderingComposer(
            $db: $db,
            $table: $db.animes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PoiAnimesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PoiAnimesTable> {
  $$PoiAnimesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PoisTableAnnotationComposer get poiId {
    final $$PoisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableAnnotationComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AnimesTableAnnotationComposer get animeId {
    final $$AnimesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.animeId,
      referencedTable: $db.animes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnimesTableAnnotationComposer(
            $db: $db,
            $table: $db.animes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PoiAnimesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PoiAnimesTable,
          PoiAnime,
          $$PoiAnimesTableFilterComposer,
          $$PoiAnimesTableOrderingComposer,
          $$PoiAnimesTableAnnotationComposer,
          $$PoiAnimesTableCreateCompanionBuilder,
          $$PoiAnimesTableUpdateCompanionBuilder,
          (PoiAnime, $$PoiAnimesTableReferences),
          PoiAnime,
          PrefetchHooks Function({bool poiId, bool animeId})
        > {
  $$PoiAnimesTableTableManager(_$AppDatabase db, $PoiAnimesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoiAnimesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoiAnimesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoiAnimesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> poiId = const Value.absent(),
                Value<String> animeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PoiAnimesCompanion(
                poiId: poiId,
                animeId: animeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String poiId,
                required String animeId,
                Value<int> rowid = const Value.absent(),
              }) => PoiAnimesCompanion.insert(
                poiId: poiId,
                animeId: animeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PoiAnimesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({poiId = false, animeId = false}) {
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
                    if (poiId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.poiId,
                                referencedTable: $$PoiAnimesTableReferences
                                    ._poiIdTable(db),
                                referencedColumn: $$PoiAnimesTableReferences
                                    ._poiIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (animeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.animeId,
                                referencedTable: $$PoiAnimesTableReferences
                                    ._animeIdTable(db),
                                referencedColumn: $$PoiAnimesTableReferences
                                    ._animeIdTable(db)
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

typedef $$PoiAnimesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PoiAnimesTable,
      PoiAnime,
      $$PoiAnimesTableFilterComposer,
      $$PoiAnimesTableOrderingComposer,
      $$PoiAnimesTableAnnotationComposer,
      $$PoiAnimesTableCreateCompanionBuilder,
      $$PoiAnimesTableUpdateCompanionBuilder,
      (PoiAnime, $$PoiAnimesTableReferences),
      PoiAnime,
      PrefetchHooks Function({bool poiId, bool animeId})
    >;
typedef $$PoiTagsTableCreateCompanionBuilder =
    PoiTagsCompanion Function({
      required String poiId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$PoiTagsTableUpdateCompanionBuilder =
    PoiTagsCompanion Function({
      Value<String> poiId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$PoiTagsTableReferences
    extends BaseReferences<_$AppDatabase, $PoiTagsTable, PoiTag> {
  $$PoiTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PoisTable _poiIdTable(_$AppDatabase db) =>
      db.pois.createAlias($_aliasNameGenerator(db.poiTags.poiId, db.pois.id));

  $$PoisTableProcessedTableManager get poiId {
    final $_column = $_itemColumn<String>('poi_id')!;

    final manager = $$PoisTableTableManager(
      $_db,
      $_db.pois,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.poiTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PoiTagsTableFilterComposer
    extends Composer<_$AppDatabase, $PoiTagsTable> {
  $$PoiTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PoisTableFilterComposer get poiId {
    final $$PoisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableFilterComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PoiTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $PoiTagsTable> {
  $$PoiTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PoisTableOrderingComposer get poiId {
    final $$PoisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableOrderingComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PoiTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PoiTagsTable> {
  $$PoiTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PoisTableAnnotationComposer get poiId {
    final $$PoisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableAnnotationComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PoiTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PoiTagsTable,
          PoiTag,
          $$PoiTagsTableFilterComposer,
          $$PoiTagsTableOrderingComposer,
          $$PoiTagsTableAnnotationComposer,
          $$PoiTagsTableCreateCompanionBuilder,
          $$PoiTagsTableUpdateCompanionBuilder,
          (PoiTag, $$PoiTagsTableReferences),
          PoiTag,
          PrefetchHooks Function({bool poiId, bool tagId})
        > {
  $$PoiTagsTableTableManager(_$AppDatabase db, $PoiTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoiTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoiTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoiTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> poiId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PoiTagsCompanion(poiId: poiId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required String poiId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => PoiTagsCompanion.insert(
                poiId: poiId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PoiTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({poiId = false, tagId = false}) {
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
                    if (poiId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.poiId,
                                referencedTable: $$PoiTagsTableReferences
                                    ._poiIdTable(db),
                                referencedColumn: $$PoiTagsTableReferences
                                    ._poiIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$PoiTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$PoiTagsTableReferences
                                    ._tagIdTable(db)
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

typedef $$PoiTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PoiTagsTable,
      PoiTag,
      $$PoiTagsTableFilterComposer,
      $$PoiTagsTableOrderingComposer,
      $$PoiTagsTableAnnotationComposer,
      $$PoiTagsTableCreateCompanionBuilder,
      $$PoiTagsTableUpdateCompanionBuilder,
      (PoiTag, $$PoiTagsTableReferences),
      PoiTag,
      PrefetchHooks Function({bool poiId, bool tagId})
    >;
typedef $$TimeChunksTableCreateCompanionBuilder =
    TimeChunksCompanion Function({
      required String id,
      required String poiId,
      Value<String?> date,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<String> status,
      Value<int> sortOrder,
      Value<int> duration,
      Value<int> transitDuration,
      Value<bool> isFixedTime,
      required String authorId,
      Value<bool> isShared,
      Value<int> createdAt,
      Value<int> syncStatus,
      Value<bool> isDeleted,
      Value<bool> hasEverSynced,
      Value<String?> originalStartTime,
      Value<String?> originalEndTime,
      Value<DateTime?> lastModifiedAt,
      Value<int> rowid,
    });
typedef $$TimeChunksTableUpdateCompanionBuilder =
    TimeChunksCompanion Function({
      Value<String> id,
      Value<String> poiId,
      Value<String?> date,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<String> status,
      Value<int> sortOrder,
      Value<int> duration,
      Value<int> transitDuration,
      Value<bool> isFixedTime,
      Value<String> authorId,
      Value<bool> isShared,
      Value<int> createdAt,
      Value<int> syncStatus,
      Value<bool> isDeleted,
      Value<bool> hasEverSynced,
      Value<String?> originalStartTime,
      Value<String?> originalEndTime,
      Value<DateTime?> lastModifiedAt,
      Value<int> rowid,
    });

final class $$TimeChunksTableReferences
    extends BaseReferences<_$AppDatabase, $TimeChunksTable, TimeChunk> {
  $$TimeChunksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PoisTable _poiIdTable(_$AppDatabase db) => db.pois.createAlias(
    $_aliasNameGenerator(db.timeChunks.poiId, db.pois.id),
  );

  $$PoisTableProcessedTableManager get poiId {
    final $_column = $_itemColumn<String>('poi_id')!;

    final manager = $$PoisTableTableManager(
      $_db,
      $_db.pois,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimeChunksTableFilterComposer
    extends Composer<_$AppDatabase, $TimeChunksTable> {
  $$TimeChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transitDuration => $composableBuilder(
    column: $table.transitDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFixedTime => $composableBuilder(
    column: $table.isFixedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasEverSynced => $composableBuilder(
    column: $table.hasEverSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalStartTime => $composableBuilder(
    column: $table.originalStartTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalEndTime => $composableBuilder(
    column: $table.originalEndTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PoisTableFilterComposer get poiId {
    final $$PoisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableFilterComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimeChunksTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeChunksTable> {
  $$TimeChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transitDuration => $composableBuilder(
    column: $table.transitDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFixedTime => $composableBuilder(
    column: $table.isFixedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasEverSynced => $composableBuilder(
    column: $table.hasEverSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalStartTime => $composableBuilder(
    column: $table.originalStartTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalEndTime => $composableBuilder(
    column: $table.originalEndTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PoisTableOrderingComposer get poiId {
    final $$PoisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableOrderingComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimeChunksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeChunksTable> {
  $$TimeChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get transitDuration => $composableBuilder(
    column: $table.transitDuration,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFixedTime => $composableBuilder(
    column: $table.isFixedTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get hasEverSynced => $composableBuilder(
    column: $table.hasEverSynced,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalStartTime => $composableBuilder(
    column: $table.originalStartTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalEndTime => $composableBuilder(
    column: $table.originalEndTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );

  $$PoisTableAnnotationComposer get poiId {
    final $$PoisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableAnnotationComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimeChunksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimeChunksTable,
          TimeChunk,
          $$TimeChunksTableFilterComposer,
          $$TimeChunksTableOrderingComposer,
          $$TimeChunksTableAnnotationComposer,
          $$TimeChunksTableCreateCompanionBuilder,
          $$TimeChunksTableUpdateCompanionBuilder,
          (TimeChunk, $$TimeChunksTableReferences),
          TimeChunk,
          PrefetchHooks Function({bool poiId})
        > {
  $$TimeChunksTableTableManager(_$AppDatabase db, $TimeChunksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeChunksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeChunksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeChunksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> poiId = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int> transitDuration = const Value.absent(),
                Value<bool> isFixedTime = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> hasEverSynced = const Value.absent(),
                Value<String?> originalStartTime = const Value.absent(),
                Value<String?> originalEndTime = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimeChunksCompanion(
                id: id,
                poiId: poiId,
                date: date,
                startTime: startTime,
                endTime: endTime,
                status: status,
                sortOrder: sortOrder,
                duration: duration,
                transitDuration: transitDuration,
                isFixedTime: isFixedTime,
                authorId: authorId,
                isShared: isShared,
                createdAt: createdAt,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                hasEverSynced: hasEverSynced,
                originalStartTime: originalStartTime,
                originalEndTime: originalEndTime,
                lastModifiedAt: lastModifiedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String poiId,
                Value<String?> date = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int> transitDuration = const Value.absent(),
                Value<bool> isFixedTime = const Value.absent(),
                required String authorId,
                Value<bool> isShared = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> hasEverSynced = const Value.absent(),
                Value<String?> originalStartTime = const Value.absent(),
                Value<String?> originalEndTime = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimeChunksCompanion.insert(
                id: id,
                poiId: poiId,
                date: date,
                startTime: startTime,
                endTime: endTime,
                status: status,
                sortOrder: sortOrder,
                duration: duration,
                transitDuration: transitDuration,
                isFixedTime: isFixedTime,
                authorId: authorId,
                isShared: isShared,
                createdAt: createdAt,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                hasEverSynced: hasEverSynced,
                originalStartTime: originalStartTime,
                originalEndTime: originalEndTime,
                lastModifiedAt: lastModifiedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimeChunksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({poiId = false}) {
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
                    if (poiId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.poiId,
                                referencedTable: $$TimeChunksTableReferences
                                    ._poiIdTable(db),
                                referencedColumn: $$TimeChunksTableReferences
                                    ._poiIdTable(db)
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

typedef $$TimeChunksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimeChunksTable,
      TimeChunk,
      $$TimeChunksTableFilterComposer,
      $$TimeChunksTableOrderingComposer,
      $$TimeChunksTableAnnotationComposer,
      $$TimeChunksTableCreateCompanionBuilder,
      $$TimeChunksTableUpdateCompanionBuilder,
      (TimeChunk, $$TimeChunksTableReferences),
      TimeChunk,
      PrefetchHooks Function({bool poiId})
    >;
typedef $$ReferenceImagesTableCreateCompanionBuilder =
    ReferenceImagesCompanion Function({
      required String id,
      required String poiId,
      required String authorId,
      Value<String?> localPath,
      Value<String?> remoteUrl,
      Value<String?> metadata,
      Value<int> createdAt,
      Value<int> rowid,
    });
typedef $$ReferenceImagesTableUpdateCompanionBuilder =
    ReferenceImagesCompanion Function({
      Value<String> id,
      Value<String> poiId,
      Value<String> authorId,
      Value<String?> localPath,
      Value<String?> remoteUrl,
      Value<String?> metadata,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$ReferenceImagesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReferenceImagesTable, ReferenceImage> {
  $$ReferenceImagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PoisTable _poiIdTable(_$AppDatabase db) => db.pois.createAlias(
    $_aliasNameGenerator(db.referenceImages.poiId, db.pois.id),
  );

  $$PoisTableProcessedTableManager get poiId {
    final $_column = $_itemColumn<String>('poi_id')!;

    final manager = $$PoisTableTableManager(
      $_db,
      $_db.pois,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MediaAssetsTable, List<MediaAsset>>
  _mediaAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mediaAssets,
    aliasName: $_aliasNameGenerator(
      db.referenceImages.id,
      db.mediaAssets.referenceImageId,
    ),
  );

  $$MediaAssetsTableProcessedTableManager get mediaAssetsRefs {
    final manager = $$MediaAssetsTableTableManager($_db, $_db.mediaAssets)
        .filter(
          (f) => f.referenceImageId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_mediaAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReferenceImagesTableFilterComposer
    extends Composer<_$AppDatabase, $ReferenceImagesTable> {
  $$ReferenceImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PoisTableFilterComposer get poiId {
    final $$PoisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableFilterComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> mediaAssetsRefs(
    Expression<bool> Function($$MediaAssetsTableFilterComposer f) f,
  ) {
    final $$MediaAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.referenceImageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableFilterComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReferenceImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferenceImagesTable> {
  $$ReferenceImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PoisTableOrderingComposer get poiId {
    final $$PoisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableOrderingComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReferenceImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferenceImagesTable> {
  $$ReferenceImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PoisTableAnnotationComposer get poiId {
    final $$PoisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableAnnotationComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> mediaAssetsRefs<T extends Object>(
    Expression<T> Function($$MediaAssetsTableAnnotationComposer a) f,
  ) {
    final $$MediaAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.referenceImageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReferenceImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReferenceImagesTable,
          ReferenceImage,
          $$ReferenceImagesTableFilterComposer,
          $$ReferenceImagesTableOrderingComposer,
          $$ReferenceImagesTableAnnotationComposer,
          $$ReferenceImagesTableCreateCompanionBuilder,
          $$ReferenceImagesTableUpdateCompanionBuilder,
          (ReferenceImage, $$ReferenceImagesTableReferences),
          ReferenceImage,
          PrefetchHooks Function({bool poiId, bool mediaAssetsRefs})
        > {
  $$ReferenceImagesTableTableManager(
    _$AppDatabase db,
    $ReferenceImagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferenceImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferenceImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferenceImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> poiId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferenceImagesCompanion(
                id: id,
                poiId: poiId,
                authorId: authorId,
                localPath: localPath,
                remoteUrl: remoteUrl,
                metadata: metadata,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String poiId,
                required String authorId,
                Value<String?> localPath = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferenceImagesCompanion.insert(
                id: id,
                poiId: poiId,
                authorId: authorId,
                localPath: localPath,
                remoteUrl: remoteUrl,
                metadata: metadata,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReferenceImagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({poiId = false, mediaAssetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (mediaAssetsRefs) db.mediaAssets],
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
                    if (poiId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.poiId,
                                referencedTable:
                                    $$ReferenceImagesTableReferences
                                        ._poiIdTable(db),
                                referencedColumn:
                                    $$ReferenceImagesTableReferences
                                        ._poiIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mediaAssetsRefs)
                    await $_getPrefetchedData<
                      ReferenceImage,
                      $ReferenceImagesTable,
                      MediaAsset
                    >(
                      currentTable: table,
                      referencedTable: $$ReferenceImagesTableReferences
                          ._mediaAssetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ReferenceImagesTableReferences(
                            db,
                            table,
                            p0,
                          ).mediaAssetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.referenceImageId == item.id,
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

typedef $$ReferenceImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReferenceImagesTable,
      ReferenceImage,
      $$ReferenceImagesTableFilterComposer,
      $$ReferenceImagesTableOrderingComposer,
      $$ReferenceImagesTableAnnotationComposer,
      $$ReferenceImagesTableCreateCompanionBuilder,
      $$ReferenceImagesTableUpdateCompanionBuilder,
      (ReferenceImage, $$ReferenceImagesTableReferences),
      ReferenceImage,
      PrefetchHooks Function({bool poiId, bool mediaAssetsRefs})
    >;
typedef $$MediaAssetsTableCreateCompanionBuilder =
    MediaAssetsCompanion Function({
      required String id,
      required String poiId,
      required String authorId,
      required String type,
      Value<String?> localPath,
      Value<String?> remoteUrl,
      Value<String?> metadata,
      Value<String?> referenceImageId,
      Value<int> createdAt,
      Value<int> rowid,
    });
typedef $$MediaAssetsTableUpdateCompanionBuilder =
    MediaAssetsCompanion Function({
      Value<String> id,
      Value<String> poiId,
      Value<String> authorId,
      Value<String> type,
      Value<String?> localPath,
      Value<String?> remoteUrl,
      Value<String?> metadata,
      Value<String?> referenceImageId,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$MediaAssetsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaAssetsTable, MediaAsset> {
  $$MediaAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PoisTable _poiIdTable(_$AppDatabase db) => db.pois.createAlias(
    $_aliasNameGenerator(db.mediaAssets.poiId, db.pois.id),
  );

  $$PoisTableProcessedTableManager get poiId {
    final $_column = $_itemColumn<String>('poi_id')!;

    final manager = $$PoisTableTableManager(
      $_db,
      $_db.pois,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ReferenceImagesTable _referenceImageIdTable(_$AppDatabase db) =>
      db.referenceImages.createAlias(
        $_aliasNameGenerator(
          db.mediaAssets.referenceImageId,
          db.referenceImages.id,
        ),
      );

  $$ReferenceImagesTableProcessedTableManager? get referenceImageId {
    final $_column = $_itemColumn<String>('reference_image_id');
    if ($_column == null) return null;
    final manager = $$ReferenceImagesTableTableManager(
      $_db,
      $_db.referenceImages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_referenceImageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PoisTableFilterComposer get poiId {
    final $$PoisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableFilterComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReferenceImagesTableFilterComposer get referenceImageId {
    final $$ReferenceImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceImageId,
      referencedTable: $db.referenceImages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceImagesTableFilterComposer(
            $db: $db,
            $table: $db.referenceImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PoisTableOrderingComposer get poiId {
    final $$PoisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableOrderingComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReferenceImagesTableOrderingComposer get referenceImageId {
    final $$ReferenceImagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceImageId,
      referencedTable: $db.referenceImages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceImagesTableOrderingComposer(
            $db: $db,
            $table: $db.referenceImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PoisTableAnnotationComposer get poiId {
    final $$PoisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poiId,
      referencedTable: $db.pois,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoisTableAnnotationComposer(
            $db: $db,
            $table: $db.pois,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReferenceImagesTableAnnotationComposer get referenceImageId {
    final $$ReferenceImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceImageId,
      referencedTable: $db.referenceImages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.referenceImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaAssetsTable,
          MediaAsset,
          $$MediaAssetsTableFilterComposer,
          $$MediaAssetsTableOrderingComposer,
          $$MediaAssetsTableAnnotationComposer,
          $$MediaAssetsTableCreateCompanionBuilder,
          $$MediaAssetsTableUpdateCompanionBuilder,
          (MediaAsset, $$MediaAssetsTableReferences),
          MediaAsset,
          PrefetchHooks Function({bool poiId, bool referenceImageId})
        > {
  $$MediaAssetsTableTableManager(_$AppDatabase db, $MediaAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> poiId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String?> referenceImageId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaAssetsCompanion(
                id: id,
                poiId: poiId,
                authorId: authorId,
                type: type,
                localPath: localPath,
                remoteUrl: remoteUrl,
                metadata: metadata,
                referenceImageId: referenceImageId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String poiId,
                required String authorId,
                required String type,
                Value<String?> localPath = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String?> referenceImageId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaAssetsCompanion.insert(
                id: id,
                poiId: poiId,
                authorId: authorId,
                type: type,
                localPath: localPath,
                remoteUrl: remoteUrl,
                metadata: metadata,
                referenceImageId: referenceImageId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({poiId = false, referenceImageId = false}) {
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
                    if (poiId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.poiId,
                                referencedTable: $$MediaAssetsTableReferences
                                    ._poiIdTable(db),
                                referencedColumn: $$MediaAssetsTableReferences
                                    ._poiIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (referenceImageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.referenceImageId,
                                referencedTable: $$MediaAssetsTableReferences
                                    ._referenceImageIdTable(db),
                                referencedColumn: $$MediaAssetsTableReferences
                                    ._referenceImageIdTable(db)
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

typedef $$MediaAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaAssetsTable,
      MediaAsset,
      $$MediaAssetsTableFilterComposer,
      $$MediaAssetsTableOrderingComposer,
      $$MediaAssetsTableAnnotationComposer,
      $$MediaAssetsTableCreateCompanionBuilder,
      $$MediaAssetsTableUpdateCompanionBuilder,
      (MediaAsset, $$MediaAssetsTableReferences),
      MediaAsset,
      PrefetchHooks Function({bool poiId, bool referenceImageId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoisTableTableManager get rois => $$RoisTableTableManager(_db, _db.rois);
  $$PoisTableTableManager get pois => $$PoisTableTableManager(_db, _db.pois);
  $$AnimesTableTableManager get animes =>
      $$AnimesTableTableManager(_db, _db.animes);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$PoiAnimesTableTableManager get poiAnimes =>
      $$PoiAnimesTableTableManager(_db, _db.poiAnimes);
  $$PoiTagsTableTableManager get poiTags =>
      $$PoiTagsTableTableManager(_db, _db.poiTags);
  $$TimeChunksTableTableManager get timeChunks =>
      $$TimeChunksTableTableManager(_db, _db.timeChunks);
  $$ReferenceImagesTableTableManager get referenceImages =>
      $$ReferenceImagesTableTableManager(_db, _db.referenceImages);
  $$MediaAssetsTableTableManager get mediaAssets =>
      $$MediaAssetsTableTableManager(_db, _db.mediaAssets);
}
