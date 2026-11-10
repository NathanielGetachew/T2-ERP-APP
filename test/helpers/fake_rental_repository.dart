import 'package:t2_rental/features/rentals/domain/rental.dart';
import 'package:t2_rental/features/rentals/domain/rental_repository.dart';

class FakeRentalRepository implements RentalRepository {
  FakeRentalRepository({Iterable<RentalDetails> initial = const []})
    : _rentals = initial.toList();

  final List<RentalDetails> _rentals;

  @override
  Stream<List<RentalDetails>> watchActive({String query = ''}) =>
      watchAll(query).map(
        (items) => items
            .where(
              (item) =>
                  item.rental.status == RentalStatus.active ||
                  item.rental.status == RentalStatus.partiallyReturned,
            )
            .toList(),
      );

  @override
  Stream<List<RentalDetails>> watchAll(
    String query, {
    RentalStatus? status,
  }) async* {
    yield _filter(query, status);
  }

  @override
  Future<RentalDetails?> getById(String id) async {
    for (final item in _rentals) {
      if (item.rental.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Stream<List<RentalDetails>> watchByCustomer(String customerId) async* {
    yield _rentals
        .where((item) => item.rental.customerId == customerId)
        .toList();
  }

  @override
  Future<RentalDetails> createRental({
    required String customerId,
    required List<RentalLineDraft> lines,
    String? notes,
    bool stockOverrideConfirmed = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<int?> availableStock(String materialId) async => null;

  @override
  Future<ReturnReceipt> recordReturn(
    String rentalId,
    List<ReturnLineInput> lines,
    String? note,
  ) => throw UnimplementedError();

  final Map<String, CustomerReturnReceipt> _batchReceipts = {};
  final List<ReturnEventRecord> _allEvents = [];

  @override
  Future<CustomerHeldItems> getCustomerHeldItems(String customerId) async {
    final customerRentals = _rentals
        .where(
          (item) =>
              item.rental.customerId == customerId &&
              (item.rental.status == RentalStatus.active ||
                  item.rental.status == RentalStatus.partiallyReturned),
        )
        .toList();
    if (customerRentals.isEmpty) {
      final name =
          _rentals
              .where((r) => r.rental.customerId == customerId)
              .map((r) => r.customerName)
              .firstOrNull ??
          '';
      return CustomerHeldItems(
        customerId: customerId,
        customerName: name,
        materials: const [],
      );
    }
    final customerName = customerRentals.first.customerName;
    final linesByMat = <String, List<CustomerHeldRentalLine>>{};
    final matNames = <String, String>{};

    for (final details in customerRentals) {
      for (final line in details.lines) {
        if (line.outstandingQuantity > 0) {
          final heldLine = CustomerHeldRentalLine(
            rentalId: details.rental.id,
            rentalNumber: details.rental.rentalNumber,
            rentalItemId: line.id,
            materialId: line.materialId,
            materialName: line.materialNameSnapshot,
            rentedAt: details.rental.rentedAt,
            outstandingQuantity: line.outstandingQuantity,
            daysSoFar: 1,
            pricePerDaySnapshot: line.pricePerDaySnapshot,
          );
          linesByMat.putIfAbsent(line.materialId, () => []).add(heldLine);
          matNames[line.materialId] = line.materialNameSnapshot;
        }
      }
    }
    final mats = linesByMat.entries.map((e) {
      final total = e.value.fold<int>(0, (s, l) => s + l.outstandingQuantity);
      return CustomerHeldMaterial(
        materialId: e.key,
        materialName: matNames[e.key] ?? '',
        totalOutstanding: total,
        lines: e.value,
      );
    }).toList();
    return CustomerHeldItems(
      customerId: customerId,
      customerName: customerName,
      materials: mats,
    );
  }

  @override
  Stream<CustomerHeldItems> watchCustomerHeldItems(String customerId) async* {
    yield await getCustomerHeldItems(customerId);
  }

  @override
  Stream<List<CustomerHoldingItemsSummary>> watchCustomersHoldingItems({
    String query = '',
  }) async* {
    final results = <CustomerHoldingItemsSummary>[];
    final seen = <String>{};
    for (final r in _rentals) {
      if (seen.add(r.rental.customerId)) {
        final held = await getCustomerHeldItems(r.rental.customerId);
        if (held.totalUnitsHeld > 0) {
          results.add(
            CustomerHoldingItemsSummary(
              customerId: r.rental.customerId,
              customerName: r.customerName,
              phone: '0911000000',
              address: 'Addis Ababa',
              totalUnitsHeld: held.totalUnitsHeld,
            ),
          );
        }
      }
    }
    final norm = query.toLowerCase().trim();
    yield results
        .where(
          (c) => norm.isEmpty || c.customerName.toLowerCase().contains(norm),
        )
        .toList();
  }

  @override
  Future<CustomerReturnReceipt> recordCustomerReturn({
    required String customerId,
    required List<ReturnAllocationLine> allocations,
    String? note,
  }) async {
    final batchId = 'batch-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toUtc();
    final events = <ReturnEventRecord>[];
    var grandTotal = 0;

    for (final alloc in allocations.where((a) => a.quantity > 0)) {
      grandTotal += alloc.amount;
      final event = ReturnEventRecord(
        id: 'event-${alloc.rentalItemId}',
        rentalId: alloc.rentalId,
        rentalItemId: alloc.rentalItemId,
        quantity: alloc.quantity,
        returnedAt: now,
        billableDays: alloc.days,
        amount: alloc.amount,
        pricePerDaySnapshot: alloc.pricePerDaySnapshot,
        conditionNote: note,
        createdAt: now,
        returnBatchId: batchId,
      );
      events.add(event);
      _allEvents.add(event);
    }

    final receipt = CustomerReturnReceipt(
      batchId: batchId,
      customerId: customerId,
      customerName: 'Abebe Kebede',
      returnedAt: now,
      allocations: allocations,
      totalAmount: grandTotal,
      remainingHeld: const [],
      events: events,
    );
    _batchReceipts[batchId] = receipt;
    return receipt;
  }

  @override
  Future<CustomerReturnReceipt?> getReturnBatchSummary(String batchId) async =>
      _batchReceipts[batchId];

  @override
  Stream<List<ReturnEventRecord>> watchReturnEvents(String rentalId) async* {
    yield const [];
  }

  @override
  Future<List<ReturnEventRecord>> getReturnEvents(String rentalId) async => [];

  @override
  Future<int> monthlyRevenue(int year, int month) async => 0;

  @override
  Future<void> voidReturn(String returnEventId, String reason) async {}

  @override
  Future<void> voidRental(String rentalId, String reason) async {}

  @override
  Future<List<AuditHistoryEntry>> getAuditHistory(String rentalId) async => [];

  List<RentalDetails> _filter(String query, RentalStatus? status) {
    final normalized = query.toLowerCase().trim();
    return _rentals.where((item) {
      final statusMatches = status == null
          ? true
          : status == RentalStatus.active
          ? item.rental.status == RentalStatus.active ||
                item.rental.status == RentalStatus.partiallyReturned
          : item.rental.status == status;
      final queryMatches =
          normalized.isEmpty ||
          item.customerName.toLowerCase().contains(normalized) ||
          item.rental.rentalNumber.toString().contains(normalized);
      return statusMatches && queryMatches;
    }).toList();
  }
}
