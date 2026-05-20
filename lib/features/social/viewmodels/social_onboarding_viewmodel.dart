import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/social_privacy.dart';
import '../data/models/social_profile_model.dart';
import '../data/repositories/social_repository.dart';

part 'social_onboarding_viewmodel.g.dart';

class SocialOnboardingState {
  final SocialProfileModel? profile;
  final String? validationError;
  final String? errorMessage;
  final bool isSaving;

  const SocialOnboardingState({
    this.profile,
    this.validationError,
    this.errorMessage,
    this.isSaving = false,
  });

  SocialOnboardingState copyWith({
    SocialProfileModel? profile,
    String? validationError,
    String? errorMessage,
    bool? isSaving,
    bool clearValidationError = false,
    bool clearErrorMessage = false,
  }) {
    return SocialOnboardingState(
      profile: profile ?? this.profile,
      validationError: clearValidationError
          ? null
          : validationError ?? this.validationError,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

@riverpod
class SocialOnboardingViewModel extends _$SocialOnboardingViewModel {
  @override
  SocialOnboardingState build() {
    return const SocialOnboardingState();
  }

  Future<void> saveProfile({
    required String displayName,
    String? avatarUrl,
    required SocialPrivacy privacy,
  }) async {
    if (state.isSaving) {
      return;
    }

    final trimmedDisplayName = displayName.trim();
    if (trimmedDisplayName.isEmpty) {
      state = state.copyWith(
        validationError: 'Display name is required',
        isSaving: false,
      );
      return;
    }

    state = state.copyWith(
      isSaving: true,
      clearValidationError: true,
      clearErrorMessage: true,
    );
    try {
      final profile = await ref
          .read(socialRepositoryProvider)
          .updateMyProfile(
            displayName: trimmedDisplayName,
            avatarUrl: avatarUrl,
            isPublic: privacy.isPublic,
          );
      state = SocialOnboardingState(profile: profile);
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Failed to save profile',
        isSaving: false,
      );
    }
  }
}
