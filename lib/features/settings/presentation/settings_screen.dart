import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../application/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(localeProvider)?.languageCode ?? 'en';
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: const SafeBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.language, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'en', label: Text(l10n.english)),
              ButtonSegment(value: 'am', label: Text(l10n.amharic)),
            ],
            selected: {selected},
            onSelectionChanged: (values) {
              ref.read(localeProvider.notifier).setLocale(Locale(values.first));
            },
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            key: const ValueKey('backup_restore_button'),
            onPressed: () => context.push('/settings/backup'),
            icon: const Icon(Icons.backup_outlined),
            label: Text(l10n.backupAndRestore),
          ),
        ],
      ),
    );
  }
}
