import 'dart:io';

import 'package:ai_food_analyzer/core/database/app_database.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/history/data/datasources/analysis_history_local_data_source.dart';
import 'package:ai_food_analyzer/features/history/data/datasources/analysis_image_local_data_source.dart';
import 'package:ai_food_analyzer/features/history/data/repositories/analysis_history_repository_impl.dart';
import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:ai_food_analyzer/features/history/presentation/pages/history_page.dart';
import 'package:ai_food_analyzer/features/history/presentation/providers/history_providers.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('save controller prevents duplicate records on repeated save', () async {
    final harness = await _HistoryTestHarness.create();
    addTearDown(harness.dispose);
    final container = ProviderContainer(
      overrides: [
        analysisHistoryRepositoryProvider.overrideWithValue(harness.repository),
      ],
    );
    addTearDown(container.dispose);
    final request = SaveAnalysisRequest(
      analysis: _analysis,
      imagePath: harness.sourceImage.path,
    );
    final provider = saveAnalysisProvider(request);
    final subscription = container.listen(provider, (previous, next) {});
    addTearDown(subscription.close);

    final firstId = await container.read(provider.notifier).save();
    final secondId = await container.read(provider.notifier).save();
    final records = await harness.repository.getAllAnalyses();

    expect(secondId, firstId);
    expect(records, hasLength(1));
    expect(records.single.foodName, 'Grilled Chicken Bowl');
  });

  test('delete removes both database record and persisted image', () async {
    final harness = await _HistoryTestHarness.create();
    addTearDown(harness.dispose);

    final id = await harness.repository.saveAnalysis(
      analysis: _analysis,
      sourceImagePath: harness.sourceImage.path,
    );
    final saved = await harness.repository.getAnalysis(id);

    expect(saved, isNotNull);
    expect(await File(saved!.imagePath).exists(), isTrue);

    await harness.repository.deleteAnalysis(id);

    expect(await harness.repository.getAnalysis(id), isNull);
    expect(await File(saved.imagePath).exists(), isFalse);
  });

  testWidgets('history shows its empty state without overflow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analysisHistoryProvider.overrideWith(
            (ref) => Stream.value(const <SavedFoodAnalysis>[]),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HistoryPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No saved analyses yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _analysis = FoodAnalysis(
  foodName: 'Grilled Chicken Bowl',
  calories: 540,
  proteinGrams: 32,
  fatGrams: 18,
  carbsGrams: 56,
  fiberGrams: 7,
  confidencePercent: 87,
  servingDescription: '1 medium serving',
  description: 'Balanced meal.',
);

class _HistoryTestHarness {
  const _HistoryTestHarness({
    required this.database,
    required this.repository,
    required this.sourceImage,
    required this.directory,
  });

  final AppDatabase database;
  final AnalysisHistoryRepositoryImpl repository;
  final File sourceImage;
  final Directory directory;

  static Future<_HistoryTestHarness> create() async {
    final directory = await Directory.systemTemp.createTemp(
      'ai_food_history_test_',
    );
    final sourceImage = File('${directory.path}/source.jpg');
    await sourceImage.writeAsBytes([1, 2, 3, 4]);
    final database = AppDatabase(NativeDatabase.memory());
    final repository = AnalysisHistoryRepositoryImpl(
      AnalysisHistoryLocalDataSource(database),
      AnalysisImageLocalDataSource(
        documentsDirectoryProvider: () async => directory,
      ),
    );

    return _HistoryTestHarness(
      database: database,
      repository: repository,
      sourceImage: sourceImage,
      directory: directory,
    );
  }

  Future<void> dispose() async {
    await database.close();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
