import 'package:ai_food_analyzer/core/localization/locale_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localePreferencesProvider = Provider<LocalePreferences>((ref) {
  return const FileLocalePreferences();
});

final appLocaleProvider = AsyncNotifierProvider<AppLocaleController, Locale>(
  AppLocaleController.new,
);

class AppLocaleController extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    final saved = await ref.read(localePreferencesProvider).load();
    return Locale(saved ?? 'en');
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'en' && locale.languageCode != 'tr') return;
    final previous = state;
    state = AsyncData(locale);
    try {
      await ref.read(localePreferencesProvider).save(locale.languageCode);
    } on Object catch (error, stackTrace) {
      state = previous;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
