import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/dashboard_providers.dart';
import '../application/long_running_threshold_provider.dart';
import '../domain/dashboard_models.dart';
import 'widgets/average_duration_card.dart';
import 'widgets/currently_out_card.dart';
import 'widgets/customers_summary_card.dart';
import 'widgets/most_rented_materials_card.dart';
import 'widgets/period_selector.dart';
import 'widgets/revenue_chart_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final period = ref.watch(dashboardPeriodProvider);
    final threshold = ref.watch(longRunningThresholdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        leading: const SafeBackButton(),
      ),
      body: metricsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString()),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.refresh(dashboardMetricsProvider),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
        data: (metrics) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardMetricsProvider);
            await ref.read(dashboardMetricsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const SizedBox(height: 8),
              const PeriodSelector(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSummaryCard(context, ref, metrics, period, l10n),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RevenueChartCard(monthlyRevenue: metrics.monthlyRevenue),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AverageDurationCard(
                  averageDurationDays: metrics.averageDurationDays,
                  durationTrend: metrics.durationTrend,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MostRentedMaterialsCard(
                  materials: metrics.mostRentedMaterials,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CurrentlyOutCard(
                  activeRentalsCount: metrics.activeRentalsCount,
                  materialsOut: metrics.materialsOut,
                  longRunningRentals: metrics.longRunningRentals,
                  thresholdDays: threshold,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomersSummaryCard(
                  newCustomersCount: metrics.newCustomersCount,
                  returningCustomersCount: metrics.returningCustomersCount,
                  topByRevenue: metrics.topCustomersByRevenue,
                  topByRentals: metrics.topCustomersByRentals,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    WidgetRef ref,
    DashboardMetrics metrics,
    DashboardPeriod period,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    // Month-over-month comparison for thisMonth
    MonthRevenueMetric? currentMonthMetric;
    if (period.type == DashboardPeriodType.thisMonth &&
        metrics.monthlyRevenue.isNotEmpty) {
      currentMonthMetric = metrics.monthlyRevenue.last;
    }

    return Card(
      color: theme.colorScheme.primaryContainer.withAlpha(80),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.earnedRevenue,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  formatEtb(metrics.periodEarnedRevenue),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (currentMonthMetric?.percentChange != null)
                  _buildPercentBadge(
                    context,
                    currentMonthMetric!.percentChange!,
                  ),
              ],
            ),
            if (currentMonthMetric != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.previousMonthRevenue(
                  formatEtb(currentMonthMetric.previousMonthRevenueMinorUnits),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.outstandingEstimate,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.estimateDisclaimer,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatEtb(metrics.outstandingEstimate),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentBadge(BuildContext context, double percent) {
    final isPositive = percent >= 0;
    final color = isPositive ? Colors.green.shade700 : Colors.red.shade700;
    final text = '${isPositive ? '+' : ''}${percent.toStringAsFixed(1)}%';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
