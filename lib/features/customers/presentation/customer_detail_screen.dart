import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/image_capture_service.dart';
import '../../../core/services/image_storage_service.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/customer_providers.dart';
import '../domain/customer.dart';
import '../domain/customer_repository.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final customer = ref.watch(customerDetailProvider(customerId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerProfile),
        leading: const SafeBackButton(),
        actions: [
          customer.when(
            data: (item) => item == null
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () =>
                        context.push('/customers/$customerId/edit'),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: l10n.editCustomer,
                  ),
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: customer.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.customersLoadError)),
        data: (item) => item == null
            ? Center(child: Text(l10n.customerNotFound))
            : _CustomerProfile(customer: item),
      ),
    );
  }
}

class _CustomerProfile extends ConsumerStatefulWidget {
  const _CustomerProfile({required this.customer});

  final Customer customer;

  @override
  ConsumerState<_CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends ConsumerState<_CustomerProfile> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storage = ref.read(imageStorageServiceProvider);
    final customer = widget.customer;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: InkWell(
            onTap: () => context.push('/customers/${customer.id}/photo'),
            child: _ProfilePhoto(
              path: customer.idPhotoFrontPath,
              storage: storage,
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const ValueKey('customer_retake_front_photo_button'),
          onPressed: () => _replacePhoto(customer, CustomerPhotoSide.front),
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(l10n.retakeFrontPhoto),
        ),
        OutlinedButton.icon(
          onPressed: () => _replacePhoto(
            customer,
            CustomerPhotoSide.front,
            source: ImageSource.gallery,
          ),
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(l10n.chooseFromGallery),
        ),
        const SizedBox(height: 20),
        Text(
          customer.fullName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        _DetailLine(label: l10n.address, value: customer.address),
        if (customer.phone != null)
          _DetailLine(label: l10n.phone, value: customer.phone!),
        if (customer.notes != null)
          _DetailLine(label: l10n.notes, value: customer.notes!),
        const SizedBox(height: 20),
        Text(l10n.idPhotoBack, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _ProfilePhoto(path: customer.idPhotoBackPath, storage: storage),
        OutlinedButton.icon(
          onPressed: () => _replacePhoto(customer, CustomerPhotoSide.back),
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(
            customer.idPhotoBackPath == null
                ? l10n.addBackPhoto
                : l10n.retakeBackPhoto,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _replacePhoto(
            customer,
            CustomerPhotoSide.back,
            source: ImageSource.gallery,
          ),
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(l10n.chooseFromGallery),
        ),
        if (!customer.isActive)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              l10n.archived,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 24),
        Text(l10n.rentalHistory, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(l10n.noRentalHistory),
        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: () => _toggleActive(customer),
          child: Text(
            customer.isActive ? l10n.archiveCustomer : l10n.reactivateCustomer,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleActive(Customer customer) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(customerRepositoryProvider)
          .setActive(customer.id, !customer.isActive);
      if (!mounted) {
        return;
      }
      ref.invalidate(customerDetailProvider(customer.id));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.saveCustomerError)));
      }
    }
  }

  Future<void> _replacePhoto(
    Customer customer,
    CustomerPhotoSide side, {
    ImageSource source = ImageSource.camera,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (side == CustomerPhotoSide.front) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.replacePhotoTitle),
          content: Text(l10n.replacePhotoMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.replacePhoto),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) {
        return;
      }
    }
    try {
      final capture = ref.read(imageCaptureServiceProvider);
      final image = source == ImageSource.camera
          ? await capture.takePhoto()
          : await capture.chooseFromGallery();
      if (image == null || !mounted) {
        return;
      }
      final storage = ref.read(imageStorageServiceProvider);
      final path = await storage.saveCustomerImage(image);
      if (!mounted) {
        await storage.deleteOrphan(path);
        return;
      }
      try {
        await ref
            .read(customerRepositoryProvider)
            .replaceIdPhoto(customer.id, side, path);
      } catch (_) {
        await storage.deleteOrphan(path);
        rethrow;
      }
      if (!mounted) {
        return;
      }
      ref.invalidate(customerDetailProvider(customer.id));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.photoReplaced)));
      }
    } on ImageCaptureException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.permissionDenied
                  ? l10n.cameraPermissionDenied
                  : l10n.photoCaptureError,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.photoReplacementError)));
      }
    }
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text('$label: $value'),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.path, required this.storage});

  final String? path;
  final ImageStorageService storage;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.trim().isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Icon(Icons.badge_outlined, size: 64)),
      );
    }
    return FutureBuilder<File>(
      future: storage.resolve(path!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 180,
            child: CircularProgressIndicator(),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            snapshot.data!,
            width: 220,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              height: 180,
              width: 220,
              child: Icon(Icons.badge_outlined, size: 64),
            ),
          ),
        );
      },
    );
  }
}

class CustomerPhotoViewerScreen extends ConsumerWidget {
  const CustomerPhotoViewerScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerDetailProvider(customerId));
    final storage = ref.read(imageStorageServiceProvider);
    return Scaffold(
      appBar: AppBar(leading: const SafeBackButton()),
      body: customer.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const SizedBox.shrink(),
        data: (item) {
          if (item == null) {
            return const SizedBox.shrink();
          }
          return FutureBuilder<File>(
            future: storage.resolve(item.idPhotoFrontPath),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return InteractiveViewer(
                child: Center(child: Image.file(snapshot.data!)),
              );
            },
          );
        },
      ),
    );
  }
}
