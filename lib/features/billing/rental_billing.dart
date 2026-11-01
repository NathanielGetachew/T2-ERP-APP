import '../rentals/domain/rental.dart';

/// Billing uses an injected local offset so calendar-day behavior is
/// deterministic in tests and does not depend on the test machine timezone.
int billableDays(
  DateTime rentedAtUtc,
  DateTime endUtc, {
  required Duration localOffset,
}) {
  final start = rentedAtUtc.toUtc().add(localOffset);
  final end = endUtc.toUtc().add(localOffset);
  final startDate = DateTime.utc(start.year, start.month, start.day);
  final endDate = DateTime.utc(end.year, end.month, end.day);
  final days = endDate.difference(startDate).inDays + 1;
  return days < 1 ? 1 : days;
}

int lineAmount(int quantity, int pricePerDaySnapshot, int days) {
  if (quantity <= 0) {
    throw ArgumentError.value(quantity, 'quantity', 'Must be greater than 0.');
  }
  if (pricePerDaySnapshot < 0) {
    throw ArgumentError.value(
      pricePerDaySnapshot,
      'pricePerDaySnapshot',
      'Cannot be negative.',
    );
  }
  if (days <= 0) {
    throw ArgumentError.value(days, 'days', 'Must be greater than 0.');
  }
  return quantity * pricePerDaySnapshot * days;
}

int returnLineAmount({
  required int quantity,
  required int pricePerDaySnapshot,
  required int days,
}) => lineAmount(quantity, pricePerDaySnapshot, days);

class RentalSummary {
  const RentalSummary({
    required this.earnedTotal,
    required this.outstandingEstimate,
    required this.grandTotalEstimate,
  });

  final int earnedTotal;
  final int outstandingEstimate;
  final int grandTotalEstimate;
}

RentalSummary rentalSummary({
  required RentalRecord rental,
  required Iterable<RentalLine> lines,
  required Iterable<ReturnEventRecord> returnEvents,
  required DateTime asOfUtc,
  required Duration localOffset,
}) {
  final earned = returnEvents.fold<int>(
    0,
    (total, event) => total + (event.voidedAt == null ? event.amount : 0),
  );
  if (rental.status == RentalStatus.voided) {
    return RentalSummary(
      earnedTotal: 0,
      outstandingEstimate: 0,
      grandTotalEstimate: 0,
    );
  }
  final outstanding = rentalEstimate(
    lines.map(
      (line) => (
        quantity: line.quantity,
        quantityReturned: line.quantityReturned,
        pricePerDaySnapshot: line.pricePerDaySnapshot,
      ),
    ),
    rentedAtUtc: rental.rentedAt,
    asOfUtc: asOfUtc,
    localOffset: localOffset,
  );
  return RentalSummary(
    earnedTotal: earned,
    outstandingEstimate: outstanding,
    grandTotalEstimate: earned + outstanding,
  );
}

int rentalEstimate(
  Iterable<({int quantity, int quantityReturned, int pricePerDaySnapshot})>
  lines, {
  required DateTime rentedAtUtc,
  required DateTime asOfUtc,
  required Duration localOffset,
}) {
  final days = billableDays(rentedAtUtc, asOfUtc, localOffset: localOffset);
  return lines.fold<int>(0, (total, line) {
    final outstanding = line.quantity - line.quantityReturned;
    if (outstanding <= 0) {
      return total;
    }
    return total + lineAmount(outstanding, line.pricePerDaySnapshot, days);
  });
}
