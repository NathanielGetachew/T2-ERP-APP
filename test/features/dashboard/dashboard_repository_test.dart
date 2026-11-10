import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/database/database.dart';
import 'package:t2_rental/core/utils/clock.dart';
import 'package:t2_rental/features/customers/data/customer_repository.dart';
import 'package:t2_rental/features/dashboard/data/drift_dashboard_repository.dart';
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
  late DriftDashboardRepository dashboardRepo;
  late _FixedClock clock;

  setUp(() {
    database = AppDatabase.forTesting();
    clock = _FixedClock(DateTime.utc(2026, 5, 1, 10));
    rentals = DriftRentalRepository(database, clock: clock);
    customers = DriftCustomerRepository(database);
    materials = DriftMaterialRepository(database);
    dashboardRepo = DriftDashboardRepository(database);
  });

  tearDown(() => database.close());

  test('loadSnapshot loads valid rentals, excludes voided, and snapshots return events', () async {
    // 1. Create customers
    final c1 = await customers.create(
      fullName: 'Abebe Kebede',
      address: 'Addis Ababa',
      phone: '+251911000001',
      idPhotoFrontPath: 'customer/c1_front.jpg',
    );
    final c2 = await customers.create(
      fullName: 'Chala Gemechu',
      address: 'Adama',
      phone: '+251911000002',
      idPhotoFrontPath: 'customer/c2_front.jpg',
    );

    // 2. Create material
    final m1 = await materials.create(
      category: 'Panel',
      name: '60x120',
      pricePerDay: 25000, // 250.00 ETB
      totalStock: 10,
    );

    // 3. Create Rental 1 on 2026-05-01 for Abebe with 2 units
    clock.value = DateTime.utc(2026, 5, 1, 10);
    final r1 = await rentals.createRental(
      customerId: c1.id,
      lines: [RentalLineDraft(materialId: m1.id, quantity: 2)],
    );

    // 4. Return 1 unit of Rental 1 on 2026-05-03:
    // Calendar days: May 1 to May 3 inclusive = 3 days.
    // Hand computed arithmetic:
    // 1 unit * 25,000 cents/day * 3 days = 75,000 cents (750.00 ETB).
    clock.value = DateTime.utc(2026, 5, 3, 14);
    await rentals.recordReturn(r1.rental.id, [
      ReturnLineInput(rentalItemId: r1.lines.first.id, quantity: 1),
    ], null);

    // 5. Create Rental 2 on 2026-05-05 for Chala with 3 units, then void it
    clock.value = DateTime.utc(2026, 5, 5, 9);
    final r2 = await rentals.createRental(
      customerId: c2.id,
      lines: [RentalLineDraft(materialId: m1.id, quantity: 3)],
    );
    await rentals.voidRental(
      r2.rental.id,
      'Customer cancelled order before dispatch',
    );

    // 6. Load dashboard snapshot
    final snapshot = await dashboardRepo.loadSnapshot();

    // Check materials
    expect(snapshot.materials.length, 1);
    expect(snapshot.materials.first.id, m1.id);
    expect(snapshot.materials.first.pricePerDay, 25000);

    // Check rentals: voided rental must be excluded
    expect(snapshot.rentals.length, 1);
    expect(snapshot.rentals.first.id, r1.rental.id);
    expect(snapshot.rentals.first.status, RentalStatus.partiallyReturned);

    // Check lines
    expect(snapshot.lines.length, 1);
    expect(snapshot.lines.first.quantity, 2);
    expect(snapshot.lines.first.quantityReturned, 1);
    expect(snapshot.lines.first.outstandingQuantity, 1);

    // Return events: exactly 1 return event with 75,000 minor units
    expect(snapshot.returnEvents.length, 1);
    expect(snapshot.returnEvents.first.quantity, 1);
    // Hand computed: 1 * 25000 * 3 = 75000
    expect(snapshot.returnEvents.first.amount, 75000);

    // Customers: both exist in database
    expect(snapshot.customers.any((c) => c.id == c1.id), isTrue);
    expect(snapshot.customers.any((c) => c.id == c2.id), isTrue);
  });

  test('watchChanges emits when new return event is recorded', () async {
    final c = await customers.create(
      fullName: 'Abebe Kebede',
      address: 'Addis Ababa',
      idPhotoFrontPath: 'customer/front.jpg',
    );
    final m = await materials.create(
      category: 'Panel',
      name: '60x120',
      pricePerDay: 10000,
    );

    final r = await rentals.createRental(
      customerId: c.id,
      lines: [RentalLineDraft(materialId: m.id, quantity: 2)],
    );

    final emissions = <int>[];
    final sub = dashboardRepo.watchChanges().listen((_) {
      emissions.add(1);
    });

    // Initial query / seed
    await pumpEventQueue();

    // Record return
    await rentals.recordReturn(r.rental.id, [
      ReturnLineInput(rentalItemId: r.lines.first.id, quantity: 2),
    ], null);

    await pumpEventQueue();
    expect(emissions.isNotEmpty, isTrue);

    await sub.cancel();
  });
}
