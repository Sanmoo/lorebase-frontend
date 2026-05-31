import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lorebase/features/social/data/avatar_image_picker.dart';

void main() {
  group('AvatarImagePicker', () {
    test('converts picked XFile to AvatarUploadFile', () async {
      final client = _FakeAvatarPickerClient(
        file: await _xFile(
          bytes: [1, 2, 3],
          name: 'avatar.png',
          mimeType: 'image/png',
        ),
      );
      final picker = AvatarImagePicker(client);

      final file = await picker.pick(AvatarImageSource.gallery);

      expect(file, isNotNull);
      expect(file!.bytes, [1, 2, 3]);
      expect(file.filename, 'avatar.png');
      expect(file.mimeType, 'image/png');
    });

    test('returns null when picking is cancelled', () async {
      final picker = AvatarImagePicker(_FakeAvatarPickerClient());

      final file = await picker.pick(AvatarImageSource.gallery);

      expect(file, isNull);
    });

    test('propagates picker errors', () async {
      final error = StateError('picker failed');
      final picker = AvatarImagePicker(_FakeAvatarPickerClient(error: error));

      expect(
        () => picker.pick(AvatarImageSource.gallery),
        throwsA(same(error)),
      );
    });

    test('maps gallery source to image picker gallery source', () async {
      final client = _FakeAvatarPickerClient();
      final picker = AvatarImagePicker(client);

      await picker.pick(AvatarImageSource.gallery);

      expect(client.sources, [ImageSource.gallery]);
    });

    test('maps camera source to image picker camera source', () async {
      final client = _FakeAvatarPickerClient();
      final picker = AvatarImagePicker(client);

      await picker.pick(AvatarImageSource.camera);

      expect(client.sources, [ImageSource.camera]);
    });

    test('falls back to mime type from filename extension', () async {
      final picker = AvatarImagePicker(
        _FakeAvatarPickerClient(
          file: await _xFile(bytes: [1], name: 'avatar.webp'),
        ),
      );

      final file = await picker.pick(AvatarImageSource.gallery);

      expect(file!.mimeType, 'image/webp');
    });

    test('falls back to octet stream for unknown filename extension', () async {
      final picker = AvatarImagePicker(
        _FakeAvatarPickerClient(
          file: await _xFile(bytes: [1], name: 'avatar.gif'),
        ),
      );

      final file = await picker.pick(AvatarImageSource.gallery);

      expect(file!.mimeType, 'application/octet-stream');
    });
  });
}

Future<XFile> _xFile({
  required List<int> bytes,
  required String name,
  String? mimeType,
}) async {
  final tempDirectory = await Directory.systemTemp.createTemp(
    'avatar_image_picker_test',
  );
  final file = File('${tempDirectory.path}/$name');
  await file.writeAsBytes(bytes);
  return XFile(file.path, name: name, mimeType: mimeType);
}

class _FakeAvatarPickerClient implements AvatarPickerClient {
  _FakeAvatarPickerClient({this.file, this.error});

  final XFile? file;
  final Object? error;
  final sources = <ImageSource>[];

  @override
  Future<XFile?> pickImage({required ImageSource source}) async {
    sources.add(source);
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return file;
  }
}
