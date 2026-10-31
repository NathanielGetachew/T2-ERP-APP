import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:t2_rental/core/services/image_storage_service.dart';

void main() {
  late Directory directory;
  late File source;
  late FileImageStorageService storage;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('t2-customer-images-');
    source = File('${directory.path}${Platform.pathSeparator}source.png');
    await source.writeAsBytes([1, 2, 3]);
    storage = FileImageStorageService(documentsDirectory: directory);
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('saves a relative customer path under customer_ids', () async {
    final relative = await storage.saveCustomerImage(XFile(source.path));
    expect(relative, startsWith('customer_ids/'));
    expect(relative, endsWith('.jpg'));
    final saved = await storage.resolve(relative);
    expect(await saved.exists(), isTrue);
    expect(saved.path.startsWith(directory.path), isTrue);
  });

  test('keeps old files when a new image is saved', () async {
    final oldPath = await storage.saveCustomerImage(XFile(source.path));
    final newPath = await storage.saveCustomerImage(XFile(source.path));
    expect(await (await storage.resolve(oldPath)).exists(), isTrue);
    expect(await (await storage.resolve(newPath)).exists(), isTrue);
  });

  test('deletes an orphan path explicitly', () async {
    final relative = await storage.saveCustomerImage(XFile(source.path));
    // The customer save transaction failed after the file was created.
    await storage.deleteOrphan(relative);
    expect(await (await storage.resolve(relative)).exists(), isFalse);
  });
}
