import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/backup/backup_manifest.dart';
import '../../../core/services/backup/backup_providers.dart';
import '../../../core/utils/clock_provider.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lastBackup = ref.watch(lastBackupAtProvider);
    final now = ref.read(clockProvider).now();
    final backupAt = lastBackup.valueOrNull;
    final isOld = backupAt == null || now.difference(backupAt).inDays >= 7;
    return Scaffold(
      appBar: AppBar(
        leading: const SafeBackButton(),
        title: Text(l10n.backupAndRestore),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            color: isOld ? Theme.of(context).colorScheme.errorContainer : null,
            child: ListTile(
              title: Text(
                backupAt == null
                    ? l10n.neverBackedUp
                    : l10n.lastBackup(_date(context, backupAt)),
              ),
              subtitle: Text(
                backupAt == null
                    ? l10n.backupNeverWarning
                    : isOld
                    ? l10n.backupOlderWarning
                    : l10n.backupDataWarning,
              ),
              leading: Icon(isOld ? Icons.warning_amber : Icons.verified),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const ValueKey('create_backup_button'),
            onPressed: _busy ? null : _createBackup,
            icon: const Icon(Icons.backup_outlined),
            label: Text(l10n.createBackup),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('restore_backup_button'),
            onPressed: _busy ? null : _restoreBackup,
            icon: const Icon(Icons.restore_outlined),
            label: Text(l10n.restoreFromBackup),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    final l10n = AppLocalizations.of(context)!;
    final password = await _passwordDialog(context, confirm: true);
    if (!mounted || password == null) return;
    setState(() => _busy = true);
    File? file;
    var progressShown = false;
    try {
      final progress = ValueNotifier<double>(0);
      progressShown = true;
      _showProgress(l10n.backupProgress, progress);
      file = await ref
          .read(backupServiceProvider)
          .createBackup(
            password,
            onProgress: (value, _) => progress.value = value,
          );
      if (progressShown && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        progressShown = false;
      }
      await ref.read(backupShareProvider)([file.path]);
      await ref
          .read(backupMetadataStoreProvider)
          .writeLastBackupAt(ref.read(clockProvider).now().toUtc());
      ref.invalidate(lastBackupAtProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.backupCreated)));
      }
    } catch (_) {
      if (progressShown && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        progressShown = false;
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.backupError)));
      }
    } finally {
      if (file != null && file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.pickFiles(type: FileType.any);
    if (!mounted || picked.isEmpty || picked.first.path == null) return;
    final file = File(picked.first.path!);
    final password = await _passwordDialog(context);
    if (!mounted || password == null) return;
    setState(() => _busy = true);
    var progressShown = false;
    try {
      final service = ref.read(backupServiceProvider);
      final manifest = await service.inspectBackup(file, password);
      if (!mounted) return;
      final confirmed = await _restoreConfirmation(context, manifest);
      if (!mounted || !confirmed) return;
      final progress = ValueNotifier<double>(0);
      progressShown = true;
      _showProgress(l10n.restoreProgress, progress);
      await service.restoreBackup(
        file,
        password,
        onProgress: (value, _) => progress.value = value,
      );
      if (progressShown && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        progressShown = false;
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
        context.go('/');
      }
    } catch (_) {
      if (progressShown && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        progressShown = false;
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.restoreError)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showProgress(String title, ValueNotifier<double> progress) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (context, value, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: value == 0 ? null : value),
              const SizedBox(height: 12),
              Text('${(value * 100).round()}%'),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> _passwordDialog(BuildContext context, {bool confirm = false}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => PasswordDialog(confirm: confirm),
  );
}

class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key, required this.confirm});
  final bool confirm;

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  late final TextEditingController _password;
  late final TextEditingController _confirmation;
  final _formKey = GlobalKey<FormState>();
  var _obscure = true;

  @override
  void initState() {
    super.initState();
    _password = TextEditingController();
    _confirmation = TextEditingController();
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.confirm ? l10n.createBackup : l10n.backupPassword),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const ValueKey('backup_password_field'),
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: l10n.backupPassword,
                  suffixIcon: IconButton(
                    tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.length < 8
                    ? l10n.passwordMinimum
                    : null,
              ),
              if (widget.confirm) ...[
                TextFormField(
                  key: const ValueKey('backup_password_confirm_field'),
                  controller: _confirmation,
                  obscureText: _obscure,
                  decoration: InputDecoration(labelText: l10n.confirmPassword),
                  validator: (value) =>
                      value != _password.text ? l10n.passwordMismatch : null,
                ),
                const SizedBox(height: 12),
                Text(l10n.passwordCannotRecover),
                Text(l10n.backupPhotoWarning),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_password.text);
            }
          },
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}

Future<bool> _restoreConfirmation(
  BuildContext context,
  BackupManifest manifest,
) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => RestoreConfirmationDialog(manifest: manifest),
  ).then((val) => val ?? false);
}

class RestoreConfirmationDialog extends StatefulWidget {
  const RestoreConfirmationDialog({super.key, required this.manifest});
  final BackupManifest manifest;

  @override
  State<RestoreConfirmationDialog> createState() =>
      _RestoreConfirmationDialogState();
}

class _RestoreConfirmationDialogState extends State<RestoreConfirmationDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.restoreFromBackup),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.restoreReplaceWarning),
            const SizedBox(height: 12),
            Text(
              l10n.restoreSummary(
                widget.manifest.counts.customers,
                _date(context, widget.manifest.createdAtUtc),
                widget.manifest.counts.materials,
                widget.manifest.counts.rentals,
                widget.manifest.counts.returnEvents,
                widget.manifest.dbSchemaVersion,
              ),
            ),
            TextField(
              key: const ValueKey('restore_confirmation_field'),
              controller: _controller,
              decoration: InputDecoration(labelText: l10n.typeRestore),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _controller.text.trim().toUpperCase() == l10n.restoreConfirmation,
          ),
          child: Text(l10n.restoreConfirmation),
        ),
      ],
    );
  }
}

String _date(BuildContext context, DateTime value) =>
    DateFormat.yMd(Localizations.localeOf(context).toLanguageTag())
        .add_jm()
        .format(value.toLocal());
