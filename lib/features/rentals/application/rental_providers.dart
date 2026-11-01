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

final returnEventsProvider = StreamProvider.autoDispose
    .family<List<ReturnEventRecord>, String>(
      (ref, rentalId) =>
          ref.watch(rentalRepositoryProvider).watchReturnEvents(rentalId),
    );

final monthlyRevenueProvider = FutureProvider.autoDispose
    .family<int, ({int year, int month})>((ref, period) {
      return ref
          .watch(rentalRepositoryProvider)
          .monthlyRevenue(period.year, period.month);
    });

final rentalEditorProvider =
    AsyncNotifierProvider.autoDispose<RentalEditorController, void>(
      RentalEditorController.new,
    );

final returnControllerProvider =
    AsyncNotifierProvider.autoDispose<ReturnController, void>(
      ReturnController.new,
    );

final rentalVoidControllerProvider =
    AsyncNotifierProvider.autoDispose<RentalVoidController, void>(
      RentalVoidController.new,
    );

final rentalAuditHistoryProvider = FutureProvider.autoDispose
    .family<List<AuditHistoryEntry>, String>(
      (ref, rentalId) =>
          ref.watch(rentalRepositoryProvider).getAuditHistory(rentalId),
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

class ReturnController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ReturnReceipt> recordReturn({
    required String rentalId,
    required List<ReturnLineInput> lines,
    String? note,
  }) async {
    state = const AsyncLoading();
    try {
      final receipt = await ref
          .read(rentalRepositoryProvider)
          .recordReturn(rentalId, lines, note);
      ref.invalidate(rentalDetailProvider(rentalId));
      ref.invalidate(returnEventsProvider(rentalId));
      ref.invalidate(activeRentalsProvider);
      ref.invalidate(rentalsProvider);
      ref.invalidate(monthlyRevenueProvider);
      state = const AsyncData(null);
      return receipt;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

class RentalVoidController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> voidReturn(
    String eventId,
    String rentalId,
    String reason,
  ) async {
    await _run(
      () => ref.read(rentalRepositoryProvider).voidReturn(eventId, reason),
      rentalId,
    );
  }

  Future<void> voidRental(String rentalId, String reason) async {
    await _run(
      () => ref.read(rentalRepositoryProvider).voidRental(rentalId, reason),
      rentalId,
    );
  }

  Future<void> _run(Future<void> Function() action, String rentalId) async {
    state = const AsyncLoading();
    try {
      await action();
      ref.invalidate(rentalDetailProvider(rentalId));
      ref.invalidate(returnEventsProvider(rentalId));
      ref.invalidate(rentalAuditHistoryProvider(rentalId));
      ref.invalidate(activeRentalsProvider);
      ref.invalidate(rentalsProvider);
      ref.invalidate(monthlyRevenueProvider);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
