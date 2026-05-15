// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/strings.g.dart';
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
        SnackBar(content: Text(context.t.auth_code_sent_success)),
      );
    }
  }

  Future<void> _resetPassword() async {
    final success = await ref.read(forgotPasswordViewModelProvider.notifier).resetPassword();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.auth_password_reset_success)),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = ref.watch(forgotPasswordViewModelProvider);

    return AuthPageScaffold(
      children: [
        Text(
          state.phase == ForgotPasswordPhase.requestCode
              ? t.auth_recover_password
              : t.auth_new_password_title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          state.phase == ForgotPasswordPhase.requestCode
              ? t.auth_forgot_subtitle_request
              : t.auth_forgot_subtitle_reset,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        if (state.phase == ForgotPasswordPhase.requestCode) ...[
          AuthTextField(
            controller: _emailController,
            hint: t.auth_email_hint,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _requestCode(),
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: t.auth_send_code,
            isLoading: state.isLoading,
            onPressed: _requestCode,
          ),
        ] else ...[
          AuthTextField(
            controller: _codeController,
            hint: t.auth_verification_code_hint,
            icon: Icons.confirmation_number_outlined,
            keyboardType: TextInputType.number,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hint: t.auth_new_password_hint,
            icon: Icons.lock_outline,
            obscureText: state.obscurePassword,
            onToggleObscure: () {
              ref.read(forgotPasswordViewModelProvider.notifier).toggleObscurePassword();
            },
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmController,
            hint: t.auth_confirm_new_password_hint,
            icon: Icons.lock_outline,
            obscureText: state.obscurePassword,
            onSubmitted: (_) => _resetPassword(),
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: t.auth_reset_password,
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
          child: Text(
            t.auth_back_to_login,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
