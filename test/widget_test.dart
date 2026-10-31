// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:t2_rental/app/app.dart';
import 'package:t2_rental/core/database/database.dart';
import 'package:t2_rental/core/database/database_provider.dart';
import 'package:t2_rental/features/settings/application/locale_provider.dart';

class _TestLocaleController extends LocaleController {
  @override
  Locale? build() => const Locale('en');

  @override
  Future<void> setLocale(Locale locale) async {
    state = locale;
  }
}

void main() {
  testWidgets('app boots to Home', (WidgetTester tester) async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          localeProvider.overrideWith(_TestLocaleController.new),
        ],
        child: const T2RentalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('T2 Rental'), findsOneWidget);
  });
}
