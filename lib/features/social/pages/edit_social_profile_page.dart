// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
                  'Editar perfil social',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome de exibição',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe um nome de exibição'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _avatarUrlController,
                  decoration: const InputDecoration(labelText: 'URL do avatar'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Perfil público'),
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
                  child: const Text('Salvar alterações'),
                ),
              ],
            ),
          ),
        );
      },
      error: (_, _) => const Center(
        child: Text('Não foi possível carregar seu perfil social.'),
      ),
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
    if (saveState.profile != null &&
        saveState.errorMessage == null &&
        saveState.validationError == null) {
      ref.invalidate(mySocialProfileProvider);
      ref.invalidate(socialProfileViewModelProvider('me'));
      final router = GoRouter.maybeOf(context);
      if (router != null && router.canPop()) {
        router.pop();
      }
    }
  }
}
