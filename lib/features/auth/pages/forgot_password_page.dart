import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/forgot_password_viewmodel.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      ref.read(forgotPasswordViewModelProvider.notifier).setEmail(_emailController.text);
    });
    _codeController.addListener(() {
      ref.read(forgotPasswordViewModelProvider.notifier).setCode(_codeController.text);
    });
    _passwordController.addListener(() {
      ref.read(forgotPasswordViewModelProvider.notifier).setNewPassword(_passwordController.text);
    });
    _confirmController.addListener(() {
      ref.read(forgotPasswordViewModelProvider.notifier).setConfirmPassword(_confirmController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final success = await ref.read(forgotPasswordViewModelProvider.notifier).requestCode();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código enviado para seu e-mail')),
      );
    }
  }

  Future<void> _resetPassword() async {
    final success = await ref.read(forgotPasswordViewModelProvider.notifier).resetPassword();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha redefinida com sucesso')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordViewModelProvider);

    return AuthPageScaffold(
      children: [
        Text(
          state.phase == ForgotPasswordPhase.requestCode
              ? 'Recuperar senha'
              : 'Nova senha',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          state.phase == ForgotPasswordPhase.requestCode
              ? 'Digite seu e-mail para receber um código de verificação'
              : 'Digite o código enviado para seu e-mail e sua nova senha',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        if (state.phase == ForgotPasswordPhase.requestCode) ...[
          AuthTextField(
            controller: _emailController,
            hint: 'E-mail',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: 'Enviar código',
            isLoading: state.isLoading,
            onPressed: _requestCode,
          ),
        ] else ...[
          AuthTextField(
            controller: _codeController,
            hint: 'Código de verificação',
            icon: Icons.confirmation_number_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hint: 'Nova senha',
            icon: Icons.lock_outline,
            obscureText: state.obscurePassword,
            onToggleObscure: () {
              ref.read(forgotPasswordViewModelProvider.notifier).toggleObscurePassword();
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmController,
            hint: 'Confirmar nova senha',
            icon: Icons.lock_outline,
            obscureText: state.obscurePassword,
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: 'Redefinir senha',
            isLoading: state.isLoading,
            onPressed: _resetPassword,
          ),
        ],
        if (state.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            state.errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text(
            'Voltar para o login',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
