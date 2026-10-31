import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/database/database.dart';
import 'package:t2_rental/features/customers/data/customer_repository.dart';

void main() {
  late AppDatabase database;
  late DriftCustomerRepository repository;

  setUp(() {
    database = AppDatabase.forTesting();
    repository = DriftCustomerRepository(database);
  });

  tearDown(() => database.close());

  test('creates a customer with UTC timestamps and an audit row', () async {
    final customer = await repository.create(
      fullName: ' Abebe Kebede ',
      address: 'Addis Ababa',
      phone: '0911 123 456',
      idPhotoFrontPath: 'customer_ids/front.jpg',
    );

    expect(customer.fullName, 'Abebe Kebede');
    expect(customer.phone, '0911123456');
    expect(customer.createdAt.isUtc, isTrue);
    expect(customer.updatedAt.isUtc, isTrue);
    expect(await database.select(database.auditLogs).get(), hasLength(1));
  });

  test(
    'finds possible duplicates by name and phone or name and address',
    () async {
      final first = await repository.create(
        fullName: 'Abebe   Kebede',
        address: 'Addis Ababa',
        phone: '+251911123456',
        idPhotoFrontPath: 'old.jpg',
      );
      await repository.create(
        fullName: 'Other Person',
        address: 'Addis Ababa',
        phone: '0911123456',
        idPhotoFrontPath: 'other.jpg',
      );

      final byPhone = await repository.findPossibleDuplicates(
        fullName: ' abebe kebede ',
        address: 'Different address',
        phone: '+251 911-123456',
      );
      final byAddress = await repository.findPossibleDuplicates(
        fullName: 'ABEBE KEBEDE',
        address: 'Addis   Ababa',
      );

      expect(byPhone.map((item) => item.id).toList(), [first.id]);
      expect(byAddress.map((item) => item.id).toList(), [first.id]);
    },
  );

  test(
    'updates, archives, reactivates, and audits photo replacement',
    () async {
      final created = await repository.create(
        fullName: 'Abebe Kebede',
        address: 'Addis Ababa',
        idPhotoFrontPath: 'old-front.jpg',
      );
      final updated = await repository.update(
        created.copyWith(address: 'Bole', idPhotoFrontPath: 'new-front.jpg'),
      );
      expect(updated.address, 'Bole');
      expect(updated.updatedAt.isUtc, isTrue);

      await repository.setActive(created.id, false);
      expect((await repository.getById(created.id))!.isActive, isFalse);
      await repository.setActive(created.id, true);
      expect((await repository.getById(created.id))!.isActive, isTrue);

      final audits = await (database.select(
        database.auditLogs,
      )..orderBy([(table) => OrderingTerm.asc(table.at)])).get();
      expect(audits, hasLength(5));
      expect(
        audits.map((audit) => audit.action),
        containsAll([
          'create',
          'update',
          'photo_replace',
          'archive',
          'reactivate',
        ]),
      );
      final photoAudit = audits.firstWhere(
        (audit) => audit.action == 'photo_replace',
      );
      expect(
        jsonDecode(photoAudit.oldValue!)['idPhotoFrontPath'],
        'old-front.jpg',
      );
      expect(
        jsonDecode(photoAudit.newValue!)['idPhotoFrontPath'],
        'new-front.jpg',
      );
    },
  );

  test('searches active customers by name, phone, and address', () async {
    await repository.create(
      fullName: 'Abebe Kebede',
      address: 'Addis Ababa',
      phone: '0911123456',
      idPhotoFrontPath: 'front.jpg',
    );

    expect((await repository.watchAll('abebe').first), hasLength(1));
    expect((await repository.watchAll('0911').first), hasLength(1));
    expect((await repository.watchAll('addis').first), hasLength(1));
  });
}
