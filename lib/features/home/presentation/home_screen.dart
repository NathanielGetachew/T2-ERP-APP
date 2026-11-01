import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../rentals/application/rental_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeRentals = ref.watch(activeRentalsProvider);
    final now = DateTime.now();
    final monthlyRevenue = ref.watch(
      monthlyRevenueProvider((year: now.year, month: now.month)),
    );
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
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.home,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(l10n.phase0Message, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                FilledButton.icon(
                  key: const ValueKey('home_new_rental_button'),
                  onPressed: () => context.push('/rentals'),
                  icon: const Icon(Icons.add_business_outlined),
                  label: Text(l10n.newRental),
                ),
                const SizedBox(height: 12),
                Text('${l10n.activeRentals}: $activeCount'),
                Text('${l10n.itemsCurrentlyOut}: $itemsOut'),
                Text(
                  '${l10n.thisMonthsRevenue}: '
                  '${formatEtb(monthlyRevenue.valueOrNull ?? 0)}',
                ),
                Text(l10n.earnedFromReturns),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/rentals'),
                  child: Text(l10n.rentals),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.push('/customers'),
                  icon: const Icon(Icons.people_outline),
                  label: Text(l10n.customers),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.push('/materials'),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: Text(l10n.materials),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(l10n.settings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
