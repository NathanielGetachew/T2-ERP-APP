import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/features/dashboard/application/long_running_threshold_provider.dart';
import 'package:t2_rental/features/settings/presentation/settings_screen.dart';
import 'package:t2_rental/l10n/generated/app_localizations.dart';

Widget _buildSettingsApp({required WidgetRefCallback? onInit}) {
  return ProviderScope(
    child: Consumer(
      builder: (context, ref, _) {
        if (onInit != null) onInit(ref);
        return const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        );
      },
    ),
  );
}

typedef WidgetRefCallback = void Function(WidgetRef ref);

void main() {
  testWidgets(
    'Settings displays default threshold 14 days and allows valid update',
    (tester) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        _buildSettingsApp(onInit: (ref) => capturedRef = ref),
      );
      await tester.pumpAndSettle();

      // Verify 14 days is displayed
      expect(find.text('14 days'), findsOneWidget);

      // Tap threshold tile to open edit dialog
      await tester.tap(
        find.byKey(const ValueKey('long_running_threshold_tile')),
      );
      await tester.pumpAndSettle();

      // Dialog is open
      expect(find.byKey(const ValueKey('threshold_input')), findsOneWidget);

      // Enter invalid value (e.g. 0)
      await tester.enterText(
        find.byKey(const ValueKey('threshold_input')),
        '0',
      );
      await tester.tap(find.byKey(const ValueKey('threshold_save_button')));
      await tester.pumpAndSettle();

      // Validation error shown
      expect(find.text('Enter a number between 1 and 365'), findsOneWidget);

      // Enter invalid value (e.g. 400)
      await tester.enterText(
        find.byKey(const ValueKey('threshold_input')),
        '400',
      );
      await tester.tap(find.byKey(const ValueKey('threshold_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a number between 1 and 365'), findsOneWidget);

      // Enter valid value (e.g. 21)
      await tester.enterText(
        find.byKey(const ValueKey('threshold_input')),
        '21',
      );
      await tester.tap(find.byKey(const ValueKey('threshold_save_button')));
      await tester.pumpAndSettle();

      // Dialog closed and 21 days shown
      expect(find.text('21 days'), findsOneWidget);
      expect(capturedRef.read(longRunningThresholdProvider), 21);
    },
  );
}
