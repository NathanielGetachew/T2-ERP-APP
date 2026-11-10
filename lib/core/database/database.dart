import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

const appDatabaseSchemaVersion = 5;
const appDatabaseFileName = 't2_rental.sqlite';

@DataClassName('CustomerRow')
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

@DataClassName('MaterialRow')
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

@DataClassName('RentalRow')
class Rentals extends Table {
  TextColumn get id => text()();
  IntColumn get rentalNumber => integer().withDefault(const Constant(0))();
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

@DataClassName('RentalItemRow')
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

@DataClassName('ReturnEventRow')
class ReturnEvents extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get rentalId => text().withDefault(const Constant(''))();
  TextColumn get rentalItemId => text()();
  IntColumn get quantity => integer()();
  DateTimeColumn get returnedAt => dateTime()();
  TextColumn get conditionNote => text().nullable()();
  IntColumn get billableDays => integer()();
  IntColumn get amount => integer()();
  IntColumn get pricePerDaySnapshot =>
      integer().withDefault(const Constant(0))();
  TextColumn get returnBatchId => text().nullable()();
  DateTimeColumn get voidedAt => dateTime().nullable()();
  TextColumn get voidReason => text().nullable()();

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
    : super(
        executor ??
            driftDatabase(
              name: 't2_rental',
              native: const DriftNativeOptions(
                databaseDirectory: getApplicationDocumentsDirectory,
              ),
            ),
      );

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => appDatabaseSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(rentals, rentals.rentalNumber);
        final existing = await select(rentals).get();
        existing.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        for (var index = 0; index < existing.length; index++) {
          await (update(rentals)
                ..where((table) => table.id.equals(existing[index].id)))
              .write(RentalsCompanion(rentalNumber: Value(index + 1)));
        }
      }
      if (from < 3) {
        await m.renameColumn(returnEvents, 'days', returnEvents.billableDays);
        await m.addColumn(returnEvents, returnEvents.rentalId);
        await m.addColumn(returnEvents, returnEvents.pricePerDaySnapshot);
        await customStatement(
          'UPDATE return_events '
          'SET rental_id = (SELECT rental_id FROM rental_items '
          'WHERE rental_items.id = return_events.rental_item_id) '
          'WHERE rental_id = \'\'',
        );
        await customStatement(
          'UPDATE return_events SET price_per_day_snapshot = '
          '(SELECT price_per_day_snapshot FROM rental_items '
          'WHERE rental_items.id = return_events.rental_item_id) '
          'WHERE price_per_day_snapshot = 0',
        );
      }
      if (from < 4) {
        await m.addColumn(returnEvents, returnEvents.voidedAt);
        await m.addColumn(returnEvents, returnEvents.voidReason);
      }
      if (from < 5) {
        await m.addColumn(returnEvents, returnEvents.returnBatchId);
      }
    },
  );
}
