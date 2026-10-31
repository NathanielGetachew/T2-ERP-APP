import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/database/database.dart';

void main() {
  test('opens the in-memory database with schema version 2', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);

    expect(database.schemaVersion, 2);
    await database.customSelect('SELECT 1').getSingle();
  });
}
