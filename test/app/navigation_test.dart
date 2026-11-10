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
import 'package:t2_rental/features/dashboard/application/dashboard_providers.dart';
import 'package:t2_rental/features/dashboard/presentation/dashboard_screen.dart';
import 'package:t2_rental/features/settings/presentation/settings_screen.dart';
import 'package:t2_rental/features/home/presentation/home_screen.dart';
import 'package:t2_rental/features/rentals/application/rental_providers.dart';
import 'package:t2_rental/l10n/generated/app_localizations.dart';

import '../helpers/fake_customer_repository.dart';
import '../helpers/fake_dashboard_repository.dart';
import '../helpers/fake_material_repository.dart';
import '../helpers/fake_rental_repository.dart';
import '../helpers/widget_test_helpers.dart';

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      customerRepositoryProvider.overrideWithValue(FakeCustomerRepository()),
      materialRepositoryProvider.overrideWithValue(FakeMaterialRepository()),
      rentalRepositoryProvider.overrideWithValue(FakeRentalRepository()),
      dashboardRepositoryProvider.overrideWithValue(FakeDashboardRepository()),
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
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildApp());
    await _pumpRoute(tester);
    final customersButton = find.text('Customers');
    await tester.ensureVisible(customersButton);
    await tester.tap(customersButton);
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
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildApp());
    await _pumpRoute(tester);
    final materialsButton = find.text('Materials');
    await tester.ensureVisible(materialsButton);
    await tester.tap(materialsButton);
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
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_buildApp());
    await _pumpRoute(tester);
    final settingsButton = find.text('Settings');
    await tester.ensureVisible(settingsButton);
    await tester.tap(settingsButton);
    await _pumpRoute(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);

    await _tapBack(tester, find.byType(SettingsScreen));
    expect(find.byType(HomeScreen), findsOneWidget);
    await disposeWidgetTree(tester);
  });

  testWidgets('dashboard navigation keeps a back stack', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_buildApp());
    await _pumpRoute(tester);

    final dashboardButton = find.byKey(const ValueKey('home_dashboard_button'));
    await tester.ensureVisible(dashboardButton);
    await tester.tap(dashboardButton);
    await _pumpRoute(tester);
    expect(find.byType(DashboardScreen), findsOneWidget);

    await _tapBack(tester, find.byType(DashboardScreen));
    expect(find.byType(HomeScreen), findsOneWidget);
    await disposeWidgetTree(tester);
  });
}
