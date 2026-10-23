import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static String get supabaseUrl => _supabaseUrl.isNotEmpty
      ? _supabaseUrl
      : kReleaseMode
      ? 'https://jwdqoyxxuvumpeuzliwp.supabase.co'
      : '';

  static String get supabasePublishableKey => _supabasePublishableKey.isNotEmpty
      ? _supabasePublishableKey
      : kReleaseMode
      ? 'sb_publishable_g2JWCL7-TTdOD7I1n530RQ_F71MPj54'
      : '';

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static String get apiBaseUrl {
    final value = _apiBaseUrl.isNotEmpty
        ? _apiBaseUrl
        : kReleaseMode
        ? 'https://ai-food-analyzer-api.onrender.com'
        : 'http://localhost:8080';
    final uri = Uri.parse(value);
    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('API_BASE_URL must use HTTPS in release builds.');
    }
    return value;
  }

  static void validate() {
    // Resolve this during bootstrap so an invalid release endpoint is reported
    // by the startup error screen instead of failing later during provider setup.
    apiBaseUrl;
    if (supabaseUrl.isEmpty != supabasePublishableKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be provided together.',
      );
    }
  }
}
