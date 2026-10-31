import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'package:t2_rental/core/services/image_capture_service.dart';
import 'package:t2_rental/core/services/image_storage_service.dart';

class FakeImageCaptureService implements ImageCaptureService {
  FakeImageCaptureService({XFile? image})
    : image = image ?? XFile('fake-capture.jpg');

  final XFile? image;

  @override
  Future<XFile?> takePhoto() async => image;

  @override
  Future<XFile?> chooseFromGallery() async => image;
}

class FakeImageStorageService implements ImageStorageService {
  int saveCount = 0;
  final List<String> deletedPaths = [];

  @override
  Future<String> saveCustomerImage(XFile image) async {
    saveCount++;
    return 'customer_ids/fake-$saveCount.jpg';
  }

  @override
  Future<File> resolve(String relativePath) async => File(relativePath);

  @override
  Future<void> deleteOrphan(String relativePath) async {
    deletedPaths.add(relativePath);
  }
}
