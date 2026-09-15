import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class SmartNotificationService {
  SmartNotificationService._();

  static final instance = SmartNotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _reminderId = 4101;
  static const _insightId = 4102;
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'nutrition_reminders',
      'Beslenme hatırlatıcıları',
      channelDescription: 'Günlük beslenme takibi için seyrek hatırlatmalar',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> initialize() async {
    if (kIsWeb) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (_) {}
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  Future<bool> enableDailyReminder({
    required String title,
    required String body,
    int hour = 19,
    int minute = 30,
  }) async {
    if (kIsWeb) return false;
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final granted = androidGranted ?? iosGranted ?? true;
    if (!granted) return false;
    await _plugin.cancel(id: _reminderId);
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }

  Future<void> disableDailyReminder() => _plugin.cancel(id: _reminderId);

  Future<void> maybeShowWeeklyInsight({
    required List<SavedFoodAnalysis> analyses,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || analyses.isEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekKey = '${now.year}-${now.weekday}-${now.day ~/ 7}';
    if (preferences.getString('nutrition.insightWeek') == weekKey) return;
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    int countVegetables(DateTime start, DateTime end) {
      const keywords = [
        'vegetable',
        'salad',
        'broccoli',
        'spinach',
        'greens',
        'sebze',
        'salata',
        'ıspanak',
        'brokoli',
      ];
      return analyses.where((analysis) {
        final date = analysis.createdAt.toLocal();
        if (date.isBefore(start) || !date.isBefore(end)) return false;
        return analysis.detectedFoods.any(
          (food) => keywords.any(
            (keyword) => food.name.toLowerCase().contains(keyword),
          ),
        );
      }).length;
    }

    final thisWeek = countVegetables(
      thisWeekStart,
      today.add(const Duration(days: 1)),
    );
    final lastWeek = countVegetables(lastWeekStart, thisWeekStart);
    if (thisWeek <= lastWeek || thisWeek == 0) return;
    await _plugin.show(
      id: _insightId,
      title: title,
      body: body,
      notificationDetails: _details,
    );
    await preferences.setString('nutrition.insightWeek', weekKey);
  }
}
