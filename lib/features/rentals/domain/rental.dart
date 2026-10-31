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
