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
}
