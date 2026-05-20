import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/social_privacy.dart';
import '../viewmodels/social_onboarding_viewmodel.dart';

class EditSocialProfilePage extends ConsumerStatefulWidget {
  const EditSocialProfilePage({super.key});

  @override
  ConsumerState<EditSocialProfilePage> createState() =>
      _EditSocialProfilePageState();
}

class _EditSocialProfilePageState extends ConsumerState<EditSocialProfilePage> {
  final _displayNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  SocialPrivacy _privacy = SocialPrivacy.public;

  @override
  void dispose() {
    _displayNameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(socialOnboardingViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Editar perfil social',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(labelText: 'Nome de exibição'),
          ),
          const SizedBox(height: 12),
          TextField(
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
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.isSaving
                ? null
                : () => ref
                      .read(socialOnboardingViewModelProvider.notifier)
                      .saveProfile(
                        displayName: _displayNameController.text,
                        avatarUrl: _avatarUrlController.text.trim().isEmpty
                            ? null
                            : _avatarUrlController.text.trim(),
                        privacy: _privacy,
                      ),
            child: const Text('Salvar alterações'),
          ),
        ],
      ),
    );
  }
}
