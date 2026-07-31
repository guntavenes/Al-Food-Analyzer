import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static String get apiBaseUrl {
    final uri = Uri.parse(_apiBaseUrl);
    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('API_BASE_URL must use HTTPS in release builds.');
    }
    return _apiBaseUrl;
  }
}
