import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/dashboard_models.dart';

class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({super.key, required this.monthlyRevenue});

  final List<MonthRevenueMetric> monthlyRevenue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final theme = Theme.of(context);

    // Compute max minor units across the 12 months for chart scaling
    final maxMinorUnits = monthlyRevenue.fold<int>(
      0,
      (prev, m) => math.max(prev, m.revenueMinorUnits),
    );
    // If all zero, default to 10,000 minor units (100 ETB) so chart has vertical room
    final maxY = maxMinorUnits == 0 ? 100.0 : (maxMinorUnits / 100.0) * 1.2;

    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < monthlyRevenue.length; i++) {
      final metric = monthlyRevenue[i];
      final birr = metric.revenueMinorUnits / 100.0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: birr,
              color: birr > 0 ? null : theme.colorScheme.outlineVariant,
              gradient: birr > 0
                  ? const LinearGradient(
                      colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
                  : null,
              width: 14,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.revenueTrend,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = monthlyRevenue[groupIndex];
                        final monthStr = DateFormat.yMMM(locale)
                            .format(DateTime(item.year, item.month));
                        return BarTooltipItem(
                          '$monthStr\n${formatEtb(item.revenueMinorUnits)}',
                          TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= monthlyRevenue.length) {
                            return const SizedBox.shrink();
                          }
                          // Alternate months on small screens to prevent overlap
                          if (index % 2 != 0 &&
                              index != monthlyRevenue.length - 1) {
                            return const SizedBox.shrink();
                          }
                          final item = monthlyRevenue[index];
                          final label = DateFormat.MMM(locale)
                              .format(DateTime(item.year, item.month));
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  l10n.showAll,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                children: [
                  for (final item in monthlyRevenue.reversed)
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
                          Row(
                            children: [
                              Text(
                                formatEtb(item.revenueMinorUnits),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (item.percentChange != null) ...[
                                const SizedBox(width: 8),
                                _buildPercentBadge(
                                  context,
                                  item.percentChange!,
                                ),
                              ],
                            ],
                          ),
                        ],
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
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
