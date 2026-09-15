import 'package:ai_food_analyzer/core/config/app_config.dart';
import 'package:ai_food_analyzer/core/localization/locale_providers.dart';
import 'package:ai_food_analyzer/core/notifications/smart_notification_service.dart';
import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/core/widgets/premium_action_button.dart';
import 'package:ai_food_analyzer/features/history/presentation/providers/history_providers.dart';
import 'package:ai_food_analyzer/features/nutrition_summary/data/wellness_preferences.dart';
import 'package:ai_food_analyzer/features/nutrition_summary/domain/daily_nutrition_summary.dart';
import 'package:ai_food_analyzer/features/nutrition_summary/presentation/providers/nutrition_summary_providers.dart';
import 'package:ai_food_analyzer/features/premium/presentation/providers/premium_purchase_provider.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isOpeningHistory = false;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final settings = await ref.read(wellnessSettingsProvider.future);
      if (!settings.smartRemindersEnabled ||
          !settings.weeklyInsightsEnabled ||
          !mounted) {
        return;
      }
      final analyses = await ref.read(analysisHistoryProvider.future);
      await SmartNotificationService.instance.maybeShowWeeklyInsight(
        analyses: analyses,
        title: l10n.weeklyInsightTitle,
        body: l10n.weeklyInsightBody,
      );
    });
  }

  Future<void> _openNutritionSummary() async {
    final isPremium = ref.read(premiumEntitlementProvider).value ?? false;
    if (!isPremium) {
      await context.push(AppRoutes.premium);
      return;
    }
    await context.push(AppRoutes.nutritionSummary);
  }

  Future<void> _openHistory() async {
    if (_isOpeningHistory) return;
    setState(() => _isOpeningHistory = true);
    await context.push(AppRoutes.history);
    if (mounted) {
      setState(() => _isOpeningHistory = false);
    }
  }

  Future<void> _confirmSignOut() async {
    if (_isSigningOut) return;
    final l10n = AppLocalizations.of(context);
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Theme.of(dialogContext).colorScheme.error,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.signOutTitle,
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.signOutDescription,
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(dialogContext).colorScheme.error,
                    foregroundColor: Theme.of(
                      dialogContext,
                    ).colorScheme.onError,
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.signOut),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
    if (shouldSignOut != true || !mounted) return;

    setState(() => _isSigningOut = true);
    try {
      if (AppConfig.isSupabaseConfigured) {
        await Supabase.instance.client.auth.signOut();
      }
      if (mounted) context.go(AppRoutes.auth);
    } on AuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.signOutFailed)));
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  Future<void> _openAccount() async {
    final l10n = AppLocalizations.of(context);
    final entitlement = ref.read(accountEntitlementProvider).value;
    final isPremium = entitlement?.isPremium ?? false;
    final user = AppConfig.isSupabaseConfigured
        ? Supabase.instance.client.auth.currentUser
        : null;
    final email =
        user?.email ??
        (user?.userMetadata?['email'] as String?) ??
        (user?.userMetadata?['preferred_email'] as String?) ??
        '';
    final displayName =
        (user?.userMetadata?['full_name'] as String?) ??
        (user?.userMetadata?['name'] as String?) ??
        '';
    final avatarUrl =
        (user?.userMetadata?['avatar_url'] as String?) ??
        (user?.userMetadata?['picture'] as String?) ??
        '';
    final settings = await ref.read(wellnessSettingsProvider.future);
    if (!mounted) return;
    final remindersEnabled = settings.smartRemindersEnabled;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isPremium
                      ? const LinearGradient(
                          colors: [
                            AppColors.champagneLight,
                            AppColors.champagne,
                          ],
                        )
                      : null,
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: isPremium
                      ? AppColors.champagneLight
                      : Theme.of(
                          sheetContext,
                        ).colorScheme.surfaceContainerHighest,
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty
                      ? Icon(
                          isPremium
                              ? Icons.workspace_premium_rounded
                              : Icons.person_rounded,
                          color: isPremium
                              ? AppColors.deepEmerald
                              : Theme.of(
                                  sheetContext,
                                ).colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                displayName.isNotEmpty ? displayName : l10n.accountTitle,
                style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (isPremium) ...[
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.champagneLight, AppColors.champagne],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        size: 16,
                        color: AppColors.deepEmerald,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.premiumMember,
                        style: const TextStyle(
                          color: AppColors.deepEmerald,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(
                    sheetContext,
                  ).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline_rounded, size: 21),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        email.isNotEmpty ? email : l10n.emailUnavailable,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPremium ? l10n.premiumMember : l10n.freeMember,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isPremium && entitlement != null) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.freeAnalysesRemaining(entitlement.freeAnalysesRemaining),
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await _editNutritionGoals(settings);
                },
                icon: const Icon(Icons.track_changes_rounded),
                label: Text(l10n.nutritionGoals),
              ),
              Container(
                margin: const EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  color: Theme.of(
                    sheetContext,
                  ).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _editNotificationSettings(settings);
                  },
                  title: Text(
                    l10n.smartReminders,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    remindersEnabled
                        ? 'Açık · ${settings.reminderHour.toString().padLeft(2, '0')}:${settings.reminderMinute.toString().padLeft(2, '0')}'
                        : 'Kapalı',
                  ),
                  leading: const Icon(Icons.notifications_active_outlined),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isPremium
                        ? AppColors.deepEmerald
                        : AppColors.emerald,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop('premium'),
                  icon: Icon(
                    isPremium
                        ? Icons.workspace_premium_outlined
                        : Icons.auto_awesome_rounded,
                  ),
                  label: Text(
                    isPremium ? l10n.managePremium : l10n.upgradeToPremium,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(sheetContext).pop('tour'),
                  icon: const Icon(Icons.school_outlined),
                  label: Text(l10n.showAppTour),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(sheetContext).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(
                        sheetContext,
                      ).colorScheme.error.withValues(alpha: 0.55),
                    ),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop('signOut'),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.signOut),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'premium') {
      await context.push(AppRoutes.premium);
      ref.invalidate(premiumEntitlementProvider);
      ref.invalidate(accountEntitlementProvider);
    } else if (action == 'tour') {
      await context.push(AppRoutes.onboarding);
    } else if (action == 'signOut') {
      await _confirmSignOut();
    }
  }

  Future<void> _editNotificationSettings(WellnessSettings settings) async {
    final l10n = AppLocalizations.of(context);
    var time = TimeOfDay(
      hour: settings.reminderHour,
      minute: settings.reminderMinute,
    );
    var daily = settings.smartRemindersEnabled;
    var weekly = settings.weeklyInsightsEnabled;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.smartReminders),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_rounded),
                title: const Text('Bildirim saati'),
                trailing: Text(
                  time.format(context),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (picked != null) setState(() => time = picked);
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: daily,
                onChanged: (value) => setState(() => daily = value),
                title: const Text('Günlük hatırlatma'),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: weekly,
                onChanged: (value) => setState(() => weekly = value),
                title: const Text('Haftalık gelişim özeti'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () async {
                if (daily) {
                  final granted = await SmartNotificationService.instance
                      .enableDailyReminder(
                        title: l10n.dailyReminderTitle,
                        body: l10n.dailyReminderBody,
                        hour: time.hour,
                        minute: time.minute,
                      );
                  if (!granted && mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.notificationsPermissionRequired),
                      ),
                    );
                    return;
                  }
                } else {
                  await SmartNotificationService.instance
                      .disableDailyReminder();
                }
                final prefs = ref.read(wellnessPreferencesProvider);
                await prefs.setSmartReminders(daily);
                await prefs.saveNotificationSettings(
                  hour: time.hour,
                  minute: time.minute,
                  weeklyInsights: weekly,
                );
                ref.invalidate(wellnessSettingsProvider);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editNutritionGoals(WellnessSettings settings) async {
    final l10n = AppLocalizations.of(context);
    final caloriesController = TextEditingController(
      text: settings.calorieTarget.toString(),
    );
    final proteinController = TextEditingController(
      text: settings.proteinTarget.toString(),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.nutritionGoals),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.nutritionGoalsDescription),
            const SizedBox(height: 18),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.calorieTarget,
                suffixText: 'kcal',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: proteinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.proteinTarget,
                suffixText: 'g',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final calories = int.tryParse(caloriesController.text.trim());
              final protein = int.tryParse(proteinController.text.trim());
              if (calories == null ||
                  protein == null ||
                  calories < 800 ||
                  calories > 10000 ||
                  protein < 10 ||
                  protein > 500) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.invalidGoals)));
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: Text(l10n.saveGoals),
          ),
        ],
      ),
    );
    final calories = int.tryParse(caloriesController.text.trim());
    final protein = int.tryParse(proteinController.text.trim());
    caloriesController.dispose();
    proteinController.dispose();
    if (saved == true && calories != null && protein != null && mounted) {
      await ref
          .read(wellnessPreferencesProvider)
          .saveTargets(calories: calories, protein: protein);
      ref.invalidate(wellnessSettingsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = ref.watch(premiumEntitlementProvider).value ?? false;
    final wellnessSettings = ref.watch(wellnessSettingsProvider).value;
    final todaySummary = ref.watch(weeklyNutritionSummaryProvider).value?.last;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF071B15),
                    Color(0xFF0A211A),
                    Color(0xFF102B22),
                  ]
                : const [AppColors.ivory, AppColors.cream, Color(0xFFEAF5EE)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -110,
              right: -90,
              child: _AmbientGlow(
                size: 300,
                color: isDark
                    ? const Color(0x263BCB94)
                    : const Color(0x2ED6B875),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -120,
              child: _AmbientGlow(
                size: 340,
                color: isDark
                    ? const Color(0x1FD6B875)
                    : const Color(0x241FAD82),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    // Leave a little more breathing room below the system/status
                    // area so the brand mark does not compete with the top actions.
                    padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 52,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (todaySummary != null && wellnessSettings != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _TodayProgressCard(
                                summary: todaySummary,
                                calorieTarget: wellnessSettings.calorieTarget,
                                proteinTarget: wellnessSettings.proteinTarget,
                              ),
                            ),
                          Column(
                            children: [
                              _BrandMark(isPremium: isPremium),
                              const SizedBox(height: 24),
                              Text(
                                l10n.aiPowered,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.champagne
                                      : AppColors.emerald,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.2,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Text(
                                  l10n.chooseFeatureTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 40,
                                    height: 1.08,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.7,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 380,
                                  ),
                                  child: Text(
                                    l10n.chooseFeatureDescription,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 16,
                                      height: 1.55,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              _FeatureCard(
                                icon: Icons.insights_rounded,
                                title: l10n.nutritionSummaryTitle,
                                description: l10n.nutritionSummarySubtitle,
                                accent: AppColors.champagne,
                                onTap: _openNutritionSummary,
                              ),
                              const SizedBox(height: 14),
                              _FeatureCard(
                                icon: Icons.restaurant_rounded,
                                title: l10n.scanFoodTitle,
                                description: l10n.scanFoodDescription,
                                accent: AppColors.emerald,
                                onTap: () => _showFoodSource(context),
                              ),
                              const SizedBox(height: 14),
                              _FeatureCard(
                                icon: Icons.menu_book_rounded,
                                title: l10n.menuScanTitle,
                                description: l10n.menuScanDescription,
                                accent: AppColors.champagne,
                                onTap: () => _showMenuSource(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 10,
              right: 18,
              child: SafeArea(
                child: Row(
                  children: [
                    PopupMenuButton<String>(
                      tooltip: l10n.languageTitle,
                      onSelected: (languageCode) {
                        ref
                            .read(appLocaleProvider.notifier)
                            .setLocale(Locale(languageCode));
                      },
                      itemBuilder: (context) {
                        final selected = Localizations.localeOf(
                          context,
                        ).languageCode;
                        return [
                          _languageItem(
                            code: 'en',
                            label: l10n.englishLanguage,
                            selected: selected == 'en',
                          ),
                          _languageItem(
                            code: 'tr',
                            label: l10n.turkishLanguage,
                            selected: selected == 'tr',
                          ),
                        ];
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language_rounded, size: 20),
                            const SizedBox(width: 5),
                            Text(l10n.languageTitle),
                          ],
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: _isOpeningHistory ? null : _openHistory,
                      tooltip: l10n.historyTitle,
                      style: TextButton.styleFrom(
                        backgroundColor: colors.surface.withValues(alpha: 0.78),
                        foregroundColor: colors.onSurface,
                      ),
                      icon: _isOpeningHistory
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.history_rounded, size: 20),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      tooltip: l10n.accountTitle,
                      onPressed: _isSigningOut ? null : _openAccount,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface.withValues(alpha: 0.78),
                        foregroundColor: colors.onSurface,
                      ),
                      icon: _isSigningOut
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.person_outline_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _languageItem({
    required String code,
    required String label,
    required bool selected,
  }) {
    return PopupMenuItem(
      value: code,
      child: Row(
        children: [
          Icon(selected ? Icons.check_rounded : Icons.language_rounded),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );

    if (image != null && context.mounted) {
      await context.push(AppRoutes.preview, extra: image.path);
    }
  }

  Future<void> _showFoodSource(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<_FoodSource>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.emerald,
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.scanFoodTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                l10n.scanFoodSourceDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              PremiumActionButton(
                label: l10n.takePhoto,
                icon: Icons.photo_camera_rounded,
                onPressed: () =>
                    Navigator.pop(sheetContext, _FoodSource.camera),
              ),
              const SizedBox(height: 8),
              PremiumActionButton(
                label: l10n.chooseFromGallery,
                icon: Icons.photo_library_outlined,
                secondary: true,
                onPressed: () =>
                    Navigator.pop(sheetContext, _FoodSource.gallery),
              ),
              const SizedBox(height: 8),
              PremiumActionButton(
                label: l10n.scanBarcode,
                icon: Icons.qr_code_scanner_rounded,
                secondary: true,
                onPressed: () =>
                    Navigator.pop(sheetContext, _FoodSource.barcode),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || source == null) return;
    if (source == _FoodSource.camera) {
      await this.context.push(AppRoutes.camera);
    } else if (source == _FoodSource.gallery) {
      await _pickFromGallery(this.context);
    } else {
      await this.context.push(AppRoutes.barcodeScan);
    }
  }

  Future<void> _showMenuSource(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.champagne.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.deepEmerald,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.menuPhotoSheetTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                l10n.menuPhotoSheetDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              PremiumActionButton(
                label: l10n.takePhoto,
                icon: Icons.photo_camera_rounded,
                onPressed: () =>
                    Navigator.pop(sheetContext, ImageSource.camera),
              ),
              const SizedBox(height: 10),
              PremiumActionButton(
                label: l10n.chooseFromGallery,
                icon: Icons.photo_library_outlined,
                secondary: true,
                onPressed: () =>
                    Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || source == null) return;
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
    );
    if (image != null && mounted) {
      await this.context.push(AppRoutes.menuScan, extra: image.path);
    }
  }
}

enum _FoodSource { camera, gallery, barcode }

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({
    required this.summary,
    required this.calorieTarget,
    required this.proteinTarget,
  });

  final DailyNutritionSummary summary;
  final int calorieTarget;
  final int proteinTarget;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final calorieProgress = (summary.calories / calorieTarget).clamp(0.0, 1.0);
    final proteinProgress = (summary.proteinGrams / proteinTarget).clamp(
      0.0,
      1.0,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.champagne.withValues(alpha: .4)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: .08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.emerald,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.todayProgress,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(
                l10n.mealsTracked(summary.mealCount),
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _ProgressLine(
            label: l10n.calorieProgress,
            value: '${summary.calories} kcal',
            target: l10n.targetValue('$calorieTarget kcal'),
            progress: calorieProgress,
            color: AppColors.emerald,
          ),
          const SizedBox(height: 13),
          _ProgressLine(
            label: l10n.proteinProgress,
            value: '${summary.proteinGrams} g',
            target: l10n.targetValue('$proteinTarget g'),
            progress: proteinProgress,
            color: AppColors.champagne,
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.label,
    required this.value,
    required this.target,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final String target;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 8),
            Text(
              target,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            color: color,
            backgroundColor: color.withValues(alpha: .13),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.84),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 104,
          height: 104,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.82),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? AppColors.champagne.withValues(alpha: 0.5)
                  : Colors.white,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2ED6B875),
                blurRadius: 32,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.emeraldBright, AppColors.teal],
              ),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 45),
          ),
        ),
        if (isPremium)
          Positioned(
            bottom: -9,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.champagneLight, AppColors.champagne],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 10),
                ],
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  color: AppColors.deepEmerald,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
