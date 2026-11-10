import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/backup/backup_providers.dart';
import '../../../core/utils/clock_provider.dart';
import '../../../core/utils/money.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../rentals/application/rental_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final activeRentals = ref.watch(activeRentalsProvider);
    final now = ref.watch(clockProvider).now();
    final monthlyRevenue = ref.watch(
      monthlyRevenueProvider((year: now.year, month: now.month)),
    );
    final lastBackup = ref.watch(lastBackupAtProvider).valueOrNull;
    final backupIsOld =
        lastBackup == null || now.difference(lastBackup).inDays >= 7;
    final activeCount = activeRentals.valueOrNull?.length ?? 0;
    final itemsOut =
        activeRentals.valueOrNull?.fold<int>(
          0,
          (sum, rental) =>
              sum +
              rental.lines.fold<int>(
                0,
                (lineSum, line) => lineSum + line.outstandingQuantity,
              ),
        ) ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Backup reminder banner
            if (backupIsOld) ...[
              Card(
                color: Colors.amber.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.amber.shade300, width: 1),
                ),
                child: ListTile(
                  key: const ValueKey('home_backup_reminder'),
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.shade100,
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  title: Text(
                    l10n.homeBackupReminder,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  subtitle: Text(
                    lastBackup == null
                        ? l10n.backupNeverWarning
                        : l10n.backupOlderWarning,
                    style: TextStyle(color: Colors.amber.shade900),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/backup'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Section Title
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.home,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Hero New Rental Action Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, const Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.phase0Message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.add_business_rounded,
                        color: Colors.white70,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.newRental,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Quick digital contract with customer ID photo capture',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    key: const ValueKey('home_new_rental_button'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.push('/rentals'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      l10n.newRental,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Executive Quick Stats Card (Tappable -> Dashboard)
            InkWell(
              key: const ValueKey('home_stats_card'),
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/dashboard'),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.dashboard,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 3 Stat Metrics
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${l10n.activeRentals}: $activeCount',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${l10n.itemsCurrentlyOut}: $itemsOut',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withAlpha(
                            70,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${l10n.thisMonthsRevenue}: '
                                    '${formatEtb(monthlyRevenue.valueOrNull ?? 0)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    l10n.earnedFromReturns,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.trending_up_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Return Materials Shortcut Card
            Card(
              key: const ValueKey('home_return_shortcut'),
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.amber.shade300, width: 1),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber.shade100,
                  child: Icon(
                    Icons.assignment_return_rounded,
                    color: Colors.amber.shade900,
                  ),
                ),
                title: Text(
                  l10n.returnMaterials,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                subtitle: Text(
                  l10n.selectCustomerToReturn,
                  style: TextStyle(color: Colors.amber.shade900, fontSize: 12),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.amber.shade900,
                ),
                onTap: () => context.push('/customers-holding-items'),
              ),
            ),

            const SizedBox(height: 16),

            // Navigation Hub Grid
            Row(
              children: [
                Expanded(
                  child: _NavCard(
                    title: l10n.rentals,
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () => context.push('/rentals'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NavCard(
                    key: const ValueKey('home_dashboard_button'),
                    title: l10n.dashboard,
                    icon: Icons.analytics_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.push('/dashboard'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _NavCard(
                    title: l10n.customers,
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF059669),
                    onTap: () => context.push('/customers'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NavCard(
                    title: l10n.materials,
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFFD97706),
                    onTap: () => context.push('/materials'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Settings Tile
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.settings_suggest_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                title: Text(
                  l10n.settings,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => context.push('/settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
