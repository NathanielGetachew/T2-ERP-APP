import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:drift/native.dart';

part 'database.g.dart';

class Customers extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get fullName => text()();
  TextColumn get phone => text()();
  TextColumn get address => text()();
  TextColumn get idPhotoFront => text()();
  TextColumn get idPhotoBack => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get voidedAt => dateTime().nullable()();
  TextColumn get voidReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MaterialTypes extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get category => text()();
  TextColumn get name => text()();
  TextColumn get variant => text().nullable()();
  IntColumn get pricePerDay => integer()();
  IntColumn get totalStock => integer().nullable()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Rentals extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get customerId => text()();
  DateTimeColumn get rentedAt => dateTime()();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get customerSignature => text().nullable()();
  TextColumn get handoverPhoto => text().nullable()();
  DateTimeColumn get voidedAt => dateTime().nullable()();
  TextColumn get voidReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class RentalItems extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get rentalId => text()();
  TextColumn get materialTypeId => text()();
  TextColumn get materialNameSnapshot => text()();
  IntColumn get pricePerDaySnapshot => integer()();
  IntColumn get quantity => integer()();
  IntColumn get quantityReturned => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ReturnEvents extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get rentalItemId => text()();
  IntColumn get quantity => integer()();
  DateTimeColumn get returnedAt => dateTime()();
  TextColumn get conditionNote => text().nullable()();
  IntColumn get days => integer()();
  IntColumn get amount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AuditLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  DateTimeColumn get at => dateTime()();
  TextColumn get by => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Customers,
    MaterialTypes,
    Rentals,
    RentalItems,
    ReturnEvents,
    AuditLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 't2_rental'));

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {},
  );
}
