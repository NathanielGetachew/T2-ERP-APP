import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

abstract interface class ImageCaptureService {
  Future<XFile?> takePhoto();

  Future<XFile?> chooseFromGallery();
}

class ImageCaptureException implements Exception {
  const ImageCaptureException({required this.permissionDenied});

  final bool permissionDenied;
}

class ImagePickerCaptureService implements ImageCaptureService {
  ImagePickerCaptureService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<XFile?> takePhoto() => _pick(ImageSource.camera);

  @override
  Future<XFile?> chooseFromGallery() => _pick(ImageSource.gallery);

  Future<XFile?> _pick(ImageSource source) async {
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
    } on PlatformException catch (error) {
      throw ImageCaptureException(
        permissionDenied: error.code == 'camera_access_denied',
      );
    } catch (_) {
      throw const ImageCaptureException(permissionDenied: false);
    }
  }
}
