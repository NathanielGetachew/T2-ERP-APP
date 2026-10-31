import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/image_storage_service.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/customer_providers.dart';
import '../domain/customer.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customers = ref.watch(customersProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customers),
        leading: const SafeBackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(customerSearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                labelText: l10n.searchCustomers,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          ref.read(customerSearchQueryProvider.notifier).state =
                              '';
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.showArchived),
            value: ref.watch(showInactiveCustomersProvider),
            onChanged: (value) =>
                ref.read(showInactiveCustomersProvider.notifier).state = value,
          ),
          Expanded(
            child: customers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(l10n.customersLoadError)),
              data: (items) => items.isEmpty
                  ? Center(child: Text(l10n.noCustomers))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _CustomerTile(
                        customer: items[index],
                        storage: ref.read(imageStorageServiceProvider),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customers/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n.addCustomer),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer, required this.storage});

  final Customer customer;
  final ImageStorageService storage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = !customer.isActive;
    return Card(
      child: ListTile(
        enabled: customer.isActive,
        minVerticalPadding: 10,
        leading: _CustomerThumbnail(
          path: customer.idPhotoFrontPath,
          storage: storage,
        ),
        title: Text(customer.fullName),
        subtitle: Text(
          [
            if (customer.phone != null) customer.phone!,
            customer.address,
            if (muted) l10n.archived,
          ].join('\n'),
        ),
        onTap: () => context.push('/customers/${customer.id}'),
      ),
    );
  }
}

class _CustomerThumbnail extends StatelessWidget {
  const _CustomerThumbnail({required this.path, required this.storage});

  final String path;
  final ImageStorageService storage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: storage.resolve(path),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            width: 52,
            height: 52,
            child: Icon(Icons.badge_outlined),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            snapshot.data!,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              width: 52,
              height: 52,
              child: Icon(Icons.badge_outlined),
            ),
          ),
        );
      },
    );
  }
}
