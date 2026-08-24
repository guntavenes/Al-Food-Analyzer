import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/widgets/premium_action_button.dart';
import 'package:ai_food_analyzer/core/widgets/premium_screen_background.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _awaitingEmailConfirmation = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@') || password.length < 8) {
      setState(() => _message = l10n.authValidationMessage);
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final auth = Supabase.instance.client.auth;
      if (auth.currentUser?.isAnonymous == true) await auth.signOut();
      if (_isSignUp) {
        final response = await auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: 'aifoodanalyzer://login-callback',
        );
        if (!mounted) return;
        if (response.session == null) {
          setState(() {
            _awaitingEmailConfirmation = true;
            _message = l10n.checkEmailMessage;
          });
          return;
        }
      } else {
        await auth.signInWithPassword(email: email, password: password);
      }
      if (mounted) context.go(AppRoutes.home);
    } on AuthException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendConfirmation() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: _emailController.text.trim(),
        emailRedirectTo: 'aifoodanalyzer://login-callback',
      );
      if (mounted) setState(() => _message = l10n.confirmationResent);
    } on AuthException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: PremiumScreenBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.eco_rounded, size: 66),
                    const SizedBox(height: 24),
                    Text(
                      _isSignUp ? l10n.createAccountTitle : l10n.signInTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.authDescription,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel,
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                    if (!_isSignUp) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => context.push(AppRoutes.forgotPassword),
                          child: Text(l10n.forgotPassword),
                        ),
                      ),
                    ],
                    if (_message != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    if (_awaitingEmailConfirmation) ...[
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _isLoading ? null : _resendConfirmation,
                        icon: const Icon(Icons.outgoing_mail),
                        label: Text(l10n.resendConfirmation),
                      ),
                    ],
                    const SizedBox(height: 22),
                    PremiumActionButton(
                      label: _isSignUp ? l10n.createAccount : l10n.signIn,
                      icon: _isSignUp
                          ? Icons.person_add_alt_1_rounded
                          : Icons.login_rounded,
                      onPressed: _isLoading ? null : _submit,
                      loading: _isLoading,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                              _isSignUp = !_isSignUp;
                              _awaitingEmailConfirmation = false;
                              _message = null;
                            }),
                      child: Text(
                        _isSignUp
                            ? l10n.alreadyHaveAccount
                            : l10n.createAccountInstead,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
