import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/database/database.dart';
import 'package:t2_rental/core/utils/clock.dart';
import 'package:t2_rental/features/customers/data/customer_repository.dart';
import 'package:t2_rental/features/materials/data/material_repository.dart';
import 'package:t2_rental/features/rentals/data/rental_repository.dart';
import 'package:t2_rental/features/rentals/domain/rental.dart';
import 'package:t2_rental/features/rentals/domain/rental_repository.dart';

class _FixedClock implements Clock {
  _FixedClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;
}

void main() {
  late AppDatabase database;
  late DriftRentalRepository rentals;
  late DriftCustomerRepository customers;
  late DriftMaterialRepository materials;
  late _FixedClock clock;

  setUp(() {
    database = AppDatabase.forTesting();
    clock = _FixedClock(DateTime.utc(2026, 1, 2, 9));
    rentals = DriftRentalRepository(database, clock: clock);
    customers = DriftCustomerRepository(database);
    materials = DriftMaterialRepository(database);
  });

  tearDown(() => database.close());

  Future<(String customerId, String materialId)> seed() async {
    final customer = await customers.create(
      fullName: 'Abebe Kebede',
      address: 'Addis Ababa',
      idPhotoFrontPath: 'customer/front.jpg',
    );
    final material = await materials.create(
      category: 'Panel',
      name: '60x120',
      pricePerDay: 25000,
      totalStock: 5,
    );
    return (customer.id, material.id);
  }

  test('creates sequential rentals, snapshots prices, and audits', () async {
    final seeded = await seed();
    final first = await rentals.createRental(
      customerId: seeded.$1,
      lines: [RentalLineDraft(materialId: seeded.$2, quantity: 2)],
    );
    final updatedMaterial = (await materials.getById(seeded.$2))!
        .copyWith(pricePerDay: 40000);
    await materials.update(updatedMaterial);
    clock.value = DateTime.utc(2026, 1, 3, 9);
    final second = await rentals.createRental(
      customerId: seeded.$1,
      lines: [RentalLineDraft(materialId: seeded.$2, quantity: 1)],
      stockOverrideConfirmed: true,
    );

    expect(first.rental.rentalNumber, 1);
    expect(second.rental.rentalNumber, 2);
    expect(first.lines.single.pricePerDaySnapshot, 25000);
    expect(second.lines.single.pricePerDaySnapshot, 40000);
    expect(first.rental.rentedAt.isUtc, isTrue);
    expect(await database.select(database.auditLogs).get(), hasLength(5));
  });

  test(
    'rejects archived customers, inactive materials, empty and duplicate lines',
    () async {
      final seeded = await seed();
      await customers.setActive(seeded.$1, false);
      expect(
        () => rentals.createRental(
          customerId: seeded.$1,
          lines: [RentalLineDraft(materialId: seeded.$2, quantity: 1)],
        ),
        throwsA(isA<RentalValidationException>()),
      );
      final activeCustomer = await customers.create(
        fullName: 'Mulu Worku',
        address: 'Bole',
        idPhotoFrontPath: 'customer/front-2.jpg',
      );
      final duplicateMaterial = await materials.create(
        category: 'Panel',
        name: '90x120',
        pricePerDay: 30000,
      );
      expect(
        () => rentals.createRental(
          customerId: activeCustomer.id,
          lines: [
            RentalLineDraft(materialId: duplicateMaterial.id, quantity: 1),
            RentalLineDraft(materialId: duplicateMaterial.id, quantity: 2),
          ],
        ),
        throwsA(isA<RentalValidationException>()),
      );
      await materials.setActive(seeded.$2, false);
      expect(
        () => rentals.createRental(
          customerId: activeCustomer.id,
          lines: [RentalLineDraft(materialId: seeded.$2, quantity: 1)],
        ),
        throwsA(isA<RentalValidationException>()),
      );
      expect(
        () => rentals.createRental(
          customerId: activeCustomer.id,
          lines: const [],
        ),
        throwsA(isA<RentalValidationException>()),
      );
    },
  );

  test('calculates available stock and warns before an override', () async {
    final seeded = await seed();
    expect(await rentals.availableStock(seeded.$2), 5);
    await rentals.createRental(
      customerId: seeded.$1,
      lines: [RentalLineDraft(materialId: seeded.$2, quantity: 4)],
    );
    expect(await rentals.availableStock(seeded.$2), 1);
    StockAvailabilityException? stockError;
    try {
      await rentals.createRental(
        customerId: seeded.$1,
        lines: [RentalLineDraft(materialId: seeded.$2, quantity: 2)],
      );
    } on StockAvailabilityException catch (error) {
      stockError = error;
    }
    expect(stockError, isNotNull);
    expect(stockError!.requested, 2);
    expect(stockError.available, 1);

    final overridden = await rentals.createRental(
      customerId: seeded.$1,
      lines: [RentalLineDraft(materialId: seeded.$2, quantity: 2)],
      stockOverrideConfirmed: true,
    );
    final audit =
        await (database.select(database.auditLogs)
              ..where((table) => table.entityId.equals(overridden.rental.id)))
            .getSingle();
    final auditPayload = jsonDecode(audit.newValue!) as Map<String, dynamic>;
    expect(auditPayload['stockOverrideConfirmed'], isTrue);
  });

  test(
    'records a full return with days, amount, status, and audit data',
    () async {
      final seeded = await seed();
      final rental = await rentals.createRental(
        customerId: seeded.$1,
        lines: [RentalLineDraft(materialId: seeded.$2, quantity: 5)],
      );
      clock.value = DateTime.utc(2026, 1, 4, 9);

      final receipt = await rentals.recordReturn(rental.rental.id, [
        ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 5),
      ], 'All returned');

      expect(receipt.status, RentalStatus.returned);
      expect(receipt.events.single.billableDays, 3);
      expect(receipt.events.single.amount, 375_000);
      expect(receipt.events.single.returnedAt.isUtc, isTrue);
      expect(receipt.remainingOutstanding, isEmpty);
      final item = await (database.select(
        database.rentalItems,
      )..where((table) => table.id.equals(rental.lines.single.id))).getSingle();
      expect(item.quantityReturned, 5);
      final audit = await (database.select(
        database.auditLogs,
      )..where((table) => table.action.equals('returnRecorded'))).getSingle();
      final payload = jsonDecode(audit.newValue!) as Map<String, dynamic>;
      expect(payload['total'], 375000);
      expect(payload['lines'].single['days'], 3);
    },
  );

  test(
    'records partial return then remainder and transitions status',
    () async {
      final seeded = await seed();
      clock.value = DateTime.utc(2026, 1, 1, 9);
      final rental = await rentals.createRental(
        customerId: seeded.$1,
        lines: [RentalLineDraft(materialId: seeded.$2, quantity: 10)],
        stockOverrideConfirmed: true,
      );
      clock.value = DateTime.utc(2026, 1, 2, 9);
      final first = await rentals.recordReturn(rental.rental.id, [
        ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 4),
      ], null);
      expect(first.status, RentalStatus.partiallyReturned);
      expect(first.events.single.amount, 200_000);
      expect(first.remainingOutstanding.single.outstandingQuantity, 6);

      clock.value = DateTime.utc(2026, 1, 5, 9);
      final second = await rentals.recordReturn(rental.rental.id, [
        ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 6),
      ], null);
      expect(second.status, RentalStatus.returned);
      expect(second.events.single.billableDays, 5);
      expect(second.events.single.amount, 750_000);
      expect((await rentals.getReturnEvents(rental.rental.id)), hasLength(2));
    },
  );

  test(
    'rejects empty, over-return, and already returned requests atomically',
    () async {
      final seeded = await seed();
      final rental = await rentals.createRental(
        customerId: seeded.$1,
        lines: [RentalLineDraft(materialId: seeded.$2, quantity: 2)],
      );
      expect(
        () => rentals.recordReturn(rental.rental.id, const [], null),
        throwsA(isA<RentalValidationException>()),
      );
      expect(
        () => rentals.recordReturn(rental.rental.id, [
          ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 3),
        ], null),
        throwsA(isA<RentalValidationException>()),
      );
      expect(await database.select(database.returnEvents).get(), isEmpty);
      expect(
        (await database.select(database.rentalItems).get())
            .single
            .quantityReturned,
        0,
      );
      await rentals.recordReturn(rental.rental.id, [
        ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 2),
      ], null);
      expect(
        () => rentals.recordReturn(rental.rental.id, [
          ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 1),
        ], null),
        throwsA(isA<RentalValidationException>()),
      );
    },
  );

  test(
    'monthly revenue uses local returned month and excludes voided rentals',
    () async {
      final seeded = await seed();
      clock.value = DateTime.utc(2026, 2, 1, 5, 30);
      final rental = await rentals.createRental(
        customerId: seeded.$1,
        lines: [RentalLineDraft(materialId: seeded.$2, quantity: 1)],
      );
      // 05:30 UTC is 01:30 local in the test machine's Atlantic timezone.
      clock.value = DateTime.utc(2026, 2, 1, 6, 30);
      await rentals.recordReturn(rental.rental.id, [
        ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 1),
      ], null);
      expect(await rentals.monthlyRevenue(2026, 2), 25_000);
      expect(await rentals.monthlyRevenue(2026, 1), 0);
      await (database.update(database.rentals)
            ..where((table) => table.id.equals(rental.rental.id)))
          .write(const RentalsCompanion(status: Value('voided')));
      expect(await rentals.monthlyRevenue(2026, 2), 0);
    },
  );
}
