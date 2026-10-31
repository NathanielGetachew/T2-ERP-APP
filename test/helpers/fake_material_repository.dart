import 'package:t2_rental/features/materials/data/material_repository.dart';
import 'package:t2_rental/features/materials/domain/material_repository.dart';
import 'package:t2_rental/features/materials/domain/rental_material.dart';

class FakeMaterialRepository implements MaterialRepository {
  FakeMaterialRepository([Iterable<RentalMaterial> initial = const []])
    : _materials = initial.toList();

  final List<RentalMaterial> _materials;
  final List<RentalMaterial> createCalls = [];
  int _nextId = 0;

  @override
  Stream<List<RentalMaterial>> watchAll({bool includeInactive = false}) {
    return Stream.value(_visible(includeInactive));
  }

  @override
  Future<RentalMaterial?> getById(String id) async {
    for (final material in _materials) {
      if (material.id == id) {
        return material;
      }
    }
    return null;
  }

  @override
  Future<RentalMaterial> create({
    required String category,
    required String name,
    required int pricePerDay,
    int? totalStock,
    bool isActive = true,
  }) async {
    final cleanCategory = category.trim();
    final cleanName = name.trim();
    _validate(
      category: cleanCategory,
      name: cleanName,
      pricePerDay: pricePerDay,
      totalStock: totalStock,
    );
    _ensureUnique(cleanCategory, cleanName);
    final now = DateTime.now().toUtc();
    final material = RentalMaterial(
      id: 'fake-${_nextId++}',
      category: cleanCategory,
      name: cleanName,
      pricePerDay: pricePerDay,
      totalStock: totalStock,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
    _materials.add(material);
    createCalls.add(material);
    return material;
  }

  @override
  Future<RentalMaterial> update(RentalMaterial material) async {
    _validate(
      category: material.category,
      name: material.name,
      pricePerDay: material.pricePerDay,
      totalStock: material.totalStock,
    );
    final index = _materials.indexWhere((item) => item.id == material.id);
    if (index < 0) {
      throw const MaterialValidationException('Material not found.');
    }
    _ensureUnique(
      material.category.trim(),
      material.name.trim(),
      excludingId: material.id,
    );
    final updated = material.copyWith(
      category: material.category.trim(),
      name: material.name.trim(),
      updatedAt: DateTime.now().toUtc(),
    );
    _materials[index] = updated;
    return updated;
  }

  @override
  Future<RentalMaterial> setActive(String id, bool isActive) async {
    final material = await getById(id);
    if (material == null) {
      throw const MaterialValidationException('Material not found.');
    }
    final updated = material.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now().toUtc(),
    );
    _materials[_materials.indexOf(material)] = updated;
    return updated;
  }

  List<RentalMaterial> _visible(bool includeInactive) {
    final visible = includeInactive
        ? List<RentalMaterial>.of(_materials)
        : _materials.where((material) => material.isActive).toList();
    visible.sort((a, b) {
      final category = a.category.compareTo(b.category);
      return category == 0 ? a.name.compareTo(b.name) : category;
    });
    return visible;
  }

  void _ensureUnique(String category, String name, {String? excludingId}) {
    final duplicate = _materials.any(
      (material) =>
          material.id != excludingId &&
          material.category.trim().toLowerCase() == category.toLowerCase() &&
          material.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) {
      throw const DuplicateMaterialException();
    }
  }

  void _validate({
    required String category,
    required String name,
    required int pricePerDay,
    required int? totalStock,
  }) {
    if (category.isEmpty) {
      throw const MaterialValidationException('Category is required.');
    }
    if (name.isEmpty) {
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
  }
}
