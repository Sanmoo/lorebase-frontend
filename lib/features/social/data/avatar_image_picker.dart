import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'models/avatar_upload_file.dart';

enum AvatarImageSource { gallery, camera }

abstract class AvatarPickerClient {
  Future<XFile?> pickImage({required ImageSource source});
}

class ImagePickerAvatarClient implements AvatarPickerClient {
  ImagePickerAvatarClient({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<XFile?> pickImage({required ImageSource source}) {
    return _imagePicker.pickImage(source: source);
  }
}

class AvatarImagePicker {
  const AvatarImagePicker(this._client);

  final AvatarPickerClient _client;

  Future<AvatarUploadFile?> pick(AvatarImageSource source) async {
    final xFile = await _client.pickImage(source: _toImageSource(source));
    if (xFile == null) {
      return null;
    }

    final bytes = await xFile.readAsBytes();
    return AvatarUploadFile(
      bytes: bytes,
      filename: xFile.name,
      mimeType: xFile.mimeType ?? _mimeTypeFromFilename(xFile.name),
    );
  }

  ImageSource _toImageSource(AvatarImageSource source) {
    return switch (source) {
      AvatarImageSource.gallery => ImageSource.gallery,
      AvatarImageSource.camera => ImageSource.camera,
    };
  }

  String _mimeTypeFromFilename(String filename) {
    final lowerFilename = filename.toLowerCase();
    if (lowerFilename.endsWith('.jpg') || lowerFilename.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lowerFilename.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerFilename.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'application/octet-stream';
  }
}

final avatarImagePickerProvider = Provider<AvatarImagePicker>((ref) {
  return AvatarImagePicker(ImagePickerAvatarClient());
});
