import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/database/database.dart';
import 'package:t2_rental/core/utils/clock.dart';
import 'package:t2_rental/features/customers/data/customer_repository.dart';
import 'package:t2_rental/features/materials/data/material_repository.dart';
import 'package:t2_rental/features/rentals/data/rental_repository.dart';
import 'package:t2_rental/features/rentals/domain/rental.dart';

class _VoidTestClock implements Clock {
  _VoidTestClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;
}

void main() {
  late AppDatabase database;
  late DriftRentalRepository rentals;
  late DriftCustomerRepository customers;
  late DriftMaterialRepository materials;
  late _VoidTestClock clock;

  setUp(() {
    database = AppDatabase.forTesting();
    clock = _VoidTestClock(DateTime.utc(2026, 1, 1, 9));
    rentals = DriftRentalRepository(database, clock: clock);
    customers = DriftCustomerRepository(database);
    materials = DriftMaterialRepository(database);
  });

  tearDown(() => database.close());

  Future<RentalDetails> createRental({int quantity = 10}) async {
    final customer = await customers.create(
      fullName: 'Test Customer',
      address: 'Test Address',
      idPhotoFrontPath: 'test/front.jpg',
    );
    final material = await materials.create(
      category: 'Panel',
      name: '60x120',
      pricePerDay: 25000,
      totalStock: 20,
    );
    return rentals.createRental(
      customerId: customer.id,
      lines: [RentalLineDraft(materialId: material.id, quantity: quantity)],
    );
  }

  test(
    'voiding a return restores quantity, status, and excludes revenue',
    () async {
      final rental = await createRental();
      clock.value = DateTime.utc(2026, 1, 2, 9);
      final receipt = await rentals.recordReturn(rental.rental.id, [
        ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 4),
      ], null);
      final event = receipt.events.single;
      expect(event.amount, 200000);
      expect(
        (await rentals.getById(rental.rental.id))!.rental.status,
        RentalStatus.partiallyReturned,
      );

      clock.value = DateTime.utc(2026, 1, 3, 9);
      await rentals.voidReturn(event.id, 'Wrong quantity');

      final updated = (await rentals.getById(rental.rental.id))!;
      expect(updated.rental.status, RentalStatus.active);
      expect(updated.lines.single.quantityReturned, 0);
      expect(
        (await rentals.getReturnEvents(rental.rental.id)).single.voidReason,
        'Wrong quantity',
      );
      expect(await rentals.monthlyRevenue(2026, 1), 0);
      final audit = await database.select(database.auditLogs).get();
      expect(audit.any((row) => row.action == 'returnVoided'), isTrue);
    },
  );

  test(
    'rental void is blocked until returns are voided, then frees stock',
    () async {
      final rental = await createRental(quantity: 2);
      expect(await rentals.availableStock(rental.lines.single.materialId), 18);
      clock.value = DateTime.utc(2026, 1, 2, 9);
      final receipt = await rentals.recordReturn(rental.rental.id, [
        ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 2),
      ], null);
      expect(
        () => rentals.voidRental(rental.rental.id, 'Remove record'),
        throwsA(isA<RentalValidationException>()),
      );
      await rentals.voidReturn(receipt.events.single.id, 'Undo return');
      await rentals.voidRental(rental.rental.id, 'Duplicate record');
      expect(
        (await rentals.getById(rental.rental.id))!.rental.status,
        RentalStatus.voided,
      );
      expect(await rentals.availableStock(rental.lines.single.materialId), 20);
    },
  );

  test('void operations reject short reasons and repeat voids', () async {
    final rental = await createRental(quantity: 1);
    expect(
      () => rentals.voidRental(rental.rental.id, 'no'),
      throwsA(isA<RentalValidationException>()),
    );
    clock.value = DateTime.utc(2026, 1, 1, 10);
    final receipt = await rentals.recordReturn(rental.rental.id, [
      ReturnLineInput(rentalItemId: rental.lines.single.id, quantity: 1),
    ], null);
    await rentals.voidReturn(receipt.events.single.id, 'Correction');
    expect(
      () => rentals.voidReturn(receipt.events.single.id, 'Again'),
      throwsA(isA<RentalValidationException>()),
    );
  });
}
