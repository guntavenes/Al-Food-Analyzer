import 'package:ai_food_analyzer/core/config/app_config.dart';
import 'package:ai_food_analyzer/core/config/legal_links.dart';
import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/features/account/data/account_service.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/providers/food_analysis_providers.dart';
import 'package:ai_food_analyzer/features/history/presentation/providers/history_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  bool _deleting = false;

  String _text(String tr, String en) =>
      Localizations.localeOf(context).languageCode == 'tr' ? tr : en;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AppConfig.isSupabaseConfigured
        ? Supabase.instance.client.auth.currentUser
        : null;
    final hasPermanentAccount =
        !AppConfig.isSupabaseConfigured ||
        (user != null && user.isAnonymous != true);
    return Scaffold(
      appBar: AppBar(title: Text(_text('Hesap ayarları', 'Account settings'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          _SectionLabel(_text('KİŞİSELLEŞTİR', 'PERSONALIZE')),
          _SettingsTile(
            icon: Icons.track_changes_rounded,
            title: _text('Beslenme hedefleri', 'Nutrition goals'),
            subtitle: _text(
              'Kalori ve protein hedeflerini düzenle',
              'Edit calorie and protein targets',
            ),
            onTap: () => context.push(AppRoutes.nutritionGoals),
          ),
          _SettingsTile(
            icon: Icons.notifications_active_outlined,
            title: _text('Bildirimler', 'Notifications'),
            subtitle: _text(
              'Hatırlatma saati ve bildirim türleri',
              'Reminder time and notification types',
            ),
            onTap: () => context.push(AppRoutes.notificationSettings),
          ),
          const SizedBox(height: 18),
          _SectionLabel(_text('ÜYELİK', 'MEMBERSHIP')),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: _text('Premium üyelik', 'Premium membership'),
            subtitle: _text(
              'Planını ve aboneliğini yönet',
              'Manage your plan and subscription',
            ),
            accent: AppColors.champagne,
            onTap: () => context.push(AppRoutes.premium),
          ),
          const SizedBox(height: 18),
          _SectionLabel(_text('UYGULAMA', 'APP')),
          _SettingsTile(
            icon: Icons.school_outlined,
            title: _text('Uygulama turu', 'App tour'),
            subtitle: _text(
              'Özellikleri yeniden keşfet',
              'Review the app features',
            ),
            onTap: () => context.push(AppRoutes.onboarding),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: _text('Hakkında', 'About'),
            subtitle: 'AI Food Analyzer · v1.0.0',
            onTap: () => context.push(AppRoutes.about),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: _text('Gizlilik Politikası', 'Privacy Policy'),
            subtitle: _text(
              'Verilerinin nasıl işlendiğini oku',
              'Read how your data is handled',
            ),
            onTap: () => _open(LegalLinks.privacyPolicy),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: _text('Kullanım Koşulları', 'Terms of Use'),
            subtitle: _text(
              'Abonelik ve hizmet koşulları',
              'Subscription and service terms',
            ),
            onTap: () => _open(LegalLinks.termsOfUse),
          ),
          if (hasPermanentAccount) ...[
            const SizedBox(height: 18),
            _SectionLabel(_text('HESAP', 'ACCOUNT')),
            Card(
              color: theme.colorScheme.errorContainer.withValues(alpha: .45),
              child: ListTile(
                enabled: !_deleting,
                onTap: _confirmDeleteAccount,
                leading: Icon(
                  Icons.delete_forever_outlined,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  _text('Hesabımı sil', 'Delete my account'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.error,
                  ),
                ),
                subtitle: Text(
                  _text(
                    'Hesap, geçmiş ve bulut fotoğrafları kalıcı olarak silinir',
                    'Permanently deletes the account, history, and cloud photos',
                  ),
                ),
                trailing: _deleting
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ] else ...[
            const SizedBox(height: 18),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: Text(_text('Hesap yedeklemesi', 'Account backup')),
                subtitle: Text(
                  _text(
                    'Yeni geçmiş kayıtlarını hesabınla eşitlemek ve hesabını yönetmek için giriş yap.',
                    'Sign in to sync future history across devices and manage your account.',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(AppRoutes.auth),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _open(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text('Bağlantı açılamadı.', 'The link could not be opened.'),
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteAccount() async {
    if (!AppConfig.isSupabaseConfigured || _deleting) return;
    final auth = Supabase.instance.client.auth;
    final user = auth.currentUser;
    final session = auth.currentSession;
    final isAppleAccount =
        user?.identities?.any((identity) => identity.provider == 'apple') ==
        true;
    final appleProviderToken = isAppleAccount
        ? session?.providerRefreshToken ?? session?.providerToken
        : null;
    final appleProviderTokenType = session?.providerRefreshToken != null
        ? 'refresh_token'
        : session?.providerToken != null
        ? 'access_token'
        : null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(
          _text(
            'Hesabın kalıcı olarak silinsin mi?',
            'Permanently delete your account?',
          ),
        ),
        content: Text(
          _text(
            'Bu işlem geri alınamaz. Geçmişin ve buluttaki fotoğrafların silinir. Aktif aboneliğin Apple tarafından ayrıca yenilenebilir; devam etmeden önce Premium ekranından aboneliğini iptal etmelisin.${isAppleAccount && appleProviderToken == null ? '\n\nApple oturum anahtarı bu cihazda bulunamadı. Silme işleminden sonra Ayarlar > Apple Hesabı > Apple ile Giriş bölümünden AI Food Analyzer erişimini de kaldırmalısın.' : ''}',
            'This cannot be undone. Your history and cloud photos will be deleted. Apple may continue billing an active subscription; cancel it from the Premium screen before continuing.${isAppleAccount && appleProviderToken == null ? '\n\nThe Apple session token is not available on this device. After deletion, also remove AI Food Analyzer under Settings > Apple Account > Sign in with Apple.' : ''}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_text('Vazgeç', 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_text('Kalıcı olarak sil', 'Delete permanently')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      final service = AccountService(
        ref.read(foodAnalysisDioProvider),
        ref.read(accessTokenProvider),
      );
      final deletionResult = await service.deleteAccount(
        appleProviderToken: appleProviderToken,
        appleProviderTokenType: appleProviderTokenType,
      );
      await ref.read(analysisHistoryRepositoryProvider).clearLocalHistory();
      final auth = Supabase.instance.client.auth;
      await auth.signOut(scope: SignOutScope.local);
      try {
        await auth.signInAnonymously();
      } on Object {
        // Keep the app available even if guest-session creation must be retried.
      }
      if (isAppleAccount &&
          deletionResult.appleAuthorizationRevoked != true &&
          mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.apple),
            title: Text(_text('Apple erişimini kaldır', 'Remove Apple access')),
            content: Text(
              _text(
                'Hesabın ve verilerin silindi. Apple oturum anahtarı artık geçerli olmadığı için son adımı manuel tamamla: Ayarlar > Apple Hesabı > Apple ile Giriş > AI Food Analyzer > Kullanmayı Durdur.',
                'Your account and data were deleted. Because the Apple session token was no longer valid, finish the last step manually: Settings > Apple Account > Sign in with Apple > AI Food Analyzer > Stop Using Apple ID.',
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(_text('Tamam', 'Done')),
              ),
            ],
          ),
        );
      }
      if (mounted) context.go(AppRoutes.home);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Hesap silinemedi. Bağlantını kontrol edip tekrar dene.',
              'The account could not be deleted. Check your connection and try again.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accent;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: accent ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
