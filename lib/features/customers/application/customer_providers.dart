import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/services/image_capture_service.dart';
import '../../../core/services/image_storage_service.dart';
import '../data/customer_repository.dart';
import '../domain/customer.dart';
import '../domain/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return DriftCustomerRepository(ref.watch(databaseProvider));
});

final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  return FileImageStorageService();
});

final imageCaptureServiceProvider = Provider<ImageCaptureService>((ref) {
  return ImagePickerCaptureService();
});

final customerSearchQueryProvider = StateProvider<String>((ref) => '');
final showInactiveCustomersProvider = StateProvider<bool>((ref) => false);

final customersProvider = StreamProvider.autoDispose<List<Customer>>((
  ref,
) async* {
  final query = ref.watch(customerSearchQueryProvider);
  final includeInactive = ref.watch(showInactiveCustomersProvider);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  yield* ref
      .watch(customerRepositoryProvider)
      .watchAll(query, includeInactive: includeInactive);
});

final customerDetailProvider = FutureProvider.autoDispose
    .family<Customer?, String>(
      (ref, id) => ref.watch(customerRepositoryProvider).getById(id),
    );

final customerEditorProvider =
    AsyncNotifierProvider.autoDispose<CustomerEditorController, void>(
      CustomerEditorController.new,
    );

class CustomerEditorController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Customer> createCustomer({
    required String fullName,
    required String address,
    String? phone,
    String? notes,
    required String idPhotoFrontPath,
    String? idPhotoBackPath,
  }) async {
    state = const AsyncLoading();
    try {
      final customer = await ref
          .read(customerRepositoryProvider)
          .create(
            fullName: fullName,
            address: address,
            phone: phone,
            notes: notes,
            idPhotoFrontPath: idPhotoFrontPath,
            idPhotoBackPath: idPhotoBackPath,
          );
      state = const AsyncData(null);
      return customer;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<Customer> updateCustomer(Customer customer) async {
    state = const AsyncLoading();
    try {
      final updated = await ref
          .read(customerRepositoryProvider)
          .update(customer);
      state = const AsyncData(null);
      return updated;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
