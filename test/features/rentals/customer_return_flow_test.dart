import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:t2_rental/core/utils/clock.dart';
import 'package:t2_rental/core/utils/clock_provider.dart';
import 'package:t2_rental/features/customers/application/customer_providers.dart';
import 'package:t2_rental/features/customers/domain/customer.dart';
import 'package:t2_rental/features/customers/presentation/customer_detail_screen.dart';
import 'package:t2_rental/features/home/presentation/home_screen.dart';
import 'package:t2_rental/features/rentals/application/rental_providers.dart';
import 'package:t2_rental/features/rentals/domain/rental.dart';
import 'package:t2_rental/features/rentals/presentation/customer_return_batch_summary_screen.dart';
import 'package:t2_rental/features/rentals/presentation/customer_return_screen.dart';
import 'package:t2_rental/features/rentals/presentation/customers_holding_items_screen.dart';
import 'package:t2_rental/features/rentals/presentation/rental_detail_screen.dart';
import 'package:t2_rental/features/rentals/presentation/rentals_screen.dart';
import 'package:t2_rental/l10n/generated/app_localizations.dart';

import '../../helpers/fake_customer_repository.dart';
import '../../helpers/fake_image_services.dart';
import '../../helpers/fake_rental_repository.dart';
import '../../helpers/widget_test_helpers.dart';

class _FakeClock implements Clock {
  _FakeClock(this.nowValue);
  DateTime nowValue;

  @override
  DateTime now() => nowValue;
}

RentalDetails _r1() {
  final rentedAt = DateTime.utc(2026, 1, 1, 9);
  return RentalDetails(
    rental: RentalRecord(
      id: 'r1',
      rentalNumber: 1,
      customerId: 'cust-1',
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
        rentalId: 'r1',
        materialId: 'mat-1',
        materialNameSnapshot: 'Panel 60x120',
        pricePerDaySnapshot: 2500, // 25.00 ETB
        quantity: 10,
        quantityReturned: 0,
      ),
    ],
  );
}

RentalDetails _r3() {
  final rentedAt = DateTime.utc(2026, 1, 3, 9);
  return RentalDetails(
    rental: RentalRecord(
      id: 'r3',
      rentalNumber: 3,
      customerId: 'cust-1',
      rentedAt: rentedAt,
      status: RentalStatus.active,
      notes: null,
      createdAt: rentedAt,
      updatedAt: rentedAt,
    ),
    customerName: 'Abebe Kebede',
    lines: [
      RentalLine(
        id: 'line-3',
        rentalId: 'r3',
        materialId: 'mat-1',
        materialNameSnapshot: 'Panel 60x120',
        pricePerDaySnapshot: 2500, // 25.00 ETB
        quantity: 5,
        quantityReturned: 0,
      ),
    ],
  );
}

Customer _customer() {
  return Customer(
    id: 'cust-1',
    fullName: 'Abebe Kebede',
    address: 'Addis Ababa',
    phone: '0911000000',
    idPhotoFrontPath: 'test.jpg',
    idPhotoBackPath: null,
    notes: null,
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

Widget _wrap(
  Widget child, {
  required FakeRentalRepository rentalRepo,
  FakeCustomerRepository? customerRepo,
  Clock? clock,
}) {
  return ProviderScope(
    overrides: [
      rentalRepositoryProvider.overrideWithValue(rentalRepo),
      if (customerRepo != null)
        customerRepositoryProvider.overrideWithValue(customerRepo),
      imageCaptureServiceProvider.overrideWithValue(FakeImageCaptureService()),
      imageStorageServiceProvider.overrideWithValue(FakeImageStorageService()),
      clockProvider.overrideWithValue(
        clock ?? _FakeClock(DateTime.utc(2026, 1, 5, 9)),
      ),
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
      home: child,
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Customer Return Flow Widgets', () {
    testWidgets(
      'Customer detail shows items currently held and return button',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final rentalRepo = FakeRentalRepository(initial: [_r1(), _r3()]);
        final customerRepo = FakeCustomerRepository(initial: [_customer()]);

        await tester.pumpWidget(
          _wrap(
            const CustomerDetailScreen(customerId: 'cust-1'),
            rentalRepo: rentalRepo,
            customerRepo: customerRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Check "Items currently held" section exists
        expect(find.text('Items currently held'), findsOneWidget);
        expect(find.text('Panel 60x120'), findsOneWidget);
        // Total outstanding: 10 + 5 = 15
        expect(find.text('Outstanding: 15'), findsOneWidget);
        // "Return items" button is present
        expect(
          find.byKey(const ValueKey('customer_return_items_button')),
          findsOneWidget,
        );

        await disposeWidgetTree(tester);
      },
    );

    testWidgets('Home shortcut navigates to CustomersHoldingItemsScreen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final rentalRepo = FakeRentalRepository(initial: [_r1()]);

      await tester.pumpWidget(
        _wrap(const HomeScreen(), rentalRepo: rentalRepo),
      );
      await tester.pumpAndSettle();

      // The Return Materials shortcut exists on Home
      expect(
        find.byKey(const ValueKey('home_return_shortcut')),
        findsOneWidget,
      );
      expect(find.text('Return materials'), findsWidgets);

      await disposeWidgetTree(tester);
    });

    testWidgets('CustomersHoldingItemsScreen lists customers holding items', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final rentalRepo = FakeRentalRepository(initial: [_r1(), _r3()]);

      await tester.pumpWidget(
        _wrap(const CustomersHoldingItemsScreen(), rentalRepo: rentalRepo),
      );
      await tester.pumpAndSettle();

      // Shows customer name and units held count: 10 + 5 = 15 units held
      expect(find.text('Abebe Kebede'), findsOneWidget);
      expect(find.text('15 units held'), findsOneWidget);

      await disposeWidgetTree(tester);
    });

    testWidgets(
      'CustomerReturnScreen shows allocation preview matching hand-computed 1400.00 ETB',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Setup with R-0001 (10 units) and R-0003 (5 units)
        // Clock is Day 5 (Jan 5)
        // Customer enters 12 panels:
        // 10 from R-0001: 10 * 25.00 * 5 = 1250.00 ETB
        // 2 from R-0003: 2 * 25.00 * 3 = 150.00 ETB
        // Grand total = 1400.00 ETB
        final rentalRepo = FakeRentalRepository(initial: [_r1(), _r3()]);

        await tester.pumpWidget(
          _wrap(
            const CustomerReturnScreen(customerId: 'cust-1'),
            rentalRepo: rentalRepo,
            clock: _FakeClock(DateTime.utc(2026, 1, 5, 9)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Panel 60x120'), findsOneWidget);
        expect(find.text('Outstanding: 15'), findsOneWidget);

        // Enter 12 in the quantity field
        final qtyField = find.byKey(const ValueKey('qty_input_mat-1'));
        await tester.enterText(qtyField, '12');
        await tester.pumpAndSettle();

        // Returning summary banner: "Returning 12 of 15 | 3 will remain out"
        expect(
          find.text('Returning 12 of 15 | 3 will remain out'),
          findsOneWidget,
        );

        // Grand total is 1,400.00 ETB
        expect(find.text('1,400.00 ETB'), findsWidgets);

        // Tap confirm button to open dialog
        final confirmBtn = find.byKey(
          const ValueKey('customer_return_confirm_button'),
        );
        await tester.ensureVisible(confirmBtn);
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        // Dialog shows grand total
        expect(find.text('Confirm return'), findsWidgets);
        expect(find.text('Total to pay: 1,400.00 ETB'), findsOneWidget);

        await disposeWidgetTree(tester);
      },
    );

    testWidgets('CustomerReturnScreen manual allocation validation works', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final rentalRepo = FakeRentalRepository(initial: [_r1(), _r3()]);

      await tester.pumpWidget(
        _wrap(
          const CustomerReturnScreen(customerId: 'cust-1'),
          rentalRepo: rentalRepo,
          clock: _FakeClock(DateTime.utc(2026, 1, 5, 9)),
        ),
      );
      await tester.pumpAndSettle();

      // Enter 12 units
      final qtyField = find.byKey(const ValueKey('qty_input_mat-1'));
      await tester.enterText(qtyField, '12');
      await tester.pumpAndSettle();

      // Toggle manual allocation
      final toggleManual = find.byKey(const ValueKey('toggle_manual_mat-1'));
      await tester.ensureVisible(toggleManual);
      await tester.tap(toggleManual);
      await tester.pumpAndSettle();

      expect(find.text('Reset to oldest first'), findsOneWidget);

      // In manual mode, change line-3 to 10 (exceeds max of 5)
      final splitInputLine3 = find.byKey(const ValueKey('split_input_line-3'));
      expect(splitInputLine3, findsOneWidget);
      await tester.enterText(splitInputLine3, '10');
      await tester.pumpAndSettle();

      // Validation error must appear
      expect(find.textContaining('exceeds outstanding'), findsOneWidget);

      // Confirm button is disabled
      final confirmBtn = tester.widget<FilledButton>(
        find.byKey(const ValueKey('customer_return_confirm_button')),
      );
      expect(confirmBtn.onPressed, isNull);

      await disposeWidgetTree(tester);
    });

    testWidgets(
      'Batch summary screen displays returned lines, total, and remaining held',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final receipt = CustomerReturnReceipt(
          batchId: 'batch-test-1',
          customerId: 'cust-1',
          customerName: 'Abebe Kebede',
          returnedAt: DateTime.utc(2026, 1, 5, 9),
          allocations: [
            ReturnAllocationLine(
              rentalId: 'r1',
              rentalNumber: 1,
              rentalItemId: 'line-1',
              materialId: 'mat-1',
              materialName: 'Panel 60x120',
              rentedAt: DateTime.utc(2026, 1, 1, 9),
              quantity: 10,
              pricePerDaySnapshot: 2500,
              days: 5,
              amount: 125000,
            ),
            ReturnAllocationLine(
              rentalId: 'r3',
              rentalNumber: 3,
              rentalItemId: 'line-3',
              materialId: 'mat-1',
              materialName: 'Panel 60x120',
              rentedAt: DateTime.utc(2026, 1, 3, 9),
              quantity: 2,
              pricePerDaySnapshot: 2500,
              days: 3,
              amount: 15000,
            ),
          ],
          totalAmount: 140000,
          remainingHeld: [
            CustomerHeldMaterial(
              materialId: 'mat-1',
              materialName: 'Panel 60x120',
              totalOutstanding: 3,
              lines: const [],
            ),
          ],
          events: const [],
        );

        final rentalRepo = FakeRentalRepository();

        await tester.pumpWidget(
          _wrap(
            CustomerReturnBatchSummaryScreen(
              batchId: 'batch-test-1',
              initialReceipt: receipt,
            ),
            rentalRepo: rentalRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Batch return summary'), findsOneWidget);
        expect(find.text('Abebe Kebede'), findsOneWidget);
        // Grand total
        expect(find.text('1,400.00 ETB'), findsWidgets);
        // Still held section
        expect(find.text('Items still held by customer'), findsOneWidget);
        expect(find.text('Outstanding: 3'), findsOneWidget);
        // "Return more" and "Back to customer" buttons exist
        expect(
          find.byKey(const ValueKey('batch_return_more_button')),
          findsOneWidget,
        );

        await disposeWidgetTree(tester);
      },
    );

    testWidgets(
      'Rentals list and detail show partially returned badge and rented/returned/still out lines',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final rentedAt = DateTime.utc(2026, 1, 1, 9);
        final partialRental = RentalDetails(
          rental: RentalRecord(
            id: 'r-partial',
            rentalNumber: 42,
            customerId: 'cust-1',
            rentedAt: rentedAt,
            status: RentalStatus.partiallyReturned,
            notes: null,
            createdAt: rentedAt,
            updatedAt: rentedAt,
          ),
          customerName: 'Abebe Kebede',
          lines: [
            RentalLine(
              id: 'line-partial',
              rentalId: 'r-partial',
              materialId: 'mat-1',
              materialNameSnapshot: 'Panel 60x120',
              pricePerDaySnapshot: 2500,
              quantity: 10,
              quantityReturned: 4, // 6 outstanding
            ),
          ],
        );

        final rentalRepo = FakeRentalRepository(initial: [partialRental]);

        // Test rentals screen tile
        await tester.pumpWidget(
          _wrap(const RentalsScreen(), rentalRepo: rentalRepo),
        );
        await tester.pumpAndSettle();

        // Status badge
        expect(find.text('Partially returned'), findsWidgets);
        // Per-line breakdown: "Rented 10 | Returned 4 | Still out 6"
        expect(
          find.text('Panel 60x120: Rented 10 | Returned 4 | Still out 6'),
          findsOneWidget,
        );

        await disposeWidgetTree(tester);

        // Test rental detail screen
        await tester.pumpWidget(
          _wrap(
            const RentalDetailScreen(rentalId: 'r-partial'),
            rentalRepo: rentalRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Line card shows "Rented 10 | Returned 4 | Still out 6"
        expect(
          find.text('Rented 10 | Returned 4 | Still out 6'),
          findsOneWidget,
        );

        await disposeWidgetTree(tester);
      },
    );
  });
}
