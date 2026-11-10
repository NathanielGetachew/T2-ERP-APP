import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/database/database.dart';
import 'package:t2_rental/core/utils/clock.dart';
import 'package:t2_rental/features/customers/data/customer_repository.dart';
import 'package:t2_rental/features/materials/data/material_repository.dart';
import 'package:t2_rental/features/rentals/data/rental_repository.dart';
import 'package:t2_rental/features/rentals/domain/rental.dart';

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

  group('recordCustomerReturn', () {
    test(
      'single rental partial return: 4 on day 2, remainder 6 on day 5',
      () async {
        // Customer rents 10 units at 25.00 ETB (2500 minor units) on Day 1 (Jan 1)
        // Hand-computed arithmetic:
        // Return 1 on Day 2 (Jan 2):
        //   Quantity: 4 units
        //   Days: Jan 2 - Jan 1 + 1 = 2 days
        //   Amount: 4 × 2500 × 2 = 20,000 minor units (200.00 ETB)
        //   Status: partiallyReturned (10 - 4 = 6 remaining)
        // Return 2 on Day 5 (Jan 5):
        //   Quantity: 6 units
        //   Days: Jan 5 - Jan 1 + 1 = 5 days
        //   Amount: 6 × 2500 × 5 = 75,000 minor units (750.00 ETB)
        //   Status: returned (0 remaining)
        // Total earned: 20,000 + 75,000 = 95,000 minor units (950.00 ETB)
        final customer = await customers.create(
          fullName: 'Abebe Kebede',
          address: 'Addis Ababa',
          idPhotoFrontPath: 'customer/front.jpg',
        );
        final material = await materials.create(
          category: 'Panel',
          name: '60x120',
          pricePerDay: 2500,
          totalStock: 20,
        );

        clock.value = DateTime.utc(2026, 1, 1, 9);
        final rental = await rentals.createRental(
          customerId: customer.id,
          lines: [RentalLineDraft(materialId: material.id, quantity: 10)],
        );

        // First return on Day 2
        clock.value = DateTime.utc(2026, 1, 2, 9);
        final receipt1 = await rentals.recordReturn(rental.rental.id, [
          ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 4),
        ], null);
        expect(receipt1.total, 20000);
        expect(receipt1.status, RentalStatus.partiallyReturned);
        expect(receipt1.remainingOutstanding.single.outstandingQuantity, 6);

        // Second return on Day 5
        clock.value = DateTime.utc(2026, 1, 5, 9);
        final receipt2 = await rentals.recordReturn(rental.rental.id, [
          ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 6),
        ], null);
        expect(receipt2.total, 75000);
        expect(receipt2.status, RentalStatus.returned);
        expect(receipt2.remainingOutstanding, isEmpty);

        // Check total earned
        final events = await rentals.getReturnEvents(rental.rental.id);
        final totalEarned = events.fold<int>(0, (s, e) => s + e.amount);
        expect(totalEarned, 95000);
      },
    );

    test('allocates oldest first across multiple rentals', () async {
      // R-0001: 10 panels rented day 1 (Jan 1) at 25.00 ETB (2500 minor units)
      // R-0002: 5 panels rented day 3 (Jan 3) at 25.00 ETB (2500 minor units)
      // Customer returns 12 panels on day 5 (Jan 5)
      //
      // Hand-computed arithmetic:
      // 1) From R-0001: 10 units
      //    Days = Jan 5 - Jan 1 + 1 = 5 days
      //    Amount = 10 × 2500 × 5 = 125,000 minor units (1250.00 ETB)
      //    Status becomes returned
      // 2) From R-0002: 2 units (12 - 10 = 2)
      //    Days = Jan 5 - Jan 3 + 1 = 3 days
      //    Amount = 2 × 2500 × 3 = 15,000 minor units (150.00 ETB)
      //    Status becomes partiallyReturned (5 - 2 = 3 remaining)
      // Grand total = 125,000 + 15,000 = 140,000 minor units (1400.00 ETB)
      final customer = await customers.create(
        fullName: 'Lemma Megersa',
        address: 'Bole, Addis Ababa',
        idPhotoFrontPath: 'customer/front.jpg',
      );
      final material = await materials.create(
        category: 'Panel',
        name: '60x120',
        pricePerDay: 2500,
        totalStock: 30,
      );

      // Create R-0001 on Day 1
      clock.value = DateTime.utc(2026, 1, 1, 9);
      final r1 = await rentals.createRental(
        customerId: customer.id,
        lines: [RentalLineDraft(materialId: material.id, quantity: 10)],
      );

      // Create R-0002 on Day 3
      clock.value = DateTime.utc(2026, 1, 3, 9);
      final r2 = await rentals.createRental(
        customerId: customer.id,
        lines: [RentalLineDraft(materialId: material.id, quantity: 5)],
      );

      // Customer returns 12 units on Day 5
      clock.value = DateTime.utc(2026, 1, 5, 9);
      final held = await rentals.getCustomerHeldItems(customer.id);
      expect(held.totalUnitsHeld, 15);

      // Record customer return with allocations
      final allocations = [
        ReturnAllocationLine(
          rentalId: r1.rental.id,
          rentalNumber: r1.rental.rentalNumber,
          rentalItemId: r1.lines.single.id,
          materialId: material.id,
          materialName: 'Panel 60x120',
          rentedAt: r1.rental.rentedAt,
          quantity: 10,
          pricePerDaySnapshot: 2500,
          days: 5,
          amount: 125000,
        ),
        ReturnAllocationLine(
          rentalId: r2.rental.id,
          rentalNumber: r2.rental.rentalNumber,
          rentalItemId: r2.lines.single.id,
          materialId: material.id,
          materialName: 'Panel 60x120',
          rentedAt: r2.rental.rentedAt,
          quantity: 2,
          pricePerDaySnapshot: 2500,
          days: 3,
          amount: 15000,
        ),
      ];

      final receipt = await rentals.recordCustomerReturn(
        customerId: customer.id,
        allocations: allocations,
        note: 'Customer return batch test',
      );

      // Grand total = 125000 + 15000 = 140000
      expect(receipt.totalAmount, 140000);
      expect(receipt.batchId, isNotEmpty);
      expect(receipt.allocations.length, 2);

      // Verify all created events share the same batchId
      for (final event in receipt.events) {
        expect(event.returnBatchId, receipt.batchId);
      }

      // Verify rental 1 is fully returned
      final updatedR1 = await rentals.getById(r1.rental.id);
      expect(updatedR1!.rental.status, RentalStatus.returned);
      expect(updatedR1.lines.single.outstandingQuantity, 0);

      // Verify rental 2 is partially returned with 3 remaining
      final updatedR2 = await rentals.getById(r2.rental.id);
      expect(updatedR2!.rental.status, RentalStatus.partiallyReturned);
      expect(updatedR2.lines.single.outstandingQuantity, 3);

      // Verify remaining held after return is 3
      final updatedHeld = await rentals.getCustomerHeldItems(customer.id);
      expect(updatedHeld.totalUnitsHeld, 3);

      // Verify batch summary can be retrieved by batchId
      final batchSummary = await rentals.getReturnBatchSummary(receipt.batchId);
      expect(batchSummary, isNotNull);
      expect(batchSummary!.totalAmount, 140000);
      expect(batchSummary.batchId, receipt.batchId);

      // Verify audit logs
      final allAudit = await (database.select(
        database.auditLogs,
      )..where((t) => t.action.equals('returnBatchRecorded'))).get();
      expect(allAudit.length, 1);
      final batchAudit = allAudit.first;
      expect(batchAudit.entityId, receipt.batchId);
      final auditNewValue =
          jsonDecode(batchAudit.newValue!) as Map<String, dynamic>;
      expect(auditNewValue['grandTotal'], 140000);
    });

    test('uses own price snapshot per line when prices differ', () async {
      // R-0001: 10 panels rented day 1 at 25.00 ETB (2500 minor units)
      // R-0002: 5 panels rented day 3 at 30.00 ETB (3000 minor units)
      // Customer returns 12 panels on day 5:
      // Hand-computed arithmetic:
      // From R-0001: 10 × 2500 × 5 days = 125,000 minor units
      // From R-0002: 2 × 3000 × 3 days = 18,000 minor units
      // Grand total = 125,000 + 18,000 = 143,000 minor units (1430.00 ETB)
      final customer = await customers.create(
        fullName: 'Tadesse Chala',
        address: 'Addis Ababa',
        idPhotoFrontPath: 'customer/front.jpg',
      );
      final mat1 = await materials.create(
        category: 'Panel',
        name: 'Standard',
        pricePerDay: 2500,
        totalStock: 20,
      );
      final mat2 = await materials.create(
        category: 'Panel',
        name: 'Heavy Duty',
        pricePerDay: 3000,
        totalStock: 20,
      );

      // Create R-0001 on Day 1
      clock.value = DateTime.utc(2026, 1, 1, 9);
      final r1 = await rentals.createRental(
        customerId: customer.id,
        lines: [RentalLineDraft(materialId: mat1.id, quantity: 10)],
      );

      // Create R-0002 on Day 3
      clock.value = DateTime.utc(2026, 1, 3, 9);
      final r2 = await rentals.createRental(
        customerId: customer.id,
        lines: [RentalLineDraft(materialId: mat2.id, quantity: 5)],
      );

      // Return 12 on Day 5: 10 from r1, 2 from r2
      clock.value = DateTime.utc(2026, 1, 5, 9);
      final receipt = await rentals.recordCustomerReturn(
        customerId: customer.id,
        allocations: [
          ReturnAllocationLine(
            rentalId: r1.rental.id,
            rentalNumber: r1.rental.rentalNumber,
            rentalItemId: r1.lines.single.id,
            materialId: mat1.id,
            materialName: 'Standard',
            rentedAt: r1.rental.rentedAt,
            quantity: 10,
            pricePerDaySnapshot: 2500,
            days: 5,
            amount: 125000,
          ),
          ReturnAllocationLine(
            rentalId: r2.rental.id,
            rentalNumber: r2.rental.rentalNumber,
            rentalItemId: r2.lines.single.id,
            materialId: mat2.id,
            materialName: 'Heavy Duty',
            rentedAt: r2.rental.rentedAt,
            quantity: 2,
            pricePerDaySnapshot: 3000,
            days: 3,
            amount: 18000,
          ),
        ],
      );

      // Grand total = 125000 + 18000 = 143000
      expect(receipt.totalAmount, 143000);
    });

    test('archived customer can still return items', () async {
      final customer = await customers.create(
        fullName: 'Archived Customer',
        address: 'Addis Ababa',
        idPhotoFrontPath: 'customer/front.jpg',
      );
      final mat = await materials.create(
        category: 'Panel',
        name: 'Standard',
        pricePerDay: 2500,
      );

      clock.value = DateTime.utc(2026, 1, 1, 9);
      final rental = await rentals.createRental(
        customerId: customer.id,
        lines: [RentalLineDraft(materialId: mat.id, quantity: 3)],
      );

      // Archive customer
      await customers.setActive(customer.id, false);
      final archivedCustomer = await customers.getById(customer.id);
      expect(archivedCustomer!.isActive, isFalse);

      // Return items on Day 2
      clock.value = DateTime.utc(2026, 1, 2, 9);
      final receipt = await rentals.recordCustomerReturn(
        customerId: customer.id,
        allocations: [
          ReturnAllocationLine(
            rentalId: rental.rental.id,
            rentalNumber: rental.rental.rentalNumber,
            rentalItemId: rental.lines.single.id,
            materialId: mat.id,
            materialName: 'Standard',
            rentedAt: rental.rental.rentedAt,
            quantity: 3,
            pricePerDaySnapshot: 2500,
            days: 2,
            amount: 15000, // 3 * 2500 * 2 = 15000
          ),
        ],
      );

      expect(receipt.totalAmount, 15000);
      final updated = await rentals.getById(rental.rental.id);
      expect(updated!.rental.status, RentalStatus.returned);
    });

    test('all-or-nothing: one invalid line writes nothing', () async {
      final customer = await customers.create(
        fullName: 'Atomic Test',
        address: 'Addis Ababa',
        idPhotoFrontPath: 'customer/front.jpg',
      );
      final mat = await materials.create(
        category: 'Panel',
        name: 'Standard',
        pricePerDay: 2500,
      );

      clock.value = DateTime.utc(2026, 1, 1, 9);
      final rental = await rentals.createRental(
        customerId: customer.id,
        lines: [RentalLineDraft(materialId: mat.id, quantity: 5)],
      );

      // Try to return 10 units when only 5 were rented
      clock.value = DateTime.utc(2026, 1, 2, 9);
      expect(
        () => rentals.recordCustomerReturn(
          customerId: customer.id,
          allocations: [
            ReturnAllocationLine(
              rentalId: rental.rental.id,
              rentalNumber: rental.rental.rentalNumber,
              rentalItemId: rental.lines.single.id,
              materialId: mat.id,
              materialName: 'Standard',
              rentedAt: rental.rental.rentedAt,
              quantity: 10, // Exceeds 5
              pricePerDaySnapshot: 2500,
              days: 2,
              amount: 50000,
            ),
          ],
        ),
        throwsA(isA<RentalValidationException>()),
      );

      // Verify nothing was written to returnEvents
      final events = await rentals.getReturnEvents(rental.rental.id);
      expect(events, isEmpty);

      // Rental is still active
      final unchanged = await rentals.getById(rental.rental.id);
      expect(unchanged!.rental.status, RentalStatus.active);
      expect(unchanged.lines.single.quantityReturned, 0);
    });

    test(
      'monthly revenue includes batch return events and excludes voided',
      () async {
        final customer = await customers.create(
          fullName: 'Revenue Batch Test',
          address: 'Addis Ababa',
          idPhotoFrontPath: 'customer/front.jpg',
        );
        final mat = await materials.create(
          category: 'Panel',
          name: 'Standard',
          pricePerDay: 2500,
        );

        // Rental created in January
        clock.value = DateTime.utc(2026, 1, 15, 9);
        final rental = await rentals.createRental(
          customerId: customer.id,
          lines: [RentalLineDraft(materialId: mat.id, quantity: 4)],
        );

        // Batch return in February: 4 units × 2500 × 20 days = 200,000 minor units
        clock.value = DateTime.utc(2026, 2, 3, 9);
        final receipt = await rentals.recordCustomerReturn(
          customerId: customer.id,
          allocations: [
            ReturnAllocationLine(
              rentalId: rental.rental.id,
              rentalNumber: rental.rental.rentalNumber,
              rentalItemId: rental.lines.single.id,
              materialId: mat.id,
              materialName: 'Standard',
              rentedAt: rental.rental.rentedAt,
              quantity: 4,
              pricePerDaySnapshot: 2500,
              days: 20,
              amount: 200000,
            ),
          ],
        );

        // February revenue must include the 200,000
        expect(await rentals.monthlyRevenue(2026, 2), 200000);
        expect(await rentals.monthlyRevenue(2026, 1), 0);

        // Void the return event
        final eventId = receipt.events.single.id;
        await rentals.voidReturn(eventId, 'Customer returned wrong panels');

        // February revenue must now be 0
        expect(await rentals.monthlyRevenue(2026, 2), 0);
      },
    );
  });
}
