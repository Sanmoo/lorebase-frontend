import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/avatar_image_picker.dart';
import '../data/models/social_profile_model.dart';
import '../data/repositories/social_repository.dart';
import '../pages/social_page.dart';
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
    bool clearErrorMessage = false,
    SocialProfileModel? profile,
  }) {
    return SocialAvatarState(
      isUploading: isUploading ?? this.isUploading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
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

    state = state.copyWith(isUploading: true, clearErrorMessage: true);

    try {
      final file = await ref.read(avatarImagePickerProvider).pick(source);
      if (!ref.mounted) {
        return;
      }
      if (file == null) {
        state = state.copyWith(isUploading: false, clearErrorMessage: true);
        return;
      }

      if (!file.isSupportedMimeType) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: 'Avatar must be JPEG, PNG, or WebP',
        );
        return;
      }

      if (!file.isWithinSizeLimit) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: 'Avatar file must be 10MB or smaller',
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
        clearErrorMessage: true,
        profile: profile,
      );
    } catch (_) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Failed to update avatar',
      );
    }
  }
}
