// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/strings.g.dart';
import '../data/models/social_privacy.dart';
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
  final _avatarUrlController = TextEditingController();
  SocialPrivacy _privacy = SocialPrivacy.public;
  bool _initialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(mySocialProfileProvider);
    final state = ref.watch(socialOnboardingViewModelProvider);
    final t = context.t;

    return profile.when(
      data: (profile) {
        if (!_initialized) {
          _displayNameController.text = profile.displayName;
          _avatarUrlController.text = profile.avatarUrl ?? '';
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
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(labelText: t.social_display_name),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? t.social_display_name_required
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _avatarUrlController,
                  decoration: InputDecoration(labelText: t.social_avatar_url),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(socialOnboardingViewModelProvider.notifier)
        .saveProfile(
          displayName: _displayNameController.text,
          avatarUrl: _avatarUrlController.text.trim().isEmpty
              ? null
              : _avatarUrlController.text.trim(),
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
