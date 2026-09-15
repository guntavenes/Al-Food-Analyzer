import 'dart:async';

import 'package:ai_food_analyzer/core/config/app_config.dart';
import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/widgets/premium_action_button.dart';
import 'package:ai_food_analyzer/core/widgets/premium_screen_background.dart';
import 'package:ai_food_analyzer/features/auth/domain/auth_input_validator.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
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
  _AuthMessageType _messageType = _AuthMessageType.error;
  Timer? _resendTimer;
  int _resendSeconds = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || (_awaitingEmailConfirmation && _resendSeconds > 0)) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!AuthInputValidator.isValidEmail(email)) {
      _setMessage(l10n.invalidEmailMessage, _AuthMessageType.error);
      return;
    }
    if (password.length < 8) {
      _setMessage(l10n.passwordTooShortMessage, _AuthMessageType.error);
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
            _messageType = _AuthMessageType.success;
          });
          _startResendCooldown();
          return;
        }
      } else {
        await auth.signInWithPassword(email: email, password: password);
      }
      if (mounted) context.go(AppRoutes.home);
    } on AuthException catch (error) {
      if (mounted) {
        _setMessage(_authErrorMessage(error, l10n), _AuthMessageType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendConfirmation() async {
    if (_resendSeconds > 0) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: _emailController.text.trim(),
        emailRedirectTo: 'aifoodanalyzer://login-callback',
      );
      if (mounted) {
        _setMessage(l10n.confirmationResent, _AuthMessageType.success);
        _startResendCooldown();
      }
    } on AuthException catch (error) {
      if (mounted) {
        _setMessage(_authErrorMessage(error, l10n), _AuthMessageType.error);
        if (_isRateLimited(error)) _startResendCooldown();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _socialSignIn(OAuthProvider provider) async {
    if (_isLoading) return;
    if (!AppConfig.isSupabaseConfigured) {
      if (mounted) {
        _setMessage(
          'Giriş sağlayıcısı henüz yapılandırılmadı. Uygulamayı Supabase ayarlarıyla yeniden başlatın.',
          _AuthMessageType.error,
        );
      }
      return;
    }
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final auth = Supabase.instance.client.auth;
      if (auth.currentUser?.isAnonymous == true) await auth.signOut();
      await auth.signInWithOAuth(
        provider,
        redirectTo: 'aifoodanalyzer://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } on AuthException catch (error) {
      if (mounted) {
        _setMessage(
          _authErrorMessage(error, AppLocalizations.of(context)),
          _AuthMessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setMessage(String message, _AuthMessageType type) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _messageType = type;
    });
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds--);
    });
  }

  bool _isRateLimited(AuthException error) {
    final message = error.message.toLowerCase();
    return error.statusCode == '429' ||
        error.code == 'over_email_send_rate_limit' ||
        message.contains('rate limit') ||
        message.contains('too many requests');
  }

  String _authErrorMessage(AuthException error, AppLocalizations l10n) {
    final message = error.message.toLowerCase();
    if (_isRateLimited(error)) return l10n.emailRateLimitedMessage;
    if (message.contains('invalid email')) return l10n.invalidEmailMessage;
    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return l10n.emailAlreadyRegisteredMessage;
    }
    if (message.contains('invalid login credentials')) {
      return l10n.invalidLoginMessage;
    }
    return l10n.authGenericErrorMessage;
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
                    if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                      _SocialSignInButton(
                        label: l10n.continueWithApple,
                        icon: Icons.apple,
                        onPressed: _isLoading
                            ? null
                            : () => _socialSignIn(OAuthProvider.apple),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _SocialSignInButton(
                      label: l10n.continueWithGoogle,
                      icon: Icons.g_mobiledata_rounded,
                      onPressed: _isLoading
                          ? null
                          : () => _socialSignIn(OAuthProvider.google),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(l10n.orContinueWithEmail),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                      _AuthMessageCard(message: _message!, type: _messageType),
                    ],
                    if (_awaitingEmailConfirmation) ...[
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _isLoading || _resendSeconds > 0
                            ? null
                            : _resendConfirmation,
                        icon: const Icon(Icons.outgoing_mail),
                        label: Text(
                          _resendSeconds > 0
                              ? l10n.resendConfirmationCountdown(_resendSeconds)
                              : l10n.resendConfirmation,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    PremiumActionButton(
                      label: _isSignUp ? l10n.createAccount : l10n.signIn,
                      icon: _isSignUp
                          ? Icons.person_add_alt_1_rounded
                          : Icons.login_rounded,
                      onPressed:
                          _isLoading ||
                              (_awaitingEmailConfirmation && _resendSeconds > 0)
                          ? null
                          : _submit,
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
                              _resendTimer?.cancel();
                              _resendSeconds = 0;
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

class _SocialSignInButton extends StatelessWidget {
  const _SocialSignInButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 25),
        label: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

enum _AuthMessageType { success, error }

class _AuthMessageCard extends StatelessWidget {
  const _AuthMessageCard({required this.message, required this.type});

  final String message;
  final _AuthMessageType type;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isSuccess = type == _AuthMessageType.success;
    final foreground = isSuccess ? colors.primary : colors.error;
    final background = isSuccess
        ? colors.primaryContainer.withValues(alpha: 0.55)
        : colors.errorContainer.withValues(alpha: 0.65);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.mark_email_read_rounded : Icons.error_outline,
              color: foreground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: foreground, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
