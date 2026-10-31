import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:t2_rental/features/customers/application/customer_providers.dart';
import 'package:t2_rental/features/rentals/application/rental_providers.dart';
import 'package:t2_rental/features/customers/domain/customer.dart';
import 'package:t2_rental/features/customers/presentation/customer_detail_screen.dart';
import 'package:t2_rental/l10n/generated/app_localizations.dart';

import '../../helpers/fake_customer_repository.dart';
import '../../helpers/fake_image_services.dart';
import '../../helpers/fake_rental_repository.dart';
import '../../helpers/widget_test_helpers.dart';

Customer _customer() {
  final now = DateTime.utc(2026, 1, 1);
  return Customer(
    id: 'customer-1',
    fullName: 'Abebe Kebede',
    address: 'Addis Ababa',
    phone: null,
    notes: null,
    idPhotoFrontPath: 'customer_ids/old-front.jpg',
    idPhotoBackPath: null,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildProfile(
  FakeCustomerRepository repository,
  FakeImageCaptureService capture,
  FakeImageStorageService storage,
) {
  return ProviderScope(
    overrides: [
      customerRepositoryProvider.overrideWithValue(repository),
      rentalRepositoryProvider.overrideWithValue(FakeRentalRepository()),
      imageCaptureServiceProvider.overrideWithValue(capture),
      imageStorageServiceProvider.overrideWithValue(storage),
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
      home: const CustomerDetailScreen(customerId: 'customer-1'),
    ),
  );
}

void main() {
  testWidgets('profile retake replaces the front photo', (tester) async {
    final repository = FakeCustomerRepository(initial: [_customer()]);
    final storage = FakeImageStorageService();
    await tester.pumpWidget(
      _buildProfile(repository, FakeImageCaptureService(), storage),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(
      find.byKey(const ValueKey('customer_retake_front_photo_button')),
    );
    await tester.pump();
    await tester.tap(find.text('Replace photo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.photoReplacementCalls, hasLength(1));
    expect(
      repository.photoReplacementCalls.single.idPhotoFrontPath,
      'customer_ids/fake-1.jpg',
    );
    expect(find.text('Photo replaced.'), findsOneWidget);
    await disposeWidgetTree(tester);
  });

  testWidgets('failed profile replacement deletes the new orphan', (
    tester,
  ) async {
    final repository = FakeCustomerRepository(
      initial: [_customer()],
      failPhotoReplacement: true,
    );
    final storage = FakeImageStorageService();
    await tester.pumpWidget(
      _buildProfile(repository, FakeImageCaptureService(), storage),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(
      find.byKey(const ValueKey('customer_retake_front_photo_button')),
    );
    await tester.pump();
    await tester.tap(find.text('Replace photo'));
    await tester.pump();

    expect(storage.deletedPaths, ['customer_ids/fake-1.jpg']);
    await disposeWidgetTree(tester);
  });
}
