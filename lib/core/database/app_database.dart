import 'dart:io';

import 'package:ai_food_analyzer/core/database/tables/food_analysis_records.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [FoodAnalysisRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 1) {
          await migrator.createAll();
        }
        if (from >= 1 && from < 2) {
          await migrator.addColumn(
            foodAnalysisRecords,
            foodAnalysisRecords.sugar,
          );
          await migrator.addColumn(
            foodAnalysisRecords,
            foodAnalysisRecords.sodium,
          );
          await migrator.addColumn(
            foodAnalysisRecords,
            foodAnalysisRecords.servingWeightGrams,
          );
          await migrator.addColumn(
            foodAnalysisRecords,
            foodAnalysisRecords.healthScore,
          );
          await migrator.addColumn(
            foodAnalysisRecords,
            foodAnalysisRecords.warningsJson,
          );
          await migrator.addColumn(
            foodAnalysisRecords,
            foodAnalysisRecords.detectedFoodsJson,
          );
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  @override
  int get schemaVersion => 2;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databaseFile = File(
      p.join(documentsDirectory.path, 'ai_food_analyzer.sqlite'),
    );

    return NativeDatabase.createInBackground(databaseFile);
  });
}
