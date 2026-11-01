import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
          final returnEvents = ref.watch(returnEventsProvider(rentalId));
          final events =
              returnEvents.valueOrNull ?? const <ReturnEventRecord>[];
          final earned = events.fold<int>(
            0,
            (sum, event) => sum + event.amount,
          );
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
              Text(
                l10n.returnHistory,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (events.isEmpty)
                Text(l10n.noReturnHistory)
              else
                ...events.map(
                  (event) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_lineName(item, event)),
                    subtitle: Text(
                      l10n.returnHistoryLine(
                        formatEtb(event.amount),
                        _date(context, event.returnedAt),
                        event.billableDays,
                        _lineName(item, event),
                        event.quantity,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (earned > 0) Text('${l10n.earnedSoFar}: ${formatEtb(earned)}'),
              if (rental.status != RentalStatus.returned)
                Text('${l10n.outstandingEstimate}: ${formatEtb(estimate)}'),
              if (rental.status == RentalStatus.returned)
                Text(
                  '${l10n.finalTotal}: ${formatEtb(earned)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              if (rental.notes != null) Text('${l10n.notes}: ${rental.notes}'),
              const SizedBox(height: 24),
              if (rental.status == RentalStatus.active ||
                  rental.status == RentalStatus.partiallyReturned)
                FilledButton(
                  onPressed: () => context.push('/rentals/$rentalId/return'),
                  child: Text(l10n.returnAction),
                ),
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

String _lineName(RentalDetails details, ReturnEventRecord event) {
  for (final line in details.lines) {
    if (line.id == event.rentalItemId) return line.materialNameSnapshot;
  }
  return event.rentalItemId;
}

String _date(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(locale).add_jm().format(value.toLocal());
}

String _statusLabel(AppLocalizations l10n, RentalStatus status) {
  return switch (status) {
    RentalStatus.active => l10n.active,
    RentalStatus.partiallyReturned => l10n.partiallyReturned,
    RentalStatus.returned => l10n.returned,
    RentalStatus.voided => l10n.voided,
  };
}
