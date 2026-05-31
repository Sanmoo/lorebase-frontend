# User Avatar Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users update their social avatar from gallery or camera and immediately persist it through `PUT /users/me/avatar`.

**Architecture:** Keep all feature code under `lib/features/social/`. Add a picker abstraction, an upload file model, a repository method for the backend contract, a Riverpod avatar view model, and small UI hooks in the profile header/edit page. Use bytes-based `XFile.readAsBytes()` for web/mobile compatibility.

**Tech Stack:** Flutter, Riverpod codegen, Dio multipart upload, `image_picker`, existing social profile providers/tests.

---

## File Map

- Modify `pubspec.yaml`: add `image_picker` and `http_parser` if Dio `MultipartFile` content type needs `MediaType`.
- Create `lib/features/social/data/models/avatar_upload_file.dart`: immutable upload payload (`bytes`, `filename`, `mimeType`, `sizeBytes`).
- Modify `lib/features/social/data/repositories/social_repository.dart`: add `updateMyAvatar` interface/implementation.
- Create `lib/features/social/data/avatar_image_picker.dart`: provider-backed wrapper around `image_picker`.
- Create `lib/features/social/viewmodels/social_avatar_viewmodel.dart`: Riverpod state/mutations for gallery/camera upload.
- Modify `lib/features/social/widgets/social_profile_header.dart`: show network avatar, loading overlay, editable avatar callback.
- Modify `lib/features/social/pages/edit_social_profile_page.dart`: remove manual avatar URL field and add change-photo UI.
- Modify `lib/features/social/pages/social_profile_page.dart`: wire avatar view model into header.
- Modify `lib/l10n/*.i18n.json`: add user-facing strings; regenerate slang.
- Tests under `test/features/social/...` matching the changed files.

---

### Task 1: Add dependencies and upload file model

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/features/social/data/models/avatar_upload_file.dart`
- Test: `test/features/social/data/avatar_upload_file_test.dart`

- [ ] **Step 1: Write the model test**

Create `test/features/social/data/avatar_upload_file_test.dart`:

```dart
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
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/social/data/avatar_upload_file_test.dart`

Expected: FAIL because `avatar_upload_file.dart` does not exist.

- [ ] **Step 3: Add dependencies**

In `pubspec.yaml`, under dependencies, add:

```yaml
  image_picker: ^1.1.2
  http_parser: ^4.0.2
```

Run: `flutter pub get`

- [ ] **Step 4: Implement the model**

Create `lib/features/social/data/models/avatar_upload_file.dart`:

```dart
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

  bool get isSupportedMimeType => supportedMimeTypes.contains(mimeType);

  bool get isWithinSizeLimit => sizeBytes <= maxSizeBytes;
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/social/data/avatar_upload_file_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/features/social/data/models/avatar_upload_file.dart test/features/social/data/avatar_upload_file_test.dart
git commit -m "feat(social): add avatar upload file model"
```

---

### Task 2: Add repository multipart upload

**Files:**
- Modify: `lib/features/social/data/repositories/social_repository.dart`
- Test: `test/features/social/data/social_repository_test.dart`

- [ ] **Step 1: Add failing repository test**

In `test/features/social/data/social_repository_test.dart`, add a test near other `SocialRepositoryImpl` tests:

```dart
test('updateMyAvatar sends multipart avatar and parses updated profile', () async {
  late RequestOptions captured;
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'userId': 'user-1',
                'displayName': 'Alice',
                'avatarUrl': 'https://cdn.example/avatar.png',
                'isPublic': true,
                'followingCount': 0,
                'followerCount': 0,
                'createdAt': '2026-05-30T12:00:00Z',
                'updatedAt': '2026-05-30T12:00:00Z',
              },
            ),
          );
        },
      ),
    );
  final repo = SocialRepositoryImpl(dio);

  final profile = await repo.updateMyAvatar(
    file: AvatarUploadFile(
      bytes: Uint8List.fromList([1, 2, 3]),
      filename: 'avatar.png',
      mimeType: 'image/png',
    ),
  );

  expect(captured.method, 'PUT');
  expect(captured.path, '/users/me/avatar');
  expect(captured.data, isA<FormData>());
  final formData = captured.data as FormData;
  expect(formData.files.single.key, 'avatar');
  expect(formData.files.single.value.filename, 'avatar.png');
  expect(profile.avatarUrl, 'https://cdn.example/avatar.png');
});
```

Add needed imports: `dart:typed_data`, `package:dio/dio.dart`, and `avatar_upload_file.dart` if missing.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/social/data/social_repository_test.dart --plain-name 'updateMyAvatar sends multipart avatar and parses updated profile'`

Expected: FAIL because `updateMyAvatar` does not exist.

- [ ] **Step 3: Implement repository method**

In `SocialRepository`, add:

```dart
Future<SocialProfileModel> updateMyAvatar({required AvatarUploadFile file});
```

In `SocialRepositoryImpl`, add:

```dart
@override
Future<SocialProfileModel> updateMyAvatar({required AvatarUploadFile file}) async {
  try {
    final response = await _dio.put(
      '/users/me/avatar',
      data: FormData.fromMap({
        'avatar': MultipartFile.fromBytes(
          file.bytes,
          filename: file.filename,
          contentType: MediaType.parse(file.mimeType),
        ),
      }),
    );
    return _profileFromResponse(response.data);
  } on DioException catch (e) {
    throw _repositoryException(e, 'Failed to update avatar');
  }
}
```

Add imports:

```dart
import 'package:http_parser/http_parser.dart';
import '../models/avatar_upload_file.dart';
```

- [ ] **Step 4: Update fake repositories to compile**

Every test fake implementing `SocialRepository` must add:

```dart
@override
Future<SocialProfileModel> updateMyAvatar({required AvatarUploadFile file}) {
  throw UnimplementedError();
}
```

Add the `avatar_upload_file.dart` import in those test files.

- [ ] **Step 5: Run repository tests**

Run: `flutter test test/features/social/data/social_repository_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/social/data/repositories/social_repository.dart test/features/social
git commit -m "feat(social): upload avatar through repository"
```

---

### Task 3: Add picker abstraction

**Files:**
- Create: `lib/features/social/data/avatar_image_picker.dart`
- Test: `test/features/social/data/avatar_image_picker_test.dart`

- [ ] **Step 1: Write tests with fake picker adapter**

Create `test/features/social/data/avatar_image_picker_test.dart` testing that an `XFile` result becomes `AvatarUploadFile`, cancellation returns null, and picker errors propagate. Use a fake adapter class rather than invoking platform plugins.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/social/data/avatar_image_picker_test.dart`

Expected: FAIL because picker abstraction does not exist.

- [ ] **Step 3: Implement picker abstraction**

Create `lib/features/social/data/avatar_image_picker.dart` with:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'models/avatar_upload_file.dart';

enum AvatarImageSource { gallery, camera }

abstract class AvatarPickerClient {
  Future<XFile?> pickImage({required ImageSource source});
}

class ImagePickerAvatarClient implements AvatarPickerClient {
  ImagePickerAvatarClient(this._picker);

  final ImagePicker _picker;

  @override
  Future<XFile?> pickImage({required ImageSource source}) {
    return _picker.pickImage(source: source);
  }
}

class AvatarImagePicker {
  AvatarImagePicker(this._client);

  final AvatarPickerClient _client;

  Future<AvatarUploadFile?> pick(AvatarImageSource source) async {
    final xFile = await _client.pickImage(
      source: source == AvatarImageSource.gallery
          ? ImageSource.gallery
          : ImageSource.camera,
    );
    if (xFile == null) {
      return null;
    }
    final bytes = await xFile.readAsBytes();
    return AvatarUploadFile(
      bytes: bytes,
      filename: xFile.name,
      mimeType: xFile.mimeType ?? _mimeTypeFromName(xFile.name),
    );
  }

  String _mimeTypeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'application/octet-stream';
  }
}

final avatarImagePickerProvider = Provider<AvatarImagePicker>((ref) {
  return AvatarImagePicker(ImagePickerAvatarClient(ImagePicker()));
});
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/features/social/data/avatar_image_picker_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/data/avatar_image_picker.dart test/features/social/data/avatar_image_picker_test.dart
git commit -m "feat(social): add avatar image picker abstraction"
```

---

### Task 4: Add avatar upload view model

**Files:**
- Create: `lib/features/social/viewmodels/social_avatar_viewmodel.dart`
- Generated: `lib/features/social/viewmodels/social_avatar_viewmodel.g.dart`
- Test: `test/features/social/viewmodels/social_avatar_viewmodel_test.dart`

- [ ] **Step 1: Write view model tests**

Create tests for gallery success, camera success, cancellation, invalid type, oversized file, picker error, and repository error. Override `avatarImagePickerProvider` and `socialRepositoryProvider`. Assert state fields and repository call counts.

- [ ] **Step 2: Run tests to verify failure**

Run: `flutter test test/features/social/viewmodels/social_avatar_viewmodel_test.dart`

Expected: FAIL because view model does not exist.

- [ ] **Step 3: Implement state and view model**

Create `lib/features/social/viewmodels/social_avatar_viewmodel.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/avatar_image_picker.dart';
import '../data/models/avatar_upload_file.dart';
import '../data/models/social_profile_model.dart';
import '../data/repositories/social_repository.dart';
import 'social_profile_viewmodel.dart';

part 'social_avatar_viewmodel.g.dart';

class SocialAvatarState {
  const SocialAvatarState({
    this.isUploading = false,
    this.errorMessage,
    this.profile,
  });

  final bool isUploading;
  final String? errorMessage;
  final SocialProfileModel? profile;

  SocialAvatarState copyWith({
    bool? isUploading,
    String? errorMessage,
    SocialProfileModel? profile,
    bool clearError = false,
  }) {
    return SocialAvatarState(
      isUploading: isUploading ?? this.isUploading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      profile: profile ?? this.profile,
    );
  }
}

@riverpod
class SocialAvatarViewModel extends _$SocialAvatarViewModel {
  @override
  SocialAvatarState build() => const SocialAvatarState();

  Future<void> uploadFrom(AvatarImageSource source) async {
    if (state.isUploading) return;
    state = state.copyWith(isUploading: true, clearError: true);
    try {
      final file = await ref.read(avatarImagePickerProvider).pick(source);
      if (file == null) {
        state = state.copyWith(isUploading: false, clearError: true);
        return;
      }
      final validationError = _validate(file);
      if (validationError != null) {
        state = state.copyWith(isUploading: false, errorMessage: validationError);
        return;
      }
      final profile = await ref.read(socialRepositoryProvider).updateMyAvatar(file: file);
      ref.invalidate(mySocialProfileProvider);
      ref.invalidate(socialProfileViewModelProvider('me'));
      state = SocialAvatarState(profile: profile);
    } catch (_) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Failed to update avatar',
      );
    }
  }

  String? _validate(AvatarUploadFile file) {
    if (!file.isSupportedMimeType) return 'Avatar must be JPEG, PNG, or WebP';
    if (!file.isWithinSizeLimit) return 'Avatar must be 10 MB or smaller';
    return null;
  }
}
```

- [ ] **Step 4: Run code generation**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: generates `social_avatar_viewmodel.g.dart` and no errors.

- [ ] **Step 5: Run view model tests**

Run: `flutter test test/features/social/viewmodels/social_avatar_viewmodel_test.dart`

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/social/viewmodels/social_avatar_viewmodel.dart lib/features/social/viewmodels/social_avatar_viewmodel.g.dart test/features/social/viewmodels/social_avatar_viewmodel_test.dart
git commit -m "feat(social): manage avatar upload state"
```

---

### Task 5: Update profile header UI

**Files:**
- Modify: `lib/features/social/widgets/social_profile_header.dart`
- Test: `test/features/social/widgets/social_profile_header_test.dart`

- [ ] **Step 1: Add widget tests**

Add tests that:

```dart
expect(find.byType(CircleAvatar), findsOneWidget);
```

for fallback, plus tests that when `avatarUrl` is set the `CircleAvatar.backgroundImage` is not null, and tapping the avatar for `isMe: true` calls `onAvatarEdit`.

- [ ] **Step 2: Run tests to verify failure**

Run: `flutter test test/features/social/widgets/social_profile_header_test.dart`

Expected: FAIL because `onAvatarEdit` and network image display do not exist.

- [ ] **Step 3: Implement header changes**

Add constructor params:

```dart
this.onAvatarEdit,
this.isAvatarUploading = false,
```

Add fields:

```dart
final VoidCallback? onAvatarEdit;
final bool isAvatarUploading;
```

Replace the current `CircleAvatar` with a tappable stack that uses `NetworkImage(profile.avatarUrl!)` when present, initial fallback otherwise, an edit icon for `isMe`, and a spinner overlay when `isAvatarUploading`.

- [ ] **Step 4: Run tests**

Run: `flutter test test/features/social/widgets/social_profile_header_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/widgets/social_profile_header.dart test/features/social/widgets/social_profile_header_test.dart
git commit -m "feat(social): make profile avatar editable"
```

---

### Task 6: Wire upload flow into pages

**Files:**
- Modify: `lib/features/social/pages/social_profile_page.dart`
- Modify: `lib/features/social/pages/edit_social_profile_page.dart`
- Test: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Add page tests**

Add tests that the own profile header can open avatar source choices, gallery choice calls the avatar view model, and edit profile no longer shows the avatar URL text field but shows a change-photo action.

- [ ] **Step 2: Run tests to verify failure**

Run: `flutter test test/features/social/pages/social_pages_test.dart --plain-name avatar`

Expected: FAIL because UI is not wired yet.

- [ ] **Step 3: Implement shared source picker UI**

In the pages or a small private helper, show a bottom sheet/dialog with gallery, camera, cancel. On gallery/camera, call:

```dart
await ref.read(socialAvatarViewModelProvider.notifier).uploadFrom(AvatarImageSource.gallery);
await ref.read(socialAvatarViewModelProvider.notifier).uploadFrom(AvatarImageSource.camera);
```

After the call, if `errorMessage != null`, show a SnackBar. If success, show a short confirmation.

- [ ] **Step 4: Update `SocialProfilePage`**

Watch `socialAvatarViewModelProvider`; pass `isAvatarUploading` and `onAvatarEdit` to `SocialProfileHeader` only for `isMe`.

- [ ] **Step 5: Update `EditSocialProfilePage`**

Remove `_avatarUrlController`, its dispose call, text field, and `avatarUrl` save argument derived from the controller. Add an avatar preview/change-photo button near the top and call the same source picker. Preserve display name/privacy save behavior.

- [ ] **Step 6: Run page tests**

Run: `flutter test test/features/social/pages/social_pages_test.dart`

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/features/social/pages/social_profile_page.dart lib/features/social/pages/edit_social_profile_page.dart test/features/social/pages/social_pages_test.dart
git commit -m "feat(social): wire avatar upload into profile UI"
```

---

### Task 7: Localize strings and polish error messages

**Files:**
- Modify: `lib/l10n/en.i18n.json`
- Modify: `lib/l10n/en_US.i18n.json`
- Modify: `lib/l10n/es.i18n.json`
- Modify: `lib/l10n/pt_BR.i18n.json`
- Generated: `lib/l10n/strings*.g.dart`
- Modify any UI/view model code still using hard-coded avatar strings.

- [ ] **Step 1: Add localized keys**

Add keys for change photo, choose gallery, take photo, avatar updated, generic failure, permission failure, invalid type, and size limit.

- [ ] **Step 2: Replace hard-coded strings**

Use `context.t.<key>` in UI and either localized mapping in UI or stable error codes in view model to avoid hard-coded user-facing strings.

- [ ] **Step 3: Regenerate translations**

Run: `dart run slang`

Expected: generated string files update cleanly.

- [ ] **Step 4: Run focused tests**

Run:

```bash
flutter test test/features/social/widgets/social_profile_header_test.dart test/features/social/pages/social_pages_test.dart test/features/social/viewmodels/social_avatar_viewmodel_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/l10n lib/features/social test/features/social
git commit -m "feat(social): localize avatar upload flow"
```

---

### Task 8: Full verification

**Files:**
- No planned source changes unless verification reveals issues.

- [ ] **Step 1: Run code generation check**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: completes with no conflicts.

- [ ] **Step 2: Run analyzer**

Run: `make analyze`

Expected: PASS.

- [ ] **Step 3: Run tests**

Run: `flutter test`

Expected: PASS.

- [ ] **Step 4: Add WorkQ comment**

Run:

```bash
workq comments add lorebase-frontend:task-000023 "Implemented avatar upload frontend support using PUT /users/me/avatar. Verification: make analyze and flutter test passed."
```

Only do this after verification actually passes.

- [ ] **Step 5: Do not mark task done**

Per task instruction, do not run `workq done` unless the human explicitly asks.

---

## Self-Review

- Spec coverage: UI locations, immediate upload, backend contract, web/mobile bytes, cancellation, validation, errors, state refresh, and tests are covered.
- Placeholder scan: no deferred implementation placeholders remain; Task 3 and Task 6 allow implementation detail choices but provide concrete APIs and commands.
- Type consistency: `AvatarUploadFile`, `AvatarImageSource`, `avatarImagePickerProvider`, `SocialAvatarViewModel`, and `updateMyAvatar` names are consistent across tasks.
