import 'package:drift/drift.dart';

class FoodAnalysisRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get foodName => text()();

  IntColumn get calories => integer()();

  IntColumn get protein => integer()();

  IntColumn get carbohydrates => integer()();

  IntColumn get fat => integer()();

  IntColumn get fiber => integer()();

  IntColumn get confidence => integer()();

  TextColumn get servingDescription => text()();

  TextColumn get analysisDescription => text()();

  TextColumn get imagePath => text()();

  DateTimeColumn get createdAt => dateTime()();
}
