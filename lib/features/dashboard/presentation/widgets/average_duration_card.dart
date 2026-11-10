import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/dashboard_models.dart';

class AverageDurationCard extends StatelessWidget {
  const AverageDurationCard({
    super.key,
    required this.averageDurationDays,
    required this.durationTrend,
  });

  final double? averageDurationDays;
  final List<MonthDurationMetric> durationTrend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final theme = Theme.of(context);

    final durationString = averageDurationDays != null
        ? l10n.durationDays(averageDurationDays!.toStringAsFixed(1))
        : l10n.noCompletedRentals;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.averageDuration,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              durationString,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: averageDurationDays != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              l10n.durationTrend,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in durationTrend.reversed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.yMMMM(locale)
                          .format(DateTime(item.year, item.month)),
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      item.averageDurationDays != null
                          ? l10n.durationDays(
                              item.averageDurationDays!.toStringAsFixed(1),
                            )
                          : '-',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
