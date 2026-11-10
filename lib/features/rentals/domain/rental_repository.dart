import 'rental.dart';

class StockAvailabilityException implements Exception {
  const StockAvailabilityException({
    required this.materialId,
    required this.requested,
    required this.available,
  });

  final String materialId;
  final int requested;
  final int available;

  @override
  String toString() => 'Requested $requested, but only $available available.';
}

class RentalValidationException implements Exception {
  const RentalValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class RentalRepository {
  Stream<List<RentalDetails>> watchActive({String query = ''});

  Stream<List<RentalDetails>> watchAll(String query, {RentalStatus? status});

  Future<RentalDetails?> getById(String id);

  Stream<List<RentalDetails>> watchByCustomer(String customerId);

  Future<RentalDetails> createRental({
    required String customerId,
    required List<RentalLineDraft> lines,
    String? notes,
    bool stockOverrideConfirmed = false,
  });

  Future<int?> availableStock(String materialId);

  Future<ReturnReceipt> recordReturn(
    String rentalId,
    List<ReturnLineInput> lines,
    String? note,
  );

  Future<CustomerHeldItems> getCustomerHeldItems(String customerId);

  Stream<CustomerHeldItems> watchCustomerHeldItems(String customerId);

  Stream<List<CustomerHoldingItemsSummary>> watchCustomersHoldingItems({
    String query = '',
  });

  Future<CustomerReturnReceipt> recordCustomerReturn({
    required String customerId,
    required List<ReturnAllocationLine> allocations,
    String? note,
  });

  Future<CustomerReturnReceipt?> getReturnBatchSummary(String batchId);

  Stream<List<ReturnEventRecord>> watchReturnEvents(String rentalId);

  Future<List<ReturnEventRecord>> getReturnEvents(String rentalId);

  Future<int> monthlyRevenue(int year, int month);

  Future<void> voidReturn(String returnEventId, String reason);

  Future<void> voidRental(String rentalId, String reason);

  Future<List<AuditHistoryEntry>> getAuditHistory(String rentalId);
}
