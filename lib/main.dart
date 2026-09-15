import 'package:ai_food_analyzer/app/app.dart';
import 'package:ai_food_analyzer/core/config/app_config.dart';
import 'package:ai_food_analyzer/core/notifications/smart_notification_service.dart';
import 'package:ai_food_analyzer/features/onboarding/data/onboarding_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SmartNotificationService.instance.initialize();
  AppConfig.validate();
  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }
  final showOnboarding = !await const OnboardingPreferences().isComplete();
  runApp(ProviderScope(child: App(showOnboarding: showOnboarding)));
}
