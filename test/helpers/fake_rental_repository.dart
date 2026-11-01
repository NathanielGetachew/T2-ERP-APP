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

  @override
  Stream<List<ReturnEventRecord>> watchReturnEvents(String rentalId) async* {
    yield const [];
  }

  @override
  Future<List<ReturnEventRecord>> getReturnEvents(String rentalId) async => [];

  @override
  Future<int> monthlyRevenue(int year, int month) async => 0;

  List<RentalDetails> _filter(String query, RentalStatus? status) {
    final normalized = query.toLowerCase().trim();
    return _rentals.where((item) {
      final statusMatches = status == null || item.rental.status == status;
      final queryMatches =
          normalized.isEmpty ||
          item.customerName.toLowerCase().contains(normalized) ||
          item.rental.rentalNumber.toString().contains(normalized);
      return statusMatches && queryMatches;
    }).toList();
  }
}
