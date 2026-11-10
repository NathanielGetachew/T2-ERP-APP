import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../application/dashboard_providers.dart';
import '../../domain/dashboard_models.dart';

class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPeriod = ref.watch(dashboardPeriodProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildChip(
                context,
                ref,
                label: l10n.thisMonth,
                periodType: DashboardPeriodType.thisMonth,
                isSelected: currentPeriod.type == DashboardPeriodType.thisMonth,
              ),
              const SizedBox(width: 8),
              _buildChip(
                context,
                ref,
                label: l10n.lastMonth,
                periodType: DashboardPeriodType.lastMonth,
                isSelected: currentPeriod.type == DashboardPeriodType.lastMonth,
              ),
              const SizedBox(width: 8),
              _buildChip(
                context,
                ref,
                label: l10n.last3Months,
                periodType: DashboardPeriodType.last3Months,
                isSelected:
                    currentPeriod.type == DashboardPeriodType.last3Months,
              ),
              const SizedBox(width: 8),
              _buildChip(
                context,
                ref,
                label: l10n.thisYear,
                periodType: DashboardPeriodType.thisYear,
                isSelected: currentPeriod.type == DashboardPeriodType.thisYear,
              ),
              const SizedBox(width: 8),
              _buildCustomChip(
                context,
                ref,
                label: l10n.customRange,
                currentPeriod: currentPeriod,
                isSelected: currentPeriod.type == DashboardPeriodType.custom,
              ),
            ],
          ),
        ),
        if (currentPeriod.type == DashboardPeriodType.custom) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${DateFormat.yMMMd(locale).format(currentPeriod.startDate)} — ${DateFormat.yMMMd(locale).format(currentPeriod.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton(
                  key: const ValueKey('change_custom_range_button'),
                  onPressed: () =>
                      _pickCustomRange(context, ref, currentPeriod),
                  child: Text(l10n.selectDateRange),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required DashboardPeriodType periodType,
    required bool isSelected,
  }) {
    return ChoiceChip(
      key: ValueKey('period_chip_${periodType.name}'),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          final now = DateTime.now();
          ref.read(dashboardPeriodProvider.notifier).state =
              DashboardPeriod.fromType(periodType, now: now);
        }
      },
    );
  }

  Widget _buildCustomChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required DashboardPeriod currentPeriod,
    required bool isSelected,
  }) {
    return ChoiceChip(
      key: const ValueKey('period_chip_custom'),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) async {
        await _pickCustomRange(context, ref, currentPeriod);
      },
    );
  }

  Future<void> _pickCustomRange(
    BuildContext context,
    WidgetRef ref,
    DashboardPeriod currentPeriod,
  ) async {
    final now = DateTime.now();
    final initialRange = DateTimeRange(
      start: currentPeriod.startDate,
      end: currentPeriod.endDate,
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 10),
      initialDateRange: initialRange,
    );
    if (picked != null) {
      ref.read(dashboardPeriodProvider.notifier).state = DashboardPeriod.custom(
        picked.start,
        picked.end,
      );
    }
  }
}
