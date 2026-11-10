import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/clock_provider.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const SafeBackButton(),
        title: Text(l10n.rentals),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(rentalSearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                labelText: l10n.searchRentals,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(rentalSearchQueryProvider.notifier).state =
                              '';
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          const SizedBox(height: 6),
          Expanded(
            child: rentals.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
              data: (items) => items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noRentals,
                            style: TextStyle(color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
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
        icon: const Icon(Icons.add_business_rounded),
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
    final locale = Localizations.localeOf(context).toLanguageTag();
    final theme = Theme.of(context);
    final rental = details.rental;
    final isVoided = rental.status == RentalStatus.voided;
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

    final statusColor = _statusColor(rental.status);

    return Opacity(
      opacity: isVoided ? 0.6 : 1.0,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Rental Number & Status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formatRentalNumber(rental.rentalNumber),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isVoided
                            ? l10n.voided
                            : _statusLabel(l10n, rental.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Customer Name
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        details.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Date & Items
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat.yMMMd(locale)
                          .add_jm()
                          .format(rental.rentedAt.toLocal()),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Bottom row: items count & amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${details.lines.length} items (${details.lines.fold<int>(0, (s, l) => s + l.quantity)} units)',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (isActive && estimate != null)
                      Text(
                        '${l10n.estimate}: ${formatEtb(estimate)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                          fontSize: 14,
                        ),
                      )
                    else if (rental.status == RentalStatus.returned &&
                        finalTotal != null)
                      Text(
                        '${l10n.finalTotal}: ${formatEtb(finalTotal)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                          fontSize: 14,
                        ),
                      )
                    else
                      Text(
                        _statusLabel(l10n, rental.status),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.outline,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
                if (rental.status == RentalStatus.partiallyReturned) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: details.lines.map((l) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${l.materialNameSnapshot}: ${l10n.rentedReturnedStillOut(l.quantity, l.quantityReturned, l.outstandingQuantity)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(RentalStatus status) {
    return switch (status) {
      RentalStatus.active => const Color(0xFF059669), // Emerald
      RentalStatus.partiallyReturned => const Color(0xFFD97706), // Amber
      RentalStatus.returned => const Color(0xFF0284C7), // Blue
      RentalStatus.voided => const Color(0xFFDC2626), // Red
    };
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
