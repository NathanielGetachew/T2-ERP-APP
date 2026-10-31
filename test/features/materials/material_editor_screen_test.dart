import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:t2_rental/features/materials/application/material_providers.dart';
import 'package:t2_rental/features/materials/domain/rental_material.dart';
import 'package:t2_rental/features/materials/presentation/material_editor_screen.dart';
import 'package:t2_rental/l10n/generated/app_localizations.dart';

import '../../helpers/fake_material_repository.dart';
import '../../helpers/widget_test_helpers.dart';

Widget _buildEditor(FakeMaterialRepository repository) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MaterialEditorScreen(),
      ),
      GoRoute(
        path: '/materials',
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );
  return ProviderScope(
    overrides: [materialRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('required fields show validation messages', (tester) async {
    final repository = FakeMaterialRepository();
    await tester.pumpWidget(_buildEditor(repository));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('Price is required.'), findsOneWidget);
    await disposeWidgetTree(tester);
  });

  testWidgets('zero and invalid prices are rejected', (tester) async {
    final repository = FakeMaterialRepository();
    await tester.pumpWidget(_buildEditor(repository));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextFormField).at(1), '60x120');
    final price = find.byType(TextFormField).at(2);

    await tester.enterText(price, '0');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Price must be greater than zero.'), findsOneWidget);

    await tester.enterText(price, 'not-a-price');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(
      find.text('Enter a valid non-negative number with up to two decimals.'),
      findsOneWidget,
    );
    expect(repository.createCalls, isEmpty);
    await disposeWidgetTree(tester);
  });

  testWidgets('valid input calls fake repository create once', (tester) async {
    final repository = FakeMaterialRepository();
    await tester.pumpWidget(_buildEditor(repository));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextFormField).at(1), '60x120');
    await tester.enterText(find.byType(TextFormField).at(2), '250.50');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.createCalls, hasLength(1));
    expect(repository.createCalls.single.pricePerDay, 25050);
    await disposeWidgetTree(tester);
  });

  testWidgets('duplicate material shows the duplicate error', (tester) async {
    final now = DateTime.utc(2026, 1, 1);
    final repository = FakeMaterialRepository([
      RentalMaterial(
        id: 'existing',
        category: 'Panel',
        name: '60x120',
        pricePerDay: 25050,
        totalStock: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    await tester.pumpWidget(_buildEditor(repository));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextFormField).at(1), '60x120');
    await tester.enterText(find.byType(TextFormField).at(2), '250.50');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(
      find.text('A material with this category and name already exists.'),
      findsOneWidget,
    );
    expect(repository.createCalls, isEmpty);
    await disposeWidgetTree(tester);
  });
}
