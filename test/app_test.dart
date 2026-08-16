import 'package:ai_food_analyzer/app/app.dart';
import 'package:ai_food_analyzer/core/localization/locale_preferences.dart';
import 'package:ai_food_analyzer/core/localization/locale_providers.dart';
import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:ai_food_analyzer/features/history/presentation/providers/history_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the meal capture home screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localePreferencesProvider.overrideWithValue(
            _MemoryLocalePreferences('en'),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Take a photo of\nyour meal'), findsOneWidget);
    expect(find.text('Take a photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
  });

  testWidgets('history button opens empty history and back returns home', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localePreferencesProvider.overrideWithValue(
            _MemoryLocalePreferences('en'),
          ),
          analysisHistoryProvider.overrideWith(
            (ref) => Stream.value(const <SavedFoodAnalysis>[]),
          ),
        ],
        child: const App(),
      ),
    );

    final historyButton = find.byTooltip('History');
    expect(historyButton, findsOneWidget);

    await tester.tap(historyButton);
    await tester.tap(historyButton);
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('No saved analyses yet'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Take a photo of\nyour meal'), findsOneWidget);
    expect(find.text('History'), findsNothing);
  });

  testWidgets('language selector switches to Turkish and persists it', (
    tester,
  ) async {
    final preferences = _MemoryLocalePreferences('en');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localePreferencesProvider.overrideWithValue(preferences)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();

    expect(find.text('Yemeğinin\nfotoğrafını çek'), findsOneWidget);
    expect(find.text('Fotoğraf çek'), findsOneWidget);
    expect(preferences.savedLanguageCode, 'tr');
  });
}

class _MemoryLocalePreferences implements LocalePreferences {
  _MemoryLocalePreferences(this.savedLanguageCode);

  String? savedLanguageCode;

  @override
  Future<String?> load() async => savedLanguageCode;

  @override
  Future<void> save(String languageCode) async {
    savedLanguageCode = languageCode;
  }
}
