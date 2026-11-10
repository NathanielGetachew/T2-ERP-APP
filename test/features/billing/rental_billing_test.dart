import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/features/billing/rental_billing.dart';
import 'package:t2_rental/features/rentals/domain/rental.dart';

void main() {
  const offset = Duration(hours: 3);

  test('counts the same local calendar date as one day', () {
    expect(
      billableDays(
        DateTime.utc(2026, 1, 1, 1),
        DateTime.utc(2026, 1, 1, 20),
        localOffset: offset,
      ),
      1,
    );
  });

  test('counts consecutive, month, and year dates inclusively', () {
    expect(
      billableDays(
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 1, 3),
        localOffset: offset,
      ),
      3,
    );
    expect(
      billableDays(
        DateTime.utc(2026, 1, 31),
        DateTime.utc(2026, 2, 2),
        localOffset: offset,
      ),
      3,
    );
    expect(
      billableDays(
        DateTime.utc(2025, 12, 31),
        DateTime.utc(2026, 1, 1),
        localOffset: offset,
      ),
      2,
    );
  });

  test('handles UTC instants across a local midnight', () {
    expect(
      billableDays(
        DateTime.utc(2026, 4, 1, 20, 59),
        DateTime.utc(2026, 4, 1, 21, 1),
        localOffset: offset,
      ),
      2,
    );
  });

  test('line amount uses integer arithmetic and large quantities', () {
    expect(lineAmount(100000, 25050, 3), 7_515_000_000);
  });

  test('rejects zero or negative quantities and invalid days', () {
    expect(() => lineAmount(0, 100, 1), throwsArgumentError);
    expect(() => lineAmount(-1, 100, 1), throwsArgumentError);
    expect(() => lineAmount(1, 100, 0), throwsArgumentError);
  });

  test('estimate uses outstanding quantities and price snapshots', () {
    // Days = 3; first line = (2 - 1) * 25,050 * 3 = 75,150;
    // second line = (1 - 1) * 99,999 * 3 = 0; estimate = 75,150 + 0.
    expect(
      rentalEstimate(
        [
          (quantity: 2, quantityReturned: 1, pricePerDaySnapshot: 25050),
          (quantity: 1, quantityReturned: 1, pricePerDaySnapshot: 99999),
        ],
        rentedAtUtc: DateTime.utc(2026, 1, 1),
        asOfUtc: DateTime.utc(2026, 1, 3),
        localOffset: offset,
      ),
      75_150,
    );
  });

  test('estimates a simple three-day line', () {
    // 10 units * 2,500 minor units * 3 days = 75,000 minor units.
    expect(
      rentalEstimate(
        [(quantity: 10, quantityReturned: 0, pricePerDaySnapshot: 2500)],
        rentedAtUtc: DateTime.utc(2026, 1, 1),
        asOfUtc: DateTime.utc(2026, 1, 3),
        localOffset: offset,
      ),
      75_000,
    );
  });

  test('estimates only outstanding quantities on partially returned lines', () {
    // (10 - 6) units * 2,500 minor units * 3 days = 30,000 minor units.
    expect(
      rentalEstimate(
        [(quantity: 10, quantityReturned: 6, pricePerDaySnapshot: 2500)],
        rentedAtUtc: DateTime.utc(2026, 1, 1),
        asOfUtc: DateTime.utc(2026, 1, 3),
        localOffset: offset,
      ),
      30_000,
    );
  });

  test('calculates return amounts for a full three-day return', () {
    expect(
      returnLineAmount(quantity: 10, pricePerDaySnapshot: 2500, days: 3),
      75_000,
    );
  });

  test('calculates partial returns on different dates', () {
    final first = returnLineAmount(
      quantity: 4,
      pricePerDaySnapshot: 2500,
      days: 2,
    );
    final second = returnLineAmount(
      quantity: 6,
      pricePerDaySnapshot: 2500,
      days: 5,
    );
    expect(first + second, 95_000);
  });

  test('summarizes earned and outstanding estimates separately', () {
    final rental = RentalRecord(
      id: 'rental',
      rentalNumber: 1,
      customerId: 'customer',
      rentedAt: DateTime.utc(2026, 1, 1),
      status: RentalStatus.partiallyReturned,
      notes: null,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    final line = RentalLine(
      id: 'line',
      rentalId: 'rental',
      materialId: 'material',
      materialNameSnapshot: 'Panel',
      pricePerDaySnapshot: 2500,
      quantity: 10,
      quantityReturned: 4,
    );
    final event = ReturnEventRecord(
      id: 'event',
      rentalId: 'rental',
      rentalItemId: 'line',
      quantity: 4,
      returnedAt: DateTime.utc(2026, 1, 2),
      billableDays: 2,
      amount: 20_000,
      pricePerDaySnapshot: 2500,
      conditionNote: null,
      createdAt: DateTime.utc(2026, 1, 2),
    );
    final summary = rentalSummary(
      rental: rental,
      lines: [line],
      returnEvents: [event],
      asOfUtc: DateTime.utc(2026, 1, 5),
      localOffset: offset,
    );
    expect(summary.earnedTotal, 20_000);
    expect(summary.outstandingEstimate, 75_000);
    expect(summary.grandTotalEstimate, 95_000);
  });

  test('rejects zero and negative return quantities', () {
    expect(
      () => returnLineAmount(quantity: 0, pricePerDaySnapshot: 2500, days: 1),
      throwsArgumentError,
    );
    expect(
      () => returnLineAmount(quantity: -1, pricePerDaySnapshot: 2500, days: 1),
      throwsArgumentError,
    );
  });

  group('allocateReturnQuantityOldestFirst', () {
    // R-0001: 10 panels at 25.00 ETB (2500 minor units), rented day 1 (Jan 1)
    // R-0003: 5 panels at 25.00 ETB (2500 minor units), rented day 3 (Jan 3)
    // Customer returns 12 panels on day 5 (Jan 5)
    //
    // Hand-computed arithmetic:
    // Oldest first allocation takes:
    // 1) From R-0001: 10 units (all 10)
    //    Days = Jan 5 - Jan 1 + 1 = 5 calendar days
    //    Amount = 10 units × 2500 minor units × 5 days = 125,000 minor units (1250.00 ETB)
    // 2) From R-0003: 2 units (12 - 10 = 2)
    //    Days = Jan 5 - Jan 3 + 1 = 3 calendar days
    //    Amount = 2 units × 2500 minor units × 3 days = 15,000 minor units (150.00 ETB)
    // Grand total: 125,000 + 15,000 = 140,000 minor units (1400.00 ETB)
    final r1Line = CustomerHeldRentalLine(
      rentalId: 'r1',
      rentalNumber: 1,
      rentalItemId: 'line1',
      materialId: 'panel',
      materialName: 'Panel 60x120',
      rentedAt: DateTime.utc(2026, 1, 1),
      outstandingQuantity: 10,
      daysSoFar: 5,
      pricePerDaySnapshot: 2500,
    );
    final r3Line = CustomerHeldRentalLine(
      rentalId: 'r3',
      rentalNumber: 3,
      rentalItemId: 'line3',
      materialId: 'panel',
      materialName: 'Panel 60x120',
      rentedAt: DateTime.utc(2026, 1, 3),
      outstandingQuantity: 5,
      daysSoFar: 3,
      pricePerDaySnapshot: 2500,
    );

    test('allocates to oldest rental first with same price', () {
      final allocations = allocateReturnQuantityOldestFirst(
        lines: [r3Line, r1Line], // Pass in mixed order to verify sorting
        quantityToReturn: 12,
        returnedAtUtc: DateTime.utc(2026, 1, 5),
        localOffset: Duration.zero,
      );

      expect(allocations.length, 2);

      // First allocation: 10 units from R-0001
      expect(allocations[0].rentalId, 'r1');
      expect(allocations[0].rentalNumber, 1);
      expect(allocations[0].quantity, 10);
      expect(allocations[0].days, 5);
      // 10 * 2500 * 5 = 125000
      expect(allocations[0].amount, 125000);

      // Second allocation: 2 units from R-0003
      expect(allocations[1].rentalId, 'r3');
      expect(allocations[1].rentalNumber, 3);
      expect(allocations[1].quantity, 2);
      expect(allocations[1].days, 3);
      // 2 * 2500 * 3 = 15000
      expect(allocations[1].amount, 15000);

      final total = allocations.fold<int>(0, (s, a) => s + a.amount);
      // Grand total = 125000 + 15000 = 140000
      expect(total, 140000);
    });

    test('uses own price snapshot per line when prices differ', () {
      // R-0003 has snapshot price of 30.00 ETB (3000 minor units)
      // Hand-computed arithmetic:
      // From R-0001: 10 units × 2500 × 5 days = 125,000 minor units
      // From R-0003: 2 units × 3000 × 3 days = 18,000 minor units
      // Grand total: 125,000 + 18,000 = 143,000 minor units (1430.00 ETB)
      final r3HigherPrice = CustomerHeldRentalLine(
        rentalId: 'r3',
        rentalNumber: 3,
        rentalItemId: 'line3',
        materialId: 'panel',
        materialName: 'Panel 60x120',
        rentedAt: DateTime.utc(2026, 1, 3),
        outstandingQuantity: 5,
        daysSoFar: 3,
        pricePerDaySnapshot: 3000,
      );

      final allocations = allocateReturnQuantityOldestFirst(
        lines: [r1Line, r3HigherPrice],
        quantityToReturn: 12,
        returnedAtUtc: DateTime.utc(2026, 1, 5),
        localOffset: Duration.zero,
      );

      expect(allocations.length, 2);
      expect(allocations[0].amount, 125000);
      expect(allocations[1].amount, 18000);
      final total = allocations.fold<int>(0, (s, a) => s + a.amount);
      expect(total, 143000);
    });

    test('returns empty list for zero quantity', () {
      final allocations = allocateReturnQuantityOldestFirst(
        lines: [r1Line, r3Line],
        quantityToReturn: 0,
        returnedAtUtc: DateTime.utc(2026, 1, 5),
        localOffset: Duration.zero,
      );
      expect(allocations, isEmpty);
    });

    test('throws ArgumentError if quantity exceeds total outstanding', () {
      // Total outstanding is 10 + 5 = 15; asking for 16 must throw
      expect(
        () => allocateReturnQuantityOldestFirst(
          lines: [r1Line, r3Line],
          quantityToReturn: 16,
          returnedAtUtc: DateTime.utc(2026, 1, 5),
          localOffset: Duration.zero,
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError if quantity is negative', () {
      expect(
        () => allocateReturnQuantityOldestFirst(
          lines: [r1Line, r3Line],
          quantityToReturn: -1,
          returnedAtUtc: DateTime.utc(2026, 1, 5),
          localOffset: Duration.zero,
        ),
        throwsArgumentError,
      );
    });
  });

  group('validateManualAllocation', () {
    final r1Line = CustomerHeldRentalLine(
      rentalId: 'r1',
      rentalNumber: 1,
      rentalItemId: 'line1',
      materialId: 'panel',
      materialName: 'Panel',
      rentedAt: DateTime.utc(2026, 1, 1),
      outstandingQuantity: 10,
      daysSoFar: 1,
      pricePerDaySnapshot: 2500,
    );
    final r3Line = CustomerHeldRentalLine(
      rentalId: 'r3',
      rentalNumber: 3,
      rentalItemId: 'line3',
      materialId: 'panel',
      materialName: 'Panel',
      rentedAt: DateTime.utc(2026, 1, 3),
      outstandingQuantity: 5,
      daysSoFar: 1,
      pricePerDaySnapshot: 2500,
    );

    test('returns null for valid allocation', () {
      // 7 from line1, 5 from line3 = 12 total
      final error = validateManualAllocation(
        lines: [r1Line, r3Line],
        splits: {'line1': 7, 'line3': 5},
        expectedTotal: 12,
      );
      expect(error, isNull);
    });

    test('returns error when split exceeds line outstanding', () {
      // line3 only has 5 outstanding; requesting 7 must fail
      final error = validateManualAllocation(
        lines: [r1Line, r3Line],
        splits: {'line1': 5, 'line3': 7},
        expectedTotal: 12,
      );
      expect(error, isNotNull);
      expect(error, contains('exceeds outstanding'));
    });

    test(
      'returns error when total allocated does not match expected total',
      () {
        // 5 from line1, 5 from line3 = 10; expected is 12
        final error = validateManualAllocation(
          lines: [r1Line, r3Line],
          splits: {'line1': 5, 'line3': 5},
          expectedTotal: 12,
        );
        expect(error, isNotNull);
        expect(error, contains('Total allocated'));
      },
    );

    test('returns error when negative quantity provided', () {
      final error = validateManualAllocation(
        lines: [r1Line, r3Line],
        splits: {'line1': -1, 'line3': 13},
        expectedTotal: 12,
      );
      expect(error, isNotNull);
      expect(error, contains('negative'));
    });
  });

  group('buildAllocationLinesFromCustomSplits', () {
    test('builds lines with correct days and amounts', () {
      // Custom split: take 8 from r1, 4 from r3 on day 5 (Jan 5)
      // r1: 8 units × 2500 × 5 days = 100,000 minor units
      // r3: 4 units × 2500 × 3 days = 30,000 minor units
      // Grand total = 130,000 minor units
      final r1Line = CustomerHeldRentalLine(
        rentalId: 'r1',
        rentalNumber: 1,
        rentalItemId: 'line1',
        materialId: 'panel',
        materialName: 'Panel',
        rentedAt: DateTime.utc(2026, 1, 1),
        outstandingQuantity: 10,
        daysSoFar: 5,
        pricePerDaySnapshot: 2500,
      );
      final r3Line = CustomerHeldRentalLine(
        rentalId: 'r3',
        rentalNumber: 3,
        rentalItemId: 'line3',
        materialId: 'panel',
        materialName: 'Panel',
        rentedAt: DateTime.utc(2026, 1, 3),
        outstandingQuantity: 5,
        daysSoFar: 3,
        pricePerDaySnapshot: 2500,
      );

      final lines = buildAllocationLinesFromCustomSplits(
        lines: [r1Line, r3Line],
        splits: {'line1': 8, 'line3': 4},
        returnedAtUtc: DateTime.utc(2026, 1, 5),
        localOffset: Duration.zero,
      );

      expect(lines.length, 2);
      expect(lines[0].quantity, 8);
      expect(lines[0].amount, 100000);
      expect(lines[1].quantity, 4);
      expect(lines[1].amount, 30000);
    });
  });
}
