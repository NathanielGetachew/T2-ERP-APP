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
}
