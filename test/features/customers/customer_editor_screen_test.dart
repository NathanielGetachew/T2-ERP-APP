import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:t2_rental/features/customers/application/customer_providers.dart';
import 'package:t2_rental/features/customers/presentation/customer_editor_screen.dart';
import 'package:t2_rental/l10n/generated/app_localizations.dart';

import '../../helpers/fake_customer_repository.dart';
import '../../helpers/fake_image_services.dart';
import '../../helpers/widget_test_helpers.dart';

Widget _buildEditor(
  FakeCustomerRepository repository,
  FakeImageCaptureService capture,
  FakeImageStorageService storage,
) {
  return ProviderScope(
    overrides: [
      customerRepositoryProvider.overrideWithValue(repository),
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
      home: const CustomerEditorScreen(),
    ),
  );
}

Future<void> _enterBasicDetails(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'Abebe Kebede');
  await tester.enterText(find.byType(TextFormField).at(1), 'Addis Ababa');
}

void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _captureFront(WidgetTester tester) async {
  await _tapVisible(
    tester,
    find.byKey(const ValueKey('customer_front_photo_button')),
  );
}

void main() {
  testWidgets('required customer fields show validation messages', (
    tester,
  ) async {
    _setTallViewport(tester);
    final repository = FakeCustomerRepository();
    await tester.pumpWidget(
      _buildEditor(
        repository,
        FakeImageCaptureService(),
        FakeImageStorageService(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('customer_save_button')),
    );

    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('Address is required.'), findsOneWidget);
    await disposeWidgetTree(tester);
  });

  testWidgets('front ID photo is required', (tester) async {
    _setTallViewport(tester);
    final repository = FakeCustomerRepository();
    await tester.pumpWidget(
      _buildEditor(
        repository,
        FakeImageCaptureService(),
        FakeImageStorageService(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _enterBasicDetails(tester);
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('customer_save_button')),
    );

    expect(find.text('A front ID photo is required.'), findsOneWidget);
    expect(repository.createCalls, isEmpty);
    await disposeWidgetTree(tester);
  });

  testWidgets('duplicate warning allows continuing', (tester) async {
    _setTallViewport(tester);
    final repository = FakeCustomerRepository([
      await FakeCustomerRepository().create(
        fullName: 'Abebe Kebede',
        address: 'Addis Ababa',
        idPhotoFrontPath: 'existing.jpg',
      ),
    ]);
    final storage = FakeImageStorageService();
    await tester.pumpWidget(
      _buildEditor(repository, FakeImageCaptureService(), storage),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _enterBasicDetails(tester);
    await _captureFront(tester);
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('customer_save_button')),
    );

    expect(find.text('Possible duplicate'), findsOneWidget);
    await tester.tap(find.text('Continue saving'));
    await tester.pump();
    expect(repository.createCalls, hasLength(1));
    await disposeWidgetTree(tester);
  });

  testWidgets('valid customer save calls the fake repository', (tester) async {
    _setTallViewport(tester);
    final repository = FakeCustomerRepository();
    final storage = FakeImageStorageService();
    await tester.pumpWidget(
      _buildEditor(repository, FakeImageCaptureService(), storage),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _enterBasicDetails(tester);
    await _captureFront(tester);
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('customer_save_button')),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.createCalls, hasLength(1));
    expect(repository.createCalls.single.fullName, 'Abebe Kebede');
    expect(repository.createCalls.single.address, 'Addis Ababa');
    expect(repository.createCalls.single.idPhotoFrontPath, isNotEmpty);
    await disposeWidgetTree(tester);
  });
}
