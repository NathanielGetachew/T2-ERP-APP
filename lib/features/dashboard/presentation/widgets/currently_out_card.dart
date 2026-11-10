import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/dashboard_models.dart';

class CurrentlyOutCard extends StatelessWidget {
  const CurrentlyOutCard({
    super.key,
    required this.activeRentalsCount,
    required this.materialsOut,
    required this.longRunningRentals,
    required this.thresholdDays,
  });

  final int activeRentalsCount;
  final List<MaterialStockOutMetric> materialsOut;
  final List<LongRunningRentalMetric> longRunningRentals;
  final int thresholdDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.currentlyOut,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$activeRentalsCount ${l10n.activeRentals.toLowerCase()}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (materialsOut.isEmpty)
              Text(
                l10n.noActiveRentals,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              )
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in materialsOut)
                    Chip(
                      label: Text(
                        '${item.category} ${item.name}: ${item.quantityOut} ${l10n.units}',
                        style: theme.textTheme.bodySmall,
                      ),
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: longRunningRentals.isNotEmpty
                      ? Colors.orange.shade800
                      : theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.longRunningRentals(thresholdDays.toString()),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: longRunningRentals.isNotEmpty
                        ? Colors.orange.shade800
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (longRunningRentals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  l10n.noLongRunning,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              )
            else ...[
              for (final rental in longRunningRentals)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(rental.customerName),
                  subtitle: Text(
                    '${rental.rentalNumber} • ${DateFormat.yMMMd(locale).format(rental.rentedAt.toLocal())}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.durationDays(rental.daysSoFar.toString()),
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => context.push('/rentals/${rental.rentalId}'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
