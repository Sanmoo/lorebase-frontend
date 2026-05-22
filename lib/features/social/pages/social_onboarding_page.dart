// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/social_privacy.dart';
import '../viewmodels/social_discover_viewmodel.dart';
import '../viewmodels/social_onboarding_viewmodel.dart';
import '../widgets/discover_user_card.dart';

class SocialOnboardingPage extends ConsumerStatefulWidget {
  const SocialOnboardingPage({super.key, this.onProfileCreated, this.onFinish});

  final VoidCallback? onProfileCreated;
  final VoidCallback? onFinish;

  @override
  ConsumerState<SocialOnboardingPage> createState() =>
      _SocialOnboardingPageState();
}

class _SocialOnboardingPageState extends ConsumerState<SocialOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  SocialPrivacy? _privacy;
  bool _showPrivacyError = false;
  bool _showSuggestions = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(socialOnboardingViewModelProvider);

    if (_showSuggestions) {
      return _OnboardingSuggestions(onFinish: () => widget.onFinish?.call());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Crie seu perfil social',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Nome de exibição'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe um nome de exibição'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _avatarUrlController,
              decoration: const InputDecoration(labelText: 'URL do avatar'),
            ),
            const SizedBox(height: 16),
            Text('Privacidade', style: Theme.of(context).textTheme.titleMedium),
            RadioListTile<SocialPrivacy>(
              title: const Text('Público'),
              value: SocialPrivacy.public,
              // ignore: deprecated_member_use
              groupValue: _privacy,
              // ignore: deprecated_member_use
              onChanged: (value) => setState(() {
                _privacy = value;
                _showPrivacyError = false;
              }),
            ),
            RadioListTile<SocialPrivacy>(
              title: const Text('Privado'),
              value: SocialPrivacy.private,
              // ignore: deprecated_member_use
              groupValue: _privacy,
              // ignore: deprecated_member_use
              onChanged: (value) => setState(() {
                _privacy = value;
                _showPrivacyError = false;
              }),
            ),
            if (_showPrivacyError)
              Text(
                'Escolha a privacidade do perfil',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (state.validationError != null) Text(state.validationError!),
            if (state.errorMessage != null) Text(state.errorMessage!),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: state.isSaving ? null : _submit,
              child: state.isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Salvar perfil'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final privacy = _privacy;
    setState(() => _showPrivacyError = privacy == null);
    if (!_formKey.currentState!.validate() || privacy == null) {
      return;
    }
    await ref
        .read(socialOnboardingViewModelProvider.notifier)
        .saveProfile(
          displayName: _displayNameController.text,
          avatarUrl: _avatarUrlController.text.trim().isEmpty
              ? null
              : _avatarUrlController.text.trim(),
          privacy: privacy,
        );
    if (ref.read(socialOnboardingViewModelProvider).profile != null) {
      widget.onProfileCreated?.call();
      setState(() => _showSuggestions = true);
    }
  }
}

class _OnboardingSuggestions extends ConsumerWidget {
  const _OnboardingSuggestions({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(socialDiscoverViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Sugestões para seguir',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: suggestions.when(
            data: (data) {
              if (data.items.isEmpty) {
                return const Center(
                  child: Text('Nenhuma sugestão por enquanto.'),
                );
              }
              return ListView.builder(
                itemCount: data.items.length,
                itemBuilder: (context, index) {
                  final user = data.items[index];
                  return DiscoverUserCard(
                    user: user,
                    onFollow: () => ref
                        .read(socialDiscoverViewModelProvider.notifier)
                        .followUser(user.userId),
                  );
                },
              );
            },
            error: (_, _) =>
                const Center(child: Text('Erro ao descobrir pessoas.')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: FilledButton(
            onPressed: onFinish,
            child: const Text('Finalizar'),
          ),
        ),
      ],
    );
  }
}
