import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/utils/clock_provider.dart';
import '../data/rental_repository.dart';
import '../domain/rental.dart';
import '../domain/rental_repository.dart';

final rentalRepositoryProvider = Provider<RentalRepository>((ref) {
  return DriftRentalRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  );
});

final rentalSearchQueryProvider = StateProvider<String>((ref) => '');
final rentalStatusFilterProvider = StateProvider<RentalStatus?>(
  (ref) => RentalStatus.active,
);

final rentalsProvider = StreamProvider.autoDispose<List<RentalDetails>>((
  ref,
) async* {
  final query = ref.watch(rentalSearchQueryProvider);
  final status = ref.watch(rentalStatusFilterProvider);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  yield* ref.watch(rentalRepositoryProvider).watchAll(query, status: status);
});

final activeRentalsProvider = StreamProvider.autoDispose<List<RentalDetails>>((
  ref,
) {
  return ref.watch(rentalRepositoryProvider).watchActive();
});

final rentalDetailProvider = FutureProvider.autoDispose
    .family<RentalDetails?, String>(
      (ref, id) => ref.watch(rentalRepositoryProvider).getById(id),
    );

final rentalsByCustomerProvider = StreamProvider.autoDispose
    .family<List<RentalDetails>, String>(
      (ref, customerId) =>
          ref.watch(rentalRepositoryProvider).watchByCustomer(customerId),
    );

final rentalEditorProvider =
    AsyncNotifierProvider.autoDispose<RentalEditorController, void>(
      RentalEditorController.new,
    );

class RentalEditorController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<RentalDetails> createRental({
    required String customerId,
    required List<RentalLineDraft> lines,
    String? notes,
    bool stockOverrideConfirmed = false,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(rentalRepositoryProvider)
          .createRental(
            customerId: customerId,
            lines: lines,
            notes: notes,
            stockOverrideConfirmed: stockOverrideConfirmed,
          );
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
