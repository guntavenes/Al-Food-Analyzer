import 'package:drift/drift.dart';

class FoodAnalysisRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get foodName => text()();

  IntColumn get calories => integer()();

  IntColumn get protein => integer()();

  IntColumn get carbohydrates => integer()();

  IntColumn get fat => integer()();

  IntColumn get fiber => integer()();

  IntColumn get sugar => integer().withDefault(const Constant(0))();

  IntColumn get sodium => integer().withDefault(const Constant(0))();

  IntColumn get servingWeightGrams =>
      integer().withDefault(const Constant(0))();

  IntColumn get healthScore => integer().withDefault(const Constant(0))();

  TextColumn get warningsJson => text().withDefault(const Constant('[]'))();

  TextColumn get detectedFoodsJson =>
      text().withDefault(const Constant('[]'))();

  IntColumn get confidence => integer()();

  TextColumn get servingDescription => text()();

  TextColumn get analysisDescription => text()();

  TextColumn get imagePath => text()();

  DateTimeColumn get createdAt => dateTime()();
}
