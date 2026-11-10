import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/backup/backup_providers.dart';
import '../../../core/utils/clock_provider.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../dashboard/application/long_running_threshold_provider.dart';
import '../application/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(localeProvider)?.languageCode ?? 'en';
    final threshold = ref.watch(longRunningThresholdProvider);
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider).now();
    final lastBackup = ref.watch(lastBackupAtProvider).valueOrNull;
    final backupIsOld =
        lastBackup == null || now.difference(lastBackup).inDays >= 7;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: const SafeBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Section 1: Language
          Text(
            l10n.language,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.chooseLanguage,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(value: 'en', label: Text(l10n.english)),
                        ButtonSegment(value: 'am', label: Text(l10n.amharic)),
                      ],
                      selected: {selected},
                      onSelectionChanged: (values) {
                        ref
                            .read(localeProvider.notifier)
                            .setLocale(Locale(values.first));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section 2: Dashboard & Operations
          Text(
            l10n.dashboard,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              key: const ValueKey('long_running_threshold_tile'),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.timelapse_rounded,
                  color: Colors.orange.shade800,
                  size: 22,
                ),
              ),
              title: Text(
                l10n.longRunningThreshold,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(l10n.durationDays(threshold.toString())),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${threshold}d',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined, size: 14),
                  ],
                ),
              ),
              onTap: () => _showThresholdDialog(context, ref, threshold, l10n),
            ),
          ),

          const SizedBox(height: 24),

          // Section 3: Data Security & Backup
          Row(
            children: [
              Text(
                l10n.backupAndRestore,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (backupIsOld) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: Colors.amber.shade900,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.homeBackupReminder,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (backupIsOld) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.amber.shade300, width: 1),
              ),
              child: ListTile(
                key: const ValueKey('settings_backup_reminder'),
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
          ],
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.security_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.backupAndRestore,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const ValueKey('backup_restore_button'),
                      onPressed: () => context.push('/settings/backup'),
                      icon: const Icon(Icons.backup_rounded),
                      label: Text(l10n.backupAndRestore),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showThresholdDialog(
    BuildContext context,
    WidgetRef ref,
    int current,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController(text: current.toString());
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.longRunningThreshold),
        content: Form(
          key: formKey,
          child: TextFormField(
            key: const ValueKey('threshold_input'),
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            validator: (value) {
              final parsed = int.tryParse(value?.trim() ?? '');
              if (parsed == null || parsed < 1 || parsed > 365) {
                return l10n.invalidThreshold;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('threshold_save_button'),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final parsed = int.parse(controller.text.trim());
                ref
                    .read(longRunningThresholdProvider.notifier)
                    .setThreshold(parsed);
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
