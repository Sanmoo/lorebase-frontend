import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/avatar_image_picker.dart';
import '../data/models/avatar_upload_file.dart';
import '../data/models/social_profile_model.dart';
import '../data/repositories/social_repository.dart';
import '../pages/social_page.dart';
import 'social_profile_viewmodel.dart';

part 'social_avatar_viewmodel.g.dart';

enum SocialAvatarError { invalidType, sizeLimit, accessFailure, updateFailure }

class SocialAvatarState {
  const SocialAvatarState({this.isUploading = false, this.error, this.profile});

  final bool isUploading;
  final SocialAvatarError? error;
  final SocialProfileModel? profile;

  SocialAvatarState copyWith({
    bool? isUploading,
    SocialAvatarError? error,
    bool clearError = false,
    SocialProfileModel? profile,
  }) {
    return SocialAvatarState(
      isUploading: isUploading ?? this.isUploading,
      error: clearError ? null : error ?? this.error,
      profile: profile ?? this.profile,
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

    state = state.copyWith(isUploading: true, clearError: true);

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
      );
      return;
    }

    try {
      if (!ref.mounted) {
        return;
      }
      if (file == null) {
        state = state.copyWith(isUploading: false, clearError: true);
        return;
      }

      if (!file.isSupportedMimeType) {
        state = state.copyWith(
          isUploading: false,
          error: SocialAvatarError.invalidType,
        );
        return;
      }

      if (!file.isWithinSizeLimit) {
        state = state.copyWith(
          isUploading: false,
          error: SocialAvatarError.sizeLimit,
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
      );
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isUploading: false,
        error: SocialAvatarError.updateFailure,
      );
    }
  }
}
