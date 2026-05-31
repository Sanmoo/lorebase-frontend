// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/strings.g.dart';
import '../data/avatar_image_picker.dart';
import '../data/models/social_privacy.dart';
import '../viewmodels/social_avatar_viewmodel.dart';
import '../viewmodels/social_onboarding_viewmodel.dart';
import '../viewmodels/social_profile_viewmodel.dart';
import 'social_page.dart';

class EditSocialProfilePage extends ConsumerStatefulWidget {
  const EditSocialProfilePage({super.key});

  @override
  ConsumerState<EditSocialProfilePage> createState() =>
      _EditSocialProfilePageState();
}

class _EditSocialProfilePageState extends ConsumerState<EditSocialProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  SocialPrivacy _privacy = SocialPrivacy.public;
  String? _avatarUrl;
  bool _initialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(mySocialProfileProvider);
    final state = ref.watch(socialOnboardingViewModelProvider);
    final avatarState = ref.watch(socialAvatarViewModelProvider);
    final t = context.t;

    return profile.when(
      data: (profile) {
        if (!_initialized) {
          _displayNameController.text = profile.displayName;
          _avatarUrl = profile.avatarUrl;
          _privacy = profile.isPublic
              ? SocialPrivacy.public
              : SocialPrivacy.private;
          _initialized = true;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.social_edit_profile_title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _AvatarEditor(
                  displayName: profile.displayName,
                  avatarUrl: avatarState.profile?.avatarUrl ?? _avatarUrl,
                  isUploading: avatarState.isUploading,
                  onChangePhoto: avatarState.isUploading
                      ? null
                      : () => _pickAvatarSource(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(labelText: t.social_display_name),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? t.social_display_name_required
                      : null,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(t.social_public_profile),
                  value: _privacy == SocialPrivacy.public,
                  onChanged: (value) => setState(
                    () => _privacy = value
                        ? SocialPrivacy.public
                        : SocialPrivacy.private,
                  ),
                ),
                if (state.errorMessage != null) Text(state.errorMessage!),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: state.isSaving ? null : _submit,
                  child: Text(t.social_save_changes),
                ),
              ],
            ),
          ),
        );
      },
      error: (_, _) => Center(child: Text(t.social_profile_load_error)),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _pickAvatarSource() async {
    final source = await showModalBottomSheet<AvatarImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.t.social_choose_from_gallery),
              onTap: () => Navigator.of(context).pop(AvatarImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.t.social_take_photo),
              onTap: () => Navigator.of(context).pop(AvatarImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(context.t.social_cancel),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) {
      return;
    }

    await ref.read(socialAvatarViewModelProvider.notifier).uploadFrom(source);
    if (!mounted) {
      return;
    }
    final avatarState = ref.read(socialAvatarViewModelProvider);
    if (avatarState.lastUploadSucceeded && avatarState.profile != null) {
      setState(() => _avatarUrl = avatarState.profile!.avatarUrl);
    }
    final message =
        avatarState.error?.localizedMessage(context) ??
        (avatarState.lastUploadSucceeded
            ? context.t.social_avatar_updated_success
            : null);
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(socialOnboardingViewModelProvider.notifier)
        .saveProfile(
          displayName: _displayNameController.text,
          avatarUrl: null,
          privacy: _privacy,
        );
    if (!mounted) {
      return;
    }
    final saveState = ref.read(socialOnboardingViewModelProvider);
    if (saveState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.social_profile_save_error)),
      );
    } else if (saveState.profile != null && saveState.validationError == null) {
      ref.invalidate(mySocialProfileProvider);
      ref.invalidate(socialProfileViewModelProvider('me'));
      final router = GoRouter.maybeOf(context);
      if (router != null && router.canPop()) {
        router.pop();
      }
    }
  }
}

extension _SocialAvatarErrorMessage on SocialAvatarError {
  String localizedMessage(BuildContext context) {
    final t = context.t;
    return switch (this) {
      SocialAvatarError.invalidType => t.social_avatar_invalid_type,
      SocialAvatarError.sizeLimit => t.social_avatar_size_limit,
      SocialAvatarError.accessFailure => t.social_avatar_access_failure,
      SocialAvatarError.updateFailure => t.social_avatar_update_failure,
    };
  }
}

class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({
    required this.displayName,
    required this.avatarUrl,
    required this.isUploading,
    required this.onChangePhoto,
  });

  final String displayName;
  final String? avatarUrl;
  final bool isUploading;
  final VoidCallback? onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final trimmedAvatarUrl = avatarUrl?.trim();
    final hasAvatar = trimmedAvatarUrl != null && trimmedAvatarUrl.isNotEmpty;
    final trimmedDisplayName = displayName.trim();
    final initial = trimmedDisplayName.isEmpty
        ? '?'
        : trimmedDisplayName.characters.first.toUpperCase();
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              child: hasAvatar
                  ? ClipOval(
                      child: Image.network(
                        trimmedAvatarUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          initial,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    )
                  : Text(
                      initial,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
            ),
            if (isUploading) const CircularProgressIndicator(),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          key: const Key('editSocialProfileChangePhotoAction'),
          onPressed: onChangePhoto,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(context.t.social_change_photo),
        ),
      ],
    );
  }
}
