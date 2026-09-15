import 'package:shared_preferences/shared_preferences.dart';

class WellnessSettings {
  const WellnessSettings({
    required this.calorieTarget,
    required this.proteinTarget,
    required this.smartRemindersEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.weeklyInsightsEnabled,
  });

  final int calorieTarget;
  final int proteinTarget;
  final bool smartRemindersEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool weeklyInsightsEnabled;
}

class WellnessPreferences {
  const WellnessPreferences();

  static const _calorieTargetKey = 'wellness.calorieTarget';
  static const _proteinTargetKey = 'wellness.proteinTarget';
  static const _remindersKey = 'wellness.smartReminders';
  static const _reminderHourKey = 'wellness.reminderHour';
  static const _reminderMinuteKey = 'wellness.reminderMinute';
  static const _weeklyInsightsKey = 'wellness.weeklyInsights';

  Future<WellnessSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return WellnessSettings(
      calorieTarget: preferences.getInt(_calorieTargetKey) ?? 2000,
      proteinTarget: preferences.getInt(_proteinTargetKey) ?? 100,
      smartRemindersEnabled: preferences.getBool(_remindersKey) ?? false,
      reminderHour: preferences.getInt(_reminderHourKey) ?? 19,
      reminderMinute: preferences.getInt(_reminderMinuteKey) ?? 30,
      weeklyInsightsEnabled: preferences.getBool(_weeklyInsightsKey) ?? true,
    );
  }

  Future<void> saveTargets({
    required int calories,
    required int protein,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_calorieTargetKey, calories);
    await preferences.setInt(_proteinTargetKey, protein);
  }

  Future<void> setSmartReminders(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_remindersKey, enabled);
  }

  Future<void> saveNotificationSettings({
    required int hour,
    required int minute,
    required bool weeklyInsights,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_reminderHourKey, hour);
    await preferences.setInt(_reminderMinuteKey, minute);
    await preferences.setBool(_weeklyInsightsKey, weeklyInsights);
  }
}
