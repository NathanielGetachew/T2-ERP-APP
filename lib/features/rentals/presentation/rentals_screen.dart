import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../core/utils/clock_provider.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../billing/rental_billing.dart';
import '../application/rental_providers.dart';
import '../domain/rental.dart';
import '../domain/rental_number.dart';

class RentalsScreen extends ConsumerStatefulWidget {
  const RentalsScreen({super.key});

  @override
  ConsumerState<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends ConsumerState<RentalsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rentals = ref.watch(rentalsProvider);
    final filter = ref.watch(rentalStatusFilterProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const SafeBackButton(),
        title: Text(l10n.rentals),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(rentalSearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                labelText: l10n.searchRentals,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<RentalStatus?>(
              segments: [
                ButtonSegment(
                  value: RentalStatus.active,
                  label: Text(l10n.active),
                ),
                ButtonSegment(
                  value: RentalStatus.returned,
                  label: Text(l10n.returned),
                ),
                ButtonSegment(
                  value: RentalStatus.voided,
                  label: Text(l10n.voidedFilter),
                ),
                ButtonSegment(value: null, label: Text(l10n.all)),
              ],
              selected: {filter},
              onSelectionChanged: (selection) =>
                  ref.read(rentalStatusFilterProvider.notifier).state =
                      selection.first,
            ),
          ),
          Expanded(
            child: rentals.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
              data: (items) => items.isEmpty
                  ? Center(child: Text(l10n.noRentals))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) => _RentalTile(
                        details: items[index],
                        onTap: () =>
                            context.push('/rentals/${items[index].rental.id}'),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('rental_add_button'),
        onPressed: () => context.push('/rentals/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.newRental),
      ),
    );
  }
}

class _RentalTile extends ConsumerWidget {
  const _RentalTile({required this.details, required this.onTap});

  final RentalDetails details;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rental = details.rental;
    final isActive =
        rental.status == RentalStatus.active ||
        rental.status == RentalStatus.partiallyReturned;
    final estimate = isActive
        ? rentalEstimate(
            details.lines.map(
              (line) => (
                quantity: line.quantity,
                quantityReturned: line.quantityReturned,
                pricePerDaySnapshot: line.pricePerDaySnapshot,
              ),
            ),
            rentedAtUtc: rental.rentedAt,
            asOfUtc: ref.read(clockProvider).now(),
            localOffset: DateTime.now().timeZoneOffset,
          )
        : null;
    final returnedEvents = rental.status == RentalStatus.returned
        ? ref.watch(returnEventsProvider(rental.id)).valueOrNull
        : null;
    final finalTotal = returnedEvents?.fold<int>(
      0,
      (sum, event) => sum + event.amount,
    );
    return Opacity(
      opacity: rental.status == RentalStatus.voided ? 0.58 : 1,
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Expanded(child: Text(formatRentalNumber(rental.rentalNumber))),
            if (rental.status == RentalStatus.voided)
              Chip(label: Text(l10n.voided)),
          ],
        ),
        subtitle: Text('${details.customerName}\n${rental.rentedAt.toLocal()}'),
        isThreeLine: true,
        trailing: isActive
            ? Text('${l10n.estimate}: ${formatEtb(estimate!)}')
            : Text(
                rental.status == RentalStatus.returned && finalTotal != null
                    ? '${l10n.finalTotal}: ${formatEtb(finalTotal)}'
                    : _statusLabel(l10n, rental.status),
              ),
      ),
    );
  }
}

String _statusLabel(AppLocalizations l10n, RentalStatus status) {
  return switch (status) {
    RentalStatus.active => l10n.active,
    RentalStatus.partiallyReturned => l10n.partiallyReturned,
    RentalStatus.returned => l10n.returned,
    RentalStatus.voided => l10n.voided,
  };
}
