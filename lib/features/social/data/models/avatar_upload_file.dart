import 'dart:typed_data';

class AvatarUploadFile {
  static const maxSizeBytes = 10 * 1024 * 1024;
  static const supportedMimeTypes = {'image/jpeg', 'image/png', 'image/webp'};

  const AvatarUploadFile({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String mimeType;

  int get sizeBytes => bytes.lengthInBytes;

  bool get isSupportedMimeType =>
      supportedMimeTypes.contains(mimeType.trim().toLowerCase());

  bool get isWithinSizeLimit => sizeBytes <= maxSizeBytes;
}
