import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:t2_rental/app/router.dart';
import 'package:t2_rental/features/customers/application/customer_providers.dart';
import 'package:t2_rental/features/materials/application/material_providers.dart';
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

Future<void> _tapBack(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('customer navigation keeps a back stack', (tester) async {
    await tester.pumpWidget(_buildApp());
    await _pumpRoute(tester);
    await tester.tap(find.text('Customers'));
    await _pumpRoute(tester);
    expect(find.text('Customers'), findsOneWidget);

    await tester.tap(find.text('Add customer'));
    await _pumpRoute(tester);
    expect(find.text('Add customer'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await _tapBack(tester);
    expect(find.text('Customers'), findsOneWidget);
    await disposeWidgetTree(tester);
  });

  testWidgets('material navigation keeps a back stack', (tester) async {
    await tester.pumpWidget(_buildApp());
    await _pumpRoute(tester);
    await tester.tap(find.text('Materials'));
    await _pumpRoute(tester);
    await tester.tap(find.text('Add material'));
    await _pumpRoute(tester);

    expect(find.text('Add material'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    await _tapBack(tester);
    expect(find.text('Materials'), findsOneWidget);
    await disposeWidgetTree(tester);
  });

  testWidgets('settings back returns to Home', (tester) async {
    await tester.pumpWidget(_buildApp());
    await _pumpRoute(tester);
    await tester.tap(find.text('Settings'));
    await _pumpRoute(tester);
    expect(find.text('Settings'), findsOneWidget);

    await _tapBack(tester);
    expect(find.text('Home'), findsOneWidget);
    await disposeWidgetTree(tester);
  });
}
