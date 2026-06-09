import 'package:drift/drift.dart';

enum SyncStatus {
  synced,
  dirty,
  stashed
}

class Rois extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  
  // ADDED: Required fields for dual-track sync
  TextColumn get authorId => text()();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();
  
  IntColumn get isOfflineCached => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  IntColumn get cloudVersion => integer().withDefault(const Constant(0))();
  IntColumn get syncLockExpiresAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Animes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get bangumiId => text().nullable().unique()();
  
  // ADDED: Required fields for dual-track sync
  TextColumn get authorId => text()();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();
  
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  
  // ADDED: Required fields for dual-track sync
  TextColumn get authorId => text()();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();
  
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}

class Pois extends Table {
  TextColumn get id => text()();
  TextColumn get roiId =>
      text().nullable().references(Rois, #id, onDelete: KeyAction.setNull)();
  TextColumn get authorId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get businessHours => text().nullable()();
  TextColumn get contactInfo => text().nullable()();
  TextColumn get localCoverImagePath => text().nullable()();
  TextColumn get remoteCoverImageUrl => text().nullable()();
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class PoiAnimes extends Table {
  TextColumn get poiId =>
      text().references(Pois, #id, onDelete: KeyAction.cascade)();
  TextColumn get animeId =>
      text().references(Animes, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {poiId, animeId};
}

class PoiTags extends Table {
  TextColumn get poiId =>
      text().references(Pois, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {poiId, tagId};
}

class TimeChunks extends Table {
  TextColumn get id => text()();
  TextColumn get poiId => text().references(Pois, #id)();
  TextColumn get date => text().nullable()();
  TextColumn get startTime => text().nullable()();
  TextColumn get endTime => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('backlog'))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  
  IntColumn get duration => integer().withDefault(const Constant(60))();
  IntColumn get transitDuration => integer().withDefault(const Constant(0))();
  BoolColumn get isFixedTime => boolean().withDefault(const Constant(false))();
  
  // ADDED: Required fields for dual-track sync
  TextColumn get authorId => text()();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  IntColumn get syncStatus => intEnum<SyncStatus>().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get hasEverSynced => boolean().withDefault(const Constant(false))();

  TextColumn get originalStartTime => text().nullable()();
  TextColumn get originalEndTime => text().nullable()();
  DateTimeColumn get lastModifiedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ReferenceImages extends Table {
  TextColumn get id => text()();
  TextColumn get poiId => text().references(Pois, #id)();
  TextColumn get authorId => text()();
  TextColumn get localPath => text().nullable()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get metadata => text().nullable()();
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}

class MediaAssets extends Table {
  TextColumn get id => text()();
  TextColumn get poiId => text().references(Pois, #id)();
  TextColumn get authorId => text()();
  TextColumn get type => text()();
  TextColumn get localPath => text().nullable()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get metadata => text().nullable()();
  TextColumn get referenceImageId => text()
      .nullable()
      .references(ReferenceImages, #id, onDelete: KeyAction.setNull)();
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column> get primaryKey => {id};
}