import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/clock_provider.dart';
import '../../../core/utils/money.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/rental.dart';
import '../domain/rental_number.dart';
import '../../billing/rental_billing.dart';

class ReturnSummaryScreen extends ConsumerWidget {
  const ReturnSummaryScreen({super.key, required this.receipt});

  final ReturnReceipt receipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final now = receipt.events.isEmpty
        ? ref.read(clockProvider).now()
        : receipt.events.first.returnedAt;
    final remainingEstimate = rentalEstimate(
      receipt.remainingOutstanding.map(
        (line) => (
          quantity: line.quantity,
          quantityReturned: line.quantityReturned,
          pricePerDaySnapshot: line.pricePerDaySnapshot,
        ),
      ),
      rentedAtUtc: receipt.rental.rentedAt,
      asOfUtc: now,
      localOffset: DateTime.now().timeZoneOffset,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.returnSummary)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            formatRentalNumber(receipt.rental.rentalNumber),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('${l10n.customer}: ${receipt.customerName}'),
          Text(
            '${l10n.rentalDate}: ${_date(context, receipt.rental.rentedAt)}',
          ),
          Text('${l10n.returnDateTime}: ${_date(context, now)}'),
          Text('${l10n.status}: ${_status(context, receipt.status)}'),
          const SizedBox(height: 16),
          ...receipt.events.map(
            (event) => Card(
              child: ListTile(
                title: Text(_lineName(receipt, event)),
                subtitle: Text(
                  l10n.summaryLine(
                    formatEtb(event.amount),
                    event.billableDays,
                    formatEtb(event.pricePerDaySnapshot),
                    event.quantity,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.totalForThisReturn}: ${formatEtb(receipt.total)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (receipt.remainingOutstanding.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              l10n.remainingOutstanding,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...receipt.remainingOutstanding.map(
              (line) => Text(
                '${line.materialNameSnapshot}: ${line.outstandingQuantity}',
              ),
            ),
            Text('${l10n.runningEstimate}: ${formatEtb(remainingEstimate)}'),
          ],
          if (receipt.status == RentalStatus.returned)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                '${l10n.finalTotal}: ${formatEtb(receipt.total)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go('/rentals/${receipt.rental.id}'),
            child: Text(l10n.backToRental),
          ),
          OutlinedButton(
            onPressed: () => context.go('/'),
            child: Text(l10n.backToHome),
          ),
        ],
      ),
    );
  }

  String _lineName(ReturnReceipt receipt, ReturnEventRecord event) {
    for (final line in receipt.lines) {
      if (line.id == event.rentalItemId) return line.materialNameSnapshot;
    }
    return event.rentalItemId;
  }

  String _status(BuildContext context, RentalStatus status) {
    final l10n = AppLocalizations.of(context)!;
    return switch (status) {
      RentalStatus.active => l10n.active,
      RentalStatus.partiallyReturned => l10n.partiallyReturned,
      RentalStatus.returned => l10n.returned,
      RentalStatus.voided => l10n.voided,
    };
  }
}

String _date(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(locale).add_jm().format(value.toLocal());
}
