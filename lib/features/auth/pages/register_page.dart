// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/strings.g.dart';
import '../viewmodels/register_viewmodel.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      ref.read(registerViewModelProvider.notifier).setEmail(_emailController.text);
    });
    _passwordController.addListener(() {
      ref.read(registerViewModelProvider.notifier).setPassword(_passwordController.text);
    });
    _confirmController.addListener(() {
      ref.read(registerViewModelProvider.notifier).setConfirmPassword(_confirmController.text);
    });
    _codeController.addListener(() {
      ref.read(registerViewModelProvider.notifier).setConfirmationCode(_codeController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await ref.read(registerViewModelProvider.notifier).submit();
    if (!success && mounted) {
      // Error already shown inline
    }
  }

  Future<void> _confirm() async {
    final success = await ref.read(registerViewModelProvider.notifier).confirmSignUp();
    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  Color _strengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.redAccent;
      case PasswordStrength.medium:
        return Colors.orangeAccent;
      case PasswordStrength.strong:
        return Colors.greenAccent;
    }
  }

  String _strengthText(PasswordStrength strength, Translations t) {
    return switch (strength) {
      PasswordStrength.weak => t.auth_password_weak,
      PasswordStrength.medium => t.auth_password_medium,
      PasswordStrength.strong => t.auth_password_strong,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final registerState = ref.watch(registerViewModelProvider);

    return AuthPageScaffold(
      children: [
        Text(
          registerState.showConfirmation ? t.auth_confirm_email : t.auth_create_account,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          registerState.showConfirmation
              ? t.auth_code_sent_to.replaceFirst('{email}', registerState.email)
              : t.login_subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        if (registerState.showConfirmation) ...[
          AuthTextField(
            controller: _codeController,
            hint: t.auth_confirmation_code,
            icon: Icons.confirmation_number_outlined,
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _confirm(),
          ),
          const SizedBox(height: 16),
          AuthButton(
            text: t.auth_confirm_and_login,
            isLoading: registerState.isLoading,
            onPressed: _confirm,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.read(registerViewModelProvider.notifier).resendCode(),
            child: Text(
              t.auth_resend_code,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ] else ...[
          AuthTextField(
            controller: _emailController,
            hint: t.auth_email_hint,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hint: t.auth_password_hint,
            icon: Icons.lock_outline,
            obscureText: registerState.obscurePassword,
            onToggleObscure: () {
              ref.read(registerViewModelProvider.notifier).toggleObscurePassword();
            },
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 8),
          // Password strength indicator
          if (registerState.password.isNotEmpty)
            Row(
              children: [
                Expanded(
                  flex: registerState.passwordStrength == PasswordStrength.weak ? 1 : 0,
                  child: Container(height: 3, color: Colors.redAccent),
                ),
                Expanded(
                  flex: registerState.passwordStrength == PasswordStrength.medium ? 1 : 0,
                  child: Container(height: 3, color: Colors.orangeAccent),
                ),
                Expanded(
                  flex: registerState.passwordStrength == PasswordStrength.strong ? 1 : 0,
                  child: Container(height: 3, color: Colors.greenAccent),
                ),
                const SizedBox(width: 8),
                Text(
                  _strengthText(registerState.passwordStrength, t),
                  style: TextStyle(
                    color: _strengthColor(registerState.passwordStrength),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmController,
            hint: t.auth_confirm_password_hint,
            icon: Icons.lock_outline,
            obscureText: registerState.obscurePassword,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: registerState.termsAccepted,
                onChanged: (_) => ref.read(registerViewModelProvider.notifier).toggleTerms(),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return Colors.white30;
                }),
                checkColor: Theme.of(context).primaryColor,
              ),
              Expanded(
                child: Text(
                  t.auth_accept_terms,
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: t.auth_create_account,
            isLoading: registerState.isLoading,
            onPressed: _submit,
          ),
        ],
        if (registerState.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            registerState.errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text.rich(
            TextSpan(
              text: t.auth_already_have_account,
              style: TextStyle(color: Colors.white70),
              children: [
                TextSpan(
                  text: t.auth_sign_in,
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
