import 'package:ai_food_analyzer/app/app.dart';
import 'package:ai_food_analyzer/core/localization/locale_preferences.dart';
import 'package:ai_food_analyzer/core/localization/locale_providers.dart';
import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/pages/food_analysis_result_page.dart';
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
    await tester.pumpAndSettle();

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

  testWidgets('back from a result always returns directly to home', (
    tester,
  ) async {
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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    container
        .read(appRouterProvider)
        .go(
          AppRoutes.result,
          extra: const FoodAnalysisResultArguments(
            imagePath: '/missing/meal.jpg',
            analysis: FoodAnalysis(
              foodName: 'Meal',
              calories: 540,
              proteinGrams: 32,
              fatGrams: 18,
              carbsGrams: 56,
              fiberGrams: 7,
              confidencePercent: 87,
              servingDescription: '1 serving',
              description: 'Estimate.',
            ),
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('Food Analysis'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Take a photo of\nyour meal'), findsOneWidget);
    expect(find.text('Food Analysis'), findsNothing);
    expect(find.text('Analyzing...'), findsNothing);
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
