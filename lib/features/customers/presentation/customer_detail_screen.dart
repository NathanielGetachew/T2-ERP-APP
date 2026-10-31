import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/image_storage_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/customer_providers.dart';
import '../domain/customer.dart';

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
        actions: [
          customer.when(
            data: (item) => item == null
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () => context.go('/customers/$customerId/edit'),
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

class _CustomerProfile extends ConsumerWidget {
  const _CustomerProfile({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final storage = ref.read(imageStorageServiceProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: InkWell(
            onTap: () => context.go('/customers/${customer.id}/photo'),
            child: _ProfilePhoto(
              path: customer.idPhotoFrontPath,
              storage: storage,
            ),
          ),
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
          onPressed: () => _toggleActive(context, ref),
          child: Text(
            customer.isActive ? l10n.archiveCustomer : l10n.reactivateCustomer,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(customerRepositoryProvider)
          .setActive(customer.id, !customer.isActive);
      ref.invalidate(customerDetailProvider(customer.id));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.saveCustomerError)));
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

  final String path;
  final ImageStorageService storage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: storage.resolve(path),
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
      appBar: AppBar(),
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
