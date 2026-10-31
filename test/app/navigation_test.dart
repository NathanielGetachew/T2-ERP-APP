import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:t2_rental/app/router.dart';
import 'package:t2_rental/features/customers/application/customer_providers.dart';
import 'package:t2_rental/features/customers/presentation/customer_editor_screen.dart';
import 'package:t2_rental/features/customers/presentation/customers_screen.dart';
import 'package:t2_rental/features/materials/application/material_providers.dart';
import 'package:t2_rental/features/materials/presentation/material_editor_screen.dart';
import 'package:t2_rental/features/materials/presentation/materials_screen.dart';
import 'package:t2_rental/features/settings/presentation/settings_screen.dart';
import 'package:t2_rental/features/home/presentation/home_screen.dart';
import 'package:t2_rental/l10n/generated/app_localizations.dart';

import '../helpers/fake_customer_repository.dart';
import '../helpers/fake_material_repository.dart';
import '../helpers/widget_test_helpers.dart';

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      customerRepositoryProvider.overrideWithValue(FakeCustomerRepository()),
      materialRepositoryProvider.overrideWithValue(FakeMaterialRepository()),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: createAppRouter(),
    ),
  );
}

Future<void> _pumpRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _tapBack(WidgetTester tester, Finder screen) async {
  final backButton = find.descendant(
    of: screen,
    matching: find.byIcon(Icons.arrow_back),
  );
  await tester.tap(backButton);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('customer navigation keeps a back stack', (tester) async {
    await tester.pumpWidget(_buildApp());
    await _pumpRoute(tester);
    await tester.tap(find.text('Customers'));
    await _pumpRoute(tester);
    expect(find.byType(CustomersScreen), findsOneWidget);

    await tester.tap(find.text('Add customer'));
    await _pumpRoute(tester);
    expect(find.byType(CustomerEditorScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CustomerEditorScreen),
        matching: find.byIcon(Icons.arrow_back),
      ),
      findsOneWidget,
    );

    await _tapBack(tester, find.byType(CustomerEditorScreen));
    expect(find.byType(CustomersScreen), findsOneWidget);
    await disposeWidgetTree(tester);
  });

  testWidgets('material navigation keeps a back stack', (tester) async {
    await tester.pumpWidget(_buildApp());
    await _pumpRoute(tester);
    await tester.tap(find.text('Materials'));
    await _pumpRoute(tester);
    await tester.tap(find.text('Add material'));
    await _pumpRoute(tester);

    expect(find.byType(MaterialEditorScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(MaterialEditorScreen),
        matching: find.byIcon(Icons.arrow_back),
      ),
      findsOneWidget,
    );
    await _tapBack(tester, find.byType(MaterialEditorScreen));
    expect(find.byType(MaterialsScreen), findsOneWidget);
    await disposeWidgetTree(tester);
  });

  testWidgets('settings back returns to Home', (tester) async {
    await tester.pumpWidget(_buildApp());
    await _pumpRoute(tester);
    await tester.tap(find.text('Settings'));
    await _pumpRoute(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);

    await _tapBack(tester, find.byType(SettingsScreen));
    expect(find.byType(HomeScreen), findsOneWidget);
    await disposeWidgetTree(tester);
  });
}
