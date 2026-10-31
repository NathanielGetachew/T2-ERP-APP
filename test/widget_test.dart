import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:t2_rental/app/app.dart';
import 'package:t2_rental/features/materials/application/material_providers.dart';
import 'package:t2_rental/features/settings/application/locale_provider.dart';

import 'helpers/fake_material_repository.dart';
import 'helpers/widget_test_helpers.dart';

class _FakeLocaleController extends LocaleController {
  @override
  Locale? build() => const Locale('en');

  @override
  Future<void> setLocale(Locale locale) async {
    state = locale;
  }
}

void main() {
  testWidgets('app boots to Home', (WidgetTester tester) async {
    final repository = FakeMaterialRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          materialRepositoryProvider.overrideWithValue(repository),
          localeProvider.overrideWith(_FakeLocaleController.new),
        ],
        child: const T2RentalApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('T2 Rental'), findsOneWidget);

    await disposeWidgetTree(tester);
  });
}
