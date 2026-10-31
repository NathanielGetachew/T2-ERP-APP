import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart' as db;
import '../domain/material_repository.dart';
import '../domain/rental_material.dart';

class MaterialValidationException implements Exception {
  const MaterialValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

class DuplicateMaterialException extends MaterialValidationException {
  const DuplicateMaterialException()
    : super('A material with this category and name already exists.');
}

class DriftMaterialRepository implements MaterialRepository {
  DriftMaterialRepository(this.database);

  final db.AppDatabase database;

  @override
  Stream<List<RentalMaterial>> watchAll({bool includeInactive = false}) {
    final query = database.select(database.materialTypes)
      ..orderBy([
        (table) => OrderingTerm.asc(table.category),
        (table) => OrderingTerm.asc(table.name),
      ]);
    if (!includeInactive) {
      query.where((table) => table.isActive.equals(true));
    }
    return query.watch().map((rows) => rows.map(_fromRow).toList());
  }

  @override
  Future<RentalMaterial?> getById(String id) async {
    final row = await (database.select(
      database.materialTypes,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<RentalMaterial> create({
    required String category,
    required String name,
    required int pricePerDay,
    int? totalStock,
    bool isActive = true,
  }) async {
    final normalized = _validate(
      category: category,
      name: name,
      pricePerDay: pricePerDay,
      totalStock: totalStock,
    );
    final now = DateTime.now().toUtc();
    final material = RentalMaterial(
      id: _uuidV4(),
      category: normalized.category,
      name: normalized.name,
      pricePerDay: pricePerDay,
      totalStock: totalStock,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
    return database.transaction(() async {
      await _ensureUnique(material.category, material.name);
      await database.into(database.materialTypes).insert(_toInsert(material));
      await _audit(action: 'create', material: material, oldValue: null);
      return material;
    });
  }

  @override
  Future<RentalMaterial> update(RentalMaterial material) async {
    final normalized = _validate(
      category: material.category,
      name: material.name,
      pricePerDay: material.pricePerDay,
      totalStock: material.totalStock,
    );
    final old = await getById(material.id);
    if (old == null) {
      throw const MaterialValidationException('Material not found.');
    }
    final updated = material.copyWith(
      category: normalized.category,
      name: normalized.name,
      updatedAt: DateTime.now().toUtc(),
    );
    return database.transaction(() async {
      await _ensureUnique(
        updated.category,
        updated.name,
        excludingId: updated.id,
      );
      await (database.update(database.materialTypes)
            ..where((table) => table.id.equals(updated.id)))
          .write(_toUpdate(updated));
      await _audit(
        action: old.isActive == updated.isActive
            ? 'update'
            : (updated.isActive ? 'reactivate' : 'deactivate'),
        material: updated,
        oldValue: old,
      );
      return updated;
    });
  }

  @override
  Future<RentalMaterial> setActive(String id, bool isActive) async {
    final old = await getById(id);
    if (old == null) {
      throw const MaterialValidationException('Material not found.');
    }
    if (old.isActive == isActive) {
      return old;
    }
    final updated = old.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now().toUtc(),
    );
    return database.transaction(() async {
      await (database.update(
        database.materialTypes,
      )..where((table) => table.id.equals(id))).write(_toUpdate(updated));
      await _audit(
        action: isActive ? 'reactivate' : 'deactivate',
        material: updated,
        oldValue: old,
      );
      return updated;
    });
  }

  Future<void> _ensureUnique(
    String category,
    String name, {
    String? excludingId,
  }) async {
    final rows = await database.select(database.materialTypes).get();
    final duplicate = rows.any(
      (row) =>
          row.id != excludingId &&
          row.category.trim().toLowerCase() == category.toLowerCase() &&
          row.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) {
      throw const DuplicateMaterialException();
    }
  }

  Future<void> _audit({
    required String action,
    required RentalMaterial material,
    required RentalMaterial? oldValue,
  }) async {
    final now = DateTime.now().toUtc();
    await database
        .into(database.auditLogs)
        .insert(
          db.AuditLogsCompanion.insert(
            id: _uuidV4(),
            createdAt: now,
            updatedAt: now,
            entityType: 'materialType',
            entityId: material.id,
            action: action,
            oldValue: oldValue == null
                ? const Value.absent()
                : Value(jsonEncode(oldValue.toJson())),
            newValue: Value(jsonEncode(material.toJson())),
            at: now,
            by: 'local-user',
          ),
        );
  }

  static ({String category, String name}) _validate({
    required String category,
    required String name,
    required int pricePerDay,
    required int? totalStock,
  }) {
    final cleanCategory = category.trim();
    final cleanName = name.trim();
    if (cleanCategory.isEmpty) {
      throw const MaterialValidationException('Category is required.');
    }
    if (cleanName.isEmpty) {
      throw const MaterialValidationException('Name is required.');
    }
    if (pricePerDay <= 0) {
      throw const MaterialValidationException(
        'Price must be greater than zero.',
      );
    }
    if (totalStock != null && totalStock < 0) {
      throw const MaterialValidationException('Stock cannot be negative.');
    }
    return (category: cleanCategory, name: cleanName);
  }

  static RentalMaterial _fromRow(db.MaterialRow row) => RentalMaterial(
    id: row.id,
    category: row.category,
    name: row.name,
    pricePerDay: row.pricePerDay,
    totalStock: row.totalStock,
    isActive: row.isActive,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
  );

  static db.MaterialTypesCompanion _toInsert(RentalMaterial material) =>
      db.MaterialTypesCompanion.insert(
        id: material.id,
        createdAt: material.createdAt,
        updatedAt: material.updatedAt,
        category: material.category,
        name: material.name,
        pricePerDay: material.pricePerDay,
        totalStock: Value(material.totalStock),
        isActive: material.isActive,
      );

  static db.MaterialTypesCompanion _toUpdate(RentalMaterial material) =>
      db.MaterialTypesCompanion(
        updatedAt: Value(material.updatedAt),
        category: Value(material.category),
        name: Value(material.name),
        pricePerDay: Value(material.pricePerDay),
        totalStock: Value(material.totalStock),
        isActive: Value(material.isActive),
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
