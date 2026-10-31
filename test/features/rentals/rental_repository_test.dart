import 'dart:convert';

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
}
