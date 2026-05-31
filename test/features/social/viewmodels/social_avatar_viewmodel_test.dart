import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lorebase/features/social/data/avatar_image_picker.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/avatar_upload_file.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/repositories/social_repository.dart';
import 'package:lorebase/features/social/viewmodels/social_avatar_viewmodel.dart';

void main() {
  test('uploads gallery avatar and stores returned profile', () async {
    final file = _file('avatar.png', 'image/png');
    final repo = _FakeSocialRepository();
    final picker = _FakeAvatarImagePicker(file: file);
    final container = _container(repo: repo, picker: picker);
    addTearDown(container.dispose);

    await container
        .read(socialAvatarViewModelProvider.notifier)
        .uploadFrom(AvatarImageSource.gallery);

    final state = container.read(socialAvatarViewModelProvider);
    expect(picker.sources, [AvatarImageSource.gallery]);
    expect(repo.avatarFiles, [same(file)]);
    expect(state.isUploading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.profile?.avatarUrl, 'https://cdn.example/avatar.png');
  });

  test('uploads camera avatar', () async {
    final repo = _FakeSocialRepository();
    final picker = _FakeAvatarImagePicker(
      file: _file('avatar.jpg', 'image/jpeg'),
    );
    final container = _container(repo: repo, picker: picker);
    addTearDown(container.dispose);

    await container
        .read(socialAvatarViewModelProvider.notifier)
        .uploadFrom(AvatarImageSource.camera);

    expect(picker.sources, [AvatarImageSource.camera]);
    expect(repo.avatarFiles, hasLength(1));
    expect(container.read(socialAvatarViewModelProvider).errorMessage, isNull);
  });

  test('cancellation clears uploading without error', () async {
    final repo = _FakeSocialRepository();
    final picker = _FakeAvatarImagePicker();
    final container = _container(repo: repo, picker: picker);
    addTearDown(container.dispose);

    await container
        .read(socialAvatarViewModelProvider.notifier)
        .uploadFrom(AvatarImageSource.gallery);

    final state = container.read(socialAvatarViewModelProvider);
    expect(repo.avatarFiles, isEmpty);
    expect(state.isUploading, isFalse);
    expect(state.errorMessage, isNull);
  });

  test('rejects invalid type before repository upload', () async {
    final repo = _FakeSocialRepository();
    final picker = _FakeAvatarImagePicker(
      file: _file('avatar.gif', 'image/gif'),
    );
    final container = _container(repo: repo, picker: picker);
    addTearDown(container.dispose);

    await container
        .read(socialAvatarViewModelProvider.notifier)
        .uploadFrom(AvatarImageSource.gallery);

    final state = container.read(socialAvatarViewModelProvider);
    expect(repo.avatarFiles, isEmpty);
    expect(state.isUploading, isFalse);
    expect(state.errorMessage, 'Avatar must be JPEG, PNG, or WebP');
  });

  test('rejects oversized file before repository upload', () async {
    final repo = _FakeSocialRepository();
    final picker = _FakeAvatarImagePicker(
      file: _file(
        'avatar.png',
        'image/png',
        size: AvatarUploadFile.maxSizeBytes + 1,
      ),
    );
    final container = _container(repo: repo, picker: picker);
    addTearDown(container.dispose);

    await container
        .read(socialAvatarViewModelProvider.notifier)
        .uploadFrom(AvatarImageSource.gallery);

    final state = container.read(socialAvatarViewModelProvider);
    expect(repo.avatarFiles, isEmpty);
    expect(state.isUploading, isFalse);
    expect(state.errorMessage, contains('10MB'));
  });

  test('picker error is mapped to friendly message', () async {
    final repo = _FakeSocialRepository();
    final picker = _FakeAvatarImagePicker(error: Exception('picker failed'));
    final container = _container(repo: repo, picker: picker);
    addTearDown(container.dispose);

    await container
        .read(socialAvatarViewModelProvider.notifier)
        .uploadFrom(AvatarImageSource.gallery);

    final state = container.read(socialAvatarViewModelProvider);
    expect(repo.avatarFiles, isEmpty);
    expect(state.isUploading, isFalse);
    expect(state.errorMessage, 'Failed to update avatar');
  });

  test('repository error is mapped to friendly message', () async {
    final repo = _FakeSocialRepository(error: Exception('upload failed'));
    final picker = _FakeAvatarImagePicker(
      file: _file('avatar.png', 'image/png'),
    );
    final container = _container(repo: repo, picker: picker);
    addTearDown(container.dispose);

    await container
        .read(socialAvatarViewModelProvider.notifier)
        .uploadFrom(AvatarImageSource.gallery);

    final state = container.read(socialAvatarViewModelProvider);
    expect(repo.avatarFiles, hasLength(1));
    expect(state.isUploading, isFalse);
    expect(state.errorMessage, 'Failed to update avatar');
  });

  test('guards concurrent upload attempts', () async {
    final completer = Completer<AvatarUploadFile?>();
    final repo = _FakeSocialRepository();
    final picker = _FakeAvatarImagePicker(completer: completer);
    final container = _container(repo: repo, picker: picker);
    final subscription = container.listen(
      socialAvatarViewModelProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    addTearDown(container.dispose);

    final firstUpload = container
        .read(socialAvatarViewModelProvider.notifier)
        .uploadFrom(AvatarImageSource.gallery);
    await Future<void>.delayed(Duration.zero);

    final secondUpload = container
        .read(socialAvatarViewModelProvider.notifier)
        .uploadFrom(AvatarImageSource.camera);
    completer.complete(_file('avatar.png', 'image/png'));
    await Future.wait([firstUpload, secondUpload]);

    expect(picker.sources, [AvatarImageSource.gallery]);
    expect(repo.avatarFiles, hasLength(1));
  });
}

ProviderContainer _container({
  required _FakeSocialRepository repo,
  required _FakeAvatarImagePicker picker,
}) {
  return ProviderContainer(
    overrides: [
      socialRepositoryProvider.overrideWithValue(repo),
      avatarImagePickerProvider.overrideWithValue(picker),
    ],
  );
}

AvatarUploadFile _file(String filename, String mimeType, {int size = 3}) {
  return AvatarUploadFile(
    bytes: Uint8List(size),
    filename: filename,
    mimeType: mimeType,
  );
}

class _FakeAvatarImagePicker extends AvatarImagePicker {
  _FakeAvatarImagePicker({this.file, this.error, this.completer})
    : super(_UnusedAvatarPickerClient());

  final AvatarUploadFile? file;
  final Object? error;
  final Completer<AvatarUploadFile?>? completer;
  final sources = <AvatarImageSource>[];

  @override
  Future<AvatarUploadFile?> pick(AvatarImageSource source) async {
    sources.add(source);
    if (error != null) {
      throw error!;
    }
    if (completer != null) {
      return completer!.future;
    }
    return file;
  }
}

class _UnusedAvatarPickerClient implements AvatarPickerClient {
  @override
  Future<XFile?> pickImage({required ImageSource source}) {
    throw UnimplementedError();
  }
}

class _FakeSocialRepository implements SocialRepository {
  _FakeSocialRepository({this.error});

  final Object? error;
  final avatarFiles = <AvatarUploadFile>[];

  @override
  Future<SocialProfileModel> updateMyAvatar({
    required AvatarUploadFile file,
  }) async {
    avatarFiles.add(file);
    if (error != null) {
      throw error!;
    }
    return _profile(avatarUrl: 'https://cdn.example/avatar.png');
  }

  @override
  Future<SocialProfileModel> getMyProfile() => throw UnimplementedError();

  @override
  Future<SocialProfileModel> getProfile(String userId) =>
      throw UnimplementedError();

  @override
  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  }) => throw UnimplementedError();

  @override
  Future<void> followUser(String userId) => throw UnimplementedError();

  @override
  Future<void> unfollowUser(String userId) => throw UnimplementedError();

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getFeed({
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(
    String userId, {
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowing(
    String userId, {
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
    String userId, {
    String? status,
    String? mediaType,
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();
}

SocialProfileModel _profile({String? avatarUrl}) {
  return SocialProfileModel(
    userId: 'me',
    displayName: 'Fulano',
    avatarUrl: avatarUrl,
    isPublic: true,
    followingCount: 1,
    followerCount: 2,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}
