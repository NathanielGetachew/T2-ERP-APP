import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/database/database.dart';
import 'package:t2_rental/features/materials/data/material_repository.dart';

void main() {
  late AppDatabase database;
  late DriftMaterialRepository repository;

  setUp(() {
    database = AppDatabase.forTesting();
    repository = DriftMaterialRepository(database);
  });
  tearDown(() => database.close());

  test('creates with UTC timestamps and writes an audit row', () async {
    final material = await repository.create(
      category: 'Panel',
      name: '60x120',
      pricePerDay: 25000,
    );
    expect(material.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(material.createdAt.isUtc, isTrue);
    expect(material.updatedAt.isUtc, isTrue);
    expect(await database.select(database.auditLogs).get(), hasLength(1));
  });

  test('rejects duplicate category and name case-insensitively', () async {
    await repository.create(
      category: 'Panel',
      name: '60x120',
      pricePerDay: 25000,
    );
    expect(
      () => repository.create(
        category: ' panel ',
        name: '60X120',
        pricePerDay: 30000,
      ),
      throwsA(isA<DuplicateMaterialException>()),
    );
  });

  test(
    'updates, orders, and deactivates/reactivates without deleting',
    () async {
      final first = await repository.create(
        category: 'Panel',
        name: 'B',
        pricePerDay: 20000,
      );
      await repository.create(category: 'Panel', name: 'A', pricePerDay: 10000);
      final rows = await repository.watchAll().first;
      expect(rows.map((row) => row.name).toList(), ['A', 'B']);
      final updated = await repository.update(first.copyWith(name: 'C'));
      expect(updated.name, 'C');
      await repository.setActive(first.id, false);
      expect(await repository.watchAll().first, hasLength(1));
      await repository.setActive(first.id, true);
      expect(await repository.watchAll().first, hasLength(2));
      expect(await database.select(database.auditLogs).get(), hasLength(5));
    },
  );
}
