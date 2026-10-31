import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/material_repository.dart';
import '../domain/material_repository.dart';
import '../domain/rental_material.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return DriftMaterialRepository(ref.watch(databaseProvider));
});

final showInactiveMaterialsProvider = StateProvider<bool>((ref) => false);

final materialsProvider = StreamProvider.autoDispose<List<RentalMaterial>>((
  ref,
) {
  return ref
      .watch(materialRepositoryProvider)
      .watchAll(includeInactive: ref.watch(showInactiveMaterialsProvider));
});

final materialEditorProvider =
    AsyncNotifierProvider.autoDispose<MaterialEditorController, void>(
      MaterialEditorController.new,
    );

class MaterialEditorController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<RentalMaterial> create({
    required String category,
    required String name,
    required int pricePerDay,
    int? totalStock,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(materialRepositoryProvider)
          .create(
            category: category,
            name: name,
            pricePerDay: pricePerDay,
            totalStock: totalStock,
          );
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<RentalMaterial> updateMaterial(RentalMaterial material) async {
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(materialRepositoryProvider)
          .update(material);
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
