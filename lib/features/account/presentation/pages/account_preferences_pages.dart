import 'package:ai_food_analyzer/core/config/legal_links.dart';
import 'package:ai_food_analyzer/core/notifications/smart_notification_service.dart';
import 'package:ai_food_analyzer/features/nutrition_summary/presentation/providers/nutrition_summary_providers.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

String _localized(BuildContext context, String tr, String en) =>
    Localizations.localeOf(context).languageCode == 'tr' ? tr : en;

class NutritionGoalsPage extends ConsumerStatefulWidget {
  const NutritionGoalsPage({super.key});

  @override
  ConsumerState<NutritionGoalsPage> createState() => _NutritionGoalsPageState();
}

class _NutritionGoalsPageState extends ConsumerState<NutritionGoalsPage> {
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _calories.dispose();
    _protein.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(wellnessSettingsProvider);
    settings.whenData((value) {
      if (!_loaded) {
        _loaded = true;
        _calories.text = value.calorieTarget.toString();
        _protein.text = value.proteinTarget.toString();
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _localized(context, 'Beslenme hedefleri', 'Nutrition goals'),
        ),
      ),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, stackTrace) => Center(
          child: Text(
            _localized(
              context,
              'Ayarlar yüklenemedi.',
              'Settings could not be loaded.',
            ),
          ),
        ),
        data: (_) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              _localized(
                context,
                'Günlük hedeflerini kişiselleştir',
                'Personalize your daily goals',
              ),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              _localized(
                context,
                'Özet ve ilerleme hesaplamaları bu değerlere göre hazırlanır.',
                'Summary and progress calculations use these values.',
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _calories,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _localized(
                  context,
                  'Kalori hedefi',
                  'Calorie target',
                ),
                suffixText: 'kcal',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _protein,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _localized(
                  context,
                  'Protein hedefi',
                  'Protein target',
                ),
                suffixText: 'g',
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving
                    ? _localized(context, 'Kaydediliyor…', 'Saving…')
                    : _localized(context, 'Hedefleri kaydet', 'Save goals'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final calories = int.tryParse(_calories.text.trim());
    final protein = int.tryParse(_protein.text.trim());
    if (calories == null ||
        calories < 800 ||
        calories > 10000 ||
        protein == null ||
        protein < 10 ||
        protein > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).invalidGoals)),
      );
      return;
    }
    setState(() => _saving = true);
    await ref
        .read(wellnessPreferencesProvider)
        .saveTargets(calories: calories, protein: protein);
    ref.invalidate(wellnessSettingsProvider);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _localized(context, 'Hedefler kaydedildi.', 'Goals saved.'),
        ),
      ),
    );
  }
}

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  bool _loaded = false;
  bool _daily = false;
  bool _weekly = true;
  bool _saving = false;
  TimeOfDay _time = const TimeOfDay(hour: 19, minute: 30);

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(wellnessSettingsProvider);
    settings.whenData((value) {
      if (!_loaded) {
        _loaded = true;
        _daily = value.smartRemindersEnabled;
        _weekly = value.weeklyInsightsEnabled;
        _time = TimeOfDay(
          hour: value.reminderHour,
          minute: value.reminderMinute,
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _localized(context, 'Akıllı hatırlatmalar', 'Smart reminders'),
        ),
      ),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, stackTrace) => Center(
          child: Text(
            _localized(
              context,
              'Ayarlar yüklenemedi.',
              'Settings could not be loaded.',
            ),
          ),
        ),
        data: (_) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SwitchListTile.adaptive(
              value: _daily,
              onChanged: (value) => setState(() => _daily = value),
              title: Text(
                _localized(context, 'Günlük hatırlatma', 'Daily reminder'),
              ),
              subtitle: Text(
                _localized(
                  context,
                  'Beslenme kaydını tamamlaman için tek bir bildirim.',
                  'One reminder to complete your nutrition log.',
                ),
              ),
            ),
            ListTile(
              enabled: _daily,
              leading: const Icon(Icons.schedule_rounded),
              title: Text(
                _localized(context, 'Bildirim saati', 'Reminder time'),
              ),
              trailing: Text(
                _time.format(context),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) setState(() => _time = picked);
              },
            ),
            SwitchListTile.adaptive(
              value: _weekly,
              onChanged: (value) => setState(() => _weekly = value),
              title: Text(
                _localized(
                  context,
                  'Haftalık gelişim özeti',
                  'Weekly progress insight',
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _localized(context, 'Ayarları kaydet', 'Save settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    if (_daily) {
      final granted = await SmartNotificationService.instance
          .enableDailyReminder(
            title: l10n.dailyReminderTitle,
            body: l10n.dailyReminderBody,
            hour: _time.hour,
            minute: _time.minute,
          );
      if (!granted && mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationsPermissionRequired)),
        );
        return;
      }
    } else {
      await SmartNotificationService.instance.disableDailyReminder();
    }
    final preferences = ref.read(wellnessPreferencesProvider);
    await preferences.setSmartReminders(_daily);
    await preferences.saveNotificationSettings(
      hour: _time.hour,
      minute: _time.minute,
      weeklyInsights: _weekly,
    );
    ref.invalidate(wellnessSettingsProvider);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _localized(
            context,
            'Bildirim ayarları kaydedildi.',
            'Notification settings saved.',
          ),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_localized(context, 'Hakkında', 'About'))),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.eco_rounded, size: 72),
        const SizedBox(height: 16),
        Text(
          'AI Food Analyzer',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          '1.0.0',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        Text(
          _localized(
            context,
            'Yemek fotoğraflarından tahmini besin değerleri sunan günlük beslenme yardımcısıdır. Sonuçlar tıbbi tavsiye değildir.',
            'A daily nutrition companion that estimates nutrition from meal photos. Results are not medical advice.',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        Card(
          child: ListTile(
            leading: const Icon(Icons.support_agent_rounded),
            title: Text(_localized(context, 'Destek', 'Support')),
            subtitle: const Text(LegalLinks.supportEmail),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => launchUrl(LegalLinks.support),
          ),
        ),
      ],
    ),
  );
}
