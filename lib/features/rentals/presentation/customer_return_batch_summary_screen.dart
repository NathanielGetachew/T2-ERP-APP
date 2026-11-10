import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/rental_providers.dart';
import '../domain/rental.dart';
import '../domain/rental_number.dart';

class CustomerReturnBatchSummaryScreen extends ConsumerWidget {
  const CustomerReturnBatchSummaryScreen({
    super.key,
    required this.batchId,
    this.initialReceipt,
  });

  final String batchId;
  final CustomerReturnReceipt? initialReceipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (initialReceipt != null) {
      return _BatchSummaryBody(receipt: initialReceipt!);
    }

    final summaryAsync = ref.watch(returnBatchSummaryProvider(batchId));

    return Scaffold(
      appBar: AppBar(
        leading: const SafeBackButton(),
        title: Text(l10n.batchReturnSummary),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (receipt) {
          if (receipt == null) {
            return Center(
              child: Text(
                'Batch not found',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            );
          }
          return _BatchSummaryBody(receipt: receipt);
        },
      ),
    );
  }
}

class _BatchSummaryBody extends StatelessWidget {
  const _BatchSummaryBody({required this.receipt});

  final CustomerReturnReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasHeldRemaining =
        receipt.remainingHeld.isNotEmpty &&
        receipt.remainingHeld.any((m) => m.totalOutstanding > 0);

    return Scaffold(
      appBar: AppBar(
        leading: const SafeBackButton(),
        title: Text(l10n.batchReturnSummary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Customer & time banner
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          receipt.customerName.isNotEmpty
                              ? receipt.customerName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receipt.customerName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDateTime(context, receipt.returnedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Returned items header
          Text(
            l10n.returnMaterials,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Lines returned
          ...receipt.allocations.map((alloc) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  '${formatRentalNumber(alloc.rentalNumber)} · ${alloc.materialName}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  l10n.summaryLine(
                    formatEtb(alloc.amount),
                    alloc.days,
                    formatEtb(alloc.pricePerDaySnapshot),
                    alloc.quantity,
                  ),
                ),
                trailing: Text(
                  formatEtb(alloc.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          // Grand total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.finalTotal,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  formatEtb(receipt.totalAmount),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Still held after return
          Text(
            l10n.stillHeldAfterReturn,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (!hasHeldRemaining)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.allReturnedNoHeld,
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...receipt.remainingHeld.where((m) => m.totalOutstanding > 0).map((
              m,
            ) {
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m.materialName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        l10n.outstandingQuantity(m.totalOutstanding),
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 28),
          // Actions
          if (hasHeldRemaining) ...[
            FilledButton.icon(
              key: const ValueKey('batch_return_more_button'),
              onPressed: () =>
                  context.push('/customer-return/${receipt.customerId}'),
              icon: const Icon(Icons.assignment_return_outlined),
              label: Text(l10n.returnMore),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.go('/customers/${receipt.customerId}'),
              child: Text(l10n.backToCustomer),
            ),
          ] else ...[
            FilledButton(
              onPressed: () => context.go('/customers/${receipt.customerId}'),
              child: Text(l10n.backToCustomer),
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/'),
            child: Text(l10n.backToHome),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(locale).add_jm().format(value.toLocal());
}
