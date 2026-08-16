import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static String get apiBaseUrl {
    final uri = Uri.parse(_apiBaseUrl);
    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('API_BASE_URL must use HTTPS in release builds.');
    }
    return _apiBaseUrl;
  }

  static void validate() {
    if (supabaseUrl.isEmpty != supabasePublishableKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be provided together.',
      );
    }
  }
}
