import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/exceptions.dart';
import '../data/avatar_image_picker.dart';
import '../data/models/avatar_upload_file.dart';
import '../data/models/social_profile_model.dart';
import '../data/repositories/social_repository.dart';
import '../pages/social_page.dart';
import 'social_profile_viewmodel.dart';

part 'social_avatar_viewmodel.g.dart';

enum SocialAvatarError { invalidType, sizeLimit, accessFailure, updateFailure }

class SocialAvatarState {
  const SocialAvatarState({
    this.isUploading = false,
    this.error,
    this.profile,
    this.lastUploadSucceeded = false,
  });

  final bool isUploading;
  final SocialAvatarError? error;
  final SocialProfileModel? profile;
  final bool lastUploadSucceeded;

  SocialAvatarState copyWith({
    bool? isUploading,
    SocialAvatarError? error,
    bool clearError = false,
    SocialProfileModel? profile,
    bool? lastUploadSucceeded,
  }) {
    return SocialAvatarState(
      isUploading: isUploading ?? this.isUploading,
      error: clearError ? null : error ?? this.error,
      profile: profile ?? this.profile,
      lastUploadSucceeded: lastUploadSucceeded ?? this.lastUploadSucceeded,
    );
  }
}

@riverpod
class SocialAvatarViewModel extends _$SocialAvatarViewModel {
  @override
  SocialAvatarState build() => const SocialAvatarState();

  Future<void> uploadFrom(AvatarImageSource source) async {
    if (state.isUploading) {
      return;
    }

    state = state.copyWith(
      isUploading: true,
      clearError: true,
      lastUploadSucceeded: false,
    );

    AvatarUploadFile? file;
    try {
      file = await ref.read(avatarImagePickerProvider).pick(source);
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isUploading: false,
        error: SocialAvatarError.accessFailure,
        lastUploadSucceeded: false,
      );
      return;
    }

    try {
      if (!ref.mounted) {
        return;
      }
      if (file == null) {
        state = state.copyWith(
          isUploading: false,
          clearError: true,
          lastUploadSucceeded: false,
        );
        return;
      }

      if (!file.isSupportedMimeType) {
        state = state.copyWith(
          isUploading: false,
          error: SocialAvatarError.invalidType,
          lastUploadSucceeded: false,
        );
        return;
      }

      if (!file.isWithinSizeLimit) {
        state = state.copyWith(
          isUploading: false,
          error: SocialAvatarError.sizeLimit,
          lastUploadSucceeded: false,
        );
        return;
      }

      final profile = await ref
          .read(socialRepositoryProvider)
          .updateMyAvatar(file: file);
      if (!ref.mounted) {
        return;
      }
      ref.invalidate(mySocialProfileProvider);
      ref.invalidate(socialProfileViewModelProvider('me'));
      state = state.copyWith(
        isUploading: false,
        clearError: true,
        profile: profile,
        lastUploadSucceeded: true,
      );
    } on ServerException catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isUploading: false,
        error: _avatarErrorForStatus(error.statusCode),
        lastUploadSucceeded: false,
      );
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isUploading: false,
        error: SocialAvatarError.updateFailure,
        lastUploadSucceeded: false,
      );
    }
  }

  SocialAvatarError _avatarErrorForStatus(int? statusCode) {
    return switch (statusCode) {
      413 => SocialAvatarError.sizeLimit,
      415 => SocialAvatarError.invalidType,
      _ => SocialAvatarError.updateFailure,
    };
  }
}
