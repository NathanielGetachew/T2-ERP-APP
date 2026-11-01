import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:t2_rental/core/utils/clock.dart';
import 'package:t2_rental/core/utils/clock_provider.dart';
import 'package:t2_rental/features/rentals/application/rental_providers.dart';
import 'package:t2_rental/features/rentals/domain/rental.dart';
import 'package:t2_rental/features/rentals/presentation/return_screen.dart';
import 'package:t2_rental/l10n/generated/app_localizations.dart';

import '../../helpers/fake_rental_repository.dart';
import '../../helpers/widget_test_helpers.dart';

class _FakeClock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 1, 3, 9);
}

RentalDetails _details() {
  final rentedAt = DateTime.utc(2026, 1, 1, 9);
  return RentalDetails(
    rental: RentalRecord(
      id: 'rental-1',
      rentalNumber: 1,
      customerId: 'customer-1',
      rentedAt: rentedAt,
      status: RentalStatus.active,
      notes: null,
      createdAt: rentedAt,
      updatedAt: rentedAt,
    ),
    customerName: 'Abebe Kebede',
    lines: [
      RentalLine(
        id: 'line-1',
        rentalId: 'rental-1',
        materialId: 'material-1',
        materialNameSnapshot: 'Panel 60x120',
        pricePerDaySnapshot: 2500,
        quantity: 10,
        quantityReturned: 0,
      ),
    ],
  );
}

Widget _buildReturn(FakeRentalRepository repository) {
  return ProviderScope(
    overrides: [
      rentalRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(_FakeClock()),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ReturnScreen(rentalId: 'rental-1'),
    ),
  );
}

void main() {
  testWidgets('return screen defaults to all and previews the total', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      _buildReturn(FakeRentalRepository(initial: [_details()])),
    );
    await tester.pump();

    expect(find.text('10'), findsOneWidget);
    expect(find.text('3 days × 25.00 ETB = 750.00 ETB'), findsOneWidget);
    expect(find.text('Total to pay: 750.00 ETB'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('return_clear_line-1')));
    await tester.pump();
    expect(find.byKey(const ValueKey('return_confirm_button')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('return_confirm_button')),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const ValueKey('return_all_line-1')));
    await tester.ensureVisible(
      find.byKey(const ValueKey('return_confirm_button')),
    );
    await tester.tap(find.byKey(const ValueKey('return_confirm_button')));
    await tester.pump();
    expect(find.text('Confirm return'), findsOneWidget);
    expect(find.text('Total to pay: 750.00 ETB'), findsWidgets);
    await disposeWidgetTree(tester);
  });
}
