enum RentalStatus { active, partiallyReturned, returned, voided }

class RentalRecord {
  const RentalRecord({
    required this.id,
    required this.rentalNumber,
    required this.customerId,
    required this.rentedAt,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int rentalNumber;
  final String customerId;
  final DateTime rentedAt;
  final RentalStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class RentalLine {
  const RentalLine({
    required this.id,
    required this.rentalId,
    required this.materialId,
    required this.materialNameSnapshot,
    required this.pricePerDaySnapshot,
    required this.quantity,
    required this.quantityReturned,
  });

  final String id;
  final String rentalId;
  final String materialId;
  final String materialNameSnapshot;
  final int pricePerDaySnapshot;
  final int quantity;
  final int quantityReturned;

  int get outstandingQuantity => quantity - quantityReturned;
}

class RentalLineDraft {
  const RentalLineDraft({required this.materialId, required this.quantity});

  final String materialId;
  final int quantity;
}

class ReturnEventRecord {
  const ReturnEventRecord({
    required this.id,
    required this.rentalId,
    required this.rentalItemId,
    required this.quantity,
    required this.returnedAt,
    required this.billableDays,
    required this.amount,
    required this.pricePerDaySnapshot,
    required this.conditionNote,
    required this.createdAt,
  });

  final String id;
  final String rentalId;
  final String rentalItemId;
  final int quantity;
  final DateTime returnedAt;
  final int billableDays;
  final int amount;
  final int pricePerDaySnapshot;
  final String? conditionNote;
  final DateTime createdAt;
}

class ReturnLineInput {
  const ReturnLineInput({required this.rentalItemId, required this.quantity});

  final String rentalItemId;
  final int quantity;
}

class ReturnReceipt {
  const ReturnReceipt({
    required this.rental,
    required this.customerName,
    required this.events,
    required this.total,
    required this.status,
    required this.lines,
    required this.remainingOutstanding,
  });

  final RentalRecord rental;
  final String customerName;
  final List<ReturnEventRecord> events;
  final int total;
  final RentalStatus status;
  final List<RentalLine> lines;
  final List<RentalLine> remainingOutstanding;
}

class RentalDetails {
  const RentalDetails({
    required this.rental,
    required this.lines,
    required this.customerName,
  });

  final RentalRecord rental;
  final List<RentalLine> lines;
  final String customerName;
}
