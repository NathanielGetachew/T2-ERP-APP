import 'customer.dart';

abstract interface class CustomerRepository {
  Stream<List<Customer>> watchAll(String query, {bool includeInactive = false});

  Future<Customer?> getById(String id);

  Future<Customer> create({
    required String fullName,
    required String address,
    String? phone,
    String? notes,
    required String idPhotoFrontPath,
    String? idPhotoBackPath,
  });

  Future<Customer> update(Customer customer);

  Future<Customer> setActive(String id, bool isActive);

  Future<List<Customer>> findPossibleDuplicates({
    required String fullName,
    required String address,
    String? phone,
    String? excludingId,
  });
}
