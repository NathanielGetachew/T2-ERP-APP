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
        actions: [
          if (details.valueOrNull?.rental.status != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'void') {
                  _showVoidDialog(context, ref, rentalId, null);
                }
                if (value == 'recreate') {
                  final current = details.valueOrNull;
                  if (current != null) {
                    context.push('/rentals/new', extra: current);
                  }
                }
              },
              itemBuilder: (context) {
                final current = details.valueOrNull!;
                final hasActiveReturns =
                    current.rental.status != RentalStatus.active &&
                    current.rental.status != RentalStatus.voided;
                if (current.rental.status == RentalStatus.voided) {
                  return [
                    PopupMenuItem(
                      value: 'recreate',
                      child: Text(l10n.voidAndRecreate),
                    ),
                  ];
                }
                return [
                  PopupMenuItem(
                    value: hasActiveReturns ? 'blocked' : 'void',
                    enabled: !hasActiveReturns,
                    child: Text(
                      hasActiveReturns
                          ? '${l10n.voidRental} (${l10n.voidReturnWarning})'
                          : l10n.voidRental,
                    ),
                  ),
                ];
              },
            ),
        ],
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
            (sum, event) => sum + (event.voidedAt == null ? event.amount : 0),
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
              if (rental.status == RentalStatus.voided)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l10n.voidedOn(
                        _date(context, rental.voidedAt ?? rental.updatedAt),
                        rental.voidReason ?? '',
                      ),
                    ),
                  ),
                ),
              Text(
                formatRentalNumber(rental.rentalNumber),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('${l10n.customer}: ${item.customerName}'),
              Text('${l10n.rentalDate}: ${rental.rentedAt.toLocal()}'),
              Text('${l10n.daysSoFar}: $days'),
              Row(
                children: [
                  Text('${l10n.status}: '),
                  _StatusBadge(status: rental.status, l10n: l10n),
                ],
              ),
              const SizedBox(height: 16),
              // Material lines with Rented | Returned | Still out
              ...item.lines.map(
                (line) => _RentalLineCard(line: line, l10n: l10n),
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
                  (event) => _ReturnEventTile(
                    event: event,
                    item: item,
                    rentalId: rentalId,
                    l10n: l10n,
                    context: context,
                    ref: ref,
                  ),
                ),
              const SizedBox(height: 16),
              if (earned > 0) Text('${l10n.earnedSoFar}: ${formatEtb(earned)}'),
              if (rental.status == RentalStatus.active ||
                  rental.status == RentalStatus.partiallyReturned)
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
              FutureBuilder<List<AuditHistoryEntry>>(
                future: ref
                    .read(rentalRepositoryProvider)
                    .getAuditHistory(rentalId),
                builder: (context, snapshot) => ExpansionTile(
                  title: Text(l10n.auditHistory),
                  children: snapshot.data == null
                      ? [Text(l10n.noAuditHistory)]
                      : snapshot.data!
                            .map(
                              (entry) => ListTile(
                                title: Text(entry.action),
                                subtitle: Text(entry.description),
                                trailing: Text(_date(context, entry.at)),
                              ),
                            )
                            .toList(),
                ),
              ),
              if (rental.status != RentalStatus.voided)
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

/// Card showing "Rented X | Returned Y | Still out Z" for one rental line.
class _RentalLineCard extends StatelessWidget {
  const _RentalLineCard({required this.line, required this.l10n});

  final RentalLine line;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPartial =
        line.quantityReturned > 0 && line.outstandingQuantity > 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line.materialNameSnapshot, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              l10n.rentedReturnedStillOut(
                line.quantity,
                line.quantityReturned,
                line.outstandingQuantity,
              ),
              style: TextStyle(
                fontWeight: hasPartial ? FontWeight.bold : FontWeight.normal,
                color: hasPartial ? theme.colorScheme.primary : null,
              ),
            ),
            Text(
              '${l10n.pricePerDay}: ${formatEtb(line.pricePerDaySnapshot)}',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single return event row in the detail screen, showing batch badge if applicable.
class _ReturnEventTile extends StatelessWidget {
  const _ReturnEventTile({
    required this.event,
    required this.item,
    required this.rentalId,
    required this.l10n,
    required this.context,
    required this.ref,
  });

  final ReturnEventRecord event;
  final RentalDetails item;
  final String rentalId;
  final AppLocalizations l10n;
  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext _) {
    final isBatch = event.returnBatchId != null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Expanded(
            child: Text(
              _lineName(item, event),
              style: event.voidedAt == null
                  ? null
                  : const TextStyle(decoration: TextDecoration.lineThrough),
            ),
          ),
          if (isBatch)
            GestureDetector(
              onTap: event.voidedAt == null
                  ? () => context.push(
                      '/customer-return/batch/${event.returnBatchId}',
                    )
                  : null,
              child: Chip(
                key: ValueKey('batch_chip_${event.id}'),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 0,
                ),
                label: Text(
                  l10n.batchOfItems(1),
                  style: const TextStyle(fontSize: 11),
                ),
                avatar: const Icon(Icons.link, size: 14),
              ),
            ),
        ],
      ),
      subtitle: Text(
        event.voidedAt == null
            ? l10n.returnHistoryLine(
                formatEtb(event.amount),
                _date(context, event.returnedAt),
                event.billableDays,
                _lineName(item, event),
                event.quantity,
              )
            : '${l10n.voidedAmount(formatEtb(event.amount))}\n'
                  '${l10n.voidedReturnReason(event.voidReason ?? '')}',
      ),
      trailing: event.voidedAt == null
          ? PopupMenuButton<String>(
              onSelected: (_) =>
                  _showVoidDialog(context, ref, rentalId, event.id),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'void', child: Text(l10n.voidReturn)),
              ],
            )
          : Text(l10n.voided),
    );
  }
}

/// A compact status badge chip.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.l10n});

  final RentalStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RentalStatus.active => const Color(0xFF059669),
      RentalStatus.partiallyReturned => const Color(0xFFD97706),
      RentalStatus.returned => const Color(0xFF0284C7),
      RentalStatus.voided => const Color(0xFFDC2626),
    };
    final label = switch (status) {
      RentalStatus.active => l10n.active,
      RentalStatus.partiallyReturned => l10n.partiallyReturned,
      RentalStatus.returned => l10n.returned,
      RentalStatus.voided => l10n.voided,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

Future<void> _showVoidDialog(
  BuildContext context,
  WidgetRef ref,
  String rentalId,
  String? eventId,
) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(eventId == null ? l10n.voidRental : l10n.voidReturn),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              eventId == null ? l10n.voidRentalWarning : l10n.voidReturnWarning,
            ),
            TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.voidReason),
              validator: (value) => value == null || value.trim().length < 5
                  ? l10n.voidReasonRequired
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
          ),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(dialogContext).pop(true);
            }
          },
          child: Text(l10n.voidConfirm),
        ),
      ],
    ),
  );
  if (!context.mounted || confirmed != true) return;
  try {
    if (eventId == null) {
      await ref
          .read(rentalVoidControllerProvider.notifier)
          .voidRental(rentalId, controller.text);
    } else {
      await ref
          .read(rentalVoidControllerProvider.notifier)
          .voidReturn(eventId, rentalId, controller.text);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.voidSuccess)));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.voidError)));
  } finally {
    controller.dispose();
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
