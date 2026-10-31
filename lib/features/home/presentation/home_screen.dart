import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
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
    );
  }
}
