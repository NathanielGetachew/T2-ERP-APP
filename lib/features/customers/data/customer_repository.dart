import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart' as db;
import '../domain/customer.dart';
import '../domain/customer_repository.dart';
import '../domain/customer_validation.dart';

class DriftCustomerRepository implements CustomerRepository {
  DriftCustomerRepository(this.database);

  final db.AppDatabase database;

  @override
  Stream<List<Customer>> watchAll(
    String query, {
    bool includeInactive = false,
  }) {
    final select = database.select(database.customers)
      ..orderBy([(table) => OrderingTerm.asc(table.fullName)]);
    if (!includeInactive) {
      select.where((table) => table.voidedAt.isNull());
    }
    final normalizedQuery = normalizeCustomerText(query);
    return select.watch().map(
      (rows) => rows
          .map(_fromRow)
          .where((customer) => _matches(customer, normalizedQuery))
          .toList(),
    );
  }

  @override
  Future<Customer?> getById(String id) async {
    final row = await (database.select(
      database.customers,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
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
    final normalized = _normalizedValues(
      fullName: fullName,
      address: address,
      phone: phone,
      notes: notes,
      idPhotoFrontPath: idPhotoFrontPath,
      idPhotoBackPath: idPhotoBackPath,
    );
    final now = DateTime.now().toUtc();
    final customer = Customer(
      id: _uuidV4(),
      fullName: normalized.fullName,
      address: normalized.address,
      phone: normalized.phone,
      notes: normalized.notes,
      idPhotoFrontPath: normalized.idPhotoFrontPath,
      idPhotoBackPath: normalized.idPhotoBackPath,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    return database.transaction(() async {
      await database.into(database.customers).insert(_toInsert(customer));
      await _audit(action: 'create', customer: customer);
      return customer;
    });
  }

  @override
  Future<Customer> update(Customer customer) async {
    final normalized = _normalizedValues(
      fullName: customer.fullName,
      address: customer.address,
      phone: customer.phone,
      notes: customer.notes,
      idPhotoFrontPath: customer.idPhotoFrontPath,
      idPhotoBackPath: customer.idPhotoBackPath,
    );
    final old = await getById(customer.id);
    if (old == null) {
      throw const CustomerValidationException('Customer not found.');
    }
    final updated = customer.copyWith(
      fullName: normalized.fullName,
      address: normalized.address,
      phone: normalized.phone,
      notes: normalized.notes,
      idPhotoFrontPath: normalized.idPhotoFrontPath,
      idPhotoBackPath: normalized.idPhotoBackPath,
      updatedAt: DateTime.now().toUtc(),
    );
    return database.transaction(() async {
      await (database.update(database.customers)
            ..where((table) => table.id.equals(updated.id)))
          .write(_toUpdate(updated));
      await _audit(action: 'update', customer: updated, oldValue: old);
      if (old.idPhotoFrontPath != updated.idPhotoFrontPath ||
          old.idPhotoBackPath != updated.idPhotoBackPath) {
        await _audit(action: 'photo_replace', customer: updated, oldValue: old);
      }
      return updated;
    });
  }

  @override
  Future<Customer> replaceIdPhoto(
    String customerId,
    CustomerPhotoSide side,
    String newRelativePath,
  ) async {
    final path = newRelativePath.trim();
    if (path.isEmpty) {
      throw const CustomerValidationException('Photo path is required.');
    }
    return database.transaction(() async {
      final old = await getById(customerId);
      if (old == null) {
        throw const CustomerValidationException('Customer not found.');
      }
      final oldPath = side == CustomerPhotoSide.front
          ? old.idPhotoFrontPath
          : old.idPhotoBackPath;
      final updatedAt = DateTime.now().toUtc();
      final updated = side == CustomerPhotoSide.front
          ? old.copyWith(idPhotoFrontPath: path, updatedAt: updatedAt)
          : old.copyWith(idPhotoBackPath: path, updatedAt: updatedAt);
      final companion = side == CustomerPhotoSide.front
          ? db.CustomersCompanion(
              idPhotoFront: Value(path),
              updatedAt: Value(updatedAt),
            )
          : db.CustomersCompanion(
              idPhotoBack: Value(path),
              updatedAt: Value(updatedAt),
            );
      await (database.update(
        database.customers,
      )..where((table) => table.id.equals(customerId))).write(companion);
      await database
          .into(database.auditLogs)
          .insert(
            db.AuditLogsCompanion.insert(
              id: _uuidV4(),
              createdAt: updatedAt,
              updatedAt: updatedAt,
              entityType: 'customer',
              entityId: customerId,
              action: 'idPhotoReplaced',
              oldValue: Value(jsonEncode({'side': side.name, 'path': oldPath})),
              newValue: Value(jsonEncode({'side': side.name, 'path': path})),
              at: updatedAt,
              by: 'local-user',
            ),
          );
      return updated;
    });
  }

  @override
  Future<Customer> setActive(String id, bool isActive) async {
    final old = await getById(id);
    if (old == null) {
      throw const CustomerValidationException('Customer not found.');
    }
    if (old.isActive == isActive) {
      return old;
    }
    final now = DateTime.now().toUtc();
    final updated = old.copyWith(isActive: isActive, updatedAt: now);
    return database.transaction(() async {
      await (database.update(
        database.customers,
      )..where((table) => table.id.equals(id))).write(
        db.CustomersCompanion(
          updatedAt: Value(now),
          voidedAt: Value(isActive ? null : now),
          voidReason: Value(isActive ? null : 'Archived'),
        ),
      );
      await _audit(
        action: isActive ? 'reactivate' : 'archive',
        customer: updated,
        oldValue: old,
      );
      return updated;
    });
  }

  @override
  Future<List<Customer>> findPossibleDuplicates({
    required String fullName,
    required String address,
    String? phone,
    String? excludingId,
  }) async {
    final normalizedName = normalizeCustomerText(fullName);
    final normalizedAddress = normalizeCustomerText(address);
    final normalizedPhone = phone == null || phone.trim().isEmpty
        ? null
        : normalizeCustomerPhone(phone);
    final rows = await database.select(database.customers).get();
    return rows
        .map(_fromRow)
        .where(
          (customer) =>
              customer.id != excludingId &&
              normalizeCustomerText(customer.fullName) == normalizedName &&
              ((normalizedPhone != null &&
                      customer.phone != null &&
                      normalizeCustomerPhone(customer.phone!) ==
                          normalizedPhone) ||
                  normalizeCustomerText(customer.address) == normalizedAddress),
        )
        .toList();
  }

  Future<void> _audit({
    required String action,
    required Customer customer,
    Customer? oldValue,
  }) async {
    final now = DateTime.now().toUtc();
    await database
        .into(database.auditLogs)
        .insert(
          db.AuditLogsCompanion.insert(
            id: _uuidV4(),
            createdAt: now,
            updatedAt: now,
            entityType: 'customer',
            entityId: customer.id,
            action: action,
            oldValue: oldValue == null
                ? const Value.absent()
                : Value(jsonEncode(oldValue.toJson())),
            newValue: Value(jsonEncode(customer.toJson())),
            at: now,
            by: 'local-user',
          ),
        );
  }

  static ({
    String fullName,
    String address,
    String? phone,
    String? notes,
    String idPhotoFrontPath,
    String? idPhotoBackPath,
  })
  _normalizedValues({
    required String fullName,
    required String address,
    required String? phone,
    required String? notes,
    required String idPhotoFrontPath,
    required String? idPhotoBackPath,
  }) {
    final cleanName = fullName.trim();
    final cleanAddress = address.trim();
    final cleanPhone = phone == null || phone.trim().isEmpty
        ? null
        : normalizeCustomerPhone(phone);
    final cleanNotes = notes == null || notes.trim().isEmpty
        ? null
        : notes.trim();
    validateCustomer(
      fullName: cleanName,
      address: cleanAddress,
      phone: cleanPhone,
      idPhotoFrontPath: idPhotoFrontPath,
    );
    return (
      fullName: cleanName,
      address: cleanAddress,
      phone: cleanPhone,
      notes: cleanNotes,
      idPhotoFrontPath: idPhotoFrontPath.trim(),
      idPhotoBackPath: idPhotoBackPath == null || idPhotoBackPath.trim().isEmpty
          ? null
          : idPhotoBackPath.trim(),
    );
  }

  static bool _matches(Customer customer, String query) {
    if (query.isEmpty) {
      return true;
    }
    final fields = [
      customer.fullName,
      customer.address,
      customer.phone ?? '',
    ].map(normalizeCustomerText);
    return fields.any((field) => field.contains(query));
  }

  static Customer _fromRow(db.CustomerRow row) => Customer(
    id: row.id,
    fullName: row.fullName,
    address: row.address,
    phone: row.phone.trim().isEmpty ? null : row.phone,
    notes: row.notes,
    idPhotoFrontPath: row.idPhotoFront,
    idPhotoBackPath: row.idPhotoBack,
    isActive: row.voidedAt == null,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
  );

  static db.CustomersCompanion _toInsert(Customer customer) =>
      db.CustomersCompanion.insert(
        id: customer.id,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt,
        fullName: customer.fullName,
        phone: customer.phone ?? '',
        address: customer.address,
        idPhotoFront: customer.idPhotoFrontPath,
        idPhotoBack: Value(customer.idPhotoBackPath),
        notes: Value(customer.notes),
      );

  static db.CustomersCompanion _toUpdate(Customer customer) =>
      db.CustomersCompanion(
        updatedAt: Value(customer.updatedAt),
        fullName: Value(customer.fullName),
        phone: Value(customer.phone ?? ''),
        address: Value(customer.address),
        idPhotoFront: Value(customer.idPhotoFrontPath),
        idPhotoBack: Value(customer.idPhotoBackPath),
        notes: Value(customer.notes),
      );
}

String _uuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
