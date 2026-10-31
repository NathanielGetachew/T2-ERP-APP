import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/features/billing/rental_billing.dart';

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
}
