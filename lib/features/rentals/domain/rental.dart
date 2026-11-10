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
    this.voidedAt,
    this.voidReason,
  });

  final String id;
  final int rentalNumber;
  final String customerId;
  final DateTime rentedAt;
  final RentalStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? voidedAt;
  final String? voidReason;
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
    this.returnBatchId,
    this.voidedAt,
    this.voidReason,
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
  final String? returnBatchId;
  final DateTime? voidedAt;
  final String? voidReason;
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

class AuditHistoryEntry {
  const AuditHistoryEntry({
    required this.action,
    required this.at,
    required this.description,
  });

  final String action;
  final DateTime at;
  final String description;
}

class CustomerHeldRentalLine {
  const CustomerHeldRentalLine({
    required this.rentalId,
    required this.rentalNumber,
    required this.rentalItemId,
    required this.materialId,
    required this.materialName,
    required this.rentedAt,
    required this.outstandingQuantity,
    required this.daysSoFar,
    required this.pricePerDaySnapshot,
  });

  final String rentalId;
  final int rentalNumber;
  final String rentalItemId;
  final String materialId;
  final String materialName;
  final DateTime rentedAt;
  final int outstandingQuantity;
  final int daysSoFar;
  final int pricePerDaySnapshot;
}

class CustomerHeldMaterial {
  const CustomerHeldMaterial({
    required this.materialId,
    required this.materialName,
    required this.totalOutstanding,
    required this.lines,
  });

  final String materialId;
  final String materialName;
  final int totalOutstanding;
  final List<CustomerHeldRentalLine> lines;
}

class CustomerHeldItems {
  const CustomerHeldItems({
    required this.customerId,
    required this.customerName,
    required this.materials,
  });

  final String customerId;
  final String customerName;
  final List<CustomerHeldMaterial> materials;

  int get totalUnitsHeld =>
      materials.fold(0, (sum, m) => sum + m.totalOutstanding);
}

class ReturnAllocationLine {
  const ReturnAllocationLine({
    required this.rentalId,
    required this.rentalNumber,
    required this.rentalItemId,
    required this.materialId,
    required this.materialName,
    required this.rentedAt,
    required this.quantity,
    required this.pricePerDaySnapshot,
    required this.days,
    required this.amount,
  });

  final String rentalId;
  final int rentalNumber;
  final String rentalItemId;
  final String materialId;
  final String materialName;
  final DateTime rentedAt;
  final int quantity;
  final int pricePerDaySnapshot;
  final int days;
  final int amount;
}

class CustomerReturnReceipt {
  const CustomerReturnReceipt({
    required this.batchId,
    required this.customerId,
    required this.customerName,
    required this.returnedAt,
    required this.allocations,
    required this.totalAmount,
    required this.remainingHeld,
    required this.events,
  });

  final String batchId;
  final String customerId;
  final String customerName;
  final DateTime returnedAt;
  final List<ReturnAllocationLine> allocations;
  final int totalAmount;
  final List<CustomerHeldMaterial> remainingHeld;
  final List<ReturnEventRecord> events;
}

class CustomerHoldingItemsSummary {
  const CustomerHoldingItemsSummary({
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.totalUnitsHeld,
  });

  final String customerId;
  final String customerName;
  final String? phone;
  final String address;
  final int totalUnitsHeld;
}
