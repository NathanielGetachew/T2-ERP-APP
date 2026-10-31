import 'rental_material.dart';

abstract interface class MaterialRepository {
  Stream<List<RentalMaterial>> watchAll({bool includeInactive = false});

  Future<RentalMaterial?> getById(String id);

  Future<RentalMaterial> create({
    required String category,
    required String name,
    required int pricePerDay,
    int? totalStock,
    bool isActive = true,
  });

  Future<RentalMaterial> update(RentalMaterial material);

  Future<RentalMaterial> setActive(String id, bool isActive);
}
