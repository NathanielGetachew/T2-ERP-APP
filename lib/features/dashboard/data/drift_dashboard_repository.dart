import 'dart:async';

import '../../../core/database/database.dart';
import '../../customers/domain/customer.dart';
import '../../materials/domain/rental_material.dart';
import '../../rentals/domain/rental.dart';
import '../domain/dashboard_repository.dart';

class DriftDashboardRepository implements DashboardRepository {
  DriftDashboardRepository(this.database);

  final AppDatabase database;

  @override
  Future<DashboardDataSnapshot> loadSnapshot() async {
    final rentalRows = await (database.select(
      database.rentals,
    )..where((tbl) => tbl.voidedAt.isNull())).get();
    final lineRows = await database.select(database.rentalItems).get();
    final eventRows = await (database.select(
      database.returnEvents,
    )..where((tbl) => tbl.voidedAt.isNull())).get();
    final customerRows = await database.select(database.customers).get();
    final materialRows = await database.select(database.materialTypes).get();

    final rentals = rentalRows.map((row) {
      return RentalRecord(
        id: row.id,
        rentalNumber: row.rentalNumber,
        customerId: row.customerId,
        rentedAt: row.rentedAt,
        status: RentalStatus.values.byName(row.status),
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        voidedAt: row.voidedAt,
        voidReason: row.voidReason,
      );
    }).toList();

    final validRentalIds = rentals.map((r) => r.id).toSet();
    final lines = lineRows
        .where((row) => validRentalIds.contains(row.rentalId))
        .map((row) {
          return RentalLine(
            id: row.id,
            rentalId: row.rentalId,
            materialId: row.materialTypeId,
            materialNameSnapshot: row.materialNameSnapshot,
            pricePerDaySnapshot: row.pricePerDaySnapshot,
            quantity: row.quantity,
            quantityReturned: row.quantityReturned,
          );
        })
        .toList();

    final returnEvents = eventRows.map((row) {
      return ReturnEventRecord(
        id: row.id,
        rentalId: row.rentalId,
        rentalItemId: row.rentalItemId,
        quantity: row.quantity,
        returnedAt: row.returnedAt,
        billableDays: row.billableDays,
        amount: row.amount,
        pricePerDaySnapshot: row.pricePerDaySnapshot,
        conditionNote: row.conditionNote,
        createdAt: row.createdAt,
        voidedAt: row.voidedAt,
        voidReason: row.voidReason,
      );
    }).toList();

    final customers = customerRows.map((row) {
      return Customer(
        id: row.id,
        fullName: row.fullName,
        address: row.address,
        phone: row.phone,
        notes: row.notes,
        idPhotoFrontPath: row.idPhotoFront,
        idPhotoBackPath: row.idPhotoBack,
        isActive: row.voidedAt == null,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
    }).toList();

    final materials = materialRows.map((row) {
      return RentalMaterial(
        id: row.id,
        category: row.category,
        name: row.name,
        pricePerDay: row.pricePerDay,
        totalStock: row.totalStock,
        isActive: row.isActive,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
    }).toList();

    return DashboardDataSnapshot(
      rentals: rentals,
      lines: lines,
      returnEvents: returnEvents,
      customers: customers,
      materials: materials,
    );
  }

  @override
  Stream<void> watchChanges() {
    late StreamController<void> controller;
    final subscriptions = <StreamSubscription<dynamic>>[];

    controller = StreamController<void>.broadcast(
      onListen: () {
        void notify(dynamic _) {
          if (!controller.isClosed) {
            controller.add(null);
          }
        }

        subscriptions.add(
          database.select(database.rentals).watch().skip(1).listen(notify),
        );
        subscriptions.add(
          database.select(database.returnEvents).watch().skip(1).listen(notify),
        );
        subscriptions.add(
          database.select(database.customers).watch().skip(1).listen(notify),
        );
        subscriptions.add(
          database
              .select(database.materialTypes)
              .watch()
              .skip(1)
              .listen(notify),
        );
      },
      onCancel: () {
        for (final sub in subscriptions) {
          sub.cancel();
        }
        subscriptions.clear();
      },
    );

    return controller.stream;
  }
}
