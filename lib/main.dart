import 'package:ai_food_analyzer/app/app.dart';
import 'package:ai_food_analyzer/core/config/app_config.dart';
import 'package:ai_food_analyzer/core/notifications/smart_notification_service.dart';
import 'package:ai_food_analyzer/features/onboarding/data/onboarding_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    AppConfig.validate();
    if (AppConfig.isSupabaseConfigured) {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabasePublishableKey,
      );
      // Let people try the core app without creating an account. If the
      // network is temporarily unavailable, keep the app usable and retry
      // lazily when an authenticated feature is requested.
      try {
        if (Supabase.instance.client.auth.currentSession == null) {
          await Supabase.instance.client.auth.signInAnonymously();
        }
      } on Object {
        // Startup must not be blocked by optional guest-session creation.
      }
    }
    try {
      await SmartNotificationService.instance.initialize();
    } on Object {
      // Notifications are optional and must never block app startup.
    }
    final showOnboarding = !await const OnboardingPreferences().isComplete();
    runApp(ProviderScope(child: App(showOnboarding: showOnboarding)));
  } on Object catch (error) {
    runApp(_StartupErrorApp(message: error.toString()));
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 54),
                  const SizedBox(height: 18),
                  const Text(
                    'Uygulama başlatılamadı',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Lütfen internet bağlantını kontrol edip uygulamayı yeniden aç.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  if (!kReleaseMode)
                    SelectableText(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
