import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/avatar_upload_file.dart';

void main() {
  test('stores upload metadata and bytes', () {
    final file = AvatarUploadFile(
      bytes: Uint8List.fromList([1, 2, 3]),
      filename: 'avatar.png',
      mimeType: 'image/png',
    );

    expect(file.filename, 'avatar.png');
    expect(file.mimeType, 'image/png');
    expect(file.sizeBytes, 3);
    expect(file.isSupportedMimeType, isTrue);
  });

  test('detects unsupported mime type', () {
    final file = AvatarUploadFile(
      bytes: Uint8List.fromList([1]),
      filename: 'avatar.heic',
      mimeType: 'image/heic',
    );

    expect(file.isSupportedMimeType, isFalse);
  });

  test('normalizes mime type before checking support', () {
    final file = AvatarUploadFile(
      bytes: Uint8List.fromList([1]),
      filename: 'avatar.png',
      mimeType: ' IMAGE/PNG ',
    );

    expect(file.isSupportedMimeType, isTrue);
  });

  test('size limit allows exactly the maximum size', () {
    final file = AvatarUploadFile(
      bytes: Uint8List(AvatarUploadFile.maxSizeBytes),
      filename: 'avatar.png',
      mimeType: 'image/png',
    );

    expect(file.isWithinSizeLimit, isTrue);
  });

  test('size limit rejects one byte over the maximum size', () {
    final file = AvatarUploadFile(
      bytes: Uint8List(AvatarUploadFile.maxSizeBytes + 1),
      filename: 'avatar.png',
      mimeType: 'image/png',
    );

    expect(file.isWithinSizeLimit, isFalse);
  });
}
