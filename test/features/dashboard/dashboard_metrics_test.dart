import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/features/customers/domain/customer.dart';
import 'package:t2_rental/features/dashboard/domain/dashboard_metrics.dart';
import 'package:t2_rental/features/dashboard/domain/dashboard_models.dart';
import 'package:t2_rental/features/materials/domain/rental_material.dart';
import 'package:t2_rental/features/rentals/domain/rental.dart';

Customer _createCustomer({required String id, required String name}) {
  final now = DateTime.utc(2026, 1, 1);
  return Customer(
    id: id,
    fullName: name,
    address: 'Addis Ababa',
    phone: null,
    notes: null,
    idPhotoFrontPath: 'customer_ids/$id.jpg',
    idPhotoBackPath: null,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
}

RentalMaterial _createMaterial({
  required String id,
  required String name,
  String category = 'Panel',
  int pricePerDay = 2500,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return RentalMaterial(
    id: id,
    category: category,
    name: name,
    pricePerDay: pricePerDay,
    totalStock: 100,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  const localOffset = Duration.zero;

  test('revenue across partial returns in different months', () {
    // Hand computation:
    // Rental created on 2026-05-01 for 10 units at 25.00 ETB (2500 santim).
    // Return 1: 4 units returned on 2026-05-02 (May 2026) -> billableDays = 2.
    // Amount = 4 * 2500 * 2 = 20000 santim (200.00 ETB).
    // Return 2: 6 units returned on 2026-06-05 (June 2026) -> billableDays = 36.
    // Amount = 6 * 2500 * 36 = 540000 santim (5,400.00 ETB).
    // May earned revenue = 20000.
    // June earned revenue = 540000.
    // May period: 20000.
    // June period: 540000.
    // Total for May+June: 20000 + 540000 = 560000.
    final customer = _createCustomer(id: 'c1', name: 'Abebe');
    final material = _createMaterial(
      id: 'm1',
      name: 'Panel 60x120',
      pricePerDay: 2500,
    );

    final rental = RentalRecord(
      id: 'r1',
      rentalNumber: 1,
      customerId: 'c1',
      rentedAt: DateTime.utc(2026, 5, 1, 10, 0),
      status: RentalStatus.returned,
      notes: null,
      createdAt: DateTime.utc(2026, 5, 1, 10, 0),
      updatedAt: DateTime.utc(2026, 6, 5, 10, 0),
    );

    final line = RentalLine(
      id: 'l1',
      rentalId: 'r1',
      materialId: 'm1',
      materialNameSnapshot: 'Panel 60x120',
      pricePerDaySnapshot: 2500,
      quantity: 10,
      quantityReturned: 10,
    );

    final return1 = ReturnEventRecord(
      id: 'ret1',
      rentalId: 'r1',
      rentalItemId: 'l1',
      quantity: 4,
      returnedAt: DateTime.utc(2026, 5, 2, 10, 0),
      billableDays: 2,
      amount: 20000, // 4 * 2500 * 2
      pricePerDaySnapshot: 2500,
      conditionNote: null,
      createdAt: DateTime.utc(2026, 5, 2, 10, 0),
    );

    final return2 = ReturnEventRecord(
      id: 'ret2',
      rentalId: 'r1',
      rentalItemId: 'l1',
      quantity: 6,
      returnedAt: DateTime.utc(2026, 6, 5, 10, 0),
      billableDays: 36,
      amount: 540000, // 6 * 2500 * 36
      pricePerDaySnapshot: 2500,
      conditionNote: null,
      createdAt: DateTime.utc(2026, 6, 5, 10, 0),
    );

    final mayPeriod = DashboardPeriod.custom(
      DateTime(2026, 5, 1),
      DateTime(2026, 5, 31),
    );
    final mayMetrics = computeDashboardMetrics(
      rentals: [rental],
      lines: [line],
      returnEvents: [return1, return2],
      customers: [customer],
      materials: [material],
      period: mayPeriod,
      nowUtc: DateTime.utc(2026, 6, 15, 12, 0),
      localOffset: localOffset,
      longRunningThresholdDays: 14,
    );
    expect(mayMetrics.periodEarnedRevenue, equals(20000));

    final junePeriod = DashboardPeriod.custom(
      DateTime(2026, 6, 1),
      DateTime(2026, 6, 30),
    );
    final juneMetrics = computeDashboardMetrics(
      rentals: [rental],
      lines: [line],
      returnEvents: [return1, return2],
      customers: [customer],
      materials: [material],
      period: junePeriod,
      nowUtc: DateTime.utc(2026, 6, 15, 12, 0),
      localOffset: localOffset,
      longRunningThresholdDays: 14,
    );
    expect(juneMetrics.periodEarnedRevenue, equals(540000));
  });

  test('month/year boundary using local midnight edge cases', () {
    // Hand computation:
    // With local offset = UTC+3 (East Africa Time).
    // Event 1 returnedAt = 2026-12-31 20:59:00 UTC -> local = 2026-12-31 23:59:00 (December 2026).
    // Event 2 returnedAt = 2026-12-31 21:01:00 UTC -> local = 2027-01-01 00:01:00 (January 2027).
    // Event 1 amount = 10000.
    // Event 2 amount = 15000.
    // December 2026 revenue = 10000.
    // January 2027 revenue = 15000.
    const eatOffset = Duration(hours: 3);

    final rental1 = RentalRecord(
      id: 'r1',
      rentalNumber: 1,
      customerId: 'c1',
      rentedAt: DateTime.utc(2026, 12, 30),
      status: RentalStatus.returned,
      notes: null,
      createdAt: DateTime.utc(2026, 12, 30),
      updatedAt: DateTime.utc(2026, 12, 31, 20, 59),
    );
    final rental2 = RentalRecord(
      id: 'r2',
      rentalNumber: 2,
      customerId: 'c1',
      rentedAt: DateTime.utc(2026, 12, 30),
      status: RentalStatus.returned,
      notes: null,
      createdAt: DateTime.utc(2026, 12, 30),
      updatedAt: DateTime.utc(2026, 12, 31, 21, 1),
    );

    final event1 = ReturnEventRecord(
      id: 'e1',
      rentalId: 'r1',
      rentalItemId: 'l1',
      quantity: 1,
      returnedAt: DateTime.utc(2026, 12, 31, 20, 59),
      billableDays: 2,
      amount: 10000,
      pricePerDaySnapshot: 5000,
      conditionNote: null,
      createdAt: DateTime.utc(2026, 12, 31, 20, 59),
    );
    final event2 = ReturnEventRecord(
      id: 'e2',
      rentalId: 'r2',
      rentalItemId: 'l2',
      quantity: 1,
      returnedAt: DateTime.utc(2026, 12, 31, 21, 1),
      billableDays: 3,
      amount: 15000,
      pricePerDaySnapshot: 5000,
      conditionNote: null,
      createdAt: DateTime.utc(2026, 12, 31, 21, 1),
    );

    final metrics = computeDashboardMetrics(
      rentals: [rental1, rental2],
      lines: const [],
      returnEvents: [event1, event2],
      customers: [_createCustomer(id: 'c1', name: 'Abebe')],
      materials: const [],
      period: DashboardPeriod.custom(
        DateTime(2027, 1, 1),
        DateTime(2027, 1, 31),
      ),
      nowUtc: DateTime.utc(2027, 1, 1, 12, 0),
      localOffset: eatOffset,
      longRunningThresholdDays: 14,
    );

    // Period is January 2027 -> only event2 belongs to January 2027 in local time
    expect(metrics.periodEarnedRevenue, equals(15000));

    // Check 12-month chart for Dec 2026 and Jan 2027
    final dec2026 = metrics.monthlyRevenueChart.firstWhere(
      (m) => m.year == 2026 && m.month == 12,
    );
    final jan2027 = metrics.monthlyRevenueChart.firstWhere(
      (m) => m.year == 2027 && m.month == 1,
    );
    expect(dec2026.amount, equals(10000));
    expect(jan2027.amount, equals(15000));
  });

  test('voided return and voided rental exclusion', () {
    // Hand computation:
    // Event 1: Valid rental, valid return -> 5000 santim.
    // Event 2: Valid rental, VOIDED return -> 8000 santim (voidedAt set).
    // Event 3: VOIDED rental, return -> 12000 santim (rental.voidedAt set).
    // Earned revenue must ONLY include Event 1 = 5000 santim.
    final validRental = RentalRecord(
      id: 'r_valid',
      rentalNumber: 1,
      customerId: 'c1',
      rentedAt: DateTime.utc(2026, 6, 1),
      status: RentalStatus.returned,
      notes: null,
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 5),
    );
    final voidedRental = RentalRecord(
      id: 'r_voided',
      rentalNumber: 2,
      customerId: 'c1',
      rentedAt: DateTime.utc(2026, 6, 1),
      status: RentalStatus.voided,
      notes: null,
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 5),
      voidedAt: DateTime.utc(2026, 6, 5),
      voidReason: 'Mistake in agreement',
    );

    final eventValid = ReturnEventRecord(
      id: 'e1',
      rentalId: 'r_valid',
      rentalItemId: 'l1',
      quantity: 1,
      returnedAt: DateTime.utc(2026, 6, 3),
      billableDays: 3,
      amount: 5000,
      pricePerDaySnapshot: 5000,
      conditionNote: null,
      createdAt: DateTime.utc(2026, 6, 3),
    );
    final eventVoidedReturn = ReturnEventRecord(
      id: 'e2',
      rentalId: 'r_valid',
      rentalItemId: 'l1',
      quantity: 1,
      returnedAt: DateTime.utc(2026, 6, 4),
      billableDays: 4,
      amount: 8000,
      pricePerDaySnapshot: 5000,
      conditionNote: null,
      createdAt: DateTime.utc(2026, 6, 4),
      voidedAt: DateTime.utc(2026, 6, 4),
      voidReason: 'Wrong line returned',
    );
    final eventOnVoidedRental = ReturnEventRecord(
      id: 'e3',
      rentalId: 'r_voided',
      rentalItemId: 'l2',
      quantity: 1,
      returnedAt: DateTime.utc(2026, 6, 4),
      billableDays: 4,
      amount: 12000,
      pricePerDaySnapshot: 5000,
      conditionNote: null,
      createdAt: DateTime.utc(2026, 6, 4),
    );

    final metrics = computeDashboardMetrics(
      rentals: [validRental, voidedRental],
      lines: const [],
      returnEvents: [eventValid, eventVoidedReturn, eventOnVoidedRental],
      customers: [_createCustomer(id: 'c1', name: 'Abebe')],
      materials: const [],
      period: DashboardPeriod.custom(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 30),
      ),
      nowUtc: DateTime.utc(2026, 6, 15),
      localOffset: localOffset,
      longRunningThresholdDays: 14,
    );

    expect(metrics.periodEarnedRevenue, equals(5000));
  });

  test(
    'average duration with a rental that has partial returns on different days',
    () {
      // Hand computation:
      // Rental A: rentedAt 2026-06-01, partial return 1 on 2026-06-03, final return on 2026-06-10.
      //   Final return date = 2026-06-10.
      //   billableDays(2026-06-01, 2026-06-10) = 10 - 1 + 1 = 10 days.
      // Rental B: rentedAt 2026-06-05, final return on 2026-06-08.
      //   billableDays(2026-06-05, 2026-06-08) = 8 - 5 + 1 = 4 days.
      // Rental C: active rental (status active) -> excluded.
      // Rental D: completed rental whose final return is in May (outside period) -> excluded.
      // Average = (10 + 4) / 2 = 14 / 2 = 7.0 days.
      final rentalA = RentalRecord(
        id: 'rA',
        rentalNumber: 1,
        customerId: 'c1',
        rentedAt: DateTime.utc(2026, 6, 1),
        status: RentalStatus.returned,
        notes: null,
        createdAt: DateTime.utc(2026, 6, 1),
        updatedAt: DateTime.utc(2026, 6, 10),
      );
      final rentalB = RentalRecord(
        id: 'rB',
        rentalNumber: 2,
        customerId: 'c2',
        rentedAt: DateTime.utc(2026, 6, 5),
        status: RentalStatus.returned,
        notes: null,
        createdAt: DateTime.utc(2026, 6, 5),
        updatedAt: DateTime.utc(2026, 6, 8),
      );
      final rentalC = RentalRecord(
        id: 'rC',
        rentalNumber: 3,
        customerId: 'c1',
        rentedAt: DateTime.utc(2026, 6, 2),
        status: RentalStatus.active,
        notes: null,
        createdAt: DateTime.utc(2026, 6, 2),
        updatedAt: DateTime.utc(2026, 6, 2),
      );
      final rentalD = RentalRecord(
        id: 'rD',
        rentalNumber: 4,
        customerId: 'c1',
        rentedAt: DateTime.utc(2026, 5, 1),
        status: RentalStatus.returned,
        notes: null,
        createdAt: DateTime.utc(2026, 5, 1),
        updatedAt: DateTime.utc(2026, 5, 20),
      );

      final events = [
        ReturnEventRecord(
          id: 'eA1',
          rentalId: 'rA',
          rentalItemId: 'l1',
          quantity: 2,
          returnedAt: DateTime.utc(2026, 6, 3),
          billableDays: 3,
          amount: 3000,
          pricePerDaySnapshot: 1000,
          conditionNote: null,
          createdAt: DateTime.utc(2026, 6, 3),
        ),
        ReturnEventRecord(
          id: 'eA2',
          rentalId: 'rA',
          rentalItemId: 'l1',
          quantity: 3,
          returnedAt: DateTime.utc(2026, 6, 10),
          billableDays: 10,
          amount: 30000,
          pricePerDaySnapshot: 1000,
          conditionNote: null,
          createdAt: DateTime.utc(2026, 6, 10),
        ),
        ReturnEventRecord(
          id: 'eB',
          rentalId: 'rB',
          rentalItemId: 'l2',
          quantity: 1,
          returnedAt: DateTime.utc(2026, 6, 8),
          billableDays: 4,
          amount: 4000,
          pricePerDaySnapshot: 1000,
          conditionNote: null,
          createdAt: DateTime.utc(2026, 6, 8),
        ),
        ReturnEventRecord(
          id: 'eD',
          rentalId: 'rD',
          rentalItemId: 'l3',
          quantity: 1,
          returnedAt: DateTime.utc(2026, 5, 20),
          billableDays: 20,
          amount: 20000,
          pricePerDaySnapshot: 1000,
          conditionNote: null,
          createdAt: DateTime.utc(2026, 5, 20),
        ),
      ];

      final metrics = computeDashboardMetrics(
        rentals: [rentalA, rentalB, rentalC, rentalD],
        lines: const [],
        returnEvents: events,
        customers: const [],
        materials: const [],
        period: DashboardPeriod.custom(
          DateTime(2026, 6, 1),
          DateTime(2026, 6, 30),
        ),
        nowUtc: DateTime.utc(2026, 6, 15),
        localOffset: localOffset,
        longRunningThresholdDays: 14,
      );

      expect(metrics.averageDurationDays, equals(7.0));
    },
  );

  test('duration null when empty', () {
    final metrics = computeDashboardMetrics(
      rentals: const [],
      lines: const [],
      returnEvents: const [],
      customers: const [],
      materials: const [],
      period: DashboardPeriod.custom(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 30),
      ),
      nowUtc: DateTime.utc(2026, 6, 15),
      localOffset: localOffset,
      longRunningThresholdDays: 14,
    );
    expect(metrics.averageDurationDays, isNull);
  });

  test('unit-days ranking including a tie', () {
    // Hand computation:
    // Material 1 ("Panel 60x120"): event of qty 5 * 4 billableDays = 20 unit-days.
    // Material 2 ("Column 30x30"): event of qty 2 * 10 billableDays = 20 unit-days.
    // Material 3 ("Acrow Prop"): event of qty 1 * 5 billableDays = 5 unit-days.
    // Tie between Column (20) and Panel (20) -> tie broken alphabetically:
    // 1st: Column 30x30 (20)
    // 2nd: Panel 60x120 (20)
    // 3rd: Acrow Prop (5)
    final m1 = _createMaterial(id: 'm1', name: 'Panel 60x120');
    final m2 = _createMaterial(id: 'm2', name: 'Column 30x30');
    final m3 = _createMaterial(id: 'm3', name: 'Acrow Prop');

    final rental = RentalRecord(
      id: 'r1',
      rentalNumber: 1,
      customerId: 'c1',
      rentedAt: DateTime.utc(2026, 6, 1),
      status: RentalStatus.returned,
      notes: null,
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 11),
    );

    final lines = [
      RentalLine(
        id: 'l1',
        rentalId: 'r1',
        materialId: 'm1',
        materialNameSnapshot: 'Panel 60x120',
        pricePerDaySnapshot: 1000,
        quantity: 5,
        quantityReturned: 5,
      ),
      RentalLine(
        id: 'l2',
        rentalId: 'r1',
        materialId: 'm2',
        materialNameSnapshot: 'Column 30x30',
        pricePerDaySnapshot: 1000,
        quantity: 2,
        quantityReturned: 2,
      ),
      RentalLine(
        id: 'l3',
        rentalId: 'r1',
        materialId: 'm3',
        materialNameSnapshot: 'Acrow Prop',
        pricePerDaySnapshot: 1000,
        quantity: 1,
        quantityReturned: 1,
      ),
    ];

    final events = [
      ReturnEventRecord(
        id: 'e1',
        rentalId: 'r1',
        rentalItemId: 'l1',
        quantity: 5,
        returnedAt: DateTime.utc(2026, 6, 5),
        billableDays: 4,
        amount: 20000,
        pricePerDaySnapshot: 1000,
        conditionNote: null,
        createdAt: DateTime.utc(2026, 6, 5),
      ),
      ReturnEventRecord(
        id: 'e2',
        rentalId: 'r1',
        rentalItemId: 'l2',
        quantity: 2,
        returnedAt: DateTime.utc(2026, 6, 11),
        billableDays: 10,
        amount: 20000,
        pricePerDaySnapshot: 1000,
        conditionNote: null,
        createdAt: DateTime.utc(2026, 6, 11),
      ),
      ReturnEventRecord(
        id: 'e3',
        rentalId: 'r1',
        rentalItemId: 'l3',
        quantity: 1,
        returnedAt: DateTime.utc(2026, 6, 6),
        billableDays: 5,
        amount: 5000,
        pricePerDaySnapshot: 1000,
        conditionNote: null,
        createdAt: DateTime.utc(2026, 6, 6),
      ),
    ];

    final metrics = computeDashboardMetrics(
      rentals: [rental],
      lines: lines,
      returnEvents: events,
      customers: const [],
      materials: [m1, m2, m3],
      period: DashboardPeriod.custom(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 30),
      ),
      nowUtc: DateTime.utc(2026, 6, 15),
      localOffset: localOffset,
      longRunningThresholdDays: 14,
    );

    expect(metrics.mostRentedMaterials.length, equals(3));
    expect(metrics.mostRentedMaterials[0].materialName, equals('Column 30x30'));
    expect(metrics.mostRentedMaterials[0].unitDays, equals(20));
    expect(metrics.mostRentedMaterials[1].materialName, equals('Panel 60x120'));
    expect(metrics.mostRentedMaterials[1].unitDays, equals(20));
    expect(metrics.mostRentedMaterials[2].materialName, equals('Acrow Prop'));
    expect(metrics.mostRentedMaterials[2].unitDays, equals(5));
  });

  test('times-rented and total-quantity modes', () {
    // Hand computation:
    // Rental 1 (created 2026-06-02): m1 (qty 10), m2 (qty 2).
    // Rental 2 (created 2026-06-05): m1 (qty 5), m3 (qty 1).
    // Times rented in period:
    // m1: in Rental 1 + Rental 2 = 2 times.
    // m2: in Rental 1 = 1 time.
    // m3: in Rental 2 = 1 time.
    // Total quantity rented in period:
    // m1: 10 + 5 = 15 units.
    // m2: 2 units.
    // m3: 1 unit.
    final m1 = _createMaterial(id: 'm1', name: 'Panel 60x120');
    final m2 = _createMaterial(id: 'm2', name: 'Column 30x30');
    final m3 = _createMaterial(id: 'm3', name: 'Acrow Prop');

    final r1 = RentalRecord(
      id: 'r1',
      rentalNumber: 1,
      customerId: 'c1',
      rentedAt: DateTime.utc(2026, 6, 2),
      status: RentalStatus.active,
      notes: null,
      createdAt: DateTime.utc(2026, 6, 2),
      updatedAt: DateTime.utc(2026, 6, 2),
    );
    final r2 = RentalRecord(
      id: 'r2',
      rentalNumber: 2,
      customerId: 'c2',
      rentedAt: DateTime.utc(2026, 6, 5),
      status: RentalStatus.active,
      notes: null,
      createdAt: DateTime.utc(2026, 6, 5),
      updatedAt: DateTime.utc(2026, 6, 5),
    );

    final lines = [
      RentalLine(
        id: 'l1',
        rentalId: 'r1',
        materialId: 'm1',
        materialNameSnapshot: 'Panel 60x120',
        pricePerDaySnapshot: 1000,
        quantity: 10,
        quantityReturned: 0,
      ),
      RentalLine(
        id: 'l2',
        rentalId: 'r1',
        materialId: 'm2',
        materialNameSnapshot: 'Column 30x30',
        pricePerDaySnapshot: 1000,
        quantity: 2,
        quantityReturned: 0,
      ),
      RentalLine(
        id: 'l3',
        rentalId: 'r2',
        materialId: 'm1',
        materialNameSnapshot: 'Panel 60x120',
        pricePerDaySnapshot: 1000,
        quantity: 5,
        quantityReturned: 0,
      ),
      RentalLine(
        id: 'l4',
        rentalId: 'r2',
        materialId: 'm3',
        materialNameSnapshot: 'Acrow Prop',
        pricePerDaySnapshot: 1000,
        quantity: 1,
        quantityReturned: 0,
      ),
    ];

    final metrics = computeDashboardMetrics(
      rentals: [r1, r2],
      lines: lines,
      returnEvents: const [],
      customers: const [],
      materials: [m1, m2, m3],
      period: DashboardPeriod.custom(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 30),
      ),
      nowUtc: DateTime.utc(2026, 6, 15),
      localOffset: localOffset,
      longRunningThresholdDays: 14,
    );

    final metricM1 = metrics.mostRentedMaterials.firstWhere(
      (m) => m.materialId == 'm1',
    );
    final metricM2 = metrics.mostRentedMaterials.firstWhere(
      (m) => m.materialId == 'm2',
    );
    final metricM3 = metrics.mostRentedMaterials.firstWhere(
      (m) => m.materialId == 'm3',
    );

    expect(metricM1.timesRented, equals(2));
    expect(metricM1.totalQuantity, equals(15));

    expect(metricM2.timesRented, equals(1));
    expect(metricM2.totalQuantity, equals(2));

    expect(metricM3.timesRented, equals(1));
    expect(metricM3.totalQuantity, equals(1));
  });

  test('new vs returning customers incl. a customer whose only earlier rental is voided', () {
    // Hand computation:
    // Customer A: earlier rental on 2026-05-10 is VOIDED. Rental on 2026-06-02 is non-voided.
    //   Their first-ever non-voided rental is on 2026-06-02 (in period).
    //   -> Customer A is NEW in June 2026.
    // Customer B: earlier rental on 2026-04-10 is NON-VOIDED. Rental on 2026-06-05 is in period.
    //   First non-voided rental was before period start.
    //   -> Customer B is RETURNING in June 2026.
    // Customer C: rental on 2026-06-12 (in period), no earlier rentals.
    //   -> Customer C is NEW in June 2026.
    // Total: new = 2, returning = 1.
    final custA = _createCustomer(id: 'cA', name: 'Almaz');
    final custB = _createCustomer(id: 'cB', name: 'Bekele');
    final custC = _createCustomer(id: 'cC', name: 'Chala');

    final rentals = [
      RentalRecord(
        id: 'rA_void',
        rentalNumber: 1,
        customerId: 'cA',
        rentedAt: DateTime.utc(2026, 5, 10),
        status: RentalStatus.voided,
        notes: null,
        createdAt: DateTime.utc(2026, 5, 10),
        updatedAt: DateTime.utc(2026, 5, 11),
        voidedAt: DateTime.utc(2026, 5, 11),
        voidReason: 'Mistake',
      ),
      RentalRecord(
        id: 'rA_active',
        rentalNumber: 2,
        customerId: 'cA',
        rentedAt: DateTime.utc(2026, 6, 2),
        status: RentalStatus.active,
        notes: null,
        createdAt: DateTime.utc(2026, 6, 2),
        updatedAt: DateTime.utc(2026, 6, 2),
      ),
      RentalRecord(
        id: 'rB_old',
        rentalNumber: 3,
        customerId: 'cB',
        rentedAt: DateTime.utc(2026, 4, 10),
        status: RentalStatus.returned,
        notes: null,
        createdAt: DateTime.utc(2026, 4, 10),
        updatedAt: DateTime.utc(2026, 4, 15),
      ),
      RentalRecord(
        id: 'rB_active',
        rentalNumber: 4,
        customerId: 'cB',
        rentedAt: DateTime.utc(2026, 6, 5),
        status: RentalStatus.active,
        notes: null,
        createdAt: DateTime.utc(2026, 6, 5),
        updatedAt: DateTime.utc(2026, 6, 5),
      ),
      RentalRecord(
        id: 'rC_active',
        rentalNumber: 5,
        customerId: 'cC',
        rentedAt: DateTime.utc(2026, 6, 12),
        status: RentalStatus.active,
        notes: null,
        createdAt: DateTime.utc(2026, 6, 12),
        updatedAt: DateTime.utc(2026, 6, 12),
      ),
    ];

    final metrics = computeDashboardMetrics(
      rentals: rentals,
      lines: const [],
      returnEvents: const [],
      customers: [custA, custB, custC],
      materials: const [],
      period: DashboardPeriod.custom(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 30),
      ),
      nowUtc: DateTime.utc(2026, 6, 15),
      localOffset: localOffset,
      longRunningThresholdDays: 14,
    );

    expect(metrics.newCustomersCount, equals(2));
    expect(metrics.returningCustomersCount, equals(1));
  });

  test('long-running threshold boundary (exactly N days)', () {
    // Hand computation:
    // Threshold = 14 days.
    // asOf date = 2026-06-15.
    // Rental 1: rentedAt 2026-06-02.
    //   billableDays(2026-06-02, 2026-06-15) = 15 - 2 + 1 = 14 days.
    //   14 >= 14 -> INCLUDED.
    // Rental 2: rentedAt 2026-06-03.
    //   billableDays(2026-06-03, 2026-06-15) = 15 - 3 + 1 = 13 days.
    //   13 < 14 -> EXCLUDED.
    // Rental 3: rentedAt 2026-05-15 (32 days), but status = returned -> EXCLUDED.
    final r1 = RentalRecord(
      id: 'r1',
      rentalNumber: 1,
      customerId: 'c1',
      rentedAt: DateTime.utc(2026, 6, 2, 10, 0),
      status: RentalStatus.active,
      notes: null,
      createdAt: DateTime.utc(2026, 6, 2),
      updatedAt: DateTime.utc(2026, 6, 2),
    );
    final r2 = RentalRecord(
      id: 'r2',
      rentalNumber: 2,
      customerId: 'c1',
      rentedAt: DateTime.utc(2026, 6, 3, 10, 0),
      status: RentalStatus.active,
      notes: null,
      createdAt: DateTime.utc(2026, 6, 3),
      updatedAt: DateTime.utc(2026, 6, 3),
    );
    final r3 = RentalRecord(
      id: 'r3',
      rentalNumber: 3,
      customerId: 'c1',
      rentedAt: DateTime.utc(2026, 5, 15, 10, 0),
      status: RentalStatus.returned,
      notes: null,
      createdAt: DateTime.utc(2026, 5, 15),
      updatedAt: DateTime.utc(2026, 6, 10),
    );

    final metrics = computeDashboardMetrics(
      rentals: [r1, r2, r3],
      lines: const [],
      returnEvents: const [],
      customers: [_createCustomer(id: 'c1', name: 'Abebe')],
      materials: const [],
      period: DashboardPeriod.custom(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 30),
      ),
      nowUtc: DateTime.utc(2026, 6, 15, 12, 0),
      localOffset: localOffset,
      longRunningThresholdDays: 14,
    );

    expect(metrics.longRunningRentals.length, equals(1));
    expect(metrics.longRunningRentals.single.rentalId, equals('r1'));
    expect(metrics.longRunningRentals.single.daysSoFar, equals(14));
  });

  test('each period option incl. custom with a single day', () {
    // Hand computation:
    // nowLocal = 2026-06-15.
    final now = DateTime(2026, 6, 15, 14, 30);

    // This month: 2026-06-01 00:00:00 to 2026-06-30 23:59:59.999
    final thisMonth = DashboardPeriod.thisMonth(now);
    expect(thisMonth.type, equals(DashboardPeriodType.thisMonth));
    expect(thisMonth.startDateLocal, equals(DateTime.utc(2026, 6, 1)));
    expect(
      thisMonth.endDateLocal,
      equals(DateTime.utc(2026, 6, 30, 23, 59, 59, 999)),
    );

    // Last month: 2026-05-01 00:00:00 to 2026-05-31 23:59:59.999
    final lastMonth = DashboardPeriod.lastMonth(now);
    expect(lastMonth.type, equals(DashboardPeriodType.lastMonth));
    expect(lastMonth.startDateLocal, equals(DateTime.utc(2026, 5, 1)));
    expect(
      lastMonth.endDateLocal,
      equals(DateTime.utc(2026, 5, 31, 23, 59, 59, 999)),
    );

    // Last 3 months: 2026-04-01 00:00:00 to 2026-06-30 23:59:59.999
    final last3Months = DashboardPeriod.last3Months(now);
    expect(last3Months.type, equals(DashboardPeriodType.last3Months));
    expect(last3Months.startDateLocal, equals(DateTime.utc(2026, 4, 1)));
    expect(
      last3Months.endDateLocal,
      equals(DateTime.utc(2026, 6, 30, 23, 59, 59, 999)),
    );

    // This year: 2026-01-01 00:00:00 to 2026-12-31 23:59:59.999
    final thisYear = DashboardPeriod.thisYear(now);
    expect(thisYear.type, equals(DashboardPeriodType.thisYear));
    expect(thisYear.startDateLocal, equals(DateTime.utc(2026, 1, 1)));
    expect(
      thisYear.endDateLocal,
      equals(DateTime.utc(2026, 12, 31, 23, 59, 59, 999)),
    );

    // Custom single day: 2026-06-15 00:00:00 to 2026-06-15 23:59:59.999
    final singleDay = DashboardPeriod.custom(
      DateTime.utc(2026, 6, 15),
      DateTime.utc(2026, 6, 15),
    );
    expect(singleDay.type, equals(DashboardPeriodType.custom));
    expect(singleDay.startDateLocal, equals(DateTime.utc(2026, 6, 15)));
    expect(
      singleDay.endDateLocal,
      equals(DateTime.utc(2026, 6, 15, 23, 59, 59, 999)),
    );
    expect(singleDay.containsLocalDate(DateTime(2026, 6, 15, 12, 0)), isTrue);
    expect(singleDay.containsLocalDate(DateTime(2026, 6, 14, 23, 59)), isFalse);
    expect(singleDay.containsLocalDate(DateTime(2026, 6, 16, 0, 1)), isFalse);
  });

  test('percent change with previous = 0', () {
    // Hand computation:
    // Case 1: prev = 0, current = 0 -> 0.0%
    expect(computeMonthOverMonthPercent(current: 0, previous: 0), equals(0.0));

    // Case 2: prev = 0, current = 50000 -> null (cannot divide by zero / undefined change)
    expect(computeMonthOverMonthPercent(current: 50000, previous: 0), isNull);

    // Case 3: prev = 20000, current = 30000 -> ((30000 - 20000) / 20000) * 100 = 50.0%
    expect(
      computeMonthOverMonthPercent(current: 30000, previous: 20000),
      equals(50.0),
    );

    // Case 4: prev = 40000, current = 20000 -> ((20000 - 40000) / 40000) * 100 = -50.0%
    expect(
      computeMonthOverMonthPercent(current: 20000, previous: 40000),
      equals(-50.0),
    );
  });
}
