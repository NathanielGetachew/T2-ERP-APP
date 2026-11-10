import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/uuid.dart';

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
    final relativePath = 'customer_ids/${uuidV4()}.jpg';
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
