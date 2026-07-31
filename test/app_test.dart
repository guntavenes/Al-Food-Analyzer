import 'package:ai_food_analyzer/app/app.dart';
import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:ai_food_analyzer/features/history/presentation/providers/history_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the meal capture home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

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
}
