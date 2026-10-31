import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart' as db;
import '../../../core/utils/clock.dart';
import '../domain/rental.dart';
import '../domain/rental_repository.dart';

class RentalValidationException implements Exception {
  const RentalValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DriftRentalRepository implements RentalRepository {
  DriftRentalRepository(this.database, {this.clock = const SystemClock()});

  final db.AppDatabase database;
  final Clock clock;

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
  Stream<List<RentalDetails>> watchAll(String query, {RentalStatus? status}) {
    final normalized = query.trim().toLowerCase();
    final statement = database.select(database.rentals)
      ..orderBy([(table) => OrderingTerm.desc(table.rentedAt)]);
    if (status != null) {
      statement.where((table) => table.status.equals(status.name));
    }
    return statement.watch().asyncMap((rows) async {
      final result = <RentalDetails>[];
      for (final row in rows) {
        final details = await _details(row);
        if (normalized.isEmpty ||
            details.customerName.toLowerCase().contains(normalized) ||
            _formatNumber(row.rentalNumber)
                .toLowerCase()
                .contains(normalized)) {
          result.add(details);
        }
      }
      return result;
    });
  }

  @override
  Future<RentalDetails?> getById(String id) async {
    final row = await (database.select(
      database.rentals,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : await _details(row);
  }

  @override
  Stream<List<RentalDetails>> watchByCustomer(String customerId) {
    final statement = database.select(database.rentals)
      ..where((table) => table.customerId.equals(customerId))
      ..orderBy([(table) => OrderingTerm.desc(table.rentedAt)]);
    return statement.watch().asyncMap(
      (rows) => Future.wait(rows.map(_details)),
    );
  }

  @override
  Future<RentalDetails> createRental({
    required String customerId,
    required List<RentalLineDraft> lines,
    String? notes,
    bool stockOverrideConfirmed = false,
  }) async {
    if (lines.isEmpty) {
      throw const RentalValidationException(
        'At least one material line is required.',
      );
    }
    final materialIds = <String>{};
    for (final line in lines) {
      if (line.quantity < 1) {
        throw const RentalValidationException(
          'Each material quantity must be at least 1.',
        );
      }
      if (!materialIds.add(line.materialId)) {
        throw const RentalValidationException(
          'A material cannot appear more than once in a rental.',
        );
      }
    }

    return database.transaction(() async {
      final customer = await (database.select(
        database.customers,
      )..where((table) => table.id.equals(customerId))).getSingleOrNull();
      if (customer == null || customer.voidedAt != null) {
        throw const RentalValidationException(
          'An active customer is required for a rental.',
        );
      }

      final materialRows = <String, db.MaterialRow>{};
      for (final line in lines) {
        final material =
            await (database.select(database.materialTypes)
                  ..where((table) => table.id.equals(line.materialId)))
                .getSingleOrNull();
        if (material == null || !material.isActive) {
          throw const RentalValidationException(
            'All selected materials must be active.',
          );
        }
        materialRows[line.materialId] = material;
        final available = await _availableStockInTransaction(
          material.id,
          material.totalStock,
        );
        if (available != null &&
            line.quantity > available &&
            !stockOverrideConfirmed) {
          throw StockAvailabilityException(
            materialId: material.id,
            requested: line.quantity,
            available: available,
          );
        }
      }

      final now = clock.now().toUtc();
      final rentalNumber = await _nextRentalNumber();
      final rental = RentalRecord(
        id: _uuidV4(),
        rentalNumber: rentalNumber,
        customerId: customerId,
        rentedAt: now,
        status: RentalStatus.active,
        notes: notes == null || notes.trim().isEmpty ? null : notes.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await database
          .into(database.rentals)
          .insert(
            db.RentalsCompanion.insert(
              id: rental.id,
              rentalNumber: Value(rentalNumber),
              createdAt: now,
              updatedAt: now,
              customerId: customerId,
              rentedAt: now,
              status: rental.status.name,
              notes: Value(rental.notes),
            ),
          );
      final savedLines = <RentalLine>[];
      for (final line in lines) {
        final material = materialRows[line.materialId]!;
        final saved = RentalLine(
          id: _uuidV4(),
          rentalId: rental.id,
          materialId: material.id,
          materialNameSnapshot: material.name,
          pricePerDaySnapshot: material.pricePerDay,
          quantity: line.quantity,
          quantityReturned: 0,
        );
        savedLines.add(saved);
        await database
            .into(database.rentalItems)
            .insert(
              db.RentalItemsCompanion.insert(
                id: saved.id,
                createdAt: now,
                updatedAt: now,
                rentalId: saved.rentalId,
                materialTypeId: saved.materialId,
                materialNameSnapshot: saved.materialNameSnapshot,
                pricePerDaySnapshot: saved.pricePerDaySnapshot,
                quantity: saved.quantity,
                quantityReturned: saved.quantityReturned,
              ),
            );
      }
      await database
          .into(database.auditLogs)
          .insert(
            db.AuditLogsCompanion.insert(
              id: _uuidV4(),
              createdAt: now,
              updatedAt: now,
              entityType: 'rental',
              entityId: rental.id,
              action: 'rentalCreated',
              newValue: Value(
                jsonEncode({
                  'rentalNumber': rental.rentalNumber,
                  'customerId': rental.customerId,
                  'rentedAt': rental.rentedAt.toIso8601String(),
                  'notes': rental.notes,
                  'stockOverrideConfirmed': stockOverrideConfirmed,
                  'lines': savedLines
                      .map(
                        (line) => {
                          'materialId': line.materialId,
                          'materialNameSnapshot': line.materialNameSnapshot,
                          'pricePerDaySnapshot': line.pricePerDaySnapshot,
                          'quantity': line.quantity,
                        },
                      )
                      .toList(),
                }),
              ),
              at: now,
              by: 'local-user',
            ),
          );
      return RentalDetails(
        rental: rental,
        lines: savedLines,
        customerName: customer.fullName,
      );
    });
  }

  @override
  Future<int?> availableStock(String materialId) async {
    final material = await (database.select(
      database.materialTypes,
    )..where((table) => table.id.equals(materialId))).getSingleOrNull();
    if (material == null) {
      return null;
    }
    return _availableStockInTransaction(materialId, material.totalStock);
  }

  Future<int?> _availableStockInTransaction(
    String materialId,
    int? totalStock,
  ) async {
    if (totalStock == null) {
      return null;
    }
    final rentals = await database.select(database.rentals).get();
    final activeRentalIds = rentals
        .where(
          (rental) =>
              rental.status != RentalStatus.returned.name &&
              rental.status != RentalStatus.voided.name,
        )
        .map((rental) => rental.id)
        .toSet();
    final items = await database.select(database.rentalItems).get();
    final outstanding = items
        .where(
          (item) =>
              item.materialTypeId == materialId &&
              activeRentalIds.contains(item.rentalId),
        )
        .fold<int>(
          0,
          (sum, item) => sum + item.quantity - item.quantityReturned,
        );
    return totalStock - outstanding;
  }

  Future<int> _nextRentalNumber() async {
    final rows = await database.select(database.rentals).get();
    return rows.fold<int>(0, (maxNumber, row) {
          final number = row.rentalNumber;
          return max(maxNumber, number);
        }) +
        1;
  }

  Future<RentalDetails> _details(db.RentalRow row) async {
    final customer = await (database.select(
      database.customers,
    )..where((table) => table.id.equals(row.customerId))).getSingle();
    final items = await (database.select(
      database.rentalItems,
    )..where((table) => table.rentalId.equals(row.id))).get();
    return RentalDetails(
      rental: RentalRecord(
        id: row.id,
        rentalNumber: row.rentalNumber,
        customerId: row.customerId,
        rentedAt: row.rentedAt.toUtc(),
        status: RentalStatus.values.byName(row.status),
        notes: row.notes,
        createdAt: row.createdAt.toUtc(),
        updatedAt: row.updatedAt.toUtc(),
      ),
      lines: items.map(_lineFromRow).toList(),
      customerName: customer.fullName,
    );
  }

  static RentalLine _lineFromRow(db.RentalItemRow row) => RentalLine(
    id: row.id,
    rentalId: row.rentalId,
    materialId: row.materialTypeId,
    materialNameSnapshot: row.materialNameSnapshot,
    pricePerDaySnapshot: row.pricePerDaySnapshot,
    quantity: row.quantity,
    quantityReturned: row.quantityReturned,
  );

  static String _formatNumber(int number) =>
      'R-${number.toString().padLeft(4, '0')}';
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
