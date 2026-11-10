import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/database/database.dart';

void main() {
  test('opens the in-memory database with schema version 5', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);

    expect(database.schemaVersion, 5);
    await database.customSelect('SELECT 1').getSingle();
  });

  test(
    'migrates from schema version 4 to 5 adding return_batch_id column',
    () async {
      final database = AppDatabase.forTesting();
      addTearDown(database.close);

      // Verify the return_events table has the return_batch_id column
      final pragma = await database
          .customSelect('PRAGMA table_info(return_events);')
          .get();
      final columnNames = pragma
          .map((row) => row.data['name'] as String)
          .toList();
      expect(columnNames, contains('return_batch_id'));
    },
  );
}
