import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      ref.read(loginViewModelProvider.notifier).setEmail(_emailController.text);
    });
    _passwordController.addListener(() {
      ref.read(loginViewModelProvider.notifier).setPassword(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await ref.read(loginViewModelProvider.notifier).submit();
    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    return AuthPageScaffold(
      children: [
        Text(
          'Bem-vindo de volta',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entre para continuar suas listas',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        AuthTextField(
          controller: _emailController,
          hint: 'E-mail',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: loginState.errorMessage != null && !loginState.isValid
              ? loginState.errorMessage
              : null,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _passwordController,
          hint: 'Senha',
          icon: Icons.lock_outline,
          obscureText: loginState.obscurePassword,
          onToggleObscure: () {
            ref.read(loginViewModelProvider.notifier).toggleObscurePassword();
          },
          onSubmitted: (_) => _submit(),
        ),
        if (loginState.errorMessage != null && loginState.isValid) ...[
          const SizedBox(height: 12),
          Text(
            loginState.errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        AuthButton(
          text: 'Entrar',
          isLoading: loginState.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push('/forgot-password'),
          child: const Text(
            'Esqueceu a senha?',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white30)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            Expanded(child: Divider(color: Colors.white30)),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push('/register'),
          child: const Text.rich(
            TextSpan(
              text: 'Não tem conta? ',
              style: TextStyle(color: Colors.white70),
              children: [
                TextSpan(
                  text: 'Cadastre-se',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
