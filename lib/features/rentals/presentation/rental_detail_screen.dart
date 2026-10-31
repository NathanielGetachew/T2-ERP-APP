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

class RentalDetailScreen extends ConsumerWidget {
  const RentalDetailScreen({super.key, required this.rentalId});

  final String rentalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final details = ref.watch(rentalDetailProvider(rentalId));
    return Scaffold(
      appBar: AppBar(
        leading: const SafeBackButton(),
        title: Text(l10n.rentalDetails),
      ),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (item) {
          if (item == null) return Center(child: Text(l10n.rentalNotFound));
          final rental = item.rental;
          final days = billableDays(
            rental.rentedAt,
            ref.read(clockProvider).now(),
            localOffset: DateTime.now().timeZoneOffset,
          );
          final estimate = rentalEstimate(
            item.lines.map(
              (line) => (
                quantity: line.quantity,
                quantityReturned: line.quantityReturned,
                pricePerDaySnapshot: line.pricePerDaySnapshot,
              ),
            ),
            rentedAtUtc: rental.rentedAt,
            asOfUtc: ref.read(clockProvider).now(),
            localOffset: DateTime.now().timeZoneOffset,
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                formatRentalNumber(rental.rentalNumber),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('${l10n.customer}: ${item.customerName}'),
              Text('${l10n.rentalDate}: ${rental.rentedAt.toLocal()}'),
              Text('${l10n.daysSoFar}: $days'),
              Text('${l10n.status}: ${_statusLabel(l10n, rental.status)}'),
              const SizedBox(height: 16),
              ...item.lines.map(
                (line) => Card(
                  child: ListTile(
                    title: Text(line.materialNameSnapshot),
                    subtitle: Text(
                      '${l10n.quantity}: ${line.quantity}\n'
                      '${l10n.pricePerDay}: ${formatEtb(line.pricePerDaySnapshot)}\n'
                      '${l10n.outstanding}: ${line.outstandingQuantity}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('${l10n.estimateIfReturnedToday}: ${formatEtb(estimate)}'),
              if (rental.notes != null) Text('${l10n.notes}: ${rental.notes}'),
              const SizedBox(height: 24),
              FilledButton(onPressed: null, child: Text(l10n.returnComingNext)),
              TextButton(
                onPressed: () =>
                    context.push('/customers/${rental.customerId}'),
                child: Text(l10n.viewCustomer),
              ),
            ],
          );
        },
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
