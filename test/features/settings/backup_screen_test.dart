import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/services/backup/backup_manifest.dart';
import 'package:t2_rental/core/services/backup/backup_providers.dart';
import 'package:t2_rental/core/services/backup/backup_service.dart';
import 'package:t2_rental/core/utils/clock.dart';
import 'package:t2_rental/core/utils/clock_provider.dart';
import 'package:t2_rental/features/home/presentation/home_screen.dart';
import 'package:t2_rental/features/rentals/application/rental_providers.dart';
import 'package:t2_rental/features/settings/presentation/backup_screen.dart';
import 'package:t2_rental/l10n/generated/app_localizations.dart';

import '../../helpers/fake_backup_service.dart';
import '../../helpers/fake_rental_repository.dart';
import '../../helpers/widget_test_helpers.dart';

Widget _buildScreen({
  required Widget child,
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

class FakeClock implements Clock {
  const FakeClock(this.fixedNow);
  final DateTime fixedNow;

  @override
  DateTime now() => fixedNow;
}

class FakeBackupMetadataStore implements BackupMetadataStore {
  FakeBackupMetadataStore([this._last]);
  DateTime? _last;

  @override
  Directory? get documentsDirectory => null;

  @override
  Future<DateTime?> readLastBackupAt() async => _last;

  @override
  Future<void> writeLastBackupAt(DateTime value) async {
    _last = value;
  }
}

void main() {
  testWidgets('password dialog validates min 8 chars and mismatch', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetPhysicalSize);

    final fakeBackup = FakeBackupService();
    await tester.pumpWidget(
      _buildScreen(
        child: const BackupScreen(),
        overrides: [
          backupServiceProvider.overrideWithValue(fakeBackup),
          lastBackupAtProvider.overrideWith((ref) => null),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Tap Create Backup
    final createBtn = find.byKey(const ValueKey('create_backup_button'));
    await tester.ensureVisible(createBtn);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    final passwordField = find.byKey(const ValueKey('backup_password_field'));
    final confirmField = find.byKey(
      const ValueKey('backup_password_confirm_field'),
    );
    final confirmBtn = find.widgetWithText(FilledButton, 'Confirm');

    // Short password (< 8 chars)
    await tester.enterText(passwordField, 'short');
    await tester.enterText(confirmField, 'short');
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();
    expect(find.text('Use at least 8 characters.'), findsOneWidget);

    // Mismatched passwords (>= 8 chars)
    await tester.enterText(passwordField, 'password123');
    await tester.enterText(confirmField, 'different123');
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match.'), findsOneWidget);

    // Cancel dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await disposeWidgetTree(tester);
  });

  testWidgets('create backup shows success snackbar and calls share', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetPhysicalSize);

    final fakeBackup = FakeBackupService();
    final metadataStore = FakeBackupMetadataStore();
    final sharedPaths = <String>[];

    await tester.pumpWidget(
      _buildScreen(
        child: const BackupScreen(),
        overrides: [
          backupServiceProvider.overrideWithValue(fakeBackup),
          backupMetadataStoreProvider.overrideWithValue(metadataStore),
          backupShareProvider.overrideWithValue((paths) async {
            sharedPaths.addAll(paths);
          }),
          lastBackupAtProvider.overrideWith((ref) => null),
          clockProvider.overrideWithValue(
            FakeClock(DateTime.utc(2026, 11, 1, 12, 0)),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final createBtn = find.byKey(const ValueKey('create_backup_button'));
    await tester.ensureVisible(createBtn);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('backup_password_field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('backup_password_confirm_field')),
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(fakeBackup.lastCreatePassword, equals('password123'));
    expect(sharedPaths, isNotEmpty);
    expect(find.text('Encrypted backup created.'), findsOneWidget);

    await disposeWidgetTree(tester);
  });

  testWidgets('create backup shows error snackbar on failure', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetPhysicalSize);

    final fakeBackup = FakeBackupService()
      ..createError = Exception('Storage full');
    await tester.pumpWidget(
      _buildScreen(
        child: const BackupScreen(),
        overrides: [
          backupServiceProvider.overrideWithValue(fakeBackup),
          lastBackupAtProvider.overrideWith((ref) => null),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final createBtn = find.byKey(const ValueKey('create_backup_button'));
    await tester.ensureVisible(createBtn);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('backup_password_field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('backup_password_confirm_field')),
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(
      find.text('Backup failed. Your current data was not changed.'),
      findsOneWidget,
    );

    await disposeWidgetTree(tester);
  });

  testWidgets(
    'RESTORE confirmation dialog requires typing RESTORE and shows counts',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      addTearDown(tester.view.resetPhysicalSize);

      final manifest = BackupManifest(
        formatVersion: 1,
        appVersion: '1.0.0+1',
        dbSchemaVersion: 4,
        createdAtUtc: DateTime.utc(2026, 11, 1, 10, 30),
        counts: const BackupCounts(
          customers: 12,
          materials: 7,
          rentals: 5,
          returnEvents: 3,
          photos: 8,
        ),
        files: const [],
      );

      bool? dialogResult;
      await tester.pumpWidget(
        _buildScreen(
          child: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  dialogResult = await showDialog<bool>(
                    context: context,
                    builder: (ctx) =>
                        RestoreConfirmationDialog(manifest: manifest),
                  );
                },
                child: const Text('Open Restore Dialog'),
              ),
            ),
          ),
          overrides: [],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Restore Dialog'));
      await tester.pumpAndSettle();

      // Verify counts and warning are rendered
      expect(find.text('Restore from backup'), findsOneWidget);
      expect(
        find.textContaining('Restore replaces all current data'),
        findsOneWidget,
      );
      expect(find.textContaining('Customers: 12'), findsOneWidget);
      expect(find.textContaining('Materials: 7'), findsOneWidget);
      expect(find.textContaining('Rentals: 5'), findsOneWidget);

      final field = find.byKey(const ValueKey('restore_confirmation_field'));
      final restoreBtn = find.widgetWithText(FilledButton, 'RESTORE');

      // Test 1: Enter wrong text -> returns false
      await tester.enterText(field, 'NOPE');
      await tester.tap(restoreBtn);
      await tester.pumpAndSettle();
      expect(dialogResult, isFalse);

      // Re-open dialog for case-insensitive 'restore'
      await tester.tap(find.text('Open Restore Dialog'));
      await tester.pumpAndSettle();

      // Test 2: Enter lowercase 'restore' -> returns true
      await tester.enterText(
        find.byKey(const ValueKey('restore_confirmation_field')),
        'restore',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'RESTORE'));
      await tester.pumpAndSettle();
      expect(dialogResult, isTrue);

      await disposeWidgetTree(tester);
    },
  );

  testWidgets('Home banner shows when never backed up', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetPhysicalSize);

    final clock = FakeClock(DateTime.utc(2026, 11, 10, 12, 0));

    await tester.pumpWidget(
      _buildScreen(
        child: const HomeScreen(),
        overrides: [
          clockProvider.overrideWithValue(clock),
          rentalRepositoryProvider.overrideWithValue(FakeRentalRepository()),
          lastBackupAtProvider.overrideWith((ref) => null),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home_backup_reminder')), findsOneWidget);
    expect(find.text('No backup has been created yet.'), findsOneWidget);

    await disposeWidgetTree(tester);
  });

  testWidgets('Home banner shows when backup is > 7 days old', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetPhysicalSize);

    final clock = FakeClock(DateTime.utc(2026, 11, 10, 12, 0));
    final eightDaysAgo = DateTime.utc(2026, 11, 2, 12, 0);

    await tester.pumpWidget(
      _buildScreen(
        child: const HomeScreen(),
        overrides: [
          clockProvider.overrideWithValue(clock),
          rentalRepositoryProvider.overrideWithValue(FakeRentalRepository()),
          lastBackupAtProvider.overrideWith((ref) => eightDaysAgo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home_backup_reminder')), findsOneWidget);
    expect(
      find.text('Your last backup is more than 7 days old.'),
      findsOneWidget,
    );

    await disposeWidgetTree(tester);
  });

  testWidgets('Home banner is hidden when backup is recent (< 7 days)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetPhysicalSize);

    final clock = FakeClock(DateTime.utc(2026, 11, 10, 12, 0));
    final twoDaysAgo = DateTime.utc(2026, 11, 8, 12, 0);

    await tester.pumpWidget(
      _buildScreen(
        child: const HomeScreen(),
        overrides: [
          clockProvider.overrideWithValue(clock),
          rentalRepositoryProvider.overrideWithValue(FakeRentalRepository()),
          lastBackupAtProvider.overrideWith((ref) => twoDaysAgo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home_backup_reminder')), findsNothing);

    await disposeWidgetTree(tester);
  });
}
