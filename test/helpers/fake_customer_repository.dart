import 'package:t2_rental/features/customers/domain/customer.dart';
import 'package:t2_rental/features/customers/domain/customer_repository.dart';
import 'package:t2_rental/features/customers/domain/customer_validation.dart';

class FakeCustomerRepository implements CustomerRepository {
  FakeCustomerRepository({
    Iterable<Customer> initial = const [],
    this.failPhotoReplacement = false,
  }) : _customers = initial.toList();

  final List<Customer> _customers;
  final List<Customer> createCalls = [];
  final List<Customer> updateCalls = [];
  final List<Customer> photoReplacementCalls = [];
  final List<String> activeChanges = [];
  final bool failPhotoReplacement;
  int _nextId = 0;

  @override
  Stream<List<Customer>> watchAll(
    String query, {
    bool includeInactive = false,
  }) {
    final normalizedQuery = normalizeCustomerText(query);
    final values = _customers.where((customer) {
      if (!includeInactive && !customer.isActive) {
        return false;
      }
      return normalizedQuery.isEmpty ||
          normalizeCustomerText(customer.fullName).contains(normalizedQuery) ||
          normalizeCustomerText(customer.address).contains(normalizedQuery) ||
          normalizeCustomerText(customer.phone ?? '').contains(normalizedQuery);
    }).toList();
    return Stream.value(values);
  }

  @override
  Future<Customer?> getById(String id) async {
    for (final customer in _customers) {
      if (customer.id == id) {
        return customer;
      }
    }
    return null;
  }

  @override
  Future<Customer> create({
    required String fullName,
    required String address,
    String? phone,
    String? notes,
    required String idPhotoFrontPath,
    String? idPhotoBackPath,
  }) async {
    final customer = _newCustomer(
      fullName: fullName,
      address: address,
      phone: phone,
      notes: notes,
      idPhotoFrontPath: idPhotoFrontPath,
      idPhotoBackPath: idPhotoBackPath,
    );
    _customers.add(customer);
    createCalls.add(customer);
    return customer;
  }

  @override
  Future<Customer> update(Customer customer) async {
    final index = _customers.indexWhere((item) => item.id == customer.id);
    if (index < 0) {
      throw const CustomerValidationException('Customer not found.');
    }
    _customers[index] = customer;
    updateCalls.add(customer);
    return customer;
  }

  @override
  Future<Customer> replaceIdPhoto(
    String customerId,
    CustomerPhotoSide side,
    String newRelativePath,
  ) async {
    if (failPhotoReplacement) {
      throw const CustomerValidationException('Photo replacement failed.');
    }
    final customer = await getById(customerId);
    if (customer == null) {
      throw const CustomerValidationException('Customer not found.');
    }
    if (newRelativePath.trim().isEmpty) {
      throw const CustomerValidationException('Photo path is required.');
    }
    final updated = side == CustomerPhotoSide.front
        ? customer.copyWith(
            idPhotoFrontPath: newRelativePath.trim(),
            updatedAt: DateTime.now().toUtc(),
          )
        : customer.copyWith(
            idPhotoBackPath: newRelativePath.trim(),
            updatedAt: DateTime.now().toUtc(),
          );
    _customers[_customers.indexOf(customer)] = updated;
    photoReplacementCalls.add(updated);
    return updated;
  }

  @override
  Future<Customer> setActive(String id, bool isActive) async {
    final customer = await getById(id);
    if (customer == null) {
      throw const CustomerValidationException('Customer not found.');
    }
    final updated = customer.copyWith(isActive: isActive);
    _customers[_customers.indexOf(customer)] = updated;
    activeChanges.add(id);
    return updated;
  }

  @override
  Future<List<Customer>> findPossibleDuplicates({
    required String fullName,
    required String address,
    String? phone,
    String? excludingId,
  }) async {
    final name = normalizeCustomerText(fullName);
    final normalizedAddress = normalizeCustomerText(address);
    final normalizedPhone = phone == null || phone.trim().isEmpty
        ? null
        : normalizeCustomerPhone(phone);
    return _customers.where((customer) {
      if (customer.id == excludingId ||
          normalizeCustomerText(customer.fullName) != name) {
        return false;
      }
      return (normalizedPhone != null &&
              customer.phone != null &&
              normalizeCustomerPhone(customer.phone!) == normalizedPhone) ||
          normalizeCustomerText(customer.address) == normalizedAddress;
    }).toList();
  }

  Customer _newCustomer({
    required String fullName,
    required String address,
    required String? phone,
    required String? notes,
    required String idPhotoFrontPath,
    required String? idPhotoBackPath,
  }) {
    if (validateCustomerFullName(fullName) != null ||
        validateCustomerAddress(address) != null ||
        validateCustomerPhone(phone) != null ||
        idPhotoFrontPath.trim().isEmpty) {
      throw const CustomerValidationException('Customer fields are invalid.');
    }
    final now = DateTime.now().toUtc();
    return Customer(
      id: 'fake-customer-${_nextId++}',
      fullName: fullName.trim(),
      address: address.trim(),
      phone: phone == null || phone.trim().isEmpty ? null : phone.trim(),
      notes: notes == null || notes.trim().isEmpty ? null : notes.trim(),
      idPhotoFrontPath: idPhotoFrontPath,
      idPhotoBackPath: idPhotoBackPath,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}
