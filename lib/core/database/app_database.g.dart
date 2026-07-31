// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoodAnalysisRecordsTable extends FoodAnalysisRecords
    with TableInfo<$FoodAnalysisRecordsTable, FoodAnalysisRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodAnalysisRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<int> protein = GeneratedColumn<int>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbohydratesMeta = const VerificationMeta(
    'carbohydrates',
  );
  @override
  late final GeneratedColumn<int> carbohydrates = GeneratedColumn<int>(
    'carbohydrates',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<int> fat = GeneratedColumn<int>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<int> fiber = GeneratedColumn<int>(
    'fiber',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<int> confidence = GeneratedColumn<int>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingDescriptionMeta =
      const VerificationMeta('servingDescription');
  @override
  late final GeneratedColumn<String> servingDescription =
      GeneratedColumn<String>(
        'serving_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _analysisDescriptionMeta =
      const VerificationMeta('analysisDescription');
  @override
  late final GeneratedColumn<String> analysisDescription =
      GeneratedColumn<String>(
        'analysis_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    foodName,
    calories,
    protein,
    carbohydrates,
    fat,
    fiber,
    confidence,
    servingDescription,
    analysisDescription,
    imagePath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_analysis_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodAnalysisRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbohydrates')) {
      context.handle(
        _carbohydratesMeta,
        carbohydrates.isAcceptableOrUnknown(
          data['carbohydrates']!,
          _carbohydratesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbohydratesMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    } else if (isInserting) {
      context.missing(_fiberMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('serving_description')) {
      context.handle(
        _servingDescriptionMeta,
        servingDescription.isAcceptableOrUnknown(
          data['serving_description']!,
          _servingDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingDescriptionMeta);
    }
    if (data.containsKey('analysis_description')) {
      context.handle(
        _analysisDescriptionMeta,
        analysisDescription.isAcceptableOrUnknown(
          data['analysis_description']!,
          _analysisDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_analysisDescriptionMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodAnalysisRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodAnalysisRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein'],
      )!,
      carbohydrates: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carbohydrates'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fat'],
      )!,
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fiber'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence'],
      )!,
      servingDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_description'],
      )!,
      analysisDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_description'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoodAnalysisRecordsTable createAlias(String alias) {
    return $FoodAnalysisRecordsTable(attachedDatabase, alias);
  }
}

class FoodAnalysisRecord extends DataClass
    implements Insertable<FoodAnalysisRecord> {
  final int id;
  final String foodName;
  final int calories;
  final int protein;
  final int carbohydrates;
  final int fat;
  final int fiber;
  final int confidence;
  final String servingDescription;
  final String analysisDescription;
  final String imagePath;
  final DateTime createdAt;
  const FoodAnalysisRecord({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.confidence,
    required this.servingDescription,
    required this.analysisDescription,
    required this.imagePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['food_name'] = Variable<String>(foodName);
    map['calories'] = Variable<int>(calories);
    map['protein'] = Variable<int>(protein);
    map['carbohydrates'] = Variable<int>(carbohydrates);
    map['fat'] = Variable<int>(fat);
    map['fiber'] = Variable<int>(fiber);
    map['confidence'] = Variable<int>(confidence);
    map['serving_description'] = Variable<String>(servingDescription);
    map['analysis_description'] = Variable<String>(analysisDescription);
    map['image_path'] = Variable<String>(imagePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoodAnalysisRecordsCompanion toCompanion(bool nullToAbsent) {
    return FoodAnalysisRecordsCompanion(
      id: Value(id),
      foodName: Value(foodName),
      calories: Value(calories),
      protein: Value(protein),
      carbohydrates: Value(carbohydrates),
      fat: Value(fat),
      fiber: Value(fiber),
      confidence: Value(confidence),
      servingDescription: Value(servingDescription),
      analysisDescription: Value(analysisDescription),
      imagePath: Value(imagePath),
      createdAt: Value(createdAt),
    );
  }

  factory FoodAnalysisRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodAnalysisRecord(
      id: serializer.fromJson<int>(json['id']),
      foodName: serializer.fromJson<String>(json['foodName']),
      calories: serializer.fromJson<int>(json['calories']),
      protein: serializer.fromJson<int>(json['protein']),
      carbohydrates: serializer.fromJson<int>(json['carbohydrates']),
      fat: serializer.fromJson<int>(json['fat']),
      fiber: serializer.fromJson<int>(json['fiber']),
      confidence: serializer.fromJson<int>(json['confidence']),
      servingDescription: serializer.fromJson<String>(
        json['servingDescription'],
      ),
      analysisDescription: serializer.fromJson<String>(
        json['analysisDescription'],
      ),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'foodName': serializer.toJson<String>(foodName),
      'calories': serializer.toJson<int>(calories),
      'protein': serializer.toJson<int>(protein),
      'carbohydrates': serializer.toJson<int>(carbohydrates),
      'fat': serializer.toJson<int>(fat),
      'fiber': serializer.toJson<int>(fiber),
      'confidence': serializer.toJson<int>(confidence),
      'servingDescription': serializer.toJson<String>(servingDescription),
      'analysisDescription': serializer.toJson<String>(analysisDescription),
      'imagePath': serializer.toJson<String>(imagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FoodAnalysisRecord copyWith({
    int? id,
    String? foodName,
    int? calories,
    int? protein,
    int? carbohydrates,
    int? fat,
    int? fiber,
    int? confidence,
    String? servingDescription,
    String? analysisDescription,
    String? imagePath,
    DateTime? createdAt,
  }) => FoodAnalysisRecord(
    id: id ?? this.id,
    foodName: foodName ?? this.foodName,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbohydrates: carbohydrates ?? this.carbohydrates,
    fat: fat ?? this.fat,
    fiber: fiber ?? this.fiber,
    confidence: confidence ?? this.confidence,
    servingDescription: servingDescription ?? this.servingDescription,
    analysisDescription: analysisDescription ?? this.analysisDescription,
    imagePath: imagePath ?? this.imagePath,
    createdAt: createdAt ?? this.createdAt,
  );
  FoodAnalysisRecord copyWithCompanion(FoodAnalysisRecordsCompanion data) {
    return FoodAnalysisRecord(
      id: data.id.present ? data.id.value : this.id,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbohydrates: data.carbohydrates.present
          ? data.carbohydrates.value
          : this.carbohydrates,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      servingDescription: data.servingDescription.present
          ? data.servingDescription.value
          : this.servingDescription,
      analysisDescription: data.analysisDescription.present
          ? data.analysisDescription.value
          : this.analysisDescription,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodAnalysisRecord(')
          ..write('id: $id, ')
          ..write('foodName: $foodName, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbohydrates: $carbohydrates, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('confidence: $confidence, ')
          ..write('servingDescription: $servingDescription, ')
          ..write('analysisDescription: $analysisDescription, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    foodName,
    calories,
    protein,
    carbohydrates,
    fat,
    fiber,
    confidence,
    servingDescription,
    analysisDescription,
    imagePath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodAnalysisRecord &&
          other.id == this.id &&
          other.foodName == this.foodName &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbohydrates == this.carbohydrates &&
          other.fat == this.fat &&
          other.fiber == this.fiber &&
          other.confidence == this.confidence &&
          other.servingDescription == this.servingDescription &&
          other.analysisDescription == this.analysisDescription &&
          other.imagePath == this.imagePath &&
          other.createdAt == this.createdAt);
}

class FoodAnalysisRecordsCompanion extends UpdateCompanion<FoodAnalysisRecord> {
  final Value<int> id;
  final Value<String> foodName;
  final Value<int> calories;
  final Value<int> protein;
  final Value<int> carbohydrates;
  final Value<int> fat;
  final Value<int> fiber;
  final Value<int> confidence;
  final Value<String> servingDescription;
  final Value<String> analysisDescription;
  final Value<String> imagePath;
  final Value<DateTime> createdAt;
  const FoodAnalysisRecordsCompanion({
    this.id = const Value.absent(),
    this.foodName = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbohydrates = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.confidence = const Value.absent(),
    this.servingDescription = const Value.absent(),
    this.analysisDescription = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FoodAnalysisRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String foodName,
    required int calories,
    required int protein,
    required int carbohydrates,
    required int fat,
    required int fiber,
    required int confidence,
    required String servingDescription,
    required String analysisDescription,
    required String imagePath,
    required DateTime createdAt,
  }) : foodName = Value(foodName),
       calories = Value(calories),
       protein = Value(protein),
       carbohydrates = Value(carbohydrates),
       fat = Value(fat),
       fiber = Value(fiber),
       confidence = Value(confidence),
       servingDescription = Value(servingDescription),
       analysisDescription = Value(analysisDescription),
       imagePath = Value(imagePath),
       createdAt = Value(createdAt);
  static Insertable<FoodAnalysisRecord> custom({
    Expression<int>? id,
    Expression<String>? foodName,
    Expression<int>? calories,
    Expression<int>? protein,
    Expression<int>? carbohydrates,
    Expression<int>? fat,
    Expression<int>? fiber,
    Expression<int>? confidence,
    Expression<String>? servingDescription,
    Expression<String>? analysisDescription,
    Expression<String>? imagePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (foodName != null) 'food_name': foodName,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbohydrates != null) 'carbohydrates': carbohydrates,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (confidence != null) 'confidence': confidence,
      if (servingDescription != null) 'serving_description': servingDescription,
      if (analysisDescription != null)
        'analysis_description': analysisDescription,
      if (imagePath != null) 'image_path': imagePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FoodAnalysisRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? foodName,
    Value<int>? calories,
    Value<int>? protein,
    Value<int>? carbohydrates,
    Value<int>? fat,
    Value<int>? fiber,
    Value<int>? confidence,
    Value<String>? servingDescription,
    Value<String>? analysisDescription,
    Value<String>? imagePath,
    Value<DateTime>? createdAt,
  }) {
    return FoodAnalysisRecordsCompanion(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      confidence: confidence ?? this.confidence,
      servingDescription: servingDescription ?? this.servingDescription,
      analysisDescription: analysisDescription ?? this.analysisDescription,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<int>(protein.value);
    }
    if (carbohydrates.present) {
      map['carbohydrates'] = Variable<int>(carbohydrates.value);
    }
    if (fat.present) {
      map['fat'] = Variable<int>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<int>(fiber.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<int>(confidence.value);
    }
    if (servingDescription.present) {
      map['serving_description'] = Variable<String>(servingDescription.value);
    }
    if (analysisDescription.present) {
      map['analysis_description'] = Variable<String>(analysisDescription.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodAnalysisRecordsCompanion(')
          ..write('id: $id, ')
          ..write('foodName: $foodName, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbohydrates: $carbohydrates, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('confidence: $confidence, ')
          ..write('servingDescription: $servingDescription, ')
          ..write('analysisDescription: $analysisDescription, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodAnalysisRecordsTable foodAnalysisRecords =
      $FoodAnalysisRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [foodAnalysisRecords];
}

typedef $$FoodAnalysisRecordsTableCreateCompanionBuilder =
    FoodAnalysisRecordsCompanion Function({
      Value<int> id,
      required String foodName,
      required int calories,
      required int protein,
      required int carbohydrates,
      required int fat,
      required int fiber,
      required int confidence,
      required String servingDescription,
      required String analysisDescription,
      required String imagePath,
      required DateTime createdAt,
    });
typedef $$FoodAnalysisRecordsTableUpdateCompanionBuilder =
    FoodAnalysisRecordsCompanion Function({
      Value<int> id,
      Value<String> foodName,
      Value<int> calories,
      Value<int> protein,
      Value<int> carbohydrates,
      Value<int> fat,
      Value<int> fiber,
      Value<int> confidence,
      Value<String> servingDescription,
      Value<String> analysisDescription,
      Value<String> imagePath,
      Value<DateTime> createdAt,
    });

class $$FoodAnalysisRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodAnalysisRecordsTable> {
  $$FoodAnalysisRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carbohydrates => $composableBuilder(
    column: $table.carbohydrates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingDescription => $composableBuilder(
    column: $table.servingDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisDescription => $composableBuilder(
    column: $table.analysisDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodAnalysisRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodAnalysisRecordsTable> {
  $$FoodAnalysisRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carbohydrates => $composableBuilder(
    column: $table.carbohydrates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingDescription => $composableBuilder(
    column: $table.servingDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisDescription => $composableBuilder(
    column: $table.analysisDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodAnalysisRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodAnalysisRecordsTable> {
  $$FoodAnalysisRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<int> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<int> get carbohydrates => $composableBuilder(
    column: $table.carbohydrates,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<int> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingDescription => $composableBuilder(
    column: $table.servingDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get analysisDescription => $composableBuilder(
    column: $table.analysisDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FoodAnalysisRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodAnalysisRecordsTable,
          FoodAnalysisRecord,
          $$FoodAnalysisRecordsTableFilterComposer,
          $$FoodAnalysisRecordsTableOrderingComposer,
          $$FoodAnalysisRecordsTableAnnotationComposer,
          $$FoodAnalysisRecordsTableCreateCompanionBuilder,
          $$FoodAnalysisRecordsTableUpdateCompanionBuilder,
          (
            FoodAnalysisRecord,
            BaseReferences<
              _$AppDatabase,
              $FoodAnalysisRecordsTable,
              FoodAnalysisRecord
            >,
          ),
          FoodAnalysisRecord,
          PrefetchHooks Function()
        > {
  $$FoodAnalysisRecordsTableTableManager(
    _$AppDatabase db,
    $FoodAnalysisRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodAnalysisRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodAnalysisRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FoodAnalysisRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<int> protein = const Value.absent(),
                Value<int> carbohydrates = const Value.absent(),
                Value<int> fat = const Value.absent(),
                Value<int> fiber = const Value.absent(),
                Value<int> confidence = const Value.absent(),
                Value<String> servingDescription = const Value.absent(),
                Value<String> analysisDescription = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoodAnalysisRecordsCompanion(
                id: id,
                foodName: foodName,
                calories: calories,
                protein: protein,
                carbohydrates: carbohydrates,
                fat: fat,
                fiber: fiber,
                confidence: confidence,
                servingDescription: servingDescription,
                analysisDescription: analysisDescription,
                imagePath: imagePath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String foodName,
                required int calories,
                required int protein,
                required int carbohydrates,
                required int fat,
                required int fiber,
                required int confidence,
                required String servingDescription,
                required String analysisDescription,
                required String imagePath,
                required DateTime createdAt,
              }) => FoodAnalysisRecordsCompanion.insert(
                id: id,
                foodName: foodName,
                calories: calories,
                protein: protein,
                carbohydrates: carbohydrates,
                fat: fat,
                fiber: fiber,
                confidence: confidence,
                servingDescription: servingDescription,
                analysisDescription: analysisDescription,
                imagePath: imagePath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodAnalysisRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodAnalysisRecordsTable,
      FoodAnalysisRecord,
      $$FoodAnalysisRecordsTableFilterComposer,
      $$FoodAnalysisRecordsTableOrderingComposer,
      $$FoodAnalysisRecordsTableAnnotationComposer,
      $$FoodAnalysisRecordsTableCreateCompanionBuilder,
      $$FoodAnalysisRecordsTableUpdateCompanionBuilder,
      (
        FoodAnalysisRecord,
        BaseReferences<
          _$AppDatabase,
          $FoodAnalysisRecordsTable,
          FoodAnalysisRecord
        >,
      ),
      FoodAnalysisRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodAnalysisRecordsTableTableManager get foodAnalysisRecords =>
      $$FoodAnalysisRecordsTableTableManager(_db, _db.foodAnalysisRecords);
}
