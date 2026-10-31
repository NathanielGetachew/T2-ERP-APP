import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class ImageStorageService {
  Future<String> saveCustomerImage(XFile image);

  Future<File> resolve(String relativePath);

  Future<void> deleteOrphan(String relativePath);
}

class FileImageStorageService implements ImageStorageService {
  FileImageStorageService({this._documentsDirectory});

  final Directory? _documentsDirectory;

  @override
  Future<String> saveCustomerImage(XFile image) async {
    final relativePath = 'customer_ids/${_uuidV4()}.jpg';
    final target = await resolve(relativePath);
    await target.parent.create(recursive: true);
    await File(image.path).copy(target.path);
    return relativePath;
  }

  @override
  Future<File> resolve(String relativePath) async {
    final directory =
        _documentsDirectory ?? await getApplicationDocumentsDirectory();
    return File('${directory.path}${Platform.pathSeparator}$relativePath');
  }

  @override
  Future<void> deleteOrphan(String relativePath) async {
    final file = await resolve(relativePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

String _uuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
