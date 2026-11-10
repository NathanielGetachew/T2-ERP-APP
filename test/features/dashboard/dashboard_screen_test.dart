import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/utils/clock.dart';
import 'package:t2_rental/core/utils/clock_provider.dart';
import 'package:t2_rental/features/customers/domain/customer.dart';
import 'package:t2_rental/features/dashboard/application/dashboard_providers.dart';
import 'package:t2_rental/features/dashboard/domain/dashboard_models.dart';
import 'package:t2_rental/features/dashboard/presentation/dashboard_screen.dart';
import 'package:t2_rental/features/dashboard/presentation/widgets/most_rented_materials_card.dart';
import 'package:t2_rental/features/materials/domain/rental_material.dart';
import 'package:t2_rental/features/rentals/domain/rental.dart';
import 'package:t2_rental/l10n/generated/app_localizations.dart';

import '../../helpers/fake_dashboard_repository.dart';

class _FixedClock implements Clock {
  const _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

Widget _buildDashboardApp({
  required FakeDashboardRepository repo,
  DateTime? fixedNow,
}) {
  final now = fixedNow ?? DateTime.utc(2026, 5, 20, 12);
  return ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(_FixedClock(now)),
      dashboardRepositoryProvider.overrideWithValue(repo),
      dashboardPeriodProvider.overrideWith(
        (ref) => DashboardPeriod.thisMonth(now),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: DashboardScreen(),
    ),
  );
}

void main() {
  testWidgets('renders empty dashboard state cleanly without crashing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repo = FakeDashboardRepository();

    await tester.pumpWidget(_buildDashboardApp(repo: repo));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Dashboard'), findsOneWidget);

    // Verify 0.00 ETB revenue
    expect(
      find.text('0.00 ETB'),
      findsNWidgets(2),
    ); // revenue + outstanding estimate

    // Verify empty state messages
    expect(find.text('No completed rentals in this period'), findsOneWidget);
    expect(find.text('No materials rented in this period'), findsOneWidget);
    expect(find.text('0 active rentals'), findsOneWidget);
    expect(find.text('No active rentals'), findsOneWidget);
    expect(find.text('No long-running rentals'), findsOneWidget);
    expect(find.text('No customers in this period'), findsOneWidget);
  });

  testWidgets('renders populated dashboard with correct hand-computed metrics', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final c1 = Customer(
      id: 'c1',
      fullName: 'Abebe Kebede',
      address: 'Addis Ababa',
      phone: '+251911000001',
      idPhotoFrontPath: 'customer/c1.jpg',
      idPhotoBackPath: null,
      isActive: true,
      notes: null,
      createdAt: DateTime.utc(2026, 5, 1, 9),
      updatedAt: DateTime.utc(2026, 5, 1, 9),
    );
    final c2 = Customer(
      id: 'c2',
      fullName: 'Chala Gemechu',
      address: 'Adama',
      phone: '+251911000002',
      idPhotoFrontPath: 'customer/c2.jpg',
      idPhotoBackPath: null,
      isActive: true,
      notes: null,
      createdAt: DateTime.utc(2026, 5, 2, 9),
      updatedAt: DateTime.utc(2026, 5, 2, 9),
    );

    final m1 = RentalMaterial(
      id: 'm1',
      category: 'Panel',
      name: '60x120',
      pricePerDay: 10000,
      totalStock: 10,
      isActive: true,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    final m2 = RentalMaterial(
      id: 'm2',
      category: 'Column',
      name: 'Formwork',
      pricePerDay: 20000,
      totalStock: 10,
      isActive: true,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    // Completed Rental 1: May 1 to May 4 (4 days)
    // Hand computed arithmetic:
    // 2 units * 10,000 cents/day * 4 days = 80,000 cents (800.00 ETB).
    final r1 = RentalRecord(
      id: 'r1',
      customerId: 'c1',
      rentalNumber: 1,
      rentedAt: DateTime.utc(2026, 5, 1, 10),
      status: RentalStatus.returned,
      notes: null,
      createdAt: DateTime.utc(2026, 5, 1, 10),
      updatedAt: DateTime.utc(2026, 5, 4, 10),
    );
    final l1 = RentalLine(
      id: 'l1',
      rentalId: 'r1',
      materialId: 'm1',
      materialNameSnapshot: '60x120',
      pricePerDaySnapshot: 10000,
      quantity: 2,
      quantityReturned: 2,
    );
    final ret1 = ReturnEventRecord(
      id: 'ret1',
      rentalId: 'r1',
      rentalItemId: 'l1',
      returnedAt: DateTime.utc(2026, 5, 4, 10),
      quantity: 2,
      billableDays: 4,
      amount: 80000,
      pricePerDaySnapshot: 10000,
      conditionNote: null,
      createdAt: DateTime.utc(2026, 5, 4, 10),
    );

    // Active Rental 2: May 2 to May 20 (19 days, threshold default is 14)
    // Hand computed arithmetic:
    // 3 units * 20,000 cents/day * 19 days = 1,140,000 cents (11,400.00 ETB).
    final r2 = RentalRecord(
      id: 'r2',
      customerId: 'c2',
      rentalNumber: 2,
      rentedAt: DateTime.utc(2026, 5, 2, 10),
      status: RentalStatus.active,
      notes: null,
      createdAt: DateTime.utc(2026, 5, 2, 10),
      updatedAt: DateTime.utc(2026, 5, 2, 10),
    );
    final l2 = RentalLine(
      id: 'l2',
      rentalId: 'r2',
      materialId: 'm2',
      materialNameSnapshot: 'Formwork',
      pricePerDaySnapshot: 20000,
      quantity: 3,
      quantityReturned: 0,
    );

    final repo = FakeDashboardRepository(
      customers: [c1, c2],
      materials: [m1, m2],
      rentals: [r1, r2],
      lines: [l1, l2],
      returnEvents: [ret1],
    );

    await tester.pumpWidget(
      _buildDashboardApp(repo: repo, fixedNow: DateTime.utc(2026, 5, 20, 12)),
    );
    await tester.pumpAndSettle();

    // Check Earned revenue: 800.00 ETB (in summary card and top customers card)
    expect(find.text('800.00 ETB'), findsNWidgets(2));

    // Check Outstanding estimate: 11,400.00 ETB
    expect(find.text('11,400.00 ETB'), findsOneWidget);

    // Check Average duration: 4.0 days (in period headline and monthly trend)
    expect(find.text('4.0 days'), findsNWidgets(2));

    // Check Most rented materials: 8 unit-days (2 units * 4 days)
    expect(find.text('8 Unit-days'), findsOneWidget);

    // Check Active rentals count: 1 active rentals
    expect(find.text('1 active rentals'), findsOneWidget);

    // Check Long running rental: Chala Gemechu with 19 days
    expect(find.text('Chala Gemechu'), findsWidgets);
    expect(find.text('19 days'), findsOneWidget);

    // Test SegmentedButton toggle on Most Rented Materials
    await tester.tap(find.text('Times rented'));
    await tester.pumpAndSettle();
    // Both m1 and m2 were rented 1 time in this test scenario
    expect(
      find.descendant(
        of: find.byType(MostRentedMaterialsCard),
        matching: find.text('1 ×'),
      ),
      findsNWidgets(2),
    );

    await tester.tap(find.text('Total quantity'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(MostRentedMaterialsCard),
        matching: find.text('2 units'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('period chips switch period', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repo = FakeDashboardRepository();
    await tester.pumpWidget(_buildDashboardApp(repo: repo));
    await tester.pumpAndSettle();

    // Tap "Last month" chip
    await tester.tap(find.byKey(const ValueKey('period_chip_lastMonth')));
    await tester.pumpAndSettle();

    // Verify "Last month" is selected
    final lastMonthChip = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('period_chip_lastMonth')),
    );
    expect(lastMonthChip.selected, isTrue);
  });
}
