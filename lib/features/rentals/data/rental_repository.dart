import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart' as db;
import '../../../core/utils/clock.dart';
import '../../../core/utils/uuid.dart';
import '../../billing/rental_billing.dart';
import '../domain/rental.dart';
import '../domain/rental_repository.dart';

export '../domain/rental_repository.dart';

class DriftRentalRepository implements RentalRepository {
  DriftRentalRepository(
    this.database, {
    this.clock = const SystemClock(),
    this.localOffset,
  });

  final db.AppDatabase database;
  final Clock clock;
  final Duration? localOffset;

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
      if (status == RentalStatus.active) {
        statement.where(
          (table) =>
              table.status.equals(RentalStatus.active.name) |
              table.status.equals(RentalStatus.partiallyReturned.name),
        );
      } else {
        statement.where((table) => table.status.equals(status.name));
      }
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
        id: uuidV4(),
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
          id: uuidV4(),
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
              id: uuidV4(),
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

  @override
  Future<ReturnReceipt> recordReturn(
    String rentalId,
    List<ReturnLineInput> lines,
    String? note,
  ) async {
    if (lines.isEmpty) {
      throw const RentalValidationException(
        'At least one return line is required.',
      );
    }
    final lineIds = <String>{};
    for (final line in lines) {
      if (line.quantity < 1) {
        throw const RentalValidationException(
          'Each returned quantity must be at least 1.',
        );
      }
      if (!lineIds.add(line.rentalItemId)) {
        throw const RentalValidationException(
          'A rental line may be returned only once per event.',
        );
      }
    }

    return database.transaction(() async {
      final rentalRow = await (database.select(
        database.rentals,
      )..where((table) => table.id.equals(rentalId))).getSingleOrNull();
      if (rentalRow == null) {
        throw const RentalValidationException('Rental not found.');
      }
      if (rentalRow.status == RentalStatus.voided.name) {
        throw const RentalValidationException(
          'A voided rental cannot be returned.',
        );
      }
      if (rentalRow.status == RentalStatus.returned.name) {
        throw const RentalValidationException(
          'A fully returned rental cannot be returned again.',
        );
      }

      final itemRows = await (database.select(
        database.rentalItems,
      )..where((table) => table.rentalId.equals(rentalId))).get();
      final itemsById = {for (final item in itemRows) item.id: item};
      for (final line in lines) {
        final item = itemsById[line.rentalItemId];
        if (item == null) {
          throw const RentalValidationException(
            'Every return line must belong to the rental.',
          );
        }
        final outstanding = item.quantity - item.quantityReturned;
        if (line.quantity > outstanding) {
          throw RentalValidationException(
            'Cannot return more than the outstanding quantity for '
            '${item.materialNameSnapshot}.',
          );
        }
      }

      final returnedAt = clock.now().toUtc();
      final days = billableDays(
        rentalRow.rentedAt,
        returnedAt,
        localOffset: localOffset ?? DateTime.now().timeZoneOffset,
      );
      final events = <ReturnEventRecord>[];
      final oldQuantities = <Map<String, Object?>>[];
      for (final line in lines) {
        final item = itemsById[line.rentalItemId]!;
        final amount = returnLineAmount(
          quantity: line.quantity,
          pricePerDaySnapshot: item.pricePerDaySnapshot,
          days: days,
        );
        final event = ReturnEventRecord(
          id: uuidV4(),
          rentalId: rentalId,
          rentalItemId: item.id,
          quantity: line.quantity,
          returnedAt: returnedAt,
          billableDays: days,
          amount: amount,
          pricePerDaySnapshot: item.pricePerDaySnapshot,
          conditionNote: note == null || note.trim().isEmpty
              ? null
              : note.trim(),
          createdAt: returnedAt,
        );
        events.add(event);
        oldQuantities.add({
          'rentalItemId': item.id,
          'quantityReturned': item.quantityReturned,
        });
        await database
            .into(database.returnEvents)
            .insert(
              db.ReturnEventsCompanion.insert(
                id: event.id,
                createdAt: returnedAt,
                updatedAt: returnedAt,
                rentalId: Value(event.rentalId),
                rentalItemId: event.rentalItemId,
                quantity: event.quantity,
                returnedAt: event.returnedAt,
                conditionNote: Value(event.conditionNote),
                billableDays: event.billableDays,
                amount: event.amount,
                pricePerDaySnapshot: Value(event.pricePerDaySnapshot),
              ),
            );
        await (database.update(
          database.rentalItems,
        )..where((table) => table.id.equals(item.id))).write(
          db.RentalItemsCompanion(
            quantityReturned: Value(item.quantityReturned + line.quantity),
            updatedAt: Value(returnedAt),
          ),
        );
      }

      final updatedItems = await (database.select(
        database.rentalItems,
      )..where((table) => table.rentalId.equals(rentalId))).get();
      final isFullyReturned = updatedItems.every(
        (item) => item.quantityReturned >= item.quantity,
      );
      final status = isFullyReturned
          ? RentalStatus.returned
          : RentalStatus.partiallyReturned;
      await (database.update(
        database.rentals,
      )..where((table) => table.id.equals(rentalId))).write(
        db.RentalsCompanion(
          status: Value(status.name),
          updatedAt: Value(returnedAt),
        ),
      );

      final total = events.fold<int>(0, (sum, event) => sum + event.amount);
      await database
          .into(database.auditLogs)
          .insert(
            db.AuditLogsCompanion.insert(
              id: uuidV4(),
              createdAt: returnedAt,
              updatedAt: returnedAt,
              entityType: 'rental',
              entityId: rentalId,
              action: 'returnRecorded',
              oldValue: Value(
                jsonEncode({
                  'status': rentalRow.status,
                  'lines': oldQuantities,
                }),
              ),
              newValue: Value(
                jsonEncode({
                  'rentalNumber': rentalRow.rentalNumber,
                  'returnedAt': returnedAt.toIso8601String(),
                  'note': note,
                  'status': status.name,
                  'lines': events
                      .map(
                        (event) => {
                          'rentalItemId': event.rentalItemId,
                          'quantity': event.quantity,
                          'days': event.billableDays,
                          'amount': event.amount,
                        },
                      )
                      .toList(),
                  'total': total,
                }),
              ),
              at: returnedAt,
              by: 'local-user',
            ),
          );

      final customer = await (database.select(
        database.customers,
      )..where((table) => table.id.equals(rentalRow.customerId))).getSingle();
      final rental = _rentalFromRow(
        rentalRow,
        status: status,
        updatedAt: returnedAt,
      );
      return ReturnReceipt(
        rental: rental,
        customerName: customer.fullName,
        events: events,
        total: total,
        status: status,
        lines: updatedItems.map(_lineFromRow).toList(),
        remainingOutstanding: updatedItems
            .map(_lineFromRow)
            .where((line) => line.outstandingQuantity > 0)
            .toList(),
      );
    });
  }

  @override
  Future<CustomerHeldItems> getCustomerHeldItems(String customerId) async {
    final customer = await (database.select(
      database.customers,
    )..where((t) => t.id.equals(customerId))).getSingleOrNull();
    final customerName = customer?.fullName ?? '';

    final customerRentals =
        await (database.select(database.rentals)
              ..where(
                (t) =>
                    t.customerId.equals(customerId) &
                    (t.status.equals(RentalStatus.active.name) |
                        t.status.equals(RentalStatus.partiallyReturned.name)),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.rentedAt),
                (t) => OrderingTerm.asc(t.rentalNumber),
              ]))
            .get();

    if (customerRentals.isEmpty) {
      return CustomerHeldItems(
        customerId: customerId,
        customerName: customerName,
        materials: const [],
      );
    }

    final rentalMap = {for (final r in customerRentals) r.id: r};
    final rentalIds = rentalMap.keys.toList();
    final itemRows = await (database.select(
      database.rentalItems,
    )..where((t) => t.rentalId.isIn(rentalIds))).get();

    final nowUtc = clock.now().toUtc();
    final offset = localOffset ?? DateTime.now().timeZoneOffset;

    final linesByMaterial = <String, List<CustomerHeldRentalLine>>{};
    final materialNames = <String, String>{};

    for (final item in itemRows) {
      final outstanding = item.quantity - item.quantityReturned;
      if (outstanding > 0) {
        final rental = rentalMap[item.rentalId]!;
        final daysSoFar = billableDays(
          rental.rentedAt,
          nowUtc,
          localOffset: offset,
        );
        final line = CustomerHeldRentalLine(
          rentalId: rental.id,
          rentalNumber: rental.rentalNumber,
          rentalItemId: item.id,
          materialId: item.materialTypeId,
          materialName: item.materialNameSnapshot,
          rentedAt: rental.rentedAt.toUtc(),
          outstandingQuantity: outstanding,
          daysSoFar: daysSoFar,
          pricePerDaySnapshot: item.pricePerDaySnapshot,
        );
        linesByMaterial.putIfAbsent(item.materialTypeId, () => []).add(line);
        materialNames[item.materialTypeId] = item.materialNameSnapshot;
      }
    }

    final materials = <CustomerHeldMaterial>[];
    for (final entry in linesByMaterial.entries) {
      // Sort lines oldest first: rentedAt asc, then rentalNumber asc
      entry.value.sort((a, b) {
        final cmp = a.rentedAt.compareTo(b.rentedAt);
        if (cmp != 0) return cmp;
        return a.rentalNumber.compareTo(b.rentalNumber);
      });
      final totalOutstanding = entry.value.fold<int>(
        0,
        (sum, l) => sum + l.outstandingQuantity,
      );
      materials.add(
        CustomerHeldMaterial(
          materialId: entry.key,
          materialName: materialNames[entry.key] ?? '',
          totalOutstanding: totalOutstanding,
          lines: entry.value,
        ),
      );
    }

    materials.sort(
      (a, b) =>
          a.materialName.toLowerCase().compareTo(b.materialName.toLowerCase()),
    );

    return CustomerHeldItems(
      customerId: customerId,
      customerName: customerName,
      materials: materials,
    );
  }

  @override
  Stream<CustomerHeldItems> watchCustomerHeldItems(String customerId) {
    return database
        .select(database.rentalItems)
        .watch()
        .asyncMap((_) => getCustomerHeldItems(customerId));
  }

  @override
  Stream<List<CustomerHoldingItemsSummary>> watchCustomersHoldingItems({
    String query = '',
  }) {
    return database
        .select(database.rentalItems)
        .watch()
        .asyncMap((_) => _getCustomersHoldingItems(query: query));
  }

  Future<List<CustomerHoldingItemsSummary>> _getCustomersHoldingItems({
    String query = '',
  }) async {
    final activeRentals =
        await (database.select(database.rentals)..where(
              (t) =>
                  t.status.equals(RentalStatus.active.name) |
                  t.status.equals(RentalStatus.partiallyReturned.name),
            ))
            .get();
    if (activeRentals.isEmpty) return const [];

    final rentalIds = activeRentals.map((r) => r.id).toSet();
    final items = await (database.select(
      database.rentalItems,
    )..where((t) => t.rentalId.isIn(rentalIds))).get();

    final rentalToCustomer = {
      for (final r in activeRentals) r.id: r.customerId,
    };
    final unitsPerCustomer = <String, int>{};
    for (final item in items) {
      final outstanding = item.quantity - item.quantityReturned;
      if (outstanding > 0) {
        final custId = rentalToCustomer[item.rentalId];
        if (custId != null) {
          unitsPerCustomer[custId] =
              (unitsPerCustomer[custId] ?? 0) + outstanding;
        }
      }
    }

    if (unitsPerCustomer.isEmpty) return const [];

    final customers = await (database.select(
      database.customers,
    )..where((t) => t.id.isIn(unitsPerCustomer.keys))).get();

    final normalized = query.toLowerCase().trim();
    final results = <CustomerHoldingItemsSummary>[];
    for (final c in customers) {
      final total = unitsPerCustomer[c.id] ?? 0;
      if (total <= 0) continue;
      final matchesQuery =
          normalized.isEmpty ||
          c.fullName.toLowerCase().contains(normalized) ||
          c.phone.toLowerCase().contains(normalized) ||
          c.address.toLowerCase().contains(normalized);
      if (matchesQuery) {
        results.add(
          CustomerHoldingItemsSummary(
            customerId: c.id,
            customerName: c.fullName,
            phone: c.phone,
            address: c.address,
            totalUnitsHeld: total,
          ),
        );
      }
    }
    results.sort(
      (a, b) =>
          a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase()),
    );
    return results;
  }

  @override
  Future<CustomerReturnReceipt> recordCustomerReturn({
    required String customerId,
    required List<ReturnAllocationLine> allocations,
    String? note,
  }) async {
    final activeAllocations = allocations.where((a) => a.quantity > 0).toList();
    if (activeAllocations.isEmpty) {
      throw const RentalValidationException(
        'At least one return line is required.',
      );
    }

    return database.transaction(() async {
      final customer = await (database.select(
        database.customers,
      )..where((t) => t.id.equals(customerId))).getSingleOrNull();
      if (customer == null) {
        throw const RentalValidationException('Customer not found.');
      }

      final batchId = uuidV4();
      final returnedAt = clock.now().toUtc();
      final offset = localOffset ?? DateTime.now().timeZoneOffset;

      // Group allocations by rentalId
      final allocationsByRental = <String, List<ReturnAllocationLine>>{};
      for (final alloc in activeAllocations) {
        if (alloc.quantity < 1) {
          throw const RentalValidationException(
            'Each returned quantity must be at least 1.',
          );
        }
        allocationsByRental.putIfAbsent(alloc.rentalId, () => []).add(alloc);
      }

      final allEvents = <ReturnEventRecord>[];
      final resolvedAllocations = <ReturnAllocationLine>[];
      var grandTotal = 0;

      for (final entry in allocationsByRental.entries) {
        final rentalId = entry.key;
        final rentalAllocations = entry.value;

        final rentalRow = await (database.select(
          database.rentals,
        )..where((t) => t.id.equals(rentalId))).getSingleOrNull();
        if (rentalRow == null) {
          throw const RentalValidationException('Rental not found.');
        }
        if (rentalRow.status == RentalStatus.voided.name) {
          throw const RentalValidationException(
            'A voided rental cannot be returned.',
          );
        }
        if (rentalRow.status == RentalStatus.returned.name) {
          throw const RentalValidationException(
            'A fully returned rental cannot be returned again.',
          );
        }

        final itemRows = await (database.select(
          database.rentalItems,
        )..where((t) => t.rentalId.equals(rentalId))).get();
        final itemsById = {for (final item in itemRows) item.id: item};

        final days = billableDays(
          rentalRow.rentedAt,
          returnedAt,
          localOffset: offset,
        );

        final rentalEvents = <ReturnEventRecord>[];
        final oldQuantities = <Map<String, Object?>>[];
        var rentalTotal = 0;

        for (final alloc in rentalAllocations) {
          final item = itemsById[alloc.rentalItemId];
          if (item == null) {
            throw const RentalValidationException(
              'Rental line does not belong to the rental.',
            );
          }
          final outstanding = item.quantity - item.quantityReturned;
          if (alloc.quantity > outstanding) {
            throw RentalValidationException(
              'Cannot return more than the outstanding quantity for '
              '${item.materialNameSnapshot}.',
            );
          }

          final amount = returnLineAmount(
            quantity: alloc.quantity,
            pricePerDaySnapshot: item.pricePerDaySnapshot,
            days: days,
          );

          final event = ReturnEventRecord(
            id: uuidV4(),
            rentalId: rentalId,
            rentalItemId: item.id,
            quantity: alloc.quantity,
            returnedAt: returnedAt,
            billableDays: days,
            amount: amount,
            pricePerDaySnapshot: item.pricePerDaySnapshot,
            conditionNote: note == null || note.trim().isEmpty
                ? null
                : note.trim(),
            createdAt: returnedAt,
            returnBatchId: batchId,
          );
          rentalEvents.add(event);
          allEvents.add(event);
          rentalTotal += amount;
          grandTotal += amount;

          oldQuantities.add({
            'rentalItemId': item.id,
            'quantityReturned': item.quantityReturned,
          });

          await database
              .into(database.returnEvents)
              .insert(
                db.ReturnEventsCompanion.insert(
                  id: event.id,
                  createdAt: returnedAt,
                  updatedAt: returnedAt,
                  rentalId: Value(event.rentalId),
                  rentalItemId: event.rentalItemId,
                  quantity: event.quantity,
                  returnedAt: event.returnedAt,
                  conditionNote: Value(event.conditionNote),
                  billableDays: event.billableDays,
                  amount: event.amount,
                  pricePerDaySnapshot: Value(event.pricePerDaySnapshot),
                  returnBatchId: Value(batchId),
                ),
              );

          await (database.update(
            database.rentalItems,
          )..where((t) => t.id.equals(item.id))).write(
            db.RentalItemsCompanion(
              quantityReturned: Value(item.quantityReturned + alloc.quantity),
              updatedAt: Value(returnedAt),
            ),
          );

          resolvedAllocations.add(
            ReturnAllocationLine(
              rentalId: rentalId,
              rentalNumber: rentalRow.rentalNumber,
              rentalItemId: item.id,
              materialId: item.materialTypeId,
              materialName: item.materialNameSnapshot,
              rentedAt: rentalRow.rentedAt.toUtc(),
              quantity: alloc.quantity,
              pricePerDaySnapshot: item.pricePerDaySnapshot,
              days: days,
              amount: amount,
            ),
          );
        }

        // Update rental status
        final updatedItems = await (database.select(
          database.rentalItems,
        )..where((t) => t.rentalId.equals(rentalId))).get();
        final isFullyReturned = updatedItems.every(
          (item) => item.quantityReturned >= item.quantity,
        );
        final status = isFullyReturned
            ? RentalStatus.returned
            : RentalStatus.partiallyReturned;

        await (database.update(
          database.rentals,
        )..where((t) => t.id.equals(rentalId))).write(
          db.RentalsCompanion(
            status: Value(status.name),
            updatedAt: Value(returnedAt),
          ),
        );

        // Per-rental audit log
        await database
            .into(database.auditLogs)
            .insert(
              db.AuditLogsCompanion.insert(
                id: uuidV4(),
                createdAt: returnedAt,
                updatedAt: returnedAt,
                entityType: 'rental',
                entityId: rentalId,
                action: 'returnRecorded',
                oldValue: Value(
                  jsonEncode({
                    'status': rentalRow.status,
                    'lines': oldQuantities,
                  }),
                ),
                newValue: Value(
                  jsonEncode({
                    'rentalNumber': rentalRow.rentalNumber,
                    'returnedAt': returnedAt.toIso8601String(),
                    'note': note,
                    'status': status.name,
                    'returnBatchId': batchId,
                    'lines': rentalEvents
                        .map(
                          (e) => {
                            'rentalItemId': e.rentalItemId,
                            'quantity': e.quantity,
                            'days': e.billableDays,
                            'amount': e.amount,
                          },
                        )
                        .toList(),
                    'total': rentalTotal,
                  }),
                ),
                at: returnedAt,
                by: 'local-user',
              ),
            );
      }

      // Batch-level audit log
      await database
          .into(database.auditLogs)
          .insert(
            db.AuditLogsCompanion.insert(
              id: uuidV4(),
              createdAt: returnedAt,
              updatedAt: returnedAt,
              entityType: 'returnBatch',
              entityId: batchId,
              action: 'returnBatchRecorded',
              newValue: Value(
                jsonEncode({
                  'batchId': batchId,
                  'customerId': customerId,
                  'returnedAt': returnedAt.toIso8601String(),
                  'note': note,
                  'total': grandTotal,
                  'grandTotal': grandTotal,
                  'eventCount': allEvents.length,
                  'allocations': resolvedAllocations
                      .map(
                        (a) => {
                          'rentalId': a.rentalId,
                          'rentalNumber': a.rentalNumber,
                          'rentalItemId': a.rentalItemId,
                          'materialId': a.materialId,
                          'materialName': a.materialName,
                          'quantity': a.quantity,
                          'days': a.days,
                          'pricePerDaySnapshot': a.pricePerDaySnapshot,
                          'amount': a.amount,
                        },
                      )
                      .toList(),
                }),
              ),
              at: returnedAt,
              by: 'local-user',
            ),
          );

      final remainingHeld = await getCustomerHeldItems(customerId);

      return CustomerReturnReceipt(
        batchId: batchId,
        customerId: customerId,
        customerName: customer.fullName,
        returnedAt: returnedAt,
        allocations: resolvedAllocations,
        totalAmount: grandTotal,
        remainingHeld: remainingHeld.materials,
        events: allEvents,
      );
    });
  }

  @override
  Future<CustomerReturnReceipt?> getReturnBatchSummary(String batchId) async {
    final events =
        await (database.select(database.returnEvents)
              ..where((t) => t.returnBatchId.equals(batchId))
              ..orderBy([(t) => OrderingTerm.asc(t.returnedAt)]))
            .get();
    if (events.isEmpty) return null;

    final firstRentalId = events.first.rentalId;
    final firstRental = await (database.select(
      database.rentals,
    )..where((t) => t.id.equals(firstRentalId))).getSingleOrNull();
    if (firstRental == null) return null;

    final customer = await (database.select(
      database.customers,
    )..where((t) => t.id.equals(firstRental.customerId))).getSingleOrNull();
    if (customer == null) return null;

    final rentalIds = events.map((e) => e.rentalId).toSet();
    final rentals = await (database.select(
      database.rentals,
    )..where((t) => t.id.isIn(rentalIds))).get();
    final rentalMap = {for (final r in rentals) r.id: r};

    final itemIds = events.map((e) => e.rentalItemId).toSet();
    final items = await (database.select(
      database.rentalItems,
    )..where((t) => t.id.isIn(itemIds))).get();
    final itemMap = {for (final i in items) i.id: i};

    final allocations = <ReturnAllocationLine>[];
    var grandTotal = 0;

    for (final e in events) {
      final rental = rentalMap[e.rentalId];
      final item = itemMap[e.rentalItemId];
      if (rental != null && item != null) {
        allocations.add(
          ReturnAllocationLine(
            rentalId: rental.id,
            rentalNumber: rental.rentalNumber,
            rentalItemId: item.id,
            materialId: item.materialTypeId,
            materialName: item.materialNameSnapshot,
            rentedAt: rental.rentedAt.toUtc(),
            quantity: e.quantity,
            pricePerDaySnapshot: e.pricePerDaySnapshot,
            days: e.billableDays,
            amount: e.amount,
          ),
        );
        if (e.voidedAt == null) {
          grandTotal += e.amount;
        }
      }
    }

    final held = await getCustomerHeldItems(customer.id);

    return CustomerReturnReceipt(
      batchId: batchId,
      customerId: customer.id,
      customerName: customer.fullName,
      returnedAt: events.first.returnedAt.toUtc(),
      allocations: allocations,
      totalAmount: grandTotal,
      remainingHeld: held.materials,
      events: events.map(_eventFromRow).toList(),
    );
  }

  @override
  Stream<List<ReturnEventRecord>> watchReturnEvents(String rentalId) {
    return (database.select(database.returnEvents)
          ..where((table) => table.rentalId.equals(rentalId))
          ..orderBy([(table) => OrderingTerm.asc(table.returnedAt)]))
        .watch()
        .map((rows) => rows.map(_eventFromRow).toList());
  }

  @override
  Future<List<ReturnEventRecord>> getReturnEvents(String rentalId) async {
    final rows =
        await (database.select(database.returnEvents)
              ..where((table) => table.rentalId.equals(rentalId))
              ..orderBy([(table) => OrderingTerm.asc(table.returnedAt)]))
            .get();
    return rows.map(_eventFromRow).toList();
  }

  @override
  Future<int> monthlyRevenue(int year, int month) async {
    final rentals = await database.select(database.rentals).get();
    final validRentalIds = rentals
        .where((rental) => rental.status != RentalStatus.voided.name)
        .map((rental) => rental.id)
        .toSet();
    final events = await database.select(database.returnEvents).get();
    return events
        .where((event) {
          final local = event.returnedAt.toLocal();
          return validRentalIds.contains(event.rentalId) &&
              event.voidedAt == null &&
              local.year == year &&
              local.month == month;
        })
        .fold<int>(0, (sum, event) => sum + event.amount);
  }

  @override
  Future<void> voidReturn(String returnEventId, String reason) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.length < 5) {
      throw const RentalValidationException(
        'A void reason must be at least 5 characters.',
      );
    }
    await database.transaction(() async {
      final event = await (database.select(
        database.returnEvents,
      )..where((table) => table.id.equals(returnEventId))).getSingleOrNull();
      if (event == null) {
        throw const RentalValidationException('Return event not found.');
      }
      if (event.voidedAt != null) {
        throw const RentalValidationException('This return is already voided.');
      }
      final rental = await (database.select(
        database.rentals,
      )..where((table) => table.id.equals(event.rentalId))).getSingleOrNull();
      if (rental == null) {
        throw const RentalValidationException('Rental not found.');
      }
      if (rental.voidedAt != null ||
          rental.status == RentalStatus.voided.name) {
        throw const RentalValidationException(
          'A return on a voided rental cannot be changed.',
        );
      }
      final now = clock.now().toUtc();
      await (database.update(
        database.returnEvents,
      )..where((table) => table.id.equals(returnEventId))).write(
        db.ReturnEventsCompanion(
          voidedAt: Value(now),
          voidReason: Value(normalizedReason),
          updatedAt: Value(now),
        ),
      );
      final item = await (database.select(
        database.rentalItems,
      )..where((table) => table.id.equals(event.rentalItemId))).getSingle();
      final newQuantityReturned = item.quantityReturned - event.quantity;
      await (database.update(
        database.rentalItems,
      )..where((table) => table.id.equals(item.id))).write(
        db.RentalItemsCompanion(
          quantityReturned: Value(newQuantityReturned),
          updatedAt: Value(now),
        ),
      );
      final items = await (database.select(
        database.rentalItems,
      )..where((table) => table.rentalId.equals(rental.id))).get();
      final returned = items.fold<int>(
        0,
        (sum, line) => sum + line.quantityReturned,
      );
      final total = items.fold<int>(0, (sum, line) => sum + line.quantity);
      final newStatus = returned == 0
          ? RentalStatus.active
          : returned >= total
          ? RentalStatus.returned
          : RentalStatus.partiallyReturned;
      await (database.update(
        database.rentals,
      )..where((table) => table.id.equals(rental.id))).write(
        db.RentalsCompanion(
          status: Value(newStatus.name),
          updatedAt: Value(now),
        ),
      );
      await database
          .into(database.auditLogs)
          .insert(
            db.AuditLogsCompanion.insert(
              id: uuidV4(),
              createdAt: now,
              updatedAt: now,
              entityType: 'rental',
              entityId: rental.id,
              action: 'returnVoided',
              oldValue: Value(
                jsonEncode({
                  'status': rental.status,
                  'quantityReturned': item.quantityReturned,
                }),
              ),
              newValue: Value(
                jsonEncode({
                  'rentalNumber': rental.rentalNumber,
                  'returnEventId': event.id,
                  'quantity': event.quantity,
                  'days': event.billableDays,
                  'amount': event.amount,
                  'reason': normalizedReason,
                  'oldStatus': rental.status,
                  'newStatus': newStatus.name,
                }),
              ),
              at: now,
              by: 'local-user',
            ),
          );
    });
  }

  @override
  Future<void> voidRental(String rentalId, String reason) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.length < 5) {
      throw const RentalValidationException(
        'A void reason must be at least 5 characters.',
      );
    }
    await database.transaction(() async {
      final rental = await (database.select(
        database.rentals,
      )..where((table) => table.id.equals(rentalId))).getSingleOrNull();
      if (rental == null) {
        throw const RentalValidationException('Rental not found.');
      }
      if (rental.voidedAt != null ||
          rental.status == RentalStatus.voided.name) {
        throw const RentalValidationException('This rental is already voided.');
      }
      final events =
          await (database.select(database.returnEvents)..where(
                (table) =>
                    table.rentalId.equals(rentalId) & table.voidedAt.isNull(),
              ))
              .get();
      if (events.isNotEmpty) {
        throw const RentalValidationException(
          'Void all returns before voiding this rental.',
        );
      }
      final lines = await (database.select(
        database.rentalItems,
      )..where((table) => table.rentalId.equals(rentalId))).get();
      final now = clock.now().toUtc();
      await (database.update(
        database.rentals,
      )..where((table) => table.id.equals(rentalId))).write(
        db.RentalsCompanion(
          status: Value(RentalStatus.voided.name),
          voidedAt: Value(now),
          voidReason: Value(normalizedReason),
          updatedAt: Value(now),
        ),
      );
      await database
          .into(database.auditLogs)
          .insert(
            db.AuditLogsCompanion.insert(
              id: uuidV4(),
              createdAt: now,
              updatedAt: now,
              entityType: 'rental',
              entityId: rental.id,
              action: 'rentalVoided',
              newValue: Value(
                jsonEncode({
                  'rentalNumber': rental.rentalNumber,
                  'customerId': rental.customerId,
                  'rentedAt': rental.rentedAt.toIso8601String(),
                  'oldStatus': rental.status,
                  'newStatus': RentalStatus.voided.name,
                  'reason': normalizedReason,
                  'lines': lines
                      .map(
                        (line) => {
                          'rentalItemId': line.id,
                          'materialName': line.materialNameSnapshot,
                          'quantity': line.quantity,
                          'pricePerDaySnapshot': line.pricePerDaySnapshot,
                        },
                      )
                      .toList(),
                }),
              ),
              at: now,
              by: 'local-user',
            ),
          );
    });
  }

  @override
  Future<List<AuditHistoryEntry>> getAuditHistory(String rentalId) async {
    final rows =
        await (database.select(database.auditLogs)
              ..where((table) => table.entityId.equals(rentalId))
              ..orderBy([(table) => OrderingTerm.desc(table.at)]))
            .get();
    return rows
        .map(
          (row) => AuditHistoryEntry(
            action: row.action,
            at: row.at.toUtc(),
            description: row.action,
          ),
        )
        .toList();
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
      rental: _rentalFromRow(row),
      lines: items.map(_lineFromRow).toList(),
      customerName: customer.fullName,
    );
  }

  static RentalRecord _rentalFromRow(
    db.RentalRow row, {
    RentalStatus? status,
    DateTime? updatedAt,
  }) => RentalRecord(
    id: row.id,
    rentalNumber: row.rentalNumber,
    customerId: row.customerId,
    rentedAt: row.rentedAt.toUtc(),
    status: status ?? RentalStatus.values.byName(row.status),
    notes: row.notes,
    createdAt: row.createdAt.toUtc(),
    updatedAt: updatedAt ?? row.updatedAt.toUtc(),
    voidedAt: row.voidedAt?.toUtc(),
    voidReason: row.voidReason,
  );

  static RentalLine _lineFromRow(db.RentalItemRow row) => RentalLine(
    id: row.id,
    rentalId: row.rentalId,
    materialId: row.materialTypeId,
    materialNameSnapshot: row.materialNameSnapshot,
    pricePerDaySnapshot: row.pricePerDaySnapshot,
    quantity: row.quantity,
    quantityReturned: row.quantityReturned,
  );

  static ReturnEventRecord _eventFromRow(db.ReturnEventRow row) =>
      ReturnEventRecord(
        id: row.id,
        rentalId: row.rentalId,
        rentalItemId: row.rentalItemId,
        quantity: row.quantity,
        returnedAt: row.returnedAt.toUtc(),
        billableDays: row.billableDays,
        amount: row.amount,
        pricePerDaySnapshot: row.pricePerDaySnapshot,
        conditionNote: row.conditionNote,
        createdAt: row.createdAt.toUtc(),
        returnBatchId: row.returnBatchId,
        voidedAt: row.voidedAt?.toUtc(),
        voidReason: row.voidReason,
      );

  static String _formatNumber(int number) =>
      'R-${number.toString().padLeft(4, '0')}';
}
