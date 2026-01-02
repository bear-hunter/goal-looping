// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _targetDateMeta =
      const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
      'target_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, description, targetDate, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<GoalEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('target_date')) {
      context.handle(
          _targetDateMeta,
          targetDate.isAcceptableOrUnknown(
              data['target_date']!, _targetDateMeta));
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      targetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}target_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class GoalEntry extends DataClass implements Insertable<GoalEntry> {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final DateTime createdAt;
  const GoalEntry(
      {required this.id,
      required this.title,
      required this.description,
      required this.targetDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['target_date'] = Variable<DateTime>(targetDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      targetDate: Value(targetDate),
      createdAt: Value(createdAt),
    );
  }

  factory GoalEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      targetDate: serializer.fromJson<DateTime>(json['targetDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'targetDate': serializer.toJson<DateTime>(targetDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GoalEntry copyWith(
          {String? id,
          String? title,
          String? description,
          DateTime? targetDate,
          DateTime? createdAt}) =>
      GoalEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        targetDate: targetDate ?? this.targetDate,
        createdAt: createdAt ?? this.createdAt,
      );
  GoalEntry copyWithCompanion(GoalsCompanion data) {
    return GoalEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      targetDate:
          data.targetDate.present ? data.targetDate.value : this.targetDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, targetDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.targetDate == this.targetDate &&
          other.createdAt == this.createdAt);
}

class GoalsCompanion extends UpdateCompanion<GoalEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> targetDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required DateTime targetDate,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        targetDate = Value(targetDate),
        createdAt = Value(createdAt);
  static Insertable<GoalEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (targetDate != null) 'target_date': targetDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<DateTime>? targetDate,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FactorsTable extends Factors with TableInfo<$FactorsTable, FactorEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _targetLevelMeta =
      const VerificationMeta('targetLevel');
  @override
  late final GeneratedColumn<int> targetLevel = GeneratedColumn<int>(
      'target_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(7));
  static const VerificationMeta _currentLevelMeta =
      const VerificationMeta('currentLevel');
  @override
  late final GeneratedColumn<int> currentLevel = GeneratedColumn<int>(
      'current_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
      'goal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES goals (id)'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _targetDescriptionMeta =
      const VerificationMeta('targetDescription');
  @override
  late final GeneratedColumn<String> targetDescription =
      GeneratedColumn<String>('target_description', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _currentDescriptionMeta =
      const VerificationMeta('currentDescription');
  @override
  late final GeneratedColumn<String> currentDescription =
      GeneratedColumn<String>('current_description', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _isActiveFocusMeta =
      const VerificationMeta('isActiveFocus');
  @override
  late final GeneratedColumn<bool> isActiveFocus = GeneratedColumn<bool>(
      'is_active_focus', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_active_focus" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastWorkedOnMeta =
      const VerificationMeta('lastWorkedOn');
  @override
  late final GeneratedColumn<DateTime> lastWorkedOn = GeneratedColumn<DateTime>(
      'last_worked_on', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _healthPercentMeta =
      const VerificationMeta('healthPercent');
  @override
  late final GeneratedColumn<double> healthPercent = GeneratedColumn<double>(
      'health_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(100.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        targetLevel,
        currentLevel,
        description,
        goalId,
        lastUpdated,
        targetDescription,
        currentDescription,
        isActiveFocus,
        lastWorkedOn,
        healthPercent
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'factors';
  @override
  VerificationContext validateIntegrity(Insertable<FactorEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target_level')) {
      context.handle(
          _targetLevelMeta,
          targetLevel.isAcceptableOrUnknown(
              data['target_level']!, _targetLevelMeta));
    }
    if (data.containsKey('current_level')) {
      context.handle(
          _currentLevelMeta,
          currentLevel.isAcceptableOrUnknown(
              data['current_level']!, _currentLevelMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('target_description')) {
      context.handle(
          _targetDescriptionMeta,
          targetDescription.isAcceptableOrUnknown(
              data['target_description']!, _targetDescriptionMeta));
    }
    if (data.containsKey('current_description')) {
      context.handle(
          _currentDescriptionMeta,
          currentDescription.isAcceptableOrUnknown(
              data['current_description']!, _currentDescriptionMeta));
    }
    if (data.containsKey('is_active_focus')) {
      context.handle(
          _isActiveFocusMeta,
          isActiveFocus.isAcceptableOrUnknown(
              data['is_active_focus']!, _isActiveFocusMeta));
    }
    if (data.containsKey('last_worked_on')) {
      context.handle(
          _lastWorkedOnMeta,
          lastWorkedOn.isAcceptableOrUnknown(
              data['last_worked_on']!, _lastWorkedOnMeta));
    }
    if (data.containsKey('health_percent')) {
      context.handle(
          _healthPercentMeta,
          healthPercent.isAcceptableOrUnknown(
              data['health_percent']!, _healthPercentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FactorEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FactorEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      targetLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_level'])!,
      currentLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_level'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal_id'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      targetDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}target_description'])!,
      currentDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}current_description'])!,
      isActiveFocus: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active_focus'])!,
      lastWorkedOn: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_worked_on']),
      healthPercent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}health_percent'])!,
    );
  }

  @override
  $FactorsTable createAlias(String alias) {
    return $FactorsTable(attachedDatabase, alias);
  }
}

class FactorEntry extends DataClass implements Insertable<FactorEntry> {
  final String id;
  final String name;
  final int type;
  final int targetLevel;
  final int currentLevel;
  final String description;
  final String goalId;
  final DateTime lastUpdated;
  final String targetDescription;
  final String currentDescription;
  final bool isActiveFocus;
  final DateTime? lastWorkedOn;
  final double healthPercent;
  const FactorEntry(
      {required this.id,
      required this.name,
      required this.type,
      required this.targetLevel,
      required this.currentLevel,
      required this.description,
      required this.goalId,
      required this.lastUpdated,
      required this.targetDescription,
      required this.currentDescription,
      required this.isActiveFocus,
      this.lastWorkedOn,
      required this.healthPercent});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<int>(type);
    map['target_level'] = Variable<int>(targetLevel);
    map['current_level'] = Variable<int>(currentLevel);
    map['description'] = Variable<String>(description);
    map['goal_id'] = Variable<String>(goalId);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['target_description'] = Variable<String>(targetDescription);
    map['current_description'] = Variable<String>(currentDescription);
    map['is_active_focus'] = Variable<bool>(isActiveFocus);
    if (!nullToAbsent || lastWorkedOn != null) {
      map['last_worked_on'] = Variable<DateTime>(lastWorkedOn);
    }
    map['health_percent'] = Variable<double>(healthPercent);
    return map;
  }

  FactorsCompanion toCompanion(bool nullToAbsent) {
    return FactorsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      targetLevel: Value(targetLevel),
      currentLevel: Value(currentLevel),
      description: Value(description),
      goalId: Value(goalId),
      lastUpdated: Value(lastUpdated),
      targetDescription: Value(targetDescription),
      currentDescription: Value(currentDescription),
      isActiveFocus: Value(isActiveFocus),
      lastWorkedOn: lastWorkedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWorkedOn),
      healthPercent: Value(healthPercent),
    );
  }

  factory FactorEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FactorEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<int>(json['type']),
      targetLevel: serializer.fromJson<int>(json['targetLevel']),
      currentLevel: serializer.fromJson<int>(json['currentLevel']),
      description: serializer.fromJson<String>(json['description']),
      goalId: serializer.fromJson<String>(json['goalId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      targetDescription: serializer.fromJson<String>(json['targetDescription']),
      currentDescription:
          serializer.fromJson<String>(json['currentDescription']),
      isActiveFocus: serializer.fromJson<bool>(json['isActiveFocus']),
      lastWorkedOn: serializer.fromJson<DateTime?>(json['lastWorkedOn']),
      healthPercent: serializer.fromJson<double>(json['healthPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<int>(type),
      'targetLevel': serializer.toJson<int>(targetLevel),
      'currentLevel': serializer.toJson<int>(currentLevel),
      'description': serializer.toJson<String>(description),
      'goalId': serializer.toJson<String>(goalId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'targetDescription': serializer.toJson<String>(targetDescription),
      'currentDescription': serializer.toJson<String>(currentDescription),
      'isActiveFocus': serializer.toJson<bool>(isActiveFocus),
      'lastWorkedOn': serializer.toJson<DateTime?>(lastWorkedOn),
      'healthPercent': serializer.toJson<double>(healthPercent),
    };
  }

  FactorEntry copyWith(
          {String? id,
          String? name,
          int? type,
          int? targetLevel,
          int? currentLevel,
          String? description,
          String? goalId,
          DateTime? lastUpdated,
          String? targetDescription,
          String? currentDescription,
          bool? isActiveFocus,
          Value<DateTime?> lastWorkedOn = const Value.absent(),
          double? healthPercent}) =>
      FactorEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        targetLevel: targetLevel ?? this.targetLevel,
        currentLevel: currentLevel ?? this.currentLevel,
        description: description ?? this.description,
        goalId: goalId ?? this.goalId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        targetDescription: targetDescription ?? this.targetDescription,
        currentDescription: currentDescription ?? this.currentDescription,
        isActiveFocus: isActiveFocus ?? this.isActiveFocus,
        lastWorkedOn:
            lastWorkedOn.present ? lastWorkedOn.value : this.lastWorkedOn,
        healthPercent: healthPercent ?? this.healthPercent,
      );
  FactorEntry copyWithCompanion(FactorsCompanion data) {
    return FactorEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      targetLevel:
          data.targetLevel.present ? data.targetLevel.value : this.targetLevel,
      currentLevel: data.currentLevel.present
          ? data.currentLevel.value
          : this.currentLevel,
      description:
          data.description.present ? data.description.value : this.description,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      targetDescription: data.targetDescription.present
          ? data.targetDescription.value
          : this.targetDescription,
      currentDescription: data.currentDescription.present
          ? data.currentDescription.value
          : this.currentDescription,
      isActiveFocus: data.isActiveFocus.present
          ? data.isActiveFocus.value
          : this.isActiveFocus,
      lastWorkedOn: data.lastWorkedOn.present
          ? data.lastWorkedOn.value
          : this.lastWorkedOn,
      healthPercent: data.healthPercent.present
          ? data.healthPercent.value
          : this.healthPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactorEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('targetLevel: $targetLevel, ')
          ..write('currentLevel: $currentLevel, ')
          ..write('description: $description, ')
          ..write('goalId: $goalId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('targetDescription: $targetDescription, ')
          ..write('currentDescription: $currentDescription, ')
          ..write('isActiveFocus: $isActiveFocus, ')
          ..write('lastWorkedOn: $lastWorkedOn, ')
          ..write('healthPercent: $healthPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      type,
      targetLevel,
      currentLevel,
      description,
      goalId,
      lastUpdated,
      targetDescription,
      currentDescription,
      isActiveFocus,
      lastWorkedOn,
      healthPercent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactorEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.targetLevel == this.targetLevel &&
          other.currentLevel == this.currentLevel &&
          other.description == this.description &&
          other.goalId == this.goalId &&
          other.lastUpdated == this.lastUpdated &&
          other.targetDescription == this.targetDescription &&
          other.currentDescription == this.currentDescription &&
          other.isActiveFocus == this.isActiveFocus &&
          other.lastWorkedOn == this.lastWorkedOn &&
          other.healthPercent == this.healthPercent);
}

class FactorsCompanion extends UpdateCompanion<FactorEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> type;
  final Value<int> targetLevel;
  final Value<int> currentLevel;
  final Value<String> description;
  final Value<String> goalId;
  final Value<DateTime> lastUpdated;
  final Value<String> targetDescription;
  final Value<String> currentDescription;
  final Value<bool> isActiveFocus;
  final Value<DateTime?> lastWorkedOn;
  final Value<double> healthPercent;
  final Value<int> rowid;
  const FactorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.targetLevel = const Value.absent(),
    this.currentLevel = const Value.absent(),
    this.description = const Value.absent(),
    this.goalId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.targetDescription = const Value.absent(),
    this.currentDescription = const Value.absent(),
    this.isActiveFocus = const Value.absent(),
    this.lastWorkedOn = const Value.absent(),
    this.healthPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FactorsCompanion.insert({
    required String id,
    required String name,
    required int type,
    this.targetLevel = const Value.absent(),
    this.currentLevel = const Value.absent(),
    this.description = const Value.absent(),
    required String goalId,
    required DateTime lastUpdated,
    this.targetDescription = const Value.absent(),
    this.currentDescription = const Value.absent(),
    this.isActiveFocus = const Value.absent(),
    this.lastWorkedOn = const Value.absent(),
    this.healthPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        goalId = Value(goalId),
        lastUpdated = Value(lastUpdated);
  static Insertable<FactorEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<int>? targetLevel,
    Expression<int>? currentLevel,
    Expression<String>? description,
    Expression<String>? goalId,
    Expression<DateTime>? lastUpdated,
    Expression<String>? targetDescription,
    Expression<String>? currentDescription,
    Expression<bool>? isActiveFocus,
    Expression<DateTime>? lastWorkedOn,
    Expression<double>? healthPercent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (targetLevel != null) 'target_level': targetLevel,
      if (currentLevel != null) 'current_level': currentLevel,
      if (description != null) 'description': description,
      if (goalId != null) 'goal_id': goalId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (targetDescription != null) 'target_description': targetDescription,
      if (currentDescription != null) 'current_description': currentDescription,
      if (isActiveFocus != null) 'is_active_focus': isActiveFocus,
      if (lastWorkedOn != null) 'last_worked_on': lastWorkedOn,
      if (healthPercent != null) 'health_percent': healthPercent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FactorsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? type,
      Value<int>? targetLevel,
      Value<int>? currentLevel,
      Value<String>? description,
      Value<String>? goalId,
      Value<DateTime>? lastUpdated,
      Value<String>? targetDescription,
      Value<String>? currentDescription,
      Value<bool>? isActiveFocus,
      Value<DateTime?>? lastWorkedOn,
      Value<double>? healthPercent,
      Value<int>? rowid}) {
    return FactorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetLevel: targetLevel ?? this.targetLevel,
      currentLevel: currentLevel ?? this.currentLevel,
      description: description ?? this.description,
      goalId: goalId ?? this.goalId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      targetDescription: targetDescription ?? this.targetDescription,
      currentDescription: currentDescription ?? this.currentDescription,
      isActiveFocus: isActiveFocus ?? this.isActiveFocus,
      lastWorkedOn: lastWorkedOn ?? this.lastWorkedOn,
      healthPercent: healthPercent ?? this.healthPercent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (targetLevel.present) {
      map['target_level'] = Variable<int>(targetLevel.value);
    }
    if (currentLevel.present) {
      map['current_level'] = Variable<int>(currentLevel.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (targetDescription.present) {
      map['target_description'] = Variable<String>(targetDescription.value);
    }
    if (currentDescription.present) {
      map['current_description'] = Variable<String>(currentDescription.value);
    }
    if (isActiveFocus.present) {
      map['is_active_focus'] = Variable<bool>(isActiveFocus.value);
    }
    if (lastWorkedOn.present) {
      map['last_worked_on'] = Variable<DateTime>(lastWorkedOn.value);
    }
    if (healthPercent.present) {
      map['health_percent'] = Variable<double>(healthPercent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('targetLevel: $targetLevel, ')
          ..write('currentLevel: $currentLevel, ')
          ..write('description: $description, ')
          ..write('goalId: $goalId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('targetDescription: $targetDescription, ')
          ..write('currentDescription: $currentDescription, ')
          ..write('isActiveFocus: $isActiveFocus, ')
          ..write('lastWorkedOn: $lastWorkedOn, ')
          ..write('healthPercent: $healthPercent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isPriorityMeta =
      const VerificationMeta('isPriority');
  @override
  late final GeneratedColumn<bool> isPriority = GeneratedColumn<bool>(
      'is_priority', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_priority" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<int> source = GeneratedColumn<int>(
      'source', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _experimentIdMeta =
      const VerificationMeta('experimentId');
  @override
  late final GeneratedColumn<String> experimentId = GeneratedColumn<String>(
      'experiment_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _effortMeta = const VerificationMeta('effort');
  @override
  late final GeneratedColumn<int> effort = GeneratedColumn<int>(
      'effort', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _impactMeta = const VerificationMeta('impact');
  @override
  late final GeneratedColumn<int> impact = GeneratedColumn<int>(
      'impact', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _addedToPriorityAtMeta =
      const VerificationMeta('addedToPriorityAt');
  @override
  late final GeneratedColumn<DateTime> addedToPriorityAt =
      GeneratedColumn<DateTime>('added_to_priority_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _abandonReasonMeta =
      const VerificationMeta('abandonReason');
  @override
  late final GeneratedColumn<int> abandonReason = GeneratedColumn<int>(
      'abandon_reason', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _blockedByTaskIdMeta =
      const VerificationMeta('blockedByTaskId');
  @override
  late final GeneratedColumn<String> blockedByTaskId = GeneratedColumn<String>(
      'blocked_by_task_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _customTagMeta =
      const VerificationMeta('customTag');
  @override
  late final GeneratedColumn<String> customTag = GeneratedColumn<String>(
      'custom_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _marginalGainDescriptionMeta =
      const VerificationMeta('marginalGainDescription');
  @override
  late final GeneratedColumn<String> marginalGainDescription =
      GeneratedColumn<String>('marginal_gain_description', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isResearchTaskMeta =
      const VerificationMeta('isResearchTask');
  @override
  late final GeneratedColumn<bool> isResearchTask = GeneratedColumn<bool>(
      'is_research_task', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_research_task" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checklistItemsJsonMeta =
      const VerificationMeta('checklistItemsJson');
  @override
  late final GeneratedColumn<String> checklistItemsJson =
      GeneratedColumn<String>('checklist_items_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checklistCompletedJsonMeta =
      const VerificationMeta('checklistCompletedJson');
  @override
  late final GeneratedColumn<String> checklistCompletedJson =
      GeneratedColumn<String>('checklist_completed_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityLevelMeta =
      const VerificationMeta('priorityLevel');
  @override
  late final GeneratedColumn<int> priorityLevel = GeneratedColumn<int>(
      'priority_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPendingMeta =
      const VerificationMeta('isPending');
  @override
  late final GeneratedColumn<bool> isPending = GeneratedColumn<bool>(
      'is_pending', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pending" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _reminderTimesJsonMeta =
      const VerificationMeta('reminderTimesJson');
  @override
  late final GeneratedColumn<String> reminderTimesJson =
      GeneratedColumn<String>('reminder_times_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _scheduledDateMeta =
      const VerificationMeta('scheduledDate');
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>('scheduled_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        isPriority,
        isCompleted,
        source,
        createdAt,
        completedAt,
        experimentId,
        sortOrder,
        effort,
        impact,
        addedToPriorityAt,
        abandonReason,
        blockedByTaskId,
        category,
        deadline,
        customTag,
        marginalGainDescription,
        isResearchTask,
        categoryId,
        checklistItemsJson,
        checklistCompletedJson,
        priorityLevel,
        note,
        isPending,
        reminderTimesJson,
        scheduledDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<TaskEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_priority')) {
      context.handle(
          _isPriorityMeta,
          isPriority.isAcceptableOrUnknown(
              data['is_priority']!, _isPriorityMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('experiment_id')) {
      context.handle(
          _experimentIdMeta,
          experimentId.isAcceptableOrUnknown(
              data['experiment_id']!, _experimentIdMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('effort')) {
      context.handle(_effortMeta,
          effort.isAcceptableOrUnknown(data['effort']!, _effortMeta));
    } else if (isInserting) {
      context.missing(_effortMeta);
    }
    if (data.containsKey('impact')) {
      context.handle(_impactMeta,
          impact.isAcceptableOrUnknown(data['impact']!, _impactMeta));
    } else if (isInserting) {
      context.missing(_impactMeta);
    }
    if (data.containsKey('added_to_priority_at')) {
      context.handle(
          _addedToPriorityAtMeta,
          addedToPriorityAt.isAcceptableOrUnknown(
              data['added_to_priority_at']!, _addedToPriorityAtMeta));
    }
    if (data.containsKey('abandon_reason')) {
      context.handle(
          _abandonReasonMeta,
          abandonReason.isAcceptableOrUnknown(
              data['abandon_reason']!, _abandonReasonMeta));
    }
    if (data.containsKey('blocked_by_task_id')) {
      context.handle(
          _blockedByTaskIdMeta,
          blockedByTaskId.isAcceptableOrUnknown(
              data['blocked_by_task_id']!, _blockedByTaskIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('custom_tag')) {
      context.handle(_customTagMeta,
          customTag.isAcceptableOrUnknown(data['custom_tag']!, _customTagMeta));
    }
    if (data.containsKey('marginal_gain_description')) {
      context.handle(
          _marginalGainDescriptionMeta,
          marginalGainDescription.isAcceptableOrUnknown(
              data['marginal_gain_description']!,
              _marginalGainDescriptionMeta));
    }
    if (data.containsKey('is_research_task')) {
      context.handle(
          _isResearchTaskMeta,
          isResearchTask.isAcceptableOrUnknown(
              data['is_research_task']!, _isResearchTaskMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('checklist_items_json')) {
      context.handle(
          _checklistItemsJsonMeta,
          checklistItemsJson.isAcceptableOrUnknown(
              data['checklist_items_json']!, _checklistItemsJsonMeta));
    }
    if (data.containsKey('checklist_completed_json')) {
      context.handle(
          _checklistCompletedJsonMeta,
          checklistCompletedJson.isAcceptableOrUnknown(
              data['checklist_completed_json']!, _checklistCompletedJsonMeta));
    }
    if (data.containsKey('priority_level')) {
      context.handle(
          _priorityLevelMeta,
          priorityLevel.isAcceptableOrUnknown(
              data['priority_level']!, _priorityLevelMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('is_pending')) {
      context.handle(_isPendingMeta,
          isPending.isAcceptableOrUnknown(data['is_pending']!, _isPendingMeta));
    }
    if (data.containsKey('reminder_times_json')) {
      context.handle(
          _reminderTimesJsonMeta,
          reminderTimesJson.isAcceptableOrUnknown(
              data['reminder_times_json']!, _reminderTimesJsonMeta));
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
          _scheduledDateMeta,
          scheduledDate.isAcceptableOrUnknown(
              data['scheduled_date']!, _scheduledDateMeta));
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      isPriority: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_priority'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      experimentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}experiment_id']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      effort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}effort'])!,
      impact: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}impact'])!,
      addedToPriorityAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}added_to_priority_at']),
      abandonReason: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}abandon_reason']),
      blockedByTaskId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}blocked_by_task_id']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      customTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}custom_tag']),
      marginalGainDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}marginal_gain_description']),
      isResearchTask: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_research_task'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      checklistItemsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}checklist_items_json']),
      checklistCompletedJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}checklist_completed_json']),
      priorityLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority_level'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      isPending: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pending'])!,
      reminderTimesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reminder_times_json'])!,
      scheduledDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}scheduled_date'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskEntry extends DataClass implements Insertable<TaskEntry> {
  final String id;
  final String title;
  final String description;
  final bool isPriority;
  final bool isCompleted;
  final int source;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? experimentId;
  final int sortOrder;
  final int effort;
  final int impact;
  final DateTime? addedToPriorityAt;
  final int? abandonReason;
  final String? blockedByTaskId;
  final String category;
  final DateTime? deadline;
  final String? customTag;
  final String? marginalGainDescription;
  final bool isResearchTask;
  final String? categoryId;
  final String? checklistItemsJson;
  final String? checklistCompletedJson;
  final int priorityLevel;
  final String? note;
  final bool isPending;
  final String reminderTimesJson;
  final DateTime scheduledDate;
  const TaskEntry(
      {required this.id,
      required this.title,
      required this.description,
      required this.isPriority,
      required this.isCompleted,
      required this.source,
      required this.createdAt,
      this.completedAt,
      this.experimentId,
      required this.sortOrder,
      required this.effort,
      required this.impact,
      this.addedToPriorityAt,
      this.abandonReason,
      this.blockedByTaskId,
      required this.category,
      this.deadline,
      this.customTag,
      this.marginalGainDescription,
      required this.isResearchTask,
      this.categoryId,
      this.checklistItemsJson,
      this.checklistCompletedJson,
      required this.priorityLevel,
      this.note,
      required this.isPending,
      required this.reminderTimesJson,
      required this.scheduledDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['is_priority'] = Variable<bool>(isPriority);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['source'] = Variable<int>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || experimentId != null) {
      map['experiment_id'] = Variable<String>(experimentId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['effort'] = Variable<int>(effort);
    map['impact'] = Variable<int>(impact);
    if (!nullToAbsent || addedToPriorityAt != null) {
      map['added_to_priority_at'] = Variable<DateTime>(addedToPriorityAt);
    }
    if (!nullToAbsent || abandonReason != null) {
      map['abandon_reason'] = Variable<int>(abandonReason);
    }
    if (!nullToAbsent || blockedByTaskId != null) {
      map['blocked_by_task_id'] = Variable<String>(blockedByTaskId);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || customTag != null) {
      map['custom_tag'] = Variable<String>(customTag);
    }
    if (!nullToAbsent || marginalGainDescription != null) {
      map['marginal_gain_description'] =
          Variable<String>(marginalGainDescription);
    }
    map['is_research_task'] = Variable<bool>(isResearchTask);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || checklistItemsJson != null) {
      map['checklist_items_json'] = Variable<String>(checklistItemsJson);
    }
    if (!nullToAbsent || checklistCompletedJson != null) {
      map['checklist_completed_json'] =
          Variable<String>(checklistCompletedJson);
    }
    map['priority_level'] = Variable<int>(priorityLevel);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_pending'] = Variable<bool>(isPending);
    map['reminder_times_json'] = Variable<String>(reminderTimesJson);
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      isPriority: Value(isPriority),
      isCompleted: Value(isCompleted),
      source: Value(source),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      experimentId: experimentId == null && nullToAbsent
          ? const Value.absent()
          : Value(experimentId),
      sortOrder: Value(sortOrder),
      effort: Value(effort),
      impact: Value(impact),
      addedToPriorityAt: addedToPriorityAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedToPriorityAt),
      abandonReason: abandonReason == null && nullToAbsent
          ? const Value.absent()
          : Value(abandonReason),
      blockedByTaskId: blockedByTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(blockedByTaskId),
      category: Value(category),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      customTag: customTag == null && nullToAbsent
          ? const Value.absent()
          : Value(customTag),
      marginalGainDescription: marginalGainDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(marginalGainDescription),
      isResearchTask: Value(isResearchTask),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      checklistItemsJson: checklistItemsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checklistItemsJson),
      checklistCompletedJson: checklistCompletedJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checklistCompletedJson),
      priorityLevel: Value(priorityLevel),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isPending: Value(isPending),
      reminderTimesJson: Value(reminderTimesJson),
      scheduledDate: Value(scheduledDate),
    );
  }

  factory TaskEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      isPriority: serializer.fromJson<bool>(json['isPriority']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      source: serializer.fromJson<int>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      experimentId: serializer.fromJson<String?>(json['experimentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      effort: serializer.fromJson<int>(json['effort']),
      impact: serializer.fromJson<int>(json['impact']),
      addedToPriorityAt:
          serializer.fromJson<DateTime?>(json['addedToPriorityAt']),
      abandonReason: serializer.fromJson<int?>(json['abandonReason']),
      blockedByTaskId: serializer.fromJson<String?>(json['blockedByTaskId']),
      category: serializer.fromJson<String>(json['category']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      customTag: serializer.fromJson<String?>(json['customTag']),
      marginalGainDescription:
          serializer.fromJson<String?>(json['marginalGainDescription']),
      isResearchTask: serializer.fromJson<bool>(json['isResearchTask']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      checklistItemsJson:
          serializer.fromJson<String?>(json['checklistItemsJson']),
      checklistCompletedJson:
          serializer.fromJson<String?>(json['checklistCompletedJson']),
      priorityLevel: serializer.fromJson<int>(json['priorityLevel']),
      note: serializer.fromJson<String?>(json['note']),
      isPending: serializer.fromJson<bool>(json['isPending']),
      reminderTimesJson: serializer.fromJson<String>(json['reminderTimesJson']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'isPriority': serializer.toJson<bool>(isPriority),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'source': serializer.toJson<int>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'experimentId': serializer.toJson<String?>(experimentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'effort': serializer.toJson<int>(effort),
      'impact': serializer.toJson<int>(impact),
      'addedToPriorityAt': serializer.toJson<DateTime?>(addedToPriorityAt),
      'abandonReason': serializer.toJson<int?>(abandonReason),
      'blockedByTaskId': serializer.toJson<String?>(blockedByTaskId),
      'category': serializer.toJson<String>(category),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'customTag': serializer.toJson<String?>(customTag),
      'marginalGainDescription':
          serializer.toJson<String?>(marginalGainDescription),
      'isResearchTask': serializer.toJson<bool>(isResearchTask),
      'categoryId': serializer.toJson<String?>(categoryId),
      'checklistItemsJson': serializer.toJson<String?>(checklistItemsJson),
      'checklistCompletedJson':
          serializer.toJson<String?>(checklistCompletedJson),
      'priorityLevel': serializer.toJson<int>(priorityLevel),
      'note': serializer.toJson<String?>(note),
      'isPending': serializer.toJson<bool>(isPending),
      'reminderTimesJson': serializer.toJson<String>(reminderTimesJson),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
    };
  }

  TaskEntry copyWith(
          {String? id,
          String? title,
          String? description,
          bool? isPriority,
          bool? isCompleted,
          int? source,
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<String?> experimentId = const Value.absent(),
          int? sortOrder,
          int? effort,
          int? impact,
          Value<DateTime?> addedToPriorityAt = const Value.absent(),
          Value<int?> abandonReason = const Value.absent(),
          Value<String?> blockedByTaskId = const Value.absent(),
          String? category,
          Value<DateTime?> deadline = const Value.absent(),
          Value<String?> customTag = const Value.absent(),
          Value<String?> marginalGainDescription = const Value.absent(),
          bool? isResearchTask,
          Value<String?> categoryId = const Value.absent(),
          Value<String?> checklistItemsJson = const Value.absent(),
          Value<String?> checklistCompletedJson = const Value.absent(),
          int? priorityLevel,
          Value<String?> note = const Value.absent(),
          bool? isPending,
          String? reminderTimesJson,
          DateTime? scheduledDate}) =>
      TaskEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isPriority: isPriority ?? this.isPriority,
        isCompleted: isCompleted ?? this.isCompleted,
        source: source ?? this.source,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        experimentId:
            experimentId.present ? experimentId.value : this.experimentId,
        sortOrder: sortOrder ?? this.sortOrder,
        effort: effort ?? this.effort,
        impact: impact ?? this.impact,
        addedToPriorityAt: addedToPriorityAt.present
            ? addedToPriorityAt.value
            : this.addedToPriorityAt,
        abandonReason:
            abandonReason.present ? abandonReason.value : this.abandonReason,
        blockedByTaskId: blockedByTaskId.present
            ? blockedByTaskId.value
            : this.blockedByTaskId,
        category: category ?? this.category,
        deadline: deadline.present ? deadline.value : this.deadline,
        customTag: customTag.present ? customTag.value : this.customTag,
        marginalGainDescription: marginalGainDescription.present
            ? marginalGainDescription.value
            : this.marginalGainDescription,
        isResearchTask: isResearchTask ?? this.isResearchTask,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        checklistItemsJson: checklistItemsJson.present
            ? checklistItemsJson.value
            : this.checklistItemsJson,
        checklistCompletedJson: checklistCompletedJson.present
            ? checklistCompletedJson.value
            : this.checklistCompletedJson,
        priorityLevel: priorityLevel ?? this.priorityLevel,
        note: note.present ? note.value : this.note,
        isPending: isPending ?? this.isPending,
        reminderTimesJson: reminderTimesJson ?? this.reminderTimesJson,
        scheduledDate: scheduledDate ?? this.scheduledDate,
      );
  TaskEntry copyWithCompanion(TasksCompanion data) {
    return TaskEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      isPriority:
          data.isPriority.present ? data.isPriority.value : this.isPriority,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      experimentId: data.experimentId.present
          ? data.experimentId.value
          : this.experimentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      effort: data.effort.present ? data.effort.value : this.effort,
      impact: data.impact.present ? data.impact.value : this.impact,
      addedToPriorityAt: data.addedToPriorityAt.present
          ? data.addedToPriorityAt.value
          : this.addedToPriorityAt,
      abandonReason: data.abandonReason.present
          ? data.abandonReason.value
          : this.abandonReason,
      blockedByTaskId: data.blockedByTaskId.present
          ? data.blockedByTaskId.value
          : this.blockedByTaskId,
      category: data.category.present ? data.category.value : this.category,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      customTag: data.customTag.present ? data.customTag.value : this.customTag,
      marginalGainDescription: data.marginalGainDescription.present
          ? data.marginalGainDescription.value
          : this.marginalGainDescription,
      isResearchTask: data.isResearchTask.present
          ? data.isResearchTask.value
          : this.isResearchTask,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      checklistItemsJson: data.checklistItemsJson.present
          ? data.checklistItemsJson.value
          : this.checklistItemsJson,
      checklistCompletedJson: data.checklistCompletedJson.present
          ? data.checklistCompletedJson.value
          : this.checklistCompletedJson,
      priorityLevel: data.priorityLevel.present
          ? data.priorityLevel.value
          : this.priorityLevel,
      note: data.note.present ? data.note.value : this.note,
      isPending: data.isPending.present ? data.isPending.value : this.isPending,
      reminderTimesJson: data.reminderTimesJson.present
          ? data.reminderTimesJson.value
          : this.reminderTimesJson,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isPriority: $isPriority, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('experimentId: $experimentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('effort: $effort, ')
          ..write('impact: $impact, ')
          ..write('addedToPriorityAt: $addedToPriorityAt, ')
          ..write('abandonReason: $abandonReason, ')
          ..write('blockedByTaskId: $blockedByTaskId, ')
          ..write('category: $category, ')
          ..write('deadline: $deadline, ')
          ..write('customTag: $customTag, ')
          ..write('marginalGainDescription: $marginalGainDescription, ')
          ..write('isResearchTask: $isResearchTask, ')
          ..write('categoryId: $categoryId, ')
          ..write('checklistItemsJson: $checklistItemsJson, ')
          ..write('checklistCompletedJson: $checklistCompletedJson, ')
          ..write('priorityLevel: $priorityLevel, ')
          ..write('note: $note, ')
          ..write('isPending: $isPending, ')
          ..write('reminderTimesJson: $reminderTimesJson, ')
          ..write('scheduledDate: $scheduledDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        description,
        isPriority,
        isCompleted,
        source,
        createdAt,
        completedAt,
        experimentId,
        sortOrder,
        effort,
        impact,
        addedToPriorityAt,
        abandonReason,
        blockedByTaskId,
        category,
        deadline,
        customTag,
        marginalGainDescription,
        isResearchTask,
        categoryId,
        checklistItemsJson,
        checklistCompletedJson,
        priorityLevel,
        note,
        isPending,
        reminderTimesJson,
        scheduledDate
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.isPriority == this.isPriority &&
          other.isCompleted == this.isCompleted &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.experimentId == this.experimentId &&
          other.sortOrder == this.sortOrder &&
          other.effort == this.effort &&
          other.impact == this.impact &&
          other.addedToPriorityAt == this.addedToPriorityAt &&
          other.abandonReason == this.abandonReason &&
          other.blockedByTaskId == this.blockedByTaskId &&
          other.category == this.category &&
          other.deadline == this.deadline &&
          other.customTag == this.customTag &&
          other.marginalGainDescription == this.marginalGainDescription &&
          other.isResearchTask == this.isResearchTask &&
          other.categoryId == this.categoryId &&
          other.checklistItemsJson == this.checklistItemsJson &&
          other.checklistCompletedJson == this.checklistCompletedJson &&
          other.priorityLevel == this.priorityLevel &&
          other.note == this.note &&
          other.isPending == this.isPending &&
          other.reminderTimesJson == this.reminderTimesJson &&
          other.scheduledDate == this.scheduledDate);
}

class TasksCompanion extends UpdateCompanion<TaskEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<bool> isPriority;
  final Value<bool> isCompleted;
  final Value<int> source;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<String?> experimentId;
  final Value<int> sortOrder;
  final Value<int> effort;
  final Value<int> impact;
  final Value<DateTime?> addedToPriorityAt;
  final Value<int?> abandonReason;
  final Value<String?> blockedByTaskId;
  final Value<String> category;
  final Value<DateTime?> deadline;
  final Value<String?> customTag;
  final Value<String?> marginalGainDescription;
  final Value<bool> isResearchTask;
  final Value<String?> categoryId;
  final Value<String?> checklistItemsJson;
  final Value<String?> checklistCompletedJson;
  final Value<int> priorityLevel;
  final Value<String?> note;
  final Value<bool> isPending;
  final Value<String> reminderTimesJson;
  final Value<DateTime> scheduledDate;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isPriority = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.experimentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.effort = const Value.absent(),
    this.impact = const Value.absent(),
    this.addedToPriorityAt = const Value.absent(),
    this.abandonReason = const Value.absent(),
    this.blockedByTaskId = const Value.absent(),
    this.category = const Value.absent(),
    this.deadline = const Value.absent(),
    this.customTag = const Value.absent(),
    this.marginalGainDescription = const Value.absent(),
    this.isResearchTask = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.checklistItemsJson = const Value.absent(),
    this.checklistCompletedJson = const Value.absent(),
    this.priorityLevel = const Value.absent(),
    this.note = const Value.absent(),
    this.isPending = const Value.absent(),
    this.reminderTimesJson = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.isPriority = const Value.absent(),
    this.isCompleted = const Value.absent(),
    required int source,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.experimentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int effort,
    required int impact,
    this.addedToPriorityAt = const Value.absent(),
    this.abandonReason = const Value.absent(),
    this.blockedByTaskId = const Value.absent(),
    this.category = const Value.absent(),
    this.deadline = const Value.absent(),
    this.customTag = const Value.absent(),
    this.marginalGainDescription = const Value.absent(),
    this.isResearchTask = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.checklistItemsJson = const Value.absent(),
    this.checklistCompletedJson = const Value.absent(),
    this.priorityLevel = const Value.absent(),
    this.note = const Value.absent(),
    this.isPending = const Value.absent(),
    this.reminderTimesJson = const Value.absent(),
    required DateTime scheduledDate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        source = Value(source),
        createdAt = Value(createdAt),
        effort = Value(effort),
        impact = Value(impact),
        scheduledDate = Value(scheduledDate);
  static Insertable<TaskEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isPriority,
    Expression<bool>? isCompleted,
    Expression<int>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<String>? experimentId,
    Expression<int>? sortOrder,
    Expression<int>? effort,
    Expression<int>? impact,
    Expression<DateTime>? addedToPriorityAt,
    Expression<int>? abandonReason,
    Expression<String>? blockedByTaskId,
    Expression<String>? category,
    Expression<DateTime>? deadline,
    Expression<String>? customTag,
    Expression<String>? marginalGainDescription,
    Expression<bool>? isResearchTask,
    Expression<String>? categoryId,
    Expression<String>? checklistItemsJson,
    Expression<String>? checklistCompletedJson,
    Expression<int>? priorityLevel,
    Expression<String>? note,
    Expression<bool>? isPending,
    Expression<String>? reminderTimesJson,
    Expression<DateTime>? scheduledDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isPriority != null) 'is_priority': isPriority,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (experimentId != null) 'experiment_id': experimentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (effort != null) 'effort': effort,
      if (impact != null) 'impact': impact,
      if (addedToPriorityAt != null) 'added_to_priority_at': addedToPriorityAt,
      if (abandonReason != null) 'abandon_reason': abandonReason,
      if (blockedByTaskId != null) 'blocked_by_task_id': blockedByTaskId,
      if (category != null) 'category': category,
      if (deadline != null) 'deadline': deadline,
      if (customTag != null) 'custom_tag': customTag,
      if (marginalGainDescription != null)
        'marginal_gain_description': marginalGainDescription,
      if (isResearchTask != null) 'is_research_task': isResearchTask,
      if (categoryId != null) 'category_id': categoryId,
      if (checklistItemsJson != null)
        'checklist_items_json': checklistItemsJson,
      if (checklistCompletedJson != null)
        'checklist_completed_json': checklistCompletedJson,
      if (priorityLevel != null) 'priority_level': priorityLevel,
      if (note != null) 'note': note,
      if (isPending != null) 'is_pending': isPending,
      if (reminderTimesJson != null) 'reminder_times_json': reminderTimesJson,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<bool>? isPriority,
      Value<bool>? isCompleted,
      Value<int>? source,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<String?>? experimentId,
      Value<int>? sortOrder,
      Value<int>? effort,
      Value<int>? impact,
      Value<DateTime?>? addedToPriorityAt,
      Value<int?>? abandonReason,
      Value<String?>? blockedByTaskId,
      Value<String>? category,
      Value<DateTime?>? deadline,
      Value<String?>? customTag,
      Value<String?>? marginalGainDescription,
      Value<bool>? isResearchTask,
      Value<String?>? categoryId,
      Value<String?>? checklistItemsJson,
      Value<String?>? checklistCompletedJson,
      Value<int>? priorityLevel,
      Value<String?>? note,
      Value<bool>? isPending,
      Value<String>? reminderTimesJson,
      Value<DateTime>? scheduledDate,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isPriority: isPriority ?? this.isPriority,
      isCompleted: isCompleted ?? this.isCompleted,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      experimentId: experimentId ?? this.experimentId,
      sortOrder: sortOrder ?? this.sortOrder,
      effort: effort ?? this.effort,
      impact: impact ?? this.impact,
      addedToPriorityAt: addedToPriorityAt ?? this.addedToPriorityAt,
      abandonReason: abandonReason ?? this.abandonReason,
      blockedByTaskId: blockedByTaskId ?? this.blockedByTaskId,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      customTag: customTag ?? this.customTag,
      marginalGainDescription:
          marginalGainDescription ?? this.marginalGainDescription,
      isResearchTask: isResearchTask ?? this.isResearchTask,
      categoryId: categoryId ?? this.categoryId,
      checklistItemsJson: checklistItemsJson ?? this.checklistItemsJson,
      checklistCompletedJson:
          checklistCompletedJson ?? this.checklistCompletedJson,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      note: note ?? this.note,
      isPending: isPending ?? this.isPending,
      reminderTimesJson: reminderTimesJson ?? this.reminderTimesJson,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isPriority.present) {
      map['is_priority'] = Variable<bool>(isPriority.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (experimentId.present) {
      map['experiment_id'] = Variable<String>(experimentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (effort.present) {
      map['effort'] = Variable<int>(effort.value);
    }
    if (impact.present) {
      map['impact'] = Variable<int>(impact.value);
    }
    if (addedToPriorityAt.present) {
      map['added_to_priority_at'] = Variable<DateTime>(addedToPriorityAt.value);
    }
    if (abandonReason.present) {
      map['abandon_reason'] = Variable<int>(abandonReason.value);
    }
    if (blockedByTaskId.present) {
      map['blocked_by_task_id'] = Variable<String>(blockedByTaskId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (customTag.present) {
      map['custom_tag'] = Variable<String>(customTag.value);
    }
    if (marginalGainDescription.present) {
      map['marginal_gain_description'] =
          Variable<String>(marginalGainDescription.value);
    }
    if (isResearchTask.present) {
      map['is_research_task'] = Variable<bool>(isResearchTask.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (checklistItemsJson.present) {
      map['checklist_items_json'] = Variable<String>(checklistItemsJson.value);
    }
    if (checklistCompletedJson.present) {
      map['checklist_completed_json'] =
          Variable<String>(checklistCompletedJson.value);
    }
    if (priorityLevel.present) {
      map['priority_level'] = Variable<int>(priorityLevel.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isPending.present) {
      map['is_pending'] = Variable<bool>(isPending.value);
    }
    if (reminderTimesJson.present) {
      map['reminder_times_json'] = Variable<String>(reminderTimesJson.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isPriority: $isPriority, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('experimentId: $experimentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('effort: $effort, ')
          ..write('impact: $impact, ')
          ..write('addedToPriorityAt: $addedToPriorityAt, ')
          ..write('abandonReason: $abandonReason, ')
          ..write('blockedByTaskId: $blockedByTaskId, ')
          ..write('category: $category, ')
          ..write('deadline: $deadline, ')
          ..write('customTag: $customTag, ')
          ..write('marginalGainDescription: $marginalGainDescription, ')
          ..write('isResearchTask: $isResearchTask, ')
          ..write('categoryId: $categoryId, ')
          ..write('checklistItemsJson: $checklistItemsJson, ')
          ..write('checklistCompletedJson: $checklistCompletedJson, ')
          ..write('priorityLevel: $priorityLevel, ')
          ..write('note: $note, ')
          ..write('isPending: $isPending, ')
          ..write('reminderTimesJson: $reminderTimesJson, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskFactorLinksTable extends TaskFactorLinks
    with TableInfo<$TaskFactorLinksTable, TaskFactorLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskFactorLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _factorIdMeta =
      const VerificationMeta('factorId');
  @override
  late final GeneratedColumn<String> factorId = GeneratedColumn<String>(
      'factor_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES factors (id)'));
  @override
  List<GeneratedColumn> get $columns => [taskId, factorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_factor_links';
  @override
  VerificationContext validateIntegrity(Insertable<TaskFactorLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('factor_id')) {
      context.handle(_factorIdMeta,
          factorId.isAcceptableOrUnknown(data['factor_id']!, _factorIdMeta));
    } else if (isInserting) {
      context.missing(_factorIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, factorId};
  @override
  TaskFactorLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskFactorLink(
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      factorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}factor_id'])!,
    );
  }

  @override
  $TaskFactorLinksTable createAlias(String alias) {
    return $TaskFactorLinksTable(attachedDatabase, alias);
  }
}

class TaskFactorLink extends DataClass implements Insertable<TaskFactorLink> {
  final String taskId;
  final String factorId;
  const TaskFactorLink({required this.taskId, required this.factorId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['factor_id'] = Variable<String>(factorId);
    return map;
  }

  TaskFactorLinksCompanion toCompanion(bool nullToAbsent) {
    return TaskFactorLinksCompanion(
      taskId: Value(taskId),
      factorId: Value(factorId),
    );
  }

  factory TaskFactorLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskFactorLink(
      taskId: serializer.fromJson<String>(json['taskId']),
      factorId: serializer.fromJson<String>(json['factorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'factorId': serializer.toJson<String>(factorId),
    };
  }

  TaskFactorLink copyWith({String? taskId, String? factorId}) => TaskFactorLink(
        taskId: taskId ?? this.taskId,
        factorId: factorId ?? this.factorId,
      );
  TaskFactorLink copyWithCompanion(TaskFactorLinksCompanion data) {
    return TaskFactorLink(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      factorId: data.factorId.present ? data.factorId.value : this.factorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskFactorLink(')
          ..write('taskId: $taskId, ')
          ..write('factorId: $factorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, factorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskFactorLink &&
          other.taskId == this.taskId &&
          other.factorId == this.factorId);
}

class TaskFactorLinksCompanion extends UpdateCompanion<TaskFactorLink> {
  final Value<String> taskId;
  final Value<String> factorId;
  final Value<int> rowid;
  const TaskFactorLinksCompanion({
    this.taskId = const Value.absent(),
    this.factorId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskFactorLinksCompanion.insert({
    required String taskId,
    required String factorId,
    this.rowid = const Value.absent(),
  })  : taskId = Value(taskId),
        factorId = Value(factorId);
  static Insertable<TaskFactorLink> custom({
    Expression<String>? taskId,
    Expression<String>? factorId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (factorId != null) 'factor_id': factorId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskFactorLinksCompanion copyWith(
      {Value<String>? taskId, Value<String>? factorId, Value<int>? rowid}) {
    return TaskFactorLinksCompanion(
      taskId: taskId ?? this.taskId,
      factorId: factorId ?? this.factorId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (factorId.present) {
      map['factor_id'] = Variable<String>(factorId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskFactorLinksCompanion(')
          ..write('taskId: $taskId, ')
          ..write('factorId: $factorId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubtasksTable extends Subtasks
    with TableInfo<$SubtasksTable, SubtaskEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _parentTaskIdMeta =
      const VerificationMeta('parentTaskId');
  @override
  late final GeneratedColumn<String> parentTaskId = GeneratedColumn<String>(
      'parent_task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, isCompleted, parentTaskId, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  VerificationContext validateIntegrity(Insertable<SubtaskEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('parent_task_id')) {
      context.handle(
          _parentTaskIdMeta,
          parentTaskId.isAcceptableOrUnknown(
              data['parent_task_id']!, _parentTaskIdMeta));
    } else if (isInserting) {
      context.missing(_parentTaskIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubtaskEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubtaskEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      parentTaskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_task_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SubtasksTable createAlias(String alias) {
    return $SubtasksTable(attachedDatabase, alias);
  }
}

class SubtaskEntry extends DataClass implements Insertable<SubtaskEntry> {
  final String id;
  final String title;
  final bool isCompleted;
  final String parentTaskId;
  final int sortOrder;
  final DateTime createdAt;
  const SubtaskEntry(
      {required this.id,
      required this.title,
      required this.isCompleted,
      required this.parentTaskId,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['parent_task_id'] = Variable<String>(parentTaskId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SubtasksCompanion toCompanion(bool nullToAbsent) {
    return SubtasksCompanion(
      id: Value(id),
      title: Value(title),
      isCompleted: Value(isCompleted),
      parentTaskId: Value(parentTaskId),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory SubtaskEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubtaskEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      parentTaskId: serializer.fromJson<String>(json['parentTaskId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'parentTaskId': serializer.toJson<String>(parentTaskId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SubtaskEntry copyWith(
          {String? id,
          String? title,
          bool? isCompleted,
          String? parentTaskId,
          int? sortOrder,
          DateTime? createdAt}) =>
      SubtaskEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
        parentTaskId: parentTaskId ?? this.parentTaskId,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  SubtaskEntry copyWithCompanion(SubtasksCompanion data) {
    return SubtaskEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      parentTaskId: data.parentTaskId.present
          ? data.parentTaskId.value
          : this.parentTaskId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubtaskEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, isCompleted, parentTaskId, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubtaskEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.parentTaskId == this.parentTaskId &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class SubtasksCompanion extends UpdateCompanion<SubtaskEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<String> parentTaskId;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SubtasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubtasksCompanion.insert({
    required String id,
    required String title,
    this.isCompleted = const Value.absent(),
    required String parentTaskId,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        parentTaskId = Value(parentTaskId),
        createdAt = Value(createdAt);
  static Insertable<SubtaskEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<String>? parentTaskId,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (parentTaskId != null) 'parent_task_id': parentTaskId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubtasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<bool>? isCompleted,
      Value<String>? parentTaskId,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SubtasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (parentTaskId.present) {
      map['parent_task_id'] = Variable<String>(parentTaskId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, HabitEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _triggerResponseMeta =
      const VerificationMeta('triggerResponse');
  @override
  late final GeneratedColumn<String> triggerResponse = GeneratedColumn<String>(
      'trigger_response', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currentStreakMeta =
      const VerificationMeta('currentStreak');
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
      'current_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bestStreakMeta =
      const VerificationMeta('bestStreak');
  @override
  late final GeneratedColumn<int> bestStreak = GeneratedColumn<int>(
      'best_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _completionCountMeta =
      const VerificationMeta('completionCount');
  @override
  late final GeneratedColumn<int> completionCount = GeneratedColumn<int>(
      'completion_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _factorIdMeta =
      const VerificationMeta('factorId');
  @override
  late final GeneratedColumn<String> factorId = GeneratedColumn<String>(
      'factor_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledDaysJsonMeta =
      const VerificationMeta('scheduledDaysJson');
  @override
  late final GeneratedColumn<String> scheduledDaysJson =
      GeneratedColumn<String>('scheduled_days_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _targetFrequencyMeta =
      const VerificationMeta('targetFrequency');
  @override
  late final GeneratedColumn<int> targetFrequency = GeneratedColumn<int>(
      'target_frequency', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _motivationMeta =
      const VerificationMeta('motivation');
  @override
  late final GeneratedColumn<String> motivation = GeneratedColumn<String>(
      'motivation', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _timerMinutesMeta =
      const VerificationMeta('timerMinutes');
  @override
  late final GeneratedColumn<int> timerMinutes = GeneratedColumn<int>(
      'timer_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _streakFreezesMeta =
      const VerificationMeta('streakFreezes');
  @override
  late final GeneratedColumn<int> streakFreezes = GeneratedColumn<int>(
      'streak_freezes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _freezesUsedMeta =
      const VerificationMeta('freezesUsed');
  @override
  late final GeneratedColumn<int> freezesUsed = GeneratedColumn<int>(
      'freezes_used', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _evaluationTypeMeta =
      const VerificationMeta('evaluationType');
  @override
  late final GeneratedColumn<int> evaluationType = GeneratedColumn<int>(
      'evaluation_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _frequencyTypeMeta =
      const VerificationMeta('frequencyType');
  @override
  late final GeneratedColumn<int> frequencyType = GeneratedColumn<int>(
      'frequency_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _targetValueMeta =
      const VerificationMeta('targetValue');
  @override
  late final GeneratedColumn<int> targetValue = GeneratedColumn<int>(
      'target_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checklistItemsJsonMeta =
      const VerificationMeta('checklistItemsJson');
  @override
  late final GeneratedColumn<String> checklistItemsJson =
      GeneratedColumn<String>('checklist_items_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityLevelMeta =
      const VerificationMeta('priorityLevel');
  @override
  late final GeneratedColumn<int> priorityLevel = GeneratedColumn<int>(
      'priority_level', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _reminderTimesJsonMeta =
      const VerificationMeta('reminderTimesJson');
  @override
  late final GeneratedColumn<String> reminderTimesJson =
      GeneratedColumn<String>('reminder_times_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _daysPerPeriodMeta =
      const VerificationMeta('daysPerPeriod');
  @override
  late final GeneratedColumn<int> daysPerPeriod = GeneratedColumn<int>(
      'days_per_period', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _repeatIntervalMeta =
      const VerificationMeta('repeatInterval');
  @override
  late final GeneratedColumn<int> repeatInterval = GeneratedColumn<int>(
      'repeat_interval', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _specificDatesJsonMeta =
      const VerificationMeta('specificDatesJson');
  @override
  late final GeneratedColumn<String> specificDatesJson =
      GeneratedColumn<String>('specific_dates_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _extraGoalMeta =
      const VerificationMeta('extraGoal');
  @override
  late final GeneratedColumn<int> extraGoal = GeneratedColumn<int>(
      'extra_goal', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _scoringEnabledMeta =
      const VerificationMeta('scoringEnabled');
  @override
  late final GeneratedColumn<bool> scoringEnabled = GeneratedColumn<bool>(
      'scoring_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("scoring_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        triggerResponse,
        currentStreak,
        bestStreak,
        completionCount,
        createdAt,
        isActive,
        factorId,
        scheduledDaysJson,
        targetFrequency,
        motivation,
        timerMinutes,
        streakFreezes,
        freezesUsed,
        categoryId,
        evaluationType,
        frequencyType,
        targetValue,
        unit,
        checklistItemsJson,
        priorityLevel,
        startDate,
        endDate,
        reminderTimesJson,
        isArchived,
        daysPerPeriod,
        repeatInterval,
        specificDatesJson,
        description,
        extraGoal,
        sortOrder,
        scoringEnabled,
        priority
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(Insertable<HabitEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('trigger_response')) {
      context.handle(
          _triggerResponseMeta,
          triggerResponse.isAcceptableOrUnknown(
              data['trigger_response']!, _triggerResponseMeta));
    }
    if (data.containsKey('current_streak')) {
      context.handle(
          _currentStreakMeta,
          currentStreak.isAcceptableOrUnknown(
              data['current_streak']!, _currentStreakMeta));
    }
    if (data.containsKey('best_streak')) {
      context.handle(
          _bestStreakMeta,
          bestStreak.isAcceptableOrUnknown(
              data['best_streak']!, _bestStreakMeta));
    }
    if (data.containsKey('completion_count')) {
      context.handle(
          _completionCountMeta,
          completionCount.isAcceptableOrUnknown(
              data['completion_count']!, _completionCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('factor_id')) {
      context.handle(_factorIdMeta,
          factorId.isAcceptableOrUnknown(data['factor_id']!, _factorIdMeta));
    }
    if (data.containsKey('scheduled_days_json')) {
      context.handle(
          _scheduledDaysJsonMeta,
          scheduledDaysJson.isAcceptableOrUnknown(
              data['scheduled_days_json']!, _scheduledDaysJsonMeta));
    }
    if (data.containsKey('target_frequency')) {
      context.handle(
          _targetFrequencyMeta,
          targetFrequency.isAcceptableOrUnknown(
              data['target_frequency']!, _targetFrequencyMeta));
    }
    if (data.containsKey('motivation')) {
      context.handle(
          _motivationMeta,
          motivation.isAcceptableOrUnknown(
              data['motivation']!, _motivationMeta));
    }
    if (data.containsKey('timer_minutes')) {
      context.handle(
          _timerMinutesMeta,
          timerMinutes.isAcceptableOrUnknown(
              data['timer_minutes']!, _timerMinutesMeta));
    }
    if (data.containsKey('streak_freezes')) {
      context.handle(
          _streakFreezesMeta,
          streakFreezes.isAcceptableOrUnknown(
              data['streak_freezes']!, _streakFreezesMeta));
    }
    if (data.containsKey('freezes_used')) {
      context.handle(
          _freezesUsedMeta,
          freezesUsed.isAcceptableOrUnknown(
              data['freezes_used']!, _freezesUsedMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('evaluation_type')) {
      context.handle(
          _evaluationTypeMeta,
          evaluationType.isAcceptableOrUnknown(
              data['evaluation_type']!, _evaluationTypeMeta));
    }
    if (data.containsKey('frequency_type')) {
      context.handle(
          _frequencyTypeMeta,
          frequencyType.isAcceptableOrUnknown(
              data['frequency_type']!, _frequencyTypeMeta));
    }
    if (data.containsKey('target_value')) {
      context.handle(
          _targetValueMeta,
          targetValue.isAcceptableOrUnknown(
              data['target_value']!, _targetValueMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('checklist_items_json')) {
      context.handle(
          _checklistItemsJsonMeta,
          checklistItemsJson.isAcceptableOrUnknown(
              data['checklist_items_json']!, _checklistItemsJsonMeta));
    }
    if (data.containsKey('priority_level')) {
      context.handle(
          _priorityLevelMeta,
          priorityLevel.isAcceptableOrUnknown(
              data['priority_level']!, _priorityLevelMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('reminder_times_json')) {
      context.handle(
          _reminderTimesJsonMeta,
          reminderTimesJson.isAcceptableOrUnknown(
              data['reminder_times_json']!, _reminderTimesJsonMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('days_per_period')) {
      context.handle(
          _daysPerPeriodMeta,
          daysPerPeriod.isAcceptableOrUnknown(
              data['days_per_period']!, _daysPerPeriodMeta));
    }
    if (data.containsKey('repeat_interval')) {
      context.handle(
          _repeatIntervalMeta,
          repeatInterval.isAcceptableOrUnknown(
              data['repeat_interval']!, _repeatIntervalMeta));
    }
    if (data.containsKey('specific_dates_json')) {
      context.handle(
          _specificDatesJsonMeta,
          specificDatesJson.isAcceptableOrUnknown(
              data['specific_dates_json']!, _specificDatesJsonMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('extra_goal')) {
      context.handle(_extraGoalMeta,
          extraGoal.isAcceptableOrUnknown(data['extra_goal']!, _extraGoalMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('scoring_enabled')) {
      context.handle(
          _scoringEnabledMeta,
          scoringEnabled.isAcceptableOrUnknown(
              data['scoring_enabled']!, _scoringEnabledMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      triggerResponse: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}trigger_response']),
      currentStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_streak'])!,
      bestStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}best_streak'])!,
      completionCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completion_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      factorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}factor_id']),
      scheduledDaysJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}scheduled_days_json'])!,
      targetFrequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_frequency'])!,
      motivation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motivation'])!,
      timerMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timer_minutes']),
      streakFreezes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}streak_freezes'])!,
      freezesUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}freezes_used'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      evaluationType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}evaluation_type']),
      frequencyType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency_type']),
      targetValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_value']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      checklistItemsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}checklist_items_json']),
      priorityLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority_level']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      reminderTimesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reminder_times_json']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      daysPerPeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}days_per_period']),
      repeatInterval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repeat_interval']),
      specificDatesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specific_dates_json']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      extraGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}extra_goal']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      scoringEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}scoring_enabled'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class HabitEntry extends DataClass implements Insertable<HabitEntry> {
  final String id;
  final String name;
  final int type;
  final String? triggerResponse;
  final int currentStreak;
  final int bestStreak;
  final int completionCount;
  final DateTime createdAt;
  final bool isActive;
  final String? factorId;
  final String scheduledDaysJson;
  final int targetFrequency;
  final String motivation;
  final int? timerMinutes;
  final int streakFreezes;
  final int freezesUsed;
  final String? categoryId;
  final int? evaluationType;
  final int? frequencyType;
  final int? targetValue;
  final String? unit;
  final String? checklistItemsJson;
  final int? priorityLevel;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? reminderTimesJson;
  final bool isArchived;
  final int? daysPerPeriod;
  final int? repeatInterval;
  final String? specificDatesJson;
  final String? description;
  final int? extraGoal;
  final int sortOrder;
  final bool scoringEnabled;
  final int priority;
  const HabitEntry(
      {required this.id,
      required this.name,
      required this.type,
      this.triggerResponse,
      required this.currentStreak,
      required this.bestStreak,
      required this.completionCount,
      required this.createdAt,
      required this.isActive,
      this.factorId,
      required this.scheduledDaysJson,
      required this.targetFrequency,
      required this.motivation,
      this.timerMinutes,
      required this.streakFreezes,
      required this.freezesUsed,
      this.categoryId,
      this.evaluationType,
      this.frequencyType,
      this.targetValue,
      this.unit,
      this.checklistItemsJson,
      this.priorityLevel,
      this.startDate,
      this.endDate,
      this.reminderTimesJson,
      required this.isArchived,
      this.daysPerPeriod,
      this.repeatInterval,
      this.specificDatesJson,
      this.description,
      this.extraGoal,
      required this.sortOrder,
      required this.scoringEnabled,
      required this.priority});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || triggerResponse != null) {
      map['trigger_response'] = Variable<String>(triggerResponse);
    }
    map['current_streak'] = Variable<int>(currentStreak);
    map['best_streak'] = Variable<int>(bestStreak);
    map['completion_count'] = Variable<int>(completionCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || factorId != null) {
      map['factor_id'] = Variable<String>(factorId);
    }
    map['scheduled_days_json'] = Variable<String>(scheduledDaysJson);
    map['target_frequency'] = Variable<int>(targetFrequency);
    map['motivation'] = Variable<String>(motivation);
    if (!nullToAbsent || timerMinutes != null) {
      map['timer_minutes'] = Variable<int>(timerMinutes);
    }
    map['streak_freezes'] = Variable<int>(streakFreezes);
    map['freezes_used'] = Variable<int>(freezesUsed);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || evaluationType != null) {
      map['evaluation_type'] = Variable<int>(evaluationType);
    }
    if (!nullToAbsent || frequencyType != null) {
      map['frequency_type'] = Variable<int>(frequencyType);
    }
    if (!nullToAbsent || targetValue != null) {
      map['target_value'] = Variable<int>(targetValue);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || checklistItemsJson != null) {
      map['checklist_items_json'] = Variable<String>(checklistItemsJson);
    }
    if (!nullToAbsent || priorityLevel != null) {
      map['priority_level'] = Variable<int>(priorityLevel);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || reminderTimesJson != null) {
      map['reminder_times_json'] = Variable<String>(reminderTimesJson);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || daysPerPeriod != null) {
      map['days_per_period'] = Variable<int>(daysPerPeriod);
    }
    if (!nullToAbsent || repeatInterval != null) {
      map['repeat_interval'] = Variable<int>(repeatInterval);
    }
    if (!nullToAbsent || specificDatesJson != null) {
      map['specific_dates_json'] = Variable<String>(specificDatesJson);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || extraGoal != null) {
      map['extra_goal'] = Variable<int>(extraGoal);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['scoring_enabled'] = Variable<bool>(scoringEnabled);
    map['priority'] = Variable<int>(priority);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      triggerResponse: triggerResponse == null && nullToAbsent
          ? const Value.absent()
          : Value(triggerResponse),
      currentStreak: Value(currentStreak),
      bestStreak: Value(bestStreak),
      completionCount: Value(completionCount),
      createdAt: Value(createdAt),
      isActive: Value(isActive),
      factorId: factorId == null && nullToAbsent
          ? const Value.absent()
          : Value(factorId),
      scheduledDaysJson: Value(scheduledDaysJson),
      targetFrequency: Value(targetFrequency),
      motivation: Value(motivation),
      timerMinutes: timerMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timerMinutes),
      streakFreezes: Value(streakFreezes),
      freezesUsed: Value(freezesUsed),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      evaluationType: evaluationType == null && nullToAbsent
          ? const Value.absent()
          : Value(evaluationType),
      frequencyType: frequencyType == null && nullToAbsent
          ? const Value.absent()
          : Value(frequencyType),
      targetValue: targetValue == null && nullToAbsent
          ? const Value.absent()
          : Value(targetValue),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      checklistItemsJson: checklistItemsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checklistItemsJson),
      priorityLevel: priorityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(priorityLevel),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      reminderTimesJson: reminderTimesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTimesJson),
      isArchived: Value(isArchived),
      daysPerPeriod: daysPerPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(daysPerPeriod),
      repeatInterval: repeatInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatInterval),
      specificDatesJson: specificDatesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(specificDatesJson),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      extraGoal: extraGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(extraGoal),
      sortOrder: Value(sortOrder),
      scoringEnabled: Value(scoringEnabled),
      priority: Value(priority),
    );
  }

  factory HabitEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<int>(json['type']),
      triggerResponse: serializer.fromJson<String?>(json['triggerResponse']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      bestStreak: serializer.fromJson<int>(json['bestStreak']),
      completionCount: serializer.fromJson<int>(json['completionCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      factorId: serializer.fromJson<String?>(json['factorId']),
      scheduledDaysJson: serializer.fromJson<String>(json['scheduledDaysJson']),
      targetFrequency: serializer.fromJson<int>(json['targetFrequency']),
      motivation: serializer.fromJson<String>(json['motivation']),
      timerMinutes: serializer.fromJson<int?>(json['timerMinutes']),
      streakFreezes: serializer.fromJson<int>(json['streakFreezes']),
      freezesUsed: serializer.fromJson<int>(json['freezesUsed']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      evaluationType: serializer.fromJson<int?>(json['evaluationType']),
      frequencyType: serializer.fromJson<int?>(json['frequencyType']),
      targetValue: serializer.fromJson<int?>(json['targetValue']),
      unit: serializer.fromJson<String?>(json['unit']),
      checklistItemsJson:
          serializer.fromJson<String?>(json['checklistItemsJson']),
      priorityLevel: serializer.fromJson<int?>(json['priorityLevel']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      reminderTimesJson:
          serializer.fromJson<String?>(json['reminderTimesJson']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      daysPerPeriod: serializer.fromJson<int?>(json['daysPerPeriod']),
      repeatInterval: serializer.fromJson<int?>(json['repeatInterval']),
      specificDatesJson:
          serializer.fromJson<String?>(json['specificDatesJson']),
      description: serializer.fromJson<String?>(json['description']),
      extraGoal: serializer.fromJson<int?>(json['extraGoal']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      scoringEnabled: serializer.fromJson<bool>(json['scoringEnabled']),
      priority: serializer.fromJson<int>(json['priority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<int>(type),
      'triggerResponse': serializer.toJson<String?>(triggerResponse),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'bestStreak': serializer.toJson<int>(bestStreak),
      'completionCount': serializer.toJson<int>(completionCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isActive': serializer.toJson<bool>(isActive),
      'factorId': serializer.toJson<String?>(factorId),
      'scheduledDaysJson': serializer.toJson<String>(scheduledDaysJson),
      'targetFrequency': serializer.toJson<int>(targetFrequency),
      'motivation': serializer.toJson<String>(motivation),
      'timerMinutes': serializer.toJson<int?>(timerMinutes),
      'streakFreezes': serializer.toJson<int>(streakFreezes),
      'freezesUsed': serializer.toJson<int>(freezesUsed),
      'categoryId': serializer.toJson<String?>(categoryId),
      'evaluationType': serializer.toJson<int?>(evaluationType),
      'frequencyType': serializer.toJson<int?>(frequencyType),
      'targetValue': serializer.toJson<int?>(targetValue),
      'unit': serializer.toJson<String?>(unit),
      'checklistItemsJson': serializer.toJson<String?>(checklistItemsJson),
      'priorityLevel': serializer.toJson<int?>(priorityLevel),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'reminderTimesJson': serializer.toJson<String?>(reminderTimesJson),
      'isArchived': serializer.toJson<bool>(isArchived),
      'daysPerPeriod': serializer.toJson<int?>(daysPerPeriod),
      'repeatInterval': serializer.toJson<int?>(repeatInterval),
      'specificDatesJson': serializer.toJson<String?>(specificDatesJson),
      'description': serializer.toJson<String?>(description),
      'extraGoal': serializer.toJson<int?>(extraGoal),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'scoringEnabled': serializer.toJson<bool>(scoringEnabled),
      'priority': serializer.toJson<int>(priority),
    };
  }

  HabitEntry copyWith(
          {String? id,
          String? name,
          int? type,
          Value<String?> triggerResponse = const Value.absent(),
          int? currentStreak,
          int? bestStreak,
          int? completionCount,
          DateTime? createdAt,
          bool? isActive,
          Value<String?> factorId = const Value.absent(),
          String? scheduledDaysJson,
          int? targetFrequency,
          String? motivation,
          Value<int?> timerMinutes = const Value.absent(),
          int? streakFreezes,
          int? freezesUsed,
          Value<String?> categoryId = const Value.absent(),
          Value<int?> evaluationType = const Value.absent(),
          Value<int?> frequencyType = const Value.absent(),
          Value<int?> targetValue = const Value.absent(),
          Value<String?> unit = const Value.absent(),
          Value<String?> checklistItemsJson = const Value.absent(),
          Value<int?> priorityLevel = const Value.absent(),
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          Value<String?> reminderTimesJson = const Value.absent(),
          bool? isArchived,
          Value<int?> daysPerPeriod = const Value.absent(),
          Value<int?> repeatInterval = const Value.absent(),
          Value<String?> specificDatesJson = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<int?> extraGoal = const Value.absent(),
          int? sortOrder,
          bool? scoringEnabled,
          int? priority}) =>
      HabitEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        triggerResponse: triggerResponse.present
            ? triggerResponse.value
            : this.triggerResponse,
        currentStreak: currentStreak ?? this.currentStreak,
        bestStreak: bestStreak ?? this.bestStreak,
        completionCount: completionCount ?? this.completionCount,
        createdAt: createdAt ?? this.createdAt,
        isActive: isActive ?? this.isActive,
        factorId: factorId.present ? factorId.value : this.factorId,
        scheduledDaysJson: scheduledDaysJson ?? this.scheduledDaysJson,
        targetFrequency: targetFrequency ?? this.targetFrequency,
        motivation: motivation ?? this.motivation,
        timerMinutes:
            timerMinutes.present ? timerMinutes.value : this.timerMinutes,
        streakFreezes: streakFreezes ?? this.streakFreezes,
        freezesUsed: freezesUsed ?? this.freezesUsed,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        evaluationType:
            evaluationType.present ? evaluationType.value : this.evaluationType,
        frequencyType:
            frequencyType.present ? frequencyType.value : this.frequencyType,
        targetValue: targetValue.present ? targetValue.value : this.targetValue,
        unit: unit.present ? unit.value : this.unit,
        checklistItemsJson: checklistItemsJson.present
            ? checklistItemsJson.value
            : this.checklistItemsJson,
        priorityLevel:
            priorityLevel.present ? priorityLevel.value : this.priorityLevel,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        reminderTimesJson: reminderTimesJson.present
            ? reminderTimesJson.value
            : this.reminderTimesJson,
        isArchived: isArchived ?? this.isArchived,
        daysPerPeriod:
            daysPerPeriod.present ? daysPerPeriod.value : this.daysPerPeriod,
        repeatInterval:
            repeatInterval.present ? repeatInterval.value : this.repeatInterval,
        specificDatesJson: specificDatesJson.present
            ? specificDatesJson.value
            : this.specificDatesJson,
        description: description.present ? description.value : this.description,
        extraGoal: extraGoal.present ? extraGoal.value : this.extraGoal,
        sortOrder: sortOrder ?? this.sortOrder,
        scoringEnabled: scoringEnabled ?? this.scoringEnabled,
        priority: priority ?? this.priority,
      );
  HabitEntry copyWithCompanion(HabitsCompanion data) {
    return HabitEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      triggerResponse: data.triggerResponse.present
          ? data.triggerResponse.value
          : this.triggerResponse,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      bestStreak:
          data.bestStreak.present ? data.bestStreak.value : this.bestStreak,
      completionCount: data.completionCount.present
          ? data.completionCount.value
          : this.completionCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      factorId: data.factorId.present ? data.factorId.value : this.factorId,
      scheduledDaysJson: data.scheduledDaysJson.present
          ? data.scheduledDaysJson.value
          : this.scheduledDaysJson,
      targetFrequency: data.targetFrequency.present
          ? data.targetFrequency.value
          : this.targetFrequency,
      motivation:
          data.motivation.present ? data.motivation.value : this.motivation,
      timerMinutes: data.timerMinutes.present
          ? data.timerMinutes.value
          : this.timerMinutes,
      streakFreezes: data.streakFreezes.present
          ? data.streakFreezes.value
          : this.streakFreezes,
      freezesUsed:
          data.freezesUsed.present ? data.freezesUsed.value : this.freezesUsed,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      evaluationType: data.evaluationType.present
          ? data.evaluationType.value
          : this.evaluationType,
      frequencyType: data.frequencyType.present
          ? data.frequencyType.value
          : this.frequencyType,
      targetValue:
          data.targetValue.present ? data.targetValue.value : this.targetValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      checklistItemsJson: data.checklistItemsJson.present
          ? data.checklistItemsJson.value
          : this.checklistItemsJson,
      priorityLevel: data.priorityLevel.present
          ? data.priorityLevel.value
          : this.priorityLevel,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      reminderTimesJson: data.reminderTimesJson.present
          ? data.reminderTimesJson.value
          : this.reminderTimesJson,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      daysPerPeriod: data.daysPerPeriod.present
          ? data.daysPerPeriod.value
          : this.daysPerPeriod,
      repeatInterval: data.repeatInterval.present
          ? data.repeatInterval.value
          : this.repeatInterval,
      specificDatesJson: data.specificDatesJson.present
          ? data.specificDatesJson.value
          : this.specificDatesJson,
      description:
          data.description.present ? data.description.value : this.description,
      extraGoal: data.extraGoal.present ? data.extraGoal.value : this.extraGoal,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      scoringEnabled: data.scoringEnabled.present
          ? data.scoringEnabled.value
          : this.scoringEnabled,
      priority: data.priority.present ? data.priority.value : this.priority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('triggerResponse: $triggerResponse, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('completionCount: $completionCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive, ')
          ..write('factorId: $factorId, ')
          ..write('scheduledDaysJson: $scheduledDaysJson, ')
          ..write('targetFrequency: $targetFrequency, ')
          ..write('motivation: $motivation, ')
          ..write('timerMinutes: $timerMinutes, ')
          ..write('streakFreezes: $streakFreezes, ')
          ..write('freezesUsed: $freezesUsed, ')
          ..write('categoryId: $categoryId, ')
          ..write('evaluationType: $evaluationType, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('targetValue: $targetValue, ')
          ..write('unit: $unit, ')
          ..write('checklistItemsJson: $checklistItemsJson, ')
          ..write('priorityLevel: $priorityLevel, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('reminderTimesJson: $reminderTimesJson, ')
          ..write('isArchived: $isArchived, ')
          ..write('daysPerPeriod: $daysPerPeriod, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('specificDatesJson: $specificDatesJson, ')
          ..write('description: $description, ')
          ..write('extraGoal: $extraGoal, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('scoringEnabled: $scoringEnabled, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        type,
        triggerResponse,
        currentStreak,
        bestStreak,
        completionCount,
        createdAt,
        isActive,
        factorId,
        scheduledDaysJson,
        targetFrequency,
        motivation,
        timerMinutes,
        streakFreezes,
        freezesUsed,
        categoryId,
        evaluationType,
        frequencyType,
        targetValue,
        unit,
        checklistItemsJson,
        priorityLevel,
        startDate,
        endDate,
        reminderTimesJson,
        isArchived,
        daysPerPeriod,
        repeatInterval,
        specificDatesJson,
        description,
        extraGoal,
        sortOrder,
        scoringEnabled,
        priority
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.triggerResponse == this.triggerResponse &&
          other.currentStreak == this.currentStreak &&
          other.bestStreak == this.bestStreak &&
          other.completionCount == this.completionCount &&
          other.createdAt == this.createdAt &&
          other.isActive == this.isActive &&
          other.factorId == this.factorId &&
          other.scheduledDaysJson == this.scheduledDaysJson &&
          other.targetFrequency == this.targetFrequency &&
          other.motivation == this.motivation &&
          other.timerMinutes == this.timerMinutes &&
          other.streakFreezes == this.streakFreezes &&
          other.freezesUsed == this.freezesUsed &&
          other.categoryId == this.categoryId &&
          other.evaluationType == this.evaluationType &&
          other.frequencyType == this.frequencyType &&
          other.targetValue == this.targetValue &&
          other.unit == this.unit &&
          other.checklistItemsJson == this.checklistItemsJson &&
          other.priorityLevel == this.priorityLevel &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.reminderTimesJson == this.reminderTimesJson &&
          other.isArchived == this.isArchived &&
          other.daysPerPeriod == this.daysPerPeriod &&
          other.repeatInterval == this.repeatInterval &&
          other.specificDatesJson == this.specificDatesJson &&
          other.description == this.description &&
          other.extraGoal == this.extraGoal &&
          other.sortOrder == this.sortOrder &&
          other.scoringEnabled == this.scoringEnabled &&
          other.priority == this.priority);
}

class HabitsCompanion extends UpdateCompanion<HabitEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> type;
  final Value<String?> triggerResponse;
  final Value<int> currentStreak;
  final Value<int> bestStreak;
  final Value<int> completionCount;
  final Value<DateTime> createdAt;
  final Value<bool> isActive;
  final Value<String?> factorId;
  final Value<String> scheduledDaysJson;
  final Value<int> targetFrequency;
  final Value<String> motivation;
  final Value<int?> timerMinutes;
  final Value<int> streakFreezes;
  final Value<int> freezesUsed;
  final Value<String?> categoryId;
  final Value<int?> evaluationType;
  final Value<int?> frequencyType;
  final Value<int?> targetValue;
  final Value<String?> unit;
  final Value<String?> checklistItemsJson;
  final Value<int?> priorityLevel;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> reminderTimesJson;
  final Value<bool> isArchived;
  final Value<int?> daysPerPeriod;
  final Value<int?> repeatInterval;
  final Value<String?> specificDatesJson;
  final Value<String?> description;
  final Value<int?> extraGoal;
  final Value<int> sortOrder;
  final Value<bool> scoringEnabled;
  final Value<int> priority;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.triggerResponse = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.completionCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.factorId = const Value.absent(),
    this.scheduledDaysJson = const Value.absent(),
    this.targetFrequency = const Value.absent(),
    this.motivation = const Value.absent(),
    this.timerMinutes = const Value.absent(),
    this.streakFreezes = const Value.absent(),
    this.freezesUsed = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.evaluationType = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.checklistItemsJson = const Value.absent(),
    this.priorityLevel = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.reminderTimesJson = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.daysPerPeriod = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.specificDatesJson = const Value.absent(),
    this.description = const Value.absent(),
    this.extraGoal = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.scoringEnabled = const Value.absent(),
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String name,
    required int type,
    this.triggerResponse = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.completionCount = const Value.absent(),
    required DateTime createdAt,
    this.isActive = const Value.absent(),
    this.factorId = const Value.absent(),
    this.scheduledDaysJson = const Value.absent(),
    this.targetFrequency = const Value.absent(),
    this.motivation = const Value.absent(),
    this.timerMinutes = const Value.absent(),
    this.streakFreezes = const Value.absent(),
    this.freezesUsed = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.evaluationType = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.checklistItemsJson = const Value.absent(),
    this.priorityLevel = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.reminderTimesJson = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.daysPerPeriod = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.specificDatesJson = const Value.absent(),
    this.description = const Value.absent(),
    this.extraGoal = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.scoringEnabled = const Value.absent(),
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<HabitEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<String>? triggerResponse,
    Expression<int>? currentStreak,
    Expression<int>? bestStreak,
    Expression<int>? completionCount,
    Expression<DateTime>? createdAt,
    Expression<bool>? isActive,
    Expression<String>? factorId,
    Expression<String>? scheduledDaysJson,
    Expression<int>? targetFrequency,
    Expression<String>? motivation,
    Expression<int>? timerMinutes,
    Expression<int>? streakFreezes,
    Expression<int>? freezesUsed,
    Expression<String>? categoryId,
    Expression<int>? evaluationType,
    Expression<int>? frequencyType,
    Expression<int>? targetValue,
    Expression<String>? unit,
    Expression<String>? checklistItemsJson,
    Expression<int>? priorityLevel,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? reminderTimesJson,
    Expression<bool>? isArchived,
    Expression<int>? daysPerPeriod,
    Expression<int>? repeatInterval,
    Expression<String>? specificDatesJson,
    Expression<String>? description,
    Expression<int>? extraGoal,
    Expression<int>? sortOrder,
    Expression<bool>? scoringEnabled,
    Expression<int>? priority,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (triggerResponse != null) 'trigger_response': triggerResponse,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (bestStreak != null) 'best_streak': bestStreak,
      if (completionCount != null) 'completion_count': completionCount,
      if (createdAt != null) 'created_at': createdAt,
      if (isActive != null) 'is_active': isActive,
      if (factorId != null) 'factor_id': factorId,
      if (scheduledDaysJson != null) 'scheduled_days_json': scheduledDaysJson,
      if (targetFrequency != null) 'target_frequency': targetFrequency,
      if (motivation != null) 'motivation': motivation,
      if (timerMinutes != null) 'timer_minutes': timerMinutes,
      if (streakFreezes != null) 'streak_freezes': streakFreezes,
      if (freezesUsed != null) 'freezes_used': freezesUsed,
      if (categoryId != null) 'category_id': categoryId,
      if (evaluationType != null) 'evaluation_type': evaluationType,
      if (frequencyType != null) 'frequency_type': frequencyType,
      if (targetValue != null) 'target_value': targetValue,
      if (unit != null) 'unit': unit,
      if (checklistItemsJson != null)
        'checklist_items_json': checklistItemsJson,
      if (priorityLevel != null) 'priority_level': priorityLevel,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (reminderTimesJson != null) 'reminder_times_json': reminderTimesJson,
      if (isArchived != null) 'is_archived': isArchived,
      if (daysPerPeriod != null) 'days_per_period': daysPerPeriod,
      if (repeatInterval != null) 'repeat_interval': repeatInterval,
      if (specificDatesJson != null) 'specific_dates_json': specificDatesJson,
      if (description != null) 'description': description,
      if (extraGoal != null) 'extra_goal': extraGoal,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (scoringEnabled != null) 'scoring_enabled': scoringEnabled,
      if (priority != null) 'priority': priority,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? type,
      Value<String?>? triggerResponse,
      Value<int>? currentStreak,
      Value<int>? bestStreak,
      Value<int>? completionCount,
      Value<DateTime>? createdAt,
      Value<bool>? isActive,
      Value<String?>? factorId,
      Value<String>? scheduledDaysJson,
      Value<int>? targetFrequency,
      Value<String>? motivation,
      Value<int?>? timerMinutes,
      Value<int>? streakFreezes,
      Value<int>? freezesUsed,
      Value<String?>? categoryId,
      Value<int?>? evaluationType,
      Value<int?>? frequencyType,
      Value<int?>? targetValue,
      Value<String?>? unit,
      Value<String?>? checklistItemsJson,
      Value<int?>? priorityLevel,
      Value<DateTime?>? startDate,
      Value<DateTime?>? endDate,
      Value<String?>? reminderTimesJson,
      Value<bool>? isArchived,
      Value<int?>? daysPerPeriod,
      Value<int?>? repeatInterval,
      Value<String?>? specificDatesJson,
      Value<String?>? description,
      Value<int?>? extraGoal,
      Value<int>? sortOrder,
      Value<bool>? scoringEnabled,
      Value<int>? priority,
      Value<int>? rowid}) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      triggerResponse: triggerResponse ?? this.triggerResponse,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      completionCount: completionCount ?? this.completionCount,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      factorId: factorId ?? this.factorId,
      scheduledDaysJson: scheduledDaysJson ?? this.scheduledDaysJson,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      motivation: motivation ?? this.motivation,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      freezesUsed: freezesUsed ?? this.freezesUsed,
      categoryId: categoryId ?? this.categoryId,
      evaluationType: evaluationType ?? this.evaluationType,
      frequencyType: frequencyType ?? this.frequencyType,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      checklistItemsJson: checklistItemsJson ?? this.checklistItemsJson,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderTimesJson: reminderTimesJson ?? this.reminderTimesJson,
      isArchived: isArchived ?? this.isArchived,
      daysPerPeriod: daysPerPeriod ?? this.daysPerPeriod,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      specificDatesJson: specificDatesJson ?? this.specificDatesJson,
      description: description ?? this.description,
      extraGoal: extraGoal ?? this.extraGoal,
      sortOrder: sortOrder ?? this.sortOrder,
      scoringEnabled: scoringEnabled ?? this.scoringEnabled,
      priority: priority ?? this.priority,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (triggerResponse.present) {
      map['trigger_response'] = Variable<String>(triggerResponse.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (bestStreak.present) {
      map['best_streak'] = Variable<int>(bestStreak.value);
    }
    if (completionCount.present) {
      map['completion_count'] = Variable<int>(completionCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (factorId.present) {
      map['factor_id'] = Variable<String>(factorId.value);
    }
    if (scheduledDaysJson.present) {
      map['scheduled_days_json'] = Variable<String>(scheduledDaysJson.value);
    }
    if (targetFrequency.present) {
      map['target_frequency'] = Variable<int>(targetFrequency.value);
    }
    if (motivation.present) {
      map['motivation'] = Variable<String>(motivation.value);
    }
    if (timerMinutes.present) {
      map['timer_minutes'] = Variable<int>(timerMinutes.value);
    }
    if (streakFreezes.present) {
      map['streak_freezes'] = Variable<int>(streakFreezes.value);
    }
    if (freezesUsed.present) {
      map['freezes_used'] = Variable<int>(freezesUsed.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (evaluationType.present) {
      map['evaluation_type'] = Variable<int>(evaluationType.value);
    }
    if (frequencyType.present) {
      map['frequency_type'] = Variable<int>(frequencyType.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<int>(targetValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (checklistItemsJson.present) {
      map['checklist_items_json'] = Variable<String>(checklistItemsJson.value);
    }
    if (priorityLevel.present) {
      map['priority_level'] = Variable<int>(priorityLevel.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (reminderTimesJson.present) {
      map['reminder_times_json'] = Variable<String>(reminderTimesJson.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (daysPerPeriod.present) {
      map['days_per_period'] = Variable<int>(daysPerPeriod.value);
    }
    if (repeatInterval.present) {
      map['repeat_interval'] = Variable<int>(repeatInterval.value);
    }
    if (specificDatesJson.present) {
      map['specific_dates_json'] = Variable<String>(specificDatesJson.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (extraGoal.present) {
      map['extra_goal'] = Variable<int>(extraGoal.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (scoringEnabled.present) {
      map['scoring_enabled'] = Variable<bool>(scoringEnabled.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('triggerResponse: $triggerResponse, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('completionCount: $completionCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive, ')
          ..write('factorId: $factorId, ')
          ..write('scheduledDaysJson: $scheduledDaysJson, ')
          ..write('targetFrequency: $targetFrequency, ')
          ..write('motivation: $motivation, ')
          ..write('timerMinutes: $timerMinutes, ')
          ..write('streakFreezes: $streakFreezes, ')
          ..write('freezesUsed: $freezesUsed, ')
          ..write('categoryId: $categoryId, ')
          ..write('evaluationType: $evaluationType, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('targetValue: $targetValue, ')
          ..write('unit: $unit, ')
          ..write('checklistItemsJson: $checklistItemsJson, ')
          ..write('priorityLevel: $priorityLevel, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('reminderTimesJson: $reminderTimesJson, ')
          ..write('isArchived: $isArchived, ')
          ..write('daysPerPeriod: $daysPerPeriod, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('specificDatesJson: $specificDatesJson, ')
          ..write('description: $description, ')
          ..write('extraGoal: $extraGoal, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('scoringEnabled: $scoringEnabled, ')
          ..write('priority: $priority, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTable extends HabitLogs
    with TableInfo<$HabitLogsTable, HabitLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _habitIdMeta =
      const VerificationMeta('habitId');
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
      'habit_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES habits (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _moodRatingMeta =
      const VerificationMeta('moodRating');
  @override
  late final GeneratedColumn<int> moodRating = GeneratedColumn<int>(
      'mood_rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _barrierTagMeta =
      const VerificationMeta('barrierTag');
  @override
  late final GeneratedColumn<String> barrierTag = GeneratedColumn<String>(
      'barrier_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _numericValueMeta =
      const VerificationMeta('numericValue');
  @override
  late final GeneratedColumn<int> numericValue = GeneratedColumn<int>(
      'numeric_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _checklistCompletedJsonMeta =
      const VerificationMeta('checklistCompletedJson');
  @override
  late final GeneratedColumn<String> checklistCompletedJson =
      GeneratedColumn<String>('checklist_completed_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timerSecondsMeta =
      const VerificationMeta('timerSeconds');
  @override
  late final GeneratedColumn<int> timerSeconds = GeneratedColumn<int>(
      'timer_seconds', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        habitId,
        date,
        completed,
        note,
        moodRating,
        barrierTag,
        numericValue,
        checklistCompletedJson,
        timerSeconds,
        score
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs';
  @override
  VerificationContext validateIntegrity(Insertable<HabitLogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(_habitIdMeta,
          habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta));
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('mood_rating')) {
      context.handle(
          _moodRatingMeta,
          moodRating.isAcceptableOrUnknown(
              data['mood_rating']!, _moodRatingMeta));
    }
    if (data.containsKey('barrier_tag')) {
      context.handle(
          _barrierTagMeta,
          barrierTag.isAcceptableOrUnknown(
              data['barrier_tag']!, _barrierTagMeta));
    }
    if (data.containsKey('numeric_value')) {
      context.handle(
          _numericValueMeta,
          numericValue.isAcceptableOrUnknown(
              data['numeric_value']!, _numericValueMeta));
    }
    if (data.containsKey('checklist_completed_json')) {
      context.handle(
          _checklistCompletedJsonMeta,
          checklistCompletedJson.isAcceptableOrUnknown(
              data['checklist_completed_json']!, _checklistCompletedJsonMeta));
    }
    if (data.containsKey('timer_seconds')) {
      context.handle(
          _timerSecondsMeta,
          timerSeconds.isAcceptableOrUnknown(
              data['timer_seconds']!, _timerSecondsMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      habitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}habit_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      moodRating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mood_rating']),
      barrierTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barrier_tag']),
      numericValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}numeric_value']),
      checklistCompletedJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}checklist_completed_json']),
      timerSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timer_seconds']),
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score']),
    );
  }

  @override
  $HabitLogsTable createAlias(String alias) {
    return $HabitLogsTable(attachedDatabase, alias);
  }
}

class HabitLogEntry extends DataClass implements Insertable<HabitLogEntry> {
  final int id;
  final String habitId;
  final DateTime date;
  final bool completed;
  final String? note;
  final int? moodRating;
  final String? barrierTag;
  final int? numericValue;
  final String? checklistCompletedJson;
  final int? timerSeconds;
  final int? score;
  const HabitLogEntry(
      {required this.id,
      required this.habitId,
      required this.date,
      required this.completed,
      this.note,
      this.moodRating,
      this.barrierTag,
      this.numericValue,
      this.checklistCompletedJson,
      this.timerSeconds,
      this.score});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['date'] = Variable<DateTime>(date);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || moodRating != null) {
      map['mood_rating'] = Variable<int>(moodRating);
    }
    if (!nullToAbsent || barrierTag != null) {
      map['barrier_tag'] = Variable<String>(barrierTag);
    }
    if (!nullToAbsent || numericValue != null) {
      map['numeric_value'] = Variable<int>(numericValue);
    }
    if (!nullToAbsent || checklistCompletedJson != null) {
      map['checklist_completed_json'] =
          Variable<String>(checklistCompletedJson);
    }
    if (!nullToAbsent || timerSeconds != null) {
      map['timer_seconds'] = Variable<int>(timerSeconds);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    return map;
  }

  HabitLogsCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      date: Value(date),
      completed: Value(completed),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      moodRating: moodRating == null && nullToAbsent
          ? const Value.absent()
          : Value(moodRating),
      barrierTag: barrierTag == null && nullToAbsent
          ? const Value.absent()
          : Value(barrierTag),
      numericValue: numericValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numericValue),
      checklistCompletedJson: checklistCompletedJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checklistCompletedJson),
      timerSeconds: timerSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(timerSeconds),
      score:
          score == null && nullToAbsent ? const Value.absent() : Value(score),
    );
  }

  factory HabitLogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLogEntry(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      date: serializer.fromJson<DateTime>(json['date']),
      completed: serializer.fromJson<bool>(json['completed']),
      note: serializer.fromJson<String?>(json['note']),
      moodRating: serializer.fromJson<int?>(json['moodRating']),
      barrierTag: serializer.fromJson<String?>(json['barrierTag']),
      numericValue: serializer.fromJson<int?>(json['numericValue']),
      checklistCompletedJson:
          serializer.fromJson<String?>(json['checklistCompletedJson']),
      timerSeconds: serializer.fromJson<int?>(json['timerSeconds']),
      score: serializer.fromJson<int?>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<String>(habitId),
      'date': serializer.toJson<DateTime>(date),
      'completed': serializer.toJson<bool>(completed),
      'note': serializer.toJson<String?>(note),
      'moodRating': serializer.toJson<int?>(moodRating),
      'barrierTag': serializer.toJson<String?>(barrierTag),
      'numericValue': serializer.toJson<int?>(numericValue),
      'checklistCompletedJson':
          serializer.toJson<String?>(checklistCompletedJson),
      'timerSeconds': serializer.toJson<int?>(timerSeconds),
      'score': serializer.toJson<int?>(score),
    };
  }

  HabitLogEntry copyWith(
          {int? id,
          String? habitId,
          DateTime? date,
          bool? completed,
          Value<String?> note = const Value.absent(),
          Value<int?> moodRating = const Value.absent(),
          Value<String?> barrierTag = const Value.absent(),
          Value<int?> numericValue = const Value.absent(),
          Value<String?> checklistCompletedJson = const Value.absent(),
          Value<int?> timerSeconds = const Value.absent(),
          Value<int?> score = const Value.absent()}) =>
      HabitLogEntry(
        id: id ?? this.id,
        habitId: habitId ?? this.habitId,
        date: date ?? this.date,
        completed: completed ?? this.completed,
        note: note.present ? note.value : this.note,
        moodRating: moodRating.present ? moodRating.value : this.moodRating,
        barrierTag: barrierTag.present ? barrierTag.value : this.barrierTag,
        numericValue:
            numericValue.present ? numericValue.value : this.numericValue,
        checklistCompletedJson: checklistCompletedJson.present
            ? checklistCompletedJson.value
            : this.checklistCompletedJson,
        timerSeconds:
            timerSeconds.present ? timerSeconds.value : this.timerSeconds,
        score: score.present ? score.value : this.score,
      );
  HabitLogEntry copyWithCompanion(HabitLogsCompanion data) {
    return HabitLogEntry(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
      completed: data.completed.present ? data.completed.value : this.completed,
      note: data.note.present ? data.note.value : this.note,
      moodRating:
          data.moodRating.present ? data.moodRating.value : this.moodRating,
      barrierTag:
          data.barrierTag.present ? data.barrierTag.value : this.barrierTag,
      numericValue: data.numericValue.present
          ? data.numericValue.value
          : this.numericValue,
      checklistCompletedJson: data.checklistCompletedJson.present
          ? data.checklistCompletedJson.value
          : this.checklistCompletedJson,
      timerSeconds: data.timerSeconds.present
          ? data.timerSeconds.value
          : this.timerSeconds,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogEntry(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('completed: $completed, ')
          ..write('note: $note, ')
          ..write('moodRating: $moodRating, ')
          ..write('barrierTag: $barrierTag, ')
          ..write('numericValue: $numericValue, ')
          ..write('checklistCompletedJson: $checklistCompletedJson, ')
          ..write('timerSeconds: $timerSeconds, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      habitId,
      date,
      completed,
      note,
      moodRating,
      barrierTag,
      numericValue,
      checklistCompletedJson,
      timerSeconds,
      score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLogEntry &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.date == this.date &&
          other.completed == this.completed &&
          other.note == this.note &&
          other.moodRating == this.moodRating &&
          other.barrierTag == this.barrierTag &&
          other.numericValue == this.numericValue &&
          other.checklistCompletedJson == this.checklistCompletedJson &&
          other.timerSeconds == this.timerSeconds &&
          other.score == this.score);
}

class HabitLogsCompanion extends UpdateCompanion<HabitLogEntry> {
  final Value<int> id;
  final Value<String> habitId;
  final Value<DateTime> date;
  final Value<bool> completed;
  final Value<String?> note;
  final Value<int?> moodRating;
  final Value<String?> barrierTag;
  final Value<int?> numericValue;
  final Value<String?> checklistCompletedJson;
  final Value<int?> timerSeconds;
  final Value<int?> score;
  const HabitLogsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.completed = const Value.absent(),
    this.note = const Value.absent(),
    this.moodRating = const Value.absent(),
    this.barrierTag = const Value.absent(),
    this.numericValue = const Value.absent(),
    this.checklistCompletedJson = const Value.absent(),
    this.timerSeconds = const Value.absent(),
    this.score = const Value.absent(),
  });
  HabitLogsCompanion.insert({
    this.id = const Value.absent(),
    required String habitId,
    required DateTime date,
    this.completed = const Value.absent(),
    this.note = const Value.absent(),
    this.moodRating = const Value.absent(),
    this.barrierTag = const Value.absent(),
    this.numericValue = const Value.absent(),
    this.checklistCompletedJson = const Value.absent(),
    this.timerSeconds = const Value.absent(),
    this.score = const Value.absent(),
  })  : habitId = Value(habitId),
        date = Value(date);
  static Insertable<HabitLogEntry> custom({
    Expression<int>? id,
    Expression<String>? habitId,
    Expression<DateTime>? date,
    Expression<bool>? completed,
    Expression<String>? note,
    Expression<int>? moodRating,
    Expression<String>? barrierTag,
    Expression<int>? numericValue,
    Expression<String>? checklistCompletedJson,
    Expression<int>? timerSeconds,
    Expression<int>? score,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (completed != null) 'completed': completed,
      if (note != null) 'note': note,
      if (moodRating != null) 'mood_rating': moodRating,
      if (barrierTag != null) 'barrier_tag': barrierTag,
      if (numericValue != null) 'numeric_value': numericValue,
      if (checklistCompletedJson != null)
        'checklist_completed_json': checklistCompletedJson,
      if (timerSeconds != null) 'timer_seconds': timerSeconds,
      if (score != null) 'score': score,
    });
  }

  HabitLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? habitId,
      Value<DateTime>? date,
      Value<bool>? completed,
      Value<String?>? note,
      Value<int?>? moodRating,
      Value<String?>? barrierTag,
      Value<int?>? numericValue,
      Value<String?>? checklistCompletedJson,
      Value<int?>? timerSeconds,
      Value<int?>? score}) {
    return HabitLogsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      note: note ?? this.note,
      moodRating: moodRating ?? this.moodRating,
      barrierTag: barrierTag ?? this.barrierTag,
      numericValue: numericValue ?? this.numericValue,
      checklistCompletedJson:
          checklistCompletedJson ?? this.checklistCompletedJson,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      score: score ?? this.score,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (moodRating.present) {
      map['mood_rating'] = Variable<int>(moodRating.value);
    }
    if (barrierTag.present) {
      map['barrier_tag'] = Variable<String>(barrierTag.value);
    }
    if (numericValue.present) {
      map['numeric_value'] = Variable<int>(numericValue.value);
    }
    if (checklistCompletedJson.present) {
      map['checklist_completed_json'] =
          Variable<String>(checklistCompletedJson.value);
    }
    if (timerSeconds.present) {
      map['timer_seconds'] = Variable<int>(timerSeconds.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('completed: $completed, ')
          ..write('note: $note, ')
          ..write('moodRating: $moodRating, ')
          ..write('barrierTag: $barrierTag, ')
          ..write('numericValue: $numericValue, ')
          ..write('checklistCompletedJson: $checklistCompletedJson, ')
          ..write('timerSeconds: $timerSeconds, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }
}

class $ReflectionsTable extends Reflections
    with TableInfo<$ReflectionsTable, ReflectionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _experienceMeta =
      const VerificationMeta('experience');
  @override
  late final GeneratedColumn<String> experience = GeneratedColumn<String>(
      'experience', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _reflectionMeta =
      const VerificationMeta('reflection');
  @override
  late final GeneratedColumn<String> reflection = GeneratedColumn<String>(
      'reflection', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _abstractionMeta =
      const VerificationMeta('abstraction');
  @override
  late final GeneratedColumn<String> abstraction = GeneratedColumn<String>(
      'abstraction', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isFollowUpMeta =
      const VerificationMeta('isFollowUp');
  @override
  late final GeneratedColumn<bool> isFollowUp = GeneratedColumn<bool>(
      'is_follow_up', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_follow_up" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _previousReflectionIdMeta =
      const VerificationMeta('previousReflectionId');
  @override
  late final GeneratedColumn<String> previousReflectionId =
      GeneratedColumn<String>('previous_reflection_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _rawMarkdownMeta =
      const VerificationMeta('rawMarkdown');
  @override
  late final GeneratedColumn<String> rawMarkdown = GeneratedColumn<String>(
      'raw_markdown', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _targetFactorIdMeta =
      const VerificationMeta('targetFactorId');
  @override
  late final GeneratedColumn<String> targetFactorId = GeneratedColumn<String>(
      'target_factor_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _previousExperimentIdMeta =
      const VerificationMeta('previousExperimentId');
  @override
  late final GeneratedColumn<String> previousExperimentId =
      GeneratedColumn<String>('previous_experiment_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _marginalGainDescriptionMeta =
      const VerificationMeta('marginalGainDescription');
  @override
  late final GeneratedColumn<String> marginalGainDescription =
      GeneratedColumn<String>('marginal_gain_description', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _eventSequenceMeta =
      const VerificationMeta('eventSequence');
  @override
  late final GeneratedColumn<String> eventSequence = GeneratedColumn<String>(
      'event_sequence', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _feelingsMeta =
      const VerificationMeta('feelings');
  @override
  late final GeneratedColumn<String> feelings = GeneratedColumn<String>(
      'feelings', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _difficultiesMeta =
      const VerificationMeta('difficulties');
  @override
  late final GeneratedColumn<String> difficulties = GeneratedColumn<String>(
      'difficulties', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _challengeResponseMeta =
      const VerificationMeta('challengeResponse');
  @override
  late final GeneratedColumn<String> challengeResponse =
      GeneratedColumn<String>('challenge_response', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _triggersMeta =
      const VerificationMeta('triggers');
  @override
  late final GeneratedColumn<String> triggers = GeneratedColumn<String>(
      'triggers', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _whyBehaviorMeta =
      const VerificationMeta('whyBehavior');
  @override
  late final GeneratedColumn<String> whyBehavior = GeneratedColumn<String>(
      'why_behavior', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _crossLifePatternsMeta =
      const VerificationMeta('crossLifePatterns');
  @override
  late final GeneratedColumn<String> crossLifePatterns =
      GeneratedColumn<String>('cross_life_patterns', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isManualEntryMeta =
      const VerificationMeta('isManualEntry');
  @override
  late final GeneratedColumn<bool> isManualEntry = GeneratedColumn<bool>(
      'is_manual_entry', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_manual_entry" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        experience,
        reflection,
        abstraction,
        isFollowUp,
        previousReflectionId,
        createdAt,
        rawMarkdown,
        targetFactorId,
        previousExperimentId,
        groupId,
        marginalGainDescription,
        eventSequence,
        feelings,
        difficulties,
        challengeResponse,
        triggers,
        whyBehavior,
        crossLifePatterns,
        isManualEntry
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflections';
  @override
  VerificationContext validateIntegrity(Insertable<ReflectionEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('experience')) {
      context.handle(
          _experienceMeta,
          experience.isAcceptableOrUnknown(
              data['experience']!, _experienceMeta));
    }
    if (data.containsKey('reflection')) {
      context.handle(
          _reflectionMeta,
          reflection.isAcceptableOrUnknown(
              data['reflection']!, _reflectionMeta));
    }
    if (data.containsKey('abstraction')) {
      context.handle(
          _abstractionMeta,
          abstraction.isAcceptableOrUnknown(
              data['abstraction']!, _abstractionMeta));
    }
    if (data.containsKey('is_follow_up')) {
      context.handle(
          _isFollowUpMeta,
          isFollowUp.isAcceptableOrUnknown(
              data['is_follow_up']!, _isFollowUpMeta));
    }
    if (data.containsKey('previous_reflection_id')) {
      context.handle(
          _previousReflectionIdMeta,
          previousReflectionId.isAcceptableOrUnknown(
              data['previous_reflection_id']!, _previousReflectionIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('raw_markdown')) {
      context.handle(
          _rawMarkdownMeta,
          rawMarkdown.isAcceptableOrUnknown(
              data['raw_markdown']!, _rawMarkdownMeta));
    }
    if (data.containsKey('target_factor_id')) {
      context.handle(
          _targetFactorIdMeta,
          targetFactorId.isAcceptableOrUnknown(
              data['target_factor_id']!, _targetFactorIdMeta));
    }
    if (data.containsKey('previous_experiment_id')) {
      context.handle(
          _previousExperimentIdMeta,
          previousExperimentId.isAcceptableOrUnknown(
              data['previous_experiment_id']!, _previousExperimentIdMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('marginal_gain_description')) {
      context.handle(
          _marginalGainDescriptionMeta,
          marginalGainDescription.isAcceptableOrUnknown(
              data['marginal_gain_description']!,
              _marginalGainDescriptionMeta));
    }
    if (data.containsKey('event_sequence')) {
      context.handle(
          _eventSequenceMeta,
          eventSequence.isAcceptableOrUnknown(
              data['event_sequence']!, _eventSequenceMeta));
    }
    if (data.containsKey('feelings')) {
      context.handle(_feelingsMeta,
          feelings.isAcceptableOrUnknown(data['feelings']!, _feelingsMeta));
    }
    if (data.containsKey('difficulties')) {
      context.handle(
          _difficultiesMeta,
          difficulties.isAcceptableOrUnknown(
              data['difficulties']!, _difficultiesMeta));
    }
    if (data.containsKey('challenge_response')) {
      context.handle(
          _challengeResponseMeta,
          challengeResponse.isAcceptableOrUnknown(
              data['challenge_response']!, _challengeResponseMeta));
    }
    if (data.containsKey('triggers')) {
      context.handle(_triggersMeta,
          triggers.isAcceptableOrUnknown(data['triggers']!, _triggersMeta));
    }
    if (data.containsKey('why_behavior')) {
      context.handle(
          _whyBehaviorMeta,
          whyBehavior.isAcceptableOrUnknown(
              data['why_behavior']!, _whyBehaviorMeta));
    }
    if (data.containsKey('cross_life_patterns')) {
      context.handle(
          _crossLifePatternsMeta,
          crossLifePatterns.isAcceptableOrUnknown(
              data['cross_life_patterns']!, _crossLifePatternsMeta));
    }
    if (data.containsKey('is_manual_entry')) {
      context.handle(
          _isManualEntryMeta,
          isManualEntry.isAcceptableOrUnknown(
              data['is_manual_entry']!, _isManualEntryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReflectionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReflectionEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      experience: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}experience'])!,
      reflection: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reflection'])!,
      abstraction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}abstraction'])!,
      isFollowUp: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_follow_up'])!,
      previousReflectionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}previous_reflection_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      rawMarkdown: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_markdown']),
      targetFactorId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}target_factor_id']),
      previousExperimentId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}previous_experiment_id']),
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id']),
      marginalGainDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}marginal_gain_description']),
      eventSequence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_sequence']),
      feelings: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feelings']),
      difficulties: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulties']),
      challengeResponse: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}challenge_response']),
      triggers: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}triggers']),
      whyBehavior: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}why_behavior']),
      crossLifePatterns: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cross_life_patterns']),
      isManualEntry: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_manual_entry'])!,
    );
  }

  @override
  $ReflectionsTable createAlias(String alias) {
    return $ReflectionsTable(attachedDatabase, alias);
  }
}

class ReflectionEntry extends DataClass implements Insertable<ReflectionEntry> {
  final String id;
  final String experience;
  final String reflection;
  final String abstraction;
  final bool isFollowUp;
  final String? previousReflectionId;
  final DateTime createdAt;
  final String? rawMarkdown;
  final String? targetFactorId;
  final String? previousExperimentId;
  final String? groupId;
  final String? marginalGainDescription;
  final String? eventSequence;
  final String? feelings;
  final String? difficulties;
  final String? challengeResponse;
  final String? triggers;
  final String? whyBehavior;
  final String? crossLifePatterns;
  final bool isManualEntry;
  const ReflectionEntry(
      {required this.id,
      required this.experience,
      required this.reflection,
      required this.abstraction,
      required this.isFollowUp,
      this.previousReflectionId,
      required this.createdAt,
      this.rawMarkdown,
      this.targetFactorId,
      this.previousExperimentId,
      this.groupId,
      this.marginalGainDescription,
      this.eventSequence,
      this.feelings,
      this.difficulties,
      this.challengeResponse,
      this.triggers,
      this.whyBehavior,
      this.crossLifePatterns,
      required this.isManualEntry});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['experience'] = Variable<String>(experience);
    map['reflection'] = Variable<String>(reflection);
    map['abstraction'] = Variable<String>(abstraction);
    map['is_follow_up'] = Variable<bool>(isFollowUp);
    if (!nullToAbsent || previousReflectionId != null) {
      map['previous_reflection_id'] = Variable<String>(previousReflectionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || rawMarkdown != null) {
      map['raw_markdown'] = Variable<String>(rawMarkdown);
    }
    if (!nullToAbsent || targetFactorId != null) {
      map['target_factor_id'] = Variable<String>(targetFactorId);
    }
    if (!nullToAbsent || previousExperimentId != null) {
      map['previous_experiment_id'] = Variable<String>(previousExperimentId);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || marginalGainDescription != null) {
      map['marginal_gain_description'] =
          Variable<String>(marginalGainDescription);
    }
    if (!nullToAbsent || eventSequence != null) {
      map['event_sequence'] = Variable<String>(eventSequence);
    }
    if (!nullToAbsent || feelings != null) {
      map['feelings'] = Variable<String>(feelings);
    }
    if (!nullToAbsent || difficulties != null) {
      map['difficulties'] = Variable<String>(difficulties);
    }
    if (!nullToAbsent || challengeResponse != null) {
      map['challenge_response'] = Variable<String>(challengeResponse);
    }
    if (!nullToAbsent || triggers != null) {
      map['triggers'] = Variable<String>(triggers);
    }
    if (!nullToAbsent || whyBehavior != null) {
      map['why_behavior'] = Variable<String>(whyBehavior);
    }
    if (!nullToAbsent || crossLifePatterns != null) {
      map['cross_life_patterns'] = Variable<String>(crossLifePatterns);
    }
    map['is_manual_entry'] = Variable<bool>(isManualEntry);
    return map;
  }

  ReflectionsCompanion toCompanion(bool nullToAbsent) {
    return ReflectionsCompanion(
      id: Value(id),
      experience: Value(experience),
      reflection: Value(reflection),
      abstraction: Value(abstraction),
      isFollowUp: Value(isFollowUp),
      previousReflectionId: previousReflectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousReflectionId),
      createdAt: Value(createdAt),
      rawMarkdown: rawMarkdown == null && nullToAbsent
          ? const Value.absent()
          : Value(rawMarkdown),
      targetFactorId: targetFactorId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetFactorId),
      previousExperimentId: previousExperimentId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousExperimentId),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      marginalGainDescription: marginalGainDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(marginalGainDescription),
      eventSequence: eventSequence == null && nullToAbsent
          ? const Value.absent()
          : Value(eventSequence),
      feelings: feelings == null && nullToAbsent
          ? const Value.absent()
          : Value(feelings),
      difficulties: difficulties == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulties),
      challengeResponse: challengeResponse == null && nullToAbsent
          ? const Value.absent()
          : Value(challengeResponse),
      triggers: triggers == null && nullToAbsent
          ? const Value.absent()
          : Value(triggers),
      whyBehavior: whyBehavior == null && nullToAbsent
          ? const Value.absent()
          : Value(whyBehavior),
      crossLifePatterns: crossLifePatterns == null && nullToAbsent
          ? const Value.absent()
          : Value(crossLifePatterns),
      isManualEntry: Value(isManualEntry),
    );
  }

  factory ReflectionEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReflectionEntry(
      id: serializer.fromJson<String>(json['id']),
      experience: serializer.fromJson<String>(json['experience']),
      reflection: serializer.fromJson<String>(json['reflection']),
      abstraction: serializer.fromJson<String>(json['abstraction']),
      isFollowUp: serializer.fromJson<bool>(json['isFollowUp']),
      previousReflectionId:
          serializer.fromJson<String?>(json['previousReflectionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      rawMarkdown: serializer.fromJson<String?>(json['rawMarkdown']),
      targetFactorId: serializer.fromJson<String?>(json['targetFactorId']),
      previousExperimentId:
          serializer.fromJson<String?>(json['previousExperimentId']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      marginalGainDescription:
          serializer.fromJson<String?>(json['marginalGainDescription']),
      eventSequence: serializer.fromJson<String?>(json['eventSequence']),
      feelings: serializer.fromJson<String?>(json['feelings']),
      difficulties: serializer.fromJson<String?>(json['difficulties']),
      challengeResponse:
          serializer.fromJson<String?>(json['challengeResponse']),
      triggers: serializer.fromJson<String?>(json['triggers']),
      whyBehavior: serializer.fromJson<String?>(json['whyBehavior']),
      crossLifePatterns:
          serializer.fromJson<String?>(json['crossLifePatterns']),
      isManualEntry: serializer.fromJson<bool>(json['isManualEntry']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'experience': serializer.toJson<String>(experience),
      'reflection': serializer.toJson<String>(reflection),
      'abstraction': serializer.toJson<String>(abstraction),
      'isFollowUp': serializer.toJson<bool>(isFollowUp),
      'previousReflectionId': serializer.toJson<String?>(previousReflectionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'rawMarkdown': serializer.toJson<String?>(rawMarkdown),
      'targetFactorId': serializer.toJson<String?>(targetFactorId),
      'previousExperimentId': serializer.toJson<String?>(previousExperimentId),
      'groupId': serializer.toJson<String?>(groupId),
      'marginalGainDescription':
          serializer.toJson<String?>(marginalGainDescription),
      'eventSequence': serializer.toJson<String?>(eventSequence),
      'feelings': serializer.toJson<String?>(feelings),
      'difficulties': serializer.toJson<String?>(difficulties),
      'challengeResponse': serializer.toJson<String?>(challengeResponse),
      'triggers': serializer.toJson<String?>(triggers),
      'whyBehavior': serializer.toJson<String?>(whyBehavior),
      'crossLifePatterns': serializer.toJson<String?>(crossLifePatterns),
      'isManualEntry': serializer.toJson<bool>(isManualEntry),
    };
  }

  ReflectionEntry copyWith(
          {String? id,
          String? experience,
          String? reflection,
          String? abstraction,
          bool? isFollowUp,
          Value<String?> previousReflectionId = const Value.absent(),
          DateTime? createdAt,
          Value<String?> rawMarkdown = const Value.absent(),
          Value<String?> targetFactorId = const Value.absent(),
          Value<String?> previousExperimentId = const Value.absent(),
          Value<String?> groupId = const Value.absent(),
          Value<String?> marginalGainDescription = const Value.absent(),
          Value<String?> eventSequence = const Value.absent(),
          Value<String?> feelings = const Value.absent(),
          Value<String?> difficulties = const Value.absent(),
          Value<String?> challengeResponse = const Value.absent(),
          Value<String?> triggers = const Value.absent(),
          Value<String?> whyBehavior = const Value.absent(),
          Value<String?> crossLifePatterns = const Value.absent(),
          bool? isManualEntry}) =>
      ReflectionEntry(
        id: id ?? this.id,
        experience: experience ?? this.experience,
        reflection: reflection ?? this.reflection,
        abstraction: abstraction ?? this.abstraction,
        isFollowUp: isFollowUp ?? this.isFollowUp,
        previousReflectionId: previousReflectionId.present
            ? previousReflectionId.value
            : this.previousReflectionId,
        createdAt: createdAt ?? this.createdAt,
        rawMarkdown: rawMarkdown.present ? rawMarkdown.value : this.rawMarkdown,
        targetFactorId:
            targetFactorId.present ? targetFactorId.value : this.targetFactorId,
        previousExperimentId: previousExperimentId.present
            ? previousExperimentId.value
            : this.previousExperimentId,
        groupId: groupId.present ? groupId.value : this.groupId,
        marginalGainDescription: marginalGainDescription.present
            ? marginalGainDescription.value
            : this.marginalGainDescription,
        eventSequence:
            eventSequence.present ? eventSequence.value : this.eventSequence,
        feelings: feelings.present ? feelings.value : this.feelings,
        difficulties:
            difficulties.present ? difficulties.value : this.difficulties,
        challengeResponse: challengeResponse.present
            ? challengeResponse.value
            : this.challengeResponse,
        triggers: triggers.present ? triggers.value : this.triggers,
        whyBehavior: whyBehavior.present ? whyBehavior.value : this.whyBehavior,
        crossLifePatterns: crossLifePatterns.present
            ? crossLifePatterns.value
            : this.crossLifePatterns,
        isManualEntry: isManualEntry ?? this.isManualEntry,
      );
  ReflectionEntry copyWithCompanion(ReflectionsCompanion data) {
    return ReflectionEntry(
      id: data.id.present ? data.id.value : this.id,
      experience:
          data.experience.present ? data.experience.value : this.experience,
      reflection:
          data.reflection.present ? data.reflection.value : this.reflection,
      abstraction:
          data.abstraction.present ? data.abstraction.value : this.abstraction,
      isFollowUp:
          data.isFollowUp.present ? data.isFollowUp.value : this.isFollowUp,
      previousReflectionId: data.previousReflectionId.present
          ? data.previousReflectionId.value
          : this.previousReflectionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      rawMarkdown:
          data.rawMarkdown.present ? data.rawMarkdown.value : this.rawMarkdown,
      targetFactorId: data.targetFactorId.present
          ? data.targetFactorId.value
          : this.targetFactorId,
      previousExperimentId: data.previousExperimentId.present
          ? data.previousExperimentId.value
          : this.previousExperimentId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      marginalGainDescription: data.marginalGainDescription.present
          ? data.marginalGainDescription.value
          : this.marginalGainDescription,
      eventSequence: data.eventSequence.present
          ? data.eventSequence.value
          : this.eventSequence,
      feelings: data.feelings.present ? data.feelings.value : this.feelings,
      difficulties: data.difficulties.present
          ? data.difficulties.value
          : this.difficulties,
      challengeResponse: data.challengeResponse.present
          ? data.challengeResponse.value
          : this.challengeResponse,
      triggers: data.triggers.present ? data.triggers.value : this.triggers,
      whyBehavior:
          data.whyBehavior.present ? data.whyBehavior.value : this.whyBehavior,
      crossLifePatterns: data.crossLifePatterns.present
          ? data.crossLifePatterns.value
          : this.crossLifePatterns,
      isManualEntry: data.isManualEntry.present
          ? data.isManualEntry.value
          : this.isManualEntry,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionEntry(')
          ..write('id: $id, ')
          ..write('experience: $experience, ')
          ..write('reflection: $reflection, ')
          ..write('abstraction: $abstraction, ')
          ..write('isFollowUp: $isFollowUp, ')
          ..write('previousReflectionId: $previousReflectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rawMarkdown: $rawMarkdown, ')
          ..write('targetFactorId: $targetFactorId, ')
          ..write('previousExperimentId: $previousExperimentId, ')
          ..write('groupId: $groupId, ')
          ..write('marginalGainDescription: $marginalGainDescription, ')
          ..write('eventSequence: $eventSequence, ')
          ..write('feelings: $feelings, ')
          ..write('difficulties: $difficulties, ')
          ..write('challengeResponse: $challengeResponse, ')
          ..write('triggers: $triggers, ')
          ..write('whyBehavior: $whyBehavior, ')
          ..write('crossLifePatterns: $crossLifePatterns, ')
          ..write('isManualEntry: $isManualEntry')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      experience,
      reflection,
      abstraction,
      isFollowUp,
      previousReflectionId,
      createdAt,
      rawMarkdown,
      targetFactorId,
      previousExperimentId,
      groupId,
      marginalGainDescription,
      eventSequence,
      feelings,
      difficulties,
      challengeResponse,
      triggers,
      whyBehavior,
      crossLifePatterns,
      isManualEntry);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReflectionEntry &&
          other.id == this.id &&
          other.experience == this.experience &&
          other.reflection == this.reflection &&
          other.abstraction == this.abstraction &&
          other.isFollowUp == this.isFollowUp &&
          other.previousReflectionId == this.previousReflectionId &&
          other.createdAt == this.createdAt &&
          other.rawMarkdown == this.rawMarkdown &&
          other.targetFactorId == this.targetFactorId &&
          other.previousExperimentId == this.previousExperimentId &&
          other.groupId == this.groupId &&
          other.marginalGainDescription == this.marginalGainDescription &&
          other.eventSequence == this.eventSequence &&
          other.feelings == this.feelings &&
          other.difficulties == this.difficulties &&
          other.challengeResponse == this.challengeResponse &&
          other.triggers == this.triggers &&
          other.whyBehavior == this.whyBehavior &&
          other.crossLifePatterns == this.crossLifePatterns &&
          other.isManualEntry == this.isManualEntry);
}

class ReflectionsCompanion extends UpdateCompanion<ReflectionEntry> {
  final Value<String> id;
  final Value<String> experience;
  final Value<String> reflection;
  final Value<String> abstraction;
  final Value<bool> isFollowUp;
  final Value<String?> previousReflectionId;
  final Value<DateTime> createdAt;
  final Value<String?> rawMarkdown;
  final Value<String?> targetFactorId;
  final Value<String?> previousExperimentId;
  final Value<String?> groupId;
  final Value<String?> marginalGainDescription;
  final Value<String?> eventSequence;
  final Value<String?> feelings;
  final Value<String?> difficulties;
  final Value<String?> challengeResponse;
  final Value<String?> triggers;
  final Value<String?> whyBehavior;
  final Value<String?> crossLifePatterns;
  final Value<bool> isManualEntry;
  final Value<int> rowid;
  const ReflectionsCompanion({
    this.id = const Value.absent(),
    this.experience = const Value.absent(),
    this.reflection = const Value.absent(),
    this.abstraction = const Value.absent(),
    this.isFollowUp = const Value.absent(),
    this.previousReflectionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rawMarkdown = const Value.absent(),
    this.targetFactorId = const Value.absent(),
    this.previousExperimentId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.marginalGainDescription = const Value.absent(),
    this.eventSequence = const Value.absent(),
    this.feelings = const Value.absent(),
    this.difficulties = const Value.absent(),
    this.challengeResponse = const Value.absent(),
    this.triggers = const Value.absent(),
    this.whyBehavior = const Value.absent(),
    this.crossLifePatterns = const Value.absent(),
    this.isManualEntry = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReflectionsCompanion.insert({
    required String id,
    this.experience = const Value.absent(),
    this.reflection = const Value.absent(),
    this.abstraction = const Value.absent(),
    this.isFollowUp = const Value.absent(),
    this.previousReflectionId = const Value.absent(),
    required DateTime createdAt,
    this.rawMarkdown = const Value.absent(),
    this.targetFactorId = const Value.absent(),
    this.previousExperimentId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.marginalGainDescription = const Value.absent(),
    this.eventSequence = const Value.absent(),
    this.feelings = const Value.absent(),
    this.difficulties = const Value.absent(),
    this.challengeResponse = const Value.absent(),
    this.triggers = const Value.absent(),
    this.whyBehavior = const Value.absent(),
    this.crossLifePatterns = const Value.absent(),
    this.isManualEntry = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt);
  static Insertable<ReflectionEntry> custom({
    Expression<String>? id,
    Expression<String>? experience,
    Expression<String>? reflection,
    Expression<String>? abstraction,
    Expression<bool>? isFollowUp,
    Expression<String>? previousReflectionId,
    Expression<DateTime>? createdAt,
    Expression<String>? rawMarkdown,
    Expression<String>? targetFactorId,
    Expression<String>? previousExperimentId,
    Expression<String>? groupId,
    Expression<String>? marginalGainDescription,
    Expression<String>? eventSequence,
    Expression<String>? feelings,
    Expression<String>? difficulties,
    Expression<String>? challengeResponse,
    Expression<String>? triggers,
    Expression<String>? whyBehavior,
    Expression<String>? crossLifePatterns,
    Expression<bool>? isManualEntry,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (experience != null) 'experience': experience,
      if (reflection != null) 'reflection': reflection,
      if (abstraction != null) 'abstraction': abstraction,
      if (isFollowUp != null) 'is_follow_up': isFollowUp,
      if (previousReflectionId != null)
        'previous_reflection_id': previousReflectionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rawMarkdown != null) 'raw_markdown': rawMarkdown,
      if (targetFactorId != null) 'target_factor_id': targetFactorId,
      if (previousExperimentId != null)
        'previous_experiment_id': previousExperimentId,
      if (groupId != null) 'group_id': groupId,
      if (marginalGainDescription != null)
        'marginal_gain_description': marginalGainDescription,
      if (eventSequence != null) 'event_sequence': eventSequence,
      if (feelings != null) 'feelings': feelings,
      if (difficulties != null) 'difficulties': difficulties,
      if (challengeResponse != null) 'challenge_response': challengeResponse,
      if (triggers != null) 'triggers': triggers,
      if (whyBehavior != null) 'why_behavior': whyBehavior,
      if (crossLifePatterns != null) 'cross_life_patterns': crossLifePatterns,
      if (isManualEntry != null) 'is_manual_entry': isManualEntry,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReflectionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? experience,
      Value<String>? reflection,
      Value<String>? abstraction,
      Value<bool>? isFollowUp,
      Value<String?>? previousReflectionId,
      Value<DateTime>? createdAt,
      Value<String?>? rawMarkdown,
      Value<String?>? targetFactorId,
      Value<String?>? previousExperimentId,
      Value<String?>? groupId,
      Value<String?>? marginalGainDescription,
      Value<String?>? eventSequence,
      Value<String?>? feelings,
      Value<String?>? difficulties,
      Value<String?>? challengeResponse,
      Value<String?>? triggers,
      Value<String?>? whyBehavior,
      Value<String?>? crossLifePatterns,
      Value<bool>? isManualEntry,
      Value<int>? rowid}) {
    return ReflectionsCompanion(
      id: id ?? this.id,
      experience: experience ?? this.experience,
      reflection: reflection ?? this.reflection,
      abstraction: abstraction ?? this.abstraction,
      isFollowUp: isFollowUp ?? this.isFollowUp,
      previousReflectionId: previousReflectionId ?? this.previousReflectionId,
      createdAt: createdAt ?? this.createdAt,
      rawMarkdown: rawMarkdown ?? this.rawMarkdown,
      targetFactorId: targetFactorId ?? this.targetFactorId,
      previousExperimentId: previousExperimentId ?? this.previousExperimentId,
      groupId: groupId ?? this.groupId,
      marginalGainDescription:
          marginalGainDescription ?? this.marginalGainDescription,
      eventSequence: eventSequence ?? this.eventSequence,
      feelings: feelings ?? this.feelings,
      difficulties: difficulties ?? this.difficulties,
      challengeResponse: challengeResponse ?? this.challengeResponse,
      triggers: triggers ?? this.triggers,
      whyBehavior: whyBehavior ?? this.whyBehavior,
      crossLifePatterns: crossLifePatterns ?? this.crossLifePatterns,
      isManualEntry: isManualEntry ?? this.isManualEntry,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (experience.present) {
      map['experience'] = Variable<String>(experience.value);
    }
    if (reflection.present) {
      map['reflection'] = Variable<String>(reflection.value);
    }
    if (abstraction.present) {
      map['abstraction'] = Variable<String>(abstraction.value);
    }
    if (isFollowUp.present) {
      map['is_follow_up'] = Variable<bool>(isFollowUp.value);
    }
    if (previousReflectionId.present) {
      map['previous_reflection_id'] =
          Variable<String>(previousReflectionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rawMarkdown.present) {
      map['raw_markdown'] = Variable<String>(rawMarkdown.value);
    }
    if (targetFactorId.present) {
      map['target_factor_id'] = Variable<String>(targetFactorId.value);
    }
    if (previousExperimentId.present) {
      map['previous_experiment_id'] =
          Variable<String>(previousExperimentId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (marginalGainDescription.present) {
      map['marginal_gain_description'] =
          Variable<String>(marginalGainDescription.value);
    }
    if (eventSequence.present) {
      map['event_sequence'] = Variable<String>(eventSequence.value);
    }
    if (feelings.present) {
      map['feelings'] = Variable<String>(feelings.value);
    }
    if (difficulties.present) {
      map['difficulties'] = Variable<String>(difficulties.value);
    }
    if (challengeResponse.present) {
      map['challenge_response'] = Variable<String>(challengeResponse.value);
    }
    if (triggers.present) {
      map['triggers'] = Variable<String>(triggers.value);
    }
    if (whyBehavior.present) {
      map['why_behavior'] = Variable<String>(whyBehavior.value);
    }
    if (crossLifePatterns.present) {
      map['cross_life_patterns'] = Variable<String>(crossLifePatterns.value);
    }
    if (isManualEntry.present) {
      map['is_manual_entry'] = Variable<bool>(isManualEntry.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionsCompanion(')
          ..write('id: $id, ')
          ..write('experience: $experience, ')
          ..write('reflection: $reflection, ')
          ..write('abstraction: $abstraction, ')
          ..write('isFollowUp: $isFollowUp, ')
          ..write('previousReflectionId: $previousReflectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rawMarkdown: $rawMarkdown, ')
          ..write('targetFactorId: $targetFactorId, ')
          ..write('previousExperimentId: $previousExperimentId, ')
          ..write('groupId: $groupId, ')
          ..write('marginalGainDescription: $marginalGainDescription, ')
          ..write('eventSequence: $eventSequence, ')
          ..write('feelings: $feelings, ')
          ..write('difficulties: $difficulties, ')
          ..write('challengeResponse: $challengeResponse, ')
          ..write('triggers: $triggers, ')
          ..write('whyBehavior: $whyBehavior, ')
          ..write('crossLifePatterns: $crossLifePatterns, ')
          ..write('isManualEntry: $isManualEntry, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReflectionFactorLinksTable extends ReflectionFactorLinks
    with TableInfo<$ReflectionFactorLinksTable, ReflectionFactorLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionFactorLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reflectionIdMeta =
      const VerificationMeta('reflectionId');
  @override
  late final GeneratedColumn<String> reflectionId = GeneratedColumn<String>(
      'reflection_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES reflections (id)'));
  static const VerificationMeta _factorIdMeta =
      const VerificationMeta('factorId');
  @override
  late final GeneratedColumn<String> factorId = GeneratedColumn<String>(
      'factor_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES factors (id)'));
  @override
  List<GeneratedColumn> get $columns => [reflectionId, factorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflection_factor_links';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReflectionFactorLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reflection_id')) {
      context.handle(
          _reflectionIdMeta,
          reflectionId.isAcceptableOrUnknown(
              data['reflection_id']!, _reflectionIdMeta));
    } else if (isInserting) {
      context.missing(_reflectionIdMeta);
    }
    if (data.containsKey('factor_id')) {
      context.handle(_factorIdMeta,
          factorId.isAcceptableOrUnknown(data['factor_id']!, _factorIdMeta));
    } else if (isInserting) {
      context.missing(_factorIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reflectionId, factorId};
  @override
  ReflectionFactorLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReflectionFactorLink(
      reflectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reflection_id'])!,
      factorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}factor_id'])!,
    );
  }

  @override
  $ReflectionFactorLinksTable createAlias(String alias) {
    return $ReflectionFactorLinksTable(attachedDatabase, alias);
  }
}

class ReflectionFactorLink extends DataClass
    implements Insertable<ReflectionFactorLink> {
  final String reflectionId;
  final String factorId;
  const ReflectionFactorLink(
      {required this.reflectionId, required this.factorId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reflection_id'] = Variable<String>(reflectionId);
    map['factor_id'] = Variable<String>(factorId);
    return map;
  }

  ReflectionFactorLinksCompanion toCompanion(bool nullToAbsent) {
    return ReflectionFactorLinksCompanion(
      reflectionId: Value(reflectionId),
      factorId: Value(factorId),
    );
  }

  factory ReflectionFactorLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReflectionFactorLink(
      reflectionId: serializer.fromJson<String>(json['reflectionId']),
      factorId: serializer.fromJson<String>(json['factorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reflectionId': serializer.toJson<String>(reflectionId),
      'factorId': serializer.toJson<String>(factorId),
    };
  }

  ReflectionFactorLink copyWith({String? reflectionId, String? factorId}) =>
      ReflectionFactorLink(
        reflectionId: reflectionId ?? this.reflectionId,
        factorId: factorId ?? this.factorId,
      );
  ReflectionFactorLink copyWithCompanion(ReflectionFactorLinksCompanion data) {
    return ReflectionFactorLink(
      reflectionId: data.reflectionId.present
          ? data.reflectionId.value
          : this.reflectionId,
      factorId: data.factorId.present ? data.factorId.value : this.factorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionFactorLink(')
          ..write('reflectionId: $reflectionId, ')
          ..write('factorId: $factorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(reflectionId, factorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReflectionFactorLink &&
          other.reflectionId == this.reflectionId &&
          other.factorId == this.factorId);
}

class ReflectionFactorLinksCompanion
    extends UpdateCompanion<ReflectionFactorLink> {
  final Value<String> reflectionId;
  final Value<String> factorId;
  final Value<int> rowid;
  const ReflectionFactorLinksCompanion({
    this.reflectionId = const Value.absent(),
    this.factorId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReflectionFactorLinksCompanion.insert({
    required String reflectionId,
    required String factorId,
    this.rowid = const Value.absent(),
  })  : reflectionId = Value(reflectionId),
        factorId = Value(factorId);
  static Insertable<ReflectionFactorLink> custom({
    Expression<String>? reflectionId,
    Expression<String>? factorId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (reflectionId != null) 'reflection_id': reflectionId,
      if (factorId != null) 'factor_id': factorId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReflectionFactorLinksCompanion copyWith(
      {Value<String>? reflectionId,
      Value<String>? factorId,
      Value<int>? rowid}) {
    return ReflectionFactorLinksCompanion(
      reflectionId: reflectionId ?? this.reflectionId,
      factorId: factorId ?? this.factorId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reflectionId.present) {
      map['reflection_id'] = Variable<String>(reflectionId.value);
    }
    if (factorId.present) {
      map['factor_id'] = Variable<String>(factorId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionFactorLinksCompanion(')
          ..write('reflectionId: $reflectionId, ')
          ..write('factorId: $factorId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReflectionExperimentLinksTable extends ReflectionExperimentLinks
    with TableInfo<$ReflectionExperimentLinksTable, ReflectionExperimentLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionExperimentLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reflectionIdMeta =
      const VerificationMeta('reflectionId');
  @override
  late final GeneratedColumn<String> reflectionId = GeneratedColumn<String>(
      'reflection_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES reflections (id)'));
  static const VerificationMeta _experimentIdMeta =
      const VerificationMeta('experimentId');
  @override
  late final GeneratedColumn<String> experimentId = GeneratedColumn<String>(
      'experiment_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [reflectionId, experimentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflection_experiment_links';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReflectionExperimentLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reflection_id')) {
      context.handle(
          _reflectionIdMeta,
          reflectionId.isAcceptableOrUnknown(
              data['reflection_id']!, _reflectionIdMeta));
    } else if (isInserting) {
      context.missing(_reflectionIdMeta);
    }
    if (data.containsKey('experiment_id')) {
      context.handle(
          _experimentIdMeta,
          experimentId.isAcceptableOrUnknown(
              data['experiment_id']!, _experimentIdMeta));
    } else if (isInserting) {
      context.missing(_experimentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reflectionId, experimentId};
  @override
  ReflectionExperimentLink map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReflectionExperimentLink(
      reflectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reflection_id'])!,
      experimentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}experiment_id'])!,
    );
  }

  @override
  $ReflectionExperimentLinksTable createAlias(String alias) {
    return $ReflectionExperimentLinksTable(attachedDatabase, alias);
  }
}

class ReflectionExperimentLink extends DataClass
    implements Insertable<ReflectionExperimentLink> {
  final String reflectionId;
  final String experimentId;
  const ReflectionExperimentLink(
      {required this.reflectionId, required this.experimentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reflection_id'] = Variable<String>(reflectionId);
    map['experiment_id'] = Variable<String>(experimentId);
    return map;
  }

  ReflectionExperimentLinksCompanion toCompanion(bool nullToAbsent) {
    return ReflectionExperimentLinksCompanion(
      reflectionId: Value(reflectionId),
      experimentId: Value(experimentId),
    );
  }

  factory ReflectionExperimentLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReflectionExperimentLink(
      reflectionId: serializer.fromJson<String>(json['reflectionId']),
      experimentId: serializer.fromJson<String>(json['experimentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reflectionId': serializer.toJson<String>(reflectionId),
      'experimentId': serializer.toJson<String>(experimentId),
    };
  }

  ReflectionExperimentLink copyWith(
          {String? reflectionId, String? experimentId}) =>
      ReflectionExperimentLink(
        reflectionId: reflectionId ?? this.reflectionId,
        experimentId: experimentId ?? this.experimentId,
      );
  ReflectionExperimentLink copyWithCompanion(
      ReflectionExperimentLinksCompanion data) {
    return ReflectionExperimentLink(
      reflectionId: data.reflectionId.present
          ? data.reflectionId.value
          : this.reflectionId,
      experimentId: data.experimentId.present
          ? data.experimentId.value
          : this.experimentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionExperimentLink(')
          ..write('reflectionId: $reflectionId, ')
          ..write('experimentId: $experimentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(reflectionId, experimentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReflectionExperimentLink &&
          other.reflectionId == this.reflectionId &&
          other.experimentId == this.experimentId);
}

class ReflectionExperimentLinksCompanion
    extends UpdateCompanion<ReflectionExperimentLink> {
  final Value<String> reflectionId;
  final Value<String> experimentId;
  final Value<int> rowid;
  const ReflectionExperimentLinksCompanion({
    this.reflectionId = const Value.absent(),
    this.experimentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReflectionExperimentLinksCompanion.insert({
    required String reflectionId,
    required String experimentId,
    this.rowid = const Value.absent(),
  })  : reflectionId = Value(reflectionId),
        experimentId = Value(experimentId);
  static Insertable<ReflectionExperimentLink> custom({
    Expression<String>? reflectionId,
    Expression<String>? experimentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (reflectionId != null) 'reflection_id': reflectionId,
      if (experimentId != null) 'experiment_id': experimentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReflectionExperimentLinksCompanion copyWith(
      {Value<String>? reflectionId,
      Value<String>? experimentId,
      Value<int>? rowid}) {
    return ReflectionExperimentLinksCompanion(
      reflectionId: reflectionId ?? this.reflectionId,
      experimentId: experimentId ?? this.experimentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reflectionId.present) {
      map['reflection_id'] = Variable<String>(reflectionId.value);
    }
    if (experimentId.present) {
      map['experiment_id'] = Variable<String>(experimentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionExperimentLinksCompanion(')
          ..write('reflectionId: $reflectionId, ')
          ..write('experimentId: $experimentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExperimentsTable extends Experiments
    with TableInfo<$ExperimentsTable, ExperimentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExperimentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reflectionIdMeta =
      const VerificationMeta('reflectionId');
  @override
  late final GeneratedColumn<String> reflectionId = GeneratedColumn<String>(
      'reflection_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cycleCountMeta =
      const VerificationMeta('cycleCount');
  @override
  late final GeneratedColumn<int> cycleCount = GeneratedColumn<int>(
      'cycle_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        description,
        status,
        reflectionId,
        createdAt,
        groupId,
        cycleCount,
        startedAt,
        completedAt,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'experiments';
  @override
  VerificationContext validateIntegrity(Insertable<ExperimentEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('reflection_id')) {
      context.handle(
          _reflectionIdMeta,
          reflectionId.isAcceptableOrUnknown(
              data['reflection_id']!, _reflectionIdMeta));
    } else if (isInserting) {
      context.missing(_reflectionIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('cycle_count')) {
      context.handle(
          _cycleCountMeta,
          cycleCount.isAcceptableOrUnknown(
              data['cycle_count']!, _cycleCountMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExperimentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExperimentEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      reflectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reflection_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id']),
      cycleCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_count'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $ExperimentsTable createAlias(String alias) {
    return $ExperimentsTable(attachedDatabase, alias);
  }
}

class ExperimentEntry extends DataClass implements Insertable<ExperimentEntry> {
  final String id;
  final String description;
  final int status;
  final String reflectionId;
  final DateTime createdAt;
  final String? groupId;
  final int cycleCount;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  const ExperimentEntry(
      {required this.id,
      required this.description,
      required this.status,
      required this.reflectionId,
      required this.createdAt,
      this.groupId,
      required this.cycleCount,
      this.startedAt,
      this.completedAt,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<int>(status);
    map['reflection_id'] = Variable<String>(reflectionId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['cycle_count'] = Variable<int>(cycleCount);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ExperimentsCompanion toCompanion(bool nullToAbsent) {
    return ExperimentsCompanion(
      id: Value(id),
      description: Value(description),
      status: Value(status),
      reflectionId: Value(reflectionId),
      createdAt: Value(createdAt),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      cycleCount: Value(cycleCount),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory ExperimentEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExperimentEntry(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      status: serializer.fromJson<int>(json['status']),
      reflectionId: serializer.fromJson<String>(json['reflectionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      cycleCount: serializer.fromJson<int>(json['cycleCount']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<int>(status),
      'reflectionId': serializer.toJson<String>(reflectionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'groupId': serializer.toJson<String?>(groupId),
      'cycleCount': serializer.toJson<int>(cycleCount),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ExperimentEntry copyWith(
          {String? id,
          String? description,
          int? status,
          String? reflectionId,
          DateTime? createdAt,
          Value<String?> groupId = const Value.absent(),
          int? cycleCount,
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      ExperimentEntry(
        id: id ?? this.id,
        description: description ?? this.description,
        status: status ?? this.status,
        reflectionId: reflectionId ?? this.reflectionId,
        createdAt: createdAt ?? this.createdAt,
        groupId: groupId.present ? groupId.value : this.groupId,
        cycleCount: cycleCount ?? this.cycleCount,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        notes: notes.present ? notes.value : this.notes,
      );
  ExperimentEntry copyWithCompanion(ExperimentsCompanion data) {
    return ExperimentEntry(
      id: data.id.present ? data.id.value : this.id,
      description:
          data.description.present ? data.description.value : this.description,
      status: data.status.present ? data.status.value : this.status,
      reflectionId: data.reflectionId.present
          ? data.reflectionId.value
          : this.reflectionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      cycleCount:
          data.cycleCount.present ? data.cycleCount.value : this.cycleCount,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentEntry(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('reflectionId: $reflectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('groupId: $groupId, ')
          ..write('cycleCount: $cycleCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, description, status, reflectionId,
      createdAt, groupId, cycleCount, startedAt, completedAt, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExperimentEntry &&
          other.id == this.id &&
          other.description == this.description &&
          other.status == this.status &&
          other.reflectionId == this.reflectionId &&
          other.createdAt == this.createdAt &&
          other.groupId == this.groupId &&
          other.cycleCount == this.cycleCount &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes);
}

class ExperimentsCompanion extends UpdateCompanion<ExperimentEntry> {
  final Value<String> id;
  final Value<String> description;
  final Value<int> status;
  final Value<String> reflectionId;
  final Value<DateTime> createdAt;
  final Value<String?> groupId;
  final Value<int> cycleCount;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> notes;
  final Value<int> rowid;
  const ExperimentsCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.reflectionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.groupId = const Value.absent(),
    this.cycleCount = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExperimentsCompanion.insert({
    required String id,
    required String description,
    required int status,
    required String reflectionId,
    required DateTime createdAt,
    this.groupId = const Value.absent(),
    this.cycleCount = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        description = Value(description),
        status = Value(status),
        reflectionId = Value(reflectionId),
        createdAt = Value(createdAt);
  static Insertable<ExperimentEntry> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<int>? status,
    Expression<String>? reflectionId,
    Expression<DateTime>? createdAt,
    Expression<String>? groupId,
    Expression<int>? cycleCount,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (reflectionId != null) 'reflection_id': reflectionId,
      if (createdAt != null) 'created_at': createdAt,
      if (groupId != null) 'group_id': groupId,
      if (cycleCount != null) 'cycle_count': cycleCount,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExperimentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? description,
      Value<int>? status,
      Value<String>? reflectionId,
      Value<DateTime>? createdAt,
      Value<String?>? groupId,
      Value<int>? cycleCount,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? completedAt,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return ExperimentsCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      status: status ?? this.status,
      reflectionId: reflectionId ?? this.reflectionId,
      createdAt: createdAt ?? this.createdAt,
      groupId: groupId ?? this.groupId,
      cycleCount: cycleCount ?? this.cycleCount,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (reflectionId.present) {
      map['reflection_id'] = Variable<String>(reflectionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (cycleCount.present) {
      map['cycle_count'] = Variable<int>(cycleCount.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentsCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('reflectionId: $reflectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('groupId: $groupId, ')
          ..write('cycleCount: $cycleCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusLogsTable extends FocusLogs
    with TableInfo<$FocusLogsTable, FocusLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskTitleMeta =
      const VerificationMeta('taskTitle');
  @override
  late final GeneratedColumn<String> taskTitle = GeneratedColumn<String>(
      'task_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedPomodorosMeta =
      const VerificationMeta('completedPomodoros');
  @override
  late final GeneratedColumn<int> completedPomodoros = GeneratedColumn<int>(
      'completed_pomodoros', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _distractionsJsonMeta =
      const VerificationMeta('distractionsJson');
  @override
  late final GeneratedColumn<String> distractionsJson = GeneratedColumn<String>(
      'distractions_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        taskId,
        taskTitle,
        startTime,
        durationSeconds,
        completedPomodoros,
        distractionsJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_logs';
  @override
  VerificationContext validateIntegrity(Insertable<FocusLogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('task_title')) {
      context.handle(_taskTitleMeta,
          taskTitle.isAcceptableOrUnknown(data['task_title']!, _taskTitleMeta));
    } else if (isInserting) {
      context.missing(_taskTitleMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('completed_pomodoros')) {
      context.handle(
          _completedPomodorosMeta,
          completedPomodoros.isAcceptableOrUnknown(
              data['completed_pomodoros']!, _completedPomodorosMeta));
    }
    if (data.containsKey('distractions_json')) {
      context.handle(
          _distractionsJsonMeta,
          distractionsJson.isAcceptableOrUnknown(
              data['distractions_json']!, _distractionsJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusLogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      taskTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_title'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      completedPomodoros: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}completed_pomodoros'])!,
      distractionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}distractions_json'])!,
    );
  }

  @override
  $FocusLogsTable createAlias(String alias) {
    return $FocusLogsTable(attachedDatabase, alias);
  }
}

class FocusLogEntry extends DataClass implements Insertable<FocusLogEntry> {
  final String id;
  final String taskId;
  final String taskTitle;
  final DateTime startTime;
  final int durationSeconds;
  final int completedPomodoros;
  final String distractionsJson;
  const FocusLogEntry(
      {required this.id,
      required this.taskId,
      required this.taskTitle,
      required this.startTime,
      required this.durationSeconds,
      required this.completedPomodoros,
      required this.distractionsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['task_title'] = Variable<String>(taskTitle);
    map['start_time'] = Variable<DateTime>(startTime);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['completed_pomodoros'] = Variable<int>(completedPomodoros);
    map['distractions_json'] = Variable<String>(distractionsJson);
    return map;
  }

  FocusLogsCompanion toCompanion(bool nullToAbsent) {
    return FocusLogsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      taskTitle: Value(taskTitle),
      startTime: Value(startTime),
      durationSeconds: Value(durationSeconds),
      completedPomodoros: Value(completedPomodoros),
      distractionsJson: Value(distractionsJson),
    );
  }

  factory FocusLogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusLogEntry(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      taskTitle: serializer.fromJson<String>(json['taskTitle']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      completedPomodoros: serializer.fromJson<int>(json['completedPomodoros']),
      distractionsJson: serializer.fromJson<String>(json['distractionsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'taskTitle': serializer.toJson<String>(taskTitle),
      'startTime': serializer.toJson<DateTime>(startTime),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'completedPomodoros': serializer.toJson<int>(completedPomodoros),
      'distractionsJson': serializer.toJson<String>(distractionsJson),
    };
  }

  FocusLogEntry copyWith(
          {String? id,
          String? taskId,
          String? taskTitle,
          DateTime? startTime,
          int? durationSeconds,
          int? completedPomodoros,
          String? distractionsJson}) =>
      FocusLogEntry(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        taskTitle: taskTitle ?? this.taskTitle,
        startTime: startTime ?? this.startTime,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        completedPomodoros: completedPomodoros ?? this.completedPomodoros,
        distractionsJson: distractionsJson ?? this.distractionsJson,
      );
  FocusLogEntry copyWithCompanion(FocusLogsCompanion data) {
    return FocusLogEntry(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      taskTitle: data.taskTitle.present ? data.taskTitle.value : this.taskTitle,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      completedPomodoros: data.completedPomodoros.present
          ? data.completedPomodoros.value
          : this.completedPomodoros,
      distractionsJson: data.distractionsJson.present
          ? data.distractionsJson.value
          : this.distractionsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusLogEntry(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('startTime: $startTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedPomodoros: $completedPomodoros, ')
          ..write('distractionsJson: $distractionsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, taskTitle, startTime,
      durationSeconds, completedPomodoros, distractionsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusLogEntry &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.taskTitle == this.taskTitle &&
          other.startTime == this.startTime &&
          other.durationSeconds == this.durationSeconds &&
          other.completedPomodoros == this.completedPomodoros &&
          other.distractionsJson == this.distractionsJson);
}

class FocusLogsCompanion extends UpdateCompanion<FocusLogEntry> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> taskTitle;
  final Value<DateTime> startTime;
  final Value<int> durationSeconds;
  final Value<int> completedPomodoros;
  final Value<String> distractionsJson;
  final Value<int> rowid;
  const FocusLogsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.startTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completedPomodoros = const Value.absent(),
    this.distractionsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FocusLogsCompanion.insert({
    required String id,
    required String taskId,
    required String taskTitle,
    required DateTime startTime,
    required int durationSeconds,
    this.completedPomodoros = const Value.absent(),
    this.distractionsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        taskTitle = Value(taskTitle),
        startTime = Value(startTime),
        durationSeconds = Value(durationSeconds);
  static Insertable<FocusLogEntry> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? taskTitle,
    Expression<DateTime>? startTime,
    Expression<int>? durationSeconds,
    Expression<int>? completedPomodoros,
    Expression<String>? distractionsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (taskTitle != null) 'task_title': taskTitle,
      if (startTime != null) 'start_time': startTime,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completedPomodoros != null) 'completed_pomodoros': completedPomodoros,
      if (distractionsJson != null) 'distractions_json': distractionsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FocusLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<String>? taskTitle,
      Value<DateTime>? startTime,
      Value<int>? durationSeconds,
      Value<int>? completedPomodoros,
      Value<String>? distractionsJson,
      Value<int>? rowid}) {
    return FocusLogsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      startTime: startTime ?? this.startTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      distractionsJson: distractionsJson ?? this.distractionsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (taskTitle.present) {
      map['task_title'] = Variable<String>(taskTitle.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (completedPomodoros.present) {
      map['completed_pomodoros'] = Variable<int>(completedPomodoros.value);
    }
    if (distractionsJson.present) {
      map['distractions_json'] = Variable<String>(distractionsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusLogsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('startTime: $startTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedPomodoros: $completedPomodoros, ')
          ..write('distractionsJson: $distractionsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReflectionGroupsTable extends ReflectionGroups
    with TableInfo<$ReflectionGroupsTable, ReflectionGroupEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _targetFactorIdMeta =
      const VerificationMeta('targetFactorId');
  @override
  late final GeneratedColumn<String> targetFactorId = GeneratedColumn<String>(
      'target_factor_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, createdAt, archivedAt, targetFactorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflection_groups';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReflectionGroupEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    if (data.containsKey('target_factor_id')) {
      context.handle(
          _targetFactorIdMeta,
          targetFactorId.isAcceptableOrUnknown(
              data['target_factor_id']!, _targetFactorIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReflectionGroupEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReflectionGroupEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
      targetFactorId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}target_factor_id']),
    );
  }

  @override
  $ReflectionGroupsTable createAlias(String alias) {
    return $ReflectionGroupsTable(attachedDatabase, alias);
  }
}

class ReflectionGroupEntry extends DataClass
    implements Insertable<ReflectionGroupEntry> {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? archivedAt;
  final String? targetFactorId;
  const ReflectionGroupEntry(
      {required this.id,
      required this.title,
      required this.createdAt,
      this.archivedAt,
      this.targetFactorId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || targetFactorId != null) {
      map['target_factor_id'] = Variable<String>(targetFactorId);
    }
    return map;
  }

  ReflectionGroupsCompanion toCompanion(bool nullToAbsent) {
    return ReflectionGroupsCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      targetFactorId: targetFactorId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetFactorId),
    );
  }

  factory ReflectionGroupEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReflectionGroupEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      targetFactorId: serializer.fromJson<String?>(json['targetFactorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'targetFactorId': serializer.toJson<String?>(targetFactorId),
    };
  }

  ReflectionGroupEntry copyWith(
          {String? id,
          String? title,
          DateTime? createdAt,
          Value<DateTime?> archivedAt = const Value.absent(),
          Value<String?> targetFactorId = const Value.absent()}) =>
      ReflectionGroupEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
        targetFactorId:
            targetFactorId.present ? targetFactorId.value : this.targetFactorId,
      );
  ReflectionGroupEntry copyWithCompanion(ReflectionGroupsCompanion data) {
    return ReflectionGroupEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      targetFactorId: data.targetFactorId.present
          ? data.targetFactorId.value
          : this.targetFactorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionGroupEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('targetFactorId: $targetFactorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, createdAt, archivedAt, targetFactorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReflectionGroupEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt &&
          other.targetFactorId == this.targetFactorId);
}

class ReflectionGroupsCompanion extends UpdateCompanion<ReflectionGroupEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<String?> targetFactorId;
  final Value<int> rowid;
  const ReflectionGroupsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.targetFactorId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReflectionGroupsCompanion.insert({
    required String id,
    required String title,
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.targetFactorId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<ReflectionGroupEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<String>? targetFactorId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (targetFactorId != null) 'target_factor_id': targetFactorId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReflectionGroupsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<DateTime>? createdAt,
      Value<DateTime?>? archivedAt,
      Value<String?>? targetFactorId,
      Value<int>? rowid}) {
    return ReflectionGroupsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      targetFactorId: targetFactorId ?? this.targetFactorId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (targetFactorId.present) {
      map['target_factor_id'] = Variable<String>(targetFactorId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionGroupsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('targetFactorId: $targetFactorId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconCodePointMeta =
      const VerificationMeta('iconCodePoint');
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
      'icon_code_point', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _iconFontFamilyMeta =
      const VerificationMeta('iconFontFamily');
  @override
  late final GeneratedColumn<String> iconFontFamily = GeneratedColumn<String>(
      'icon_font_family', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MaterialIcons'));
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        iconCodePoint,
        iconFontFamily,
        colorValue,
        isDefault,
        createdAt,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
          _iconCodePointMeta,
          iconCodePoint.isAcceptableOrUnknown(
              data['icon_code_point']!, _iconCodePointMeta));
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('icon_font_family')) {
      context.handle(
          _iconFontFamilyMeta,
          iconFontFamily.isAcceptableOrUnknown(
              data['icon_font_family']!, _iconFontFamilyMeta));
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconCodePoint: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon_code_point'])!,
      iconFontFamily: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}icon_font_family'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryEntry extends DataClass implements Insertable<CategoryEntry> {
  final String id;
  final String name;
  final int iconCodePoint;
  final String iconFontFamily;
  final int colorValue;
  final bool isDefault;
  final DateTime createdAt;
  final int sortOrder;
  const CategoryEntry(
      {required this.id,
      required this.name,
      required this.iconCodePoint,
      required this.iconFontFamily,
      required this.colorValue,
      required this.isDefault,
      required this.createdAt,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    map['icon_font_family'] = Variable<String>(iconFontFamily);
    map['color_value'] = Variable<int>(colorValue);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconCodePoint: Value(iconCodePoint),
      iconFontFamily: Value(iconFontFamily),
      colorValue: Value(colorValue),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      iconFontFamily: serializer.fromJson<String>(json['iconFontFamily']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'iconFontFamily': serializer.toJson<String>(iconFontFamily),
      'colorValue': serializer.toJson<int>(colorValue),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryEntry copyWith(
          {String? id,
          String? name,
          int? iconCodePoint,
          String? iconFontFamily,
          int? colorValue,
          bool? isDefault,
          DateTime? createdAt,
          int? sortOrder}) =>
      CategoryEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCodePoint: iconCodePoint ?? this.iconCodePoint,
        iconFontFamily: iconFontFamily ?? this.iconFontFamily,
        colorValue: colorValue ?? this.colorValue,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  CategoryEntry copyWithCompanion(CategoriesCompanion data) {
    return CategoryEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      iconFontFamily: data.iconFontFamily.present
          ? data.iconFontFamily.value
          : this.iconFontFamily,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('iconFontFamily: $iconFontFamily, ')
          ..write('colorValue: $colorValue, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconCodePoint, iconFontFamily,
      colorValue, isDefault, createdAt, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconCodePoint == this.iconCodePoint &&
          other.iconFontFamily == this.iconFontFamily &&
          other.colorValue == this.colorValue &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> iconCodePoint;
  final Value<String> iconFontFamily;
  final Value<int> colorValue;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.iconFontFamily = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required int iconCodePoint,
    this.iconFontFamily = const Value.absent(),
    required int colorValue,
    this.isDefault = const Value.absent(),
    required DateTime createdAt,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        iconCodePoint = Value(iconCodePoint),
        colorValue = Value(colorValue),
        createdAt = Value(createdAt);
  static Insertable<CategoryEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? iconCodePoint,
    Expression<String>? iconFontFamily,
    Expression<int>? colorValue,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (iconFontFamily != null) 'icon_font_family': iconFontFamily,
      if (colorValue != null) 'color_value': colorValue,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? iconCodePoint,
      Value<String>? iconFontFamily,
      Value<int>? colorValue,
      Value<bool>? isDefault,
      Value<DateTime>? createdAt,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (iconFontFamily.present) {
      map['icon_font_family'] = Variable<String>(iconFontFamily.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('iconFontFamily: $iconFontFamily, ')
          ..write('colorValue: $colorValue, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTasksTable extends RecurringTasks
    with TableInfo<$RecurringTasksTable, RecurringTaskEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _evaluationTypeMeta =
      const VerificationMeta('evaluationType');
  @override
  late final GeneratedColumn<int> evaluationType = GeneratedColumn<int>(
      'evaluation_type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _checklistItemsJsonMeta =
      const VerificationMeta('checklistItemsJson');
  @override
  late final GeneratedColumn<String> checklistItemsJson =
      GeneratedColumn<String>('checklist_items_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _frequencyTypeMeta =
      const VerificationMeta('frequencyType');
  @override
  late final GeneratedColumn<int> frequencyType = GeneratedColumn<int>(
      'frequency_type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scheduledDaysJsonMeta =
      const VerificationMeta('scheduledDaysJson');
  @override
  late final GeneratedColumn<String> scheduledDaysJson =
      GeneratedColumn<String>('scheduled_days_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _daysPerPeriodMeta =
      const VerificationMeta('daysPerPeriod');
  @override
  late final GeneratedColumn<int> daysPerPeriod = GeneratedColumn<int>(
      'days_per_period', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _repeatIntervalMeta =
      const VerificationMeta('repeatInterval');
  @override
  late final GeneratedColumn<int> repeatInterval = GeneratedColumn<int>(
      'repeat_interval', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _specificDatesJsonMeta =
      const VerificationMeta('specificDatesJson');
  @override
  late final GeneratedColumn<String> specificDatesJson =
      GeneratedColumn<String>('specific_dates_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _reminderTimesJsonMeta =
      const VerificationMeta('reminderTimesJson');
  @override
  late final GeneratedColumn<String> reminderTimesJson =
      GeneratedColumn<String>('reminder_times_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _priorityLevelMeta =
      const VerificationMeta('priorityLevel');
  @override
  late final GeneratedColumn<int> priorityLevel = GeneratedColumn<int>(
      'priority_level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        categoryId,
        evaluationType,
        checklistItemsJson,
        frequencyType,
        scheduledDaysJson,
        daysPerPeriod,
        repeatInterval,
        specificDatesJson,
        startDate,
        endDate,
        reminderTimesJson,
        priorityLevel,
        description,
        createdAt,
        isArchived,
        sortOrder,
        priority
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringTaskEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('evaluation_type')) {
      context.handle(
          _evaluationTypeMeta,
          evaluationType.isAcceptableOrUnknown(
              data['evaluation_type']!, _evaluationTypeMeta));
    } else if (isInserting) {
      context.missing(_evaluationTypeMeta);
    }
    if (data.containsKey('checklist_items_json')) {
      context.handle(
          _checklistItemsJsonMeta,
          checklistItemsJson.isAcceptableOrUnknown(
              data['checklist_items_json']!, _checklistItemsJsonMeta));
    }
    if (data.containsKey('frequency_type')) {
      context.handle(
          _frequencyTypeMeta,
          frequencyType.isAcceptableOrUnknown(
              data['frequency_type']!, _frequencyTypeMeta));
    } else if (isInserting) {
      context.missing(_frequencyTypeMeta);
    }
    if (data.containsKey('scheduled_days_json')) {
      context.handle(
          _scheduledDaysJsonMeta,
          scheduledDaysJson.isAcceptableOrUnknown(
              data['scheduled_days_json']!, _scheduledDaysJsonMeta));
    }
    if (data.containsKey('days_per_period')) {
      context.handle(
          _daysPerPeriodMeta,
          daysPerPeriod.isAcceptableOrUnknown(
              data['days_per_period']!, _daysPerPeriodMeta));
    }
    if (data.containsKey('repeat_interval')) {
      context.handle(
          _repeatIntervalMeta,
          repeatInterval.isAcceptableOrUnknown(
              data['repeat_interval']!, _repeatIntervalMeta));
    }
    if (data.containsKey('specific_dates_json')) {
      context.handle(
          _specificDatesJsonMeta,
          specificDatesJson.isAcceptableOrUnknown(
              data['specific_dates_json']!, _specificDatesJsonMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('reminder_times_json')) {
      context.handle(
          _reminderTimesJsonMeta,
          reminderTimesJson.isAcceptableOrUnknown(
              data['reminder_times_json']!, _reminderTimesJsonMeta));
    }
    if (data.containsKey('priority_level')) {
      context.handle(
          _priorityLevelMeta,
          priorityLevel.isAcceptableOrUnknown(
              data['priority_level']!, _priorityLevelMeta));
    } else if (isInserting) {
      context.missing(_priorityLevelMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTaskEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTaskEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      evaluationType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}evaluation_type'])!,
      checklistItemsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}checklist_items_json']),
      frequencyType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency_type'])!,
      scheduledDaysJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}scheduled_days_json'])!,
      daysPerPeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}days_per_period']),
      repeatInterval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repeat_interval']),
      specificDatesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specific_dates_json']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      reminderTimesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reminder_times_json'])!,
      priorityLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority_level'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
    );
  }

  @override
  $RecurringTasksTable createAlias(String alias) {
    return $RecurringTasksTable(attachedDatabase, alias);
  }
}

class RecurringTaskEntry extends DataClass
    implements Insertable<RecurringTaskEntry> {
  final String id;
  final String name;
  final String categoryId;
  final int evaluationType;
  final String? checklistItemsJson;
  final int frequencyType;
  final String scheduledDaysJson;
  final int? daysPerPeriod;
  final int? repeatInterval;
  final String? specificDatesJson;
  final DateTime startDate;
  final DateTime? endDate;
  final String reminderTimesJson;
  final int priorityLevel;
  final String? description;
  final DateTime createdAt;
  final bool isArchived;
  final int sortOrder;
  final int priority;
  const RecurringTaskEntry(
      {required this.id,
      required this.name,
      required this.categoryId,
      required this.evaluationType,
      this.checklistItemsJson,
      required this.frequencyType,
      required this.scheduledDaysJson,
      this.daysPerPeriod,
      this.repeatInterval,
      this.specificDatesJson,
      required this.startDate,
      this.endDate,
      required this.reminderTimesJson,
      required this.priorityLevel,
      this.description,
      required this.createdAt,
      required this.isArchived,
      required this.sortOrder,
      required this.priority});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category_id'] = Variable<String>(categoryId);
    map['evaluation_type'] = Variable<int>(evaluationType);
    if (!nullToAbsent || checklistItemsJson != null) {
      map['checklist_items_json'] = Variable<String>(checklistItemsJson);
    }
    map['frequency_type'] = Variable<int>(frequencyType);
    map['scheduled_days_json'] = Variable<String>(scheduledDaysJson);
    if (!nullToAbsent || daysPerPeriod != null) {
      map['days_per_period'] = Variable<int>(daysPerPeriod);
    }
    if (!nullToAbsent || repeatInterval != null) {
      map['repeat_interval'] = Variable<int>(repeatInterval);
    }
    if (!nullToAbsent || specificDatesJson != null) {
      map['specific_dates_json'] = Variable<String>(specificDatesJson);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['reminder_times_json'] = Variable<String>(reminderTimesJson);
    map['priority_level'] = Variable<int>(priorityLevel);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_archived'] = Variable<bool>(isArchived);
    map['sort_order'] = Variable<int>(sortOrder);
    map['priority'] = Variable<int>(priority);
    return map;
  }

  RecurringTasksCompanion toCompanion(bool nullToAbsent) {
    return RecurringTasksCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: Value(categoryId),
      evaluationType: Value(evaluationType),
      checklistItemsJson: checklistItemsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checklistItemsJson),
      frequencyType: Value(frequencyType),
      scheduledDaysJson: Value(scheduledDaysJson),
      daysPerPeriod: daysPerPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(daysPerPeriod),
      repeatInterval: repeatInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatInterval),
      specificDatesJson: specificDatesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(specificDatesJson),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      reminderTimesJson: Value(reminderTimesJson),
      priorityLevel: Value(priorityLevel),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      isArchived: Value(isArchived),
      sortOrder: Value(sortOrder),
      priority: Value(priority),
    );
  }

  factory RecurringTaskEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTaskEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      evaluationType: serializer.fromJson<int>(json['evaluationType']),
      checklistItemsJson:
          serializer.fromJson<String?>(json['checklistItemsJson']),
      frequencyType: serializer.fromJson<int>(json['frequencyType']),
      scheduledDaysJson: serializer.fromJson<String>(json['scheduledDaysJson']),
      daysPerPeriod: serializer.fromJson<int?>(json['daysPerPeriod']),
      repeatInterval: serializer.fromJson<int?>(json['repeatInterval']),
      specificDatesJson:
          serializer.fromJson<String?>(json['specificDatesJson']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      reminderTimesJson: serializer.fromJson<String>(json['reminderTimesJson']),
      priorityLevel: serializer.fromJson<int>(json['priorityLevel']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      priority: serializer.fromJson<int>(json['priority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<String>(categoryId),
      'evaluationType': serializer.toJson<int>(evaluationType),
      'checklistItemsJson': serializer.toJson<String?>(checklistItemsJson),
      'frequencyType': serializer.toJson<int>(frequencyType),
      'scheduledDaysJson': serializer.toJson<String>(scheduledDaysJson),
      'daysPerPeriod': serializer.toJson<int?>(daysPerPeriod),
      'repeatInterval': serializer.toJson<int?>(repeatInterval),
      'specificDatesJson': serializer.toJson<String?>(specificDatesJson),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'reminderTimesJson': serializer.toJson<String>(reminderTimesJson),
      'priorityLevel': serializer.toJson<int>(priorityLevel),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isArchived': serializer.toJson<bool>(isArchived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'priority': serializer.toJson<int>(priority),
    };
  }

  RecurringTaskEntry copyWith(
          {String? id,
          String? name,
          String? categoryId,
          int? evaluationType,
          Value<String?> checklistItemsJson = const Value.absent(),
          int? frequencyType,
          String? scheduledDaysJson,
          Value<int?> daysPerPeriod = const Value.absent(),
          Value<int?> repeatInterval = const Value.absent(),
          Value<String?> specificDatesJson = const Value.absent(),
          DateTime? startDate,
          Value<DateTime?> endDate = const Value.absent(),
          String? reminderTimesJson,
          int? priorityLevel,
          Value<String?> description = const Value.absent(),
          DateTime? createdAt,
          bool? isArchived,
          int? sortOrder,
          int? priority}) =>
      RecurringTaskEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryId: categoryId ?? this.categoryId,
        evaluationType: evaluationType ?? this.evaluationType,
        checklistItemsJson: checklistItemsJson.present
            ? checklistItemsJson.value
            : this.checklistItemsJson,
        frequencyType: frequencyType ?? this.frequencyType,
        scheduledDaysJson: scheduledDaysJson ?? this.scheduledDaysJson,
        daysPerPeriod:
            daysPerPeriod.present ? daysPerPeriod.value : this.daysPerPeriod,
        repeatInterval:
            repeatInterval.present ? repeatInterval.value : this.repeatInterval,
        specificDatesJson: specificDatesJson.present
            ? specificDatesJson.value
            : this.specificDatesJson,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        reminderTimesJson: reminderTimesJson ?? this.reminderTimesJson,
        priorityLevel: priorityLevel ?? this.priorityLevel,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
        isArchived: isArchived ?? this.isArchived,
        sortOrder: sortOrder ?? this.sortOrder,
        priority: priority ?? this.priority,
      );
  RecurringTaskEntry copyWithCompanion(RecurringTasksCompanion data) {
    return RecurringTaskEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      evaluationType: data.evaluationType.present
          ? data.evaluationType.value
          : this.evaluationType,
      checklistItemsJson: data.checklistItemsJson.present
          ? data.checklistItemsJson.value
          : this.checklistItemsJson,
      frequencyType: data.frequencyType.present
          ? data.frequencyType.value
          : this.frequencyType,
      scheduledDaysJson: data.scheduledDaysJson.present
          ? data.scheduledDaysJson.value
          : this.scheduledDaysJson,
      daysPerPeriod: data.daysPerPeriod.present
          ? data.daysPerPeriod.value
          : this.daysPerPeriod,
      repeatInterval: data.repeatInterval.present
          ? data.repeatInterval.value
          : this.repeatInterval,
      specificDatesJson: data.specificDatesJson.present
          ? data.specificDatesJson.value
          : this.specificDatesJson,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      reminderTimesJson: data.reminderTimesJson.present
          ? data.reminderTimesJson.value
          : this.reminderTimesJson,
      priorityLevel: data.priorityLevel.present
          ? data.priorityLevel.value
          : this.priorityLevel,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      priority: data.priority.present ? data.priority.value : this.priority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTaskEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('evaluationType: $evaluationType, ')
          ..write('checklistItemsJson: $checklistItemsJson, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('scheduledDaysJson: $scheduledDaysJson, ')
          ..write('daysPerPeriod: $daysPerPeriod, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('specificDatesJson: $specificDatesJson, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('reminderTimesJson: $reminderTimesJson, ')
          ..write('priorityLevel: $priorityLevel, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      categoryId,
      evaluationType,
      checklistItemsJson,
      frequencyType,
      scheduledDaysJson,
      daysPerPeriod,
      repeatInterval,
      specificDatesJson,
      startDate,
      endDate,
      reminderTimesJson,
      priorityLevel,
      description,
      createdAt,
      isArchived,
      sortOrder,
      priority);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTaskEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.evaluationType == this.evaluationType &&
          other.checklistItemsJson == this.checklistItemsJson &&
          other.frequencyType == this.frequencyType &&
          other.scheduledDaysJson == this.scheduledDaysJson &&
          other.daysPerPeriod == this.daysPerPeriod &&
          other.repeatInterval == this.repeatInterval &&
          other.specificDatesJson == this.specificDatesJson &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.reminderTimesJson == this.reminderTimesJson &&
          other.priorityLevel == this.priorityLevel &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.isArchived == this.isArchived &&
          other.sortOrder == this.sortOrder &&
          other.priority == this.priority);
}

class RecurringTasksCompanion extends UpdateCompanion<RecurringTaskEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> categoryId;
  final Value<int> evaluationType;
  final Value<String?> checklistItemsJson;
  final Value<int> frequencyType;
  final Value<String> scheduledDaysJson;
  final Value<int?> daysPerPeriod;
  final Value<int?> repeatInterval;
  final Value<String?> specificDatesJson;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<String> reminderTimesJson;
  final Value<int> priorityLevel;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<bool> isArchived;
  final Value<int> sortOrder;
  final Value<int> priority;
  final Value<int> rowid;
  const RecurringTasksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.evaluationType = const Value.absent(),
    this.checklistItemsJson = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.scheduledDaysJson = const Value.absent(),
    this.daysPerPeriod = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.specificDatesJson = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.reminderTimesJson = const Value.absent(),
    this.priorityLevel = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTasksCompanion.insert({
    required String id,
    required String name,
    required String categoryId,
    required int evaluationType,
    this.checklistItemsJson = const Value.absent(),
    required int frequencyType,
    this.scheduledDaysJson = const Value.absent(),
    this.daysPerPeriod = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.specificDatesJson = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.reminderTimesJson = const Value.absent(),
    required int priorityLevel,
    this.description = const Value.absent(),
    required DateTime createdAt,
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        categoryId = Value(categoryId),
        evaluationType = Value(evaluationType),
        frequencyType = Value(frequencyType),
        startDate = Value(startDate),
        priorityLevel = Value(priorityLevel),
        createdAt = Value(createdAt);
  static Insertable<RecurringTaskEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? categoryId,
    Expression<int>? evaluationType,
    Expression<String>? checklistItemsJson,
    Expression<int>? frequencyType,
    Expression<String>? scheduledDaysJson,
    Expression<int>? daysPerPeriod,
    Expression<int>? repeatInterval,
    Expression<String>? specificDatesJson,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? reminderTimesJson,
    Expression<int>? priorityLevel,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<bool>? isArchived,
    Expression<int>? sortOrder,
    Expression<int>? priority,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (evaluationType != null) 'evaluation_type': evaluationType,
      if (checklistItemsJson != null)
        'checklist_items_json': checklistItemsJson,
      if (frequencyType != null) 'frequency_type': frequencyType,
      if (scheduledDaysJson != null) 'scheduled_days_json': scheduledDaysJson,
      if (daysPerPeriod != null) 'days_per_period': daysPerPeriod,
      if (repeatInterval != null) 'repeat_interval': repeatInterval,
      if (specificDatesJson != null) 'specific_dates_json': specificDatesJson,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (reminderTimesJson != null) 'reminder_times_json': reminderTimesJson,
      if (priorityLevel != null) 'priority_level': priorityLevel,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (priority != null) 'priority': priority,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? categoryId,
      Value<int>? evaluationType,
      Value<String?>? checklistItemsJson,
      Value<int>? frequencyType,
      Value<String>? scheduledDaysJson,
      Value<int?>? daysPerPeriod,
      Value<int?>? repeatInterval,
      Value<String?>? specificDatesJson,
      Value<DateTime>? startDate,
      Value<DateTime?>? endDate,
      Value<String>? reminderTimesJson,
      Value<int>? priorityLevel,
      Value<String?>? description,
      Value<DateTime>? createdAt,
      Value<bool>? isArchived,
      Value<int>? sortOrder,
      Value<int>? priority,
      Value<int>? rowid}) {
    return RecurringTasksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      evaluationType: evaluationType ?? this.evaluationType,
      checklistItemsJson: checklistItemsJson ?? this.checklistItemsJson,
      frequencyType: frequencyType ?? this.frequencyType,
      scheduledDaysJson: scheduledDaysJson ?? this.scheduledDaysJson,
      daysPerPeriod: daysPerPeriod ?? this.daysPerPeriod,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      specificDatesJson: specificDatesJson ?? this.specificDatesJson,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderTimesJson: reminderTimesJson ?? this.reminderTimesJson,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      priority: priority ?? this.priority,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (evaluationType.present) {
      map['evaluation_type'] = Variable<int>(evaluationType.value);
    }
    if (checklistItemsJson.present) {
      map['checklist_items_json'] = Variable<String>(checklistItemsJson.value);
    }
    if (frequencyType.present) {
      map['frequency_type'] = Variable<int>(frequencyType.value);
    }
    if (scheduledDaysJson.present) {
      map['scheduled_days_json'] = Variable<String>(scheduledDaysJson.value);
    }
    if (daysPerPeriod.present) {
      map['days_per_period'] = Variable<int>(daysPerPeriod.value);
    }
    if (repeatInterval.present) {
      map['repeat_interval'] = Variable<int>(repeatInterval.value);
    }
    if (specificDatesJson.present) {
      map['specific_dates_json'] = Variable<String>(specificDatesJson.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (reminderTimesJson.present) {
      map['reminder_times_json'] = Variable<String>(reminderTimesJson.value);
    }
    if (priorityLevel.present) {
      map['priority_level'] = Variable<int>(priorityLevel.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTasksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('evaluationType: $evaluationType, ')
          ..write('checklistItemsJson: $checklistItemsJson, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('scheduledDaysJson: $scheduledDaysJson, ')
          ..write('daysPerPeriod: $daysPerPeriod, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('specificDatesJson: $specificDatesJson, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('reminderTimesJson: $reminderTimesJson, ')
          ..write('priorityLevel: $priorityLevel, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('priority: $priority, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTaskFactorLinksTable extends RecurringTaskFactorLinks
    with TableInfo<$RecurringTaskFactorLinksTable, RecurringTaskFactorLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTaskFactorLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recurringTaskIdMeta =
      const VerificationMeta('recurringTaskId');
  @override
  late final GeneratedColumn<String> recurringTaskId = GeneratedColumn<String>(
      'recurring_task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_tasks (id)'));
  static const VerificationMeta _factorIdMeta =
      const VerificationMeta('factorId');
  @override
  late final GeneratedColumn<String> factorId = GeneratedColumn<String>(
      'factor_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES factors (id)'));
  @override
  List<GeneratedColumn> get $columns => [recurringTaskId, factorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_task_factor_links';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecurringTaskFactorLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recurring_task_id')) {
      context.handle(
          _recurringTaskIdMeta,
          recurringTaskId.isAcceptableOrUnknown(
              data['recurring_task_id']!, _recurringTaskIdMeta));
    } else if (isInserting) {
      context.missing(_recurringTaskIdMeta);
    }
    if (data.containsKey('factor_id')) {
      context.handle(_factorIdMeta,
          factorId.isAcceptableOrUnknown(data['factor_id']!, _factorIdMeta));
    } else if (isInserting) {
      context.missing(_factorIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recurringTaskId, factorId};
  @override
  RecurringTaskFactorLink map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTaskFactorLink(
      recurringTaskId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurring_task_id'])!,
      factorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}factor_id'])!,
    );
  }

  @override
  $RecurringTaskFactorLinksTable createAlias(String alias) {
    return $RecurringTaskFactorLinksTable(attachedDatabase, alias);
  }
}

class RecurringTaskFactorLink extends DataClass
    implements Insertable<RecurringTaskFactorLink> {
  final String recurringTaskId;
  final String factorId;
  const RecurringTaskFactorLink(
      {required this.recurringTaskId, required this.factorId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recurring_task_id'] = Variable<String>(recurringTaskId);
    map['factor_id'] = Variable<String>(factorId);
    return map;
  }

  RecurringTaskFactorLinksCompanion toCompanion(bool nullToAbsent) {
    return RecurringTaskFactorLinksCompanion(
      recurringTaskId: Value(recurringTaskId),
      factorId: Value(factorId),
    );
  }

  factory RecurringTaskFactorLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTaskFactorLink(
      recurringTaskId: serializer.fromJson<String>(json['recurringTaskId']),
      factorId: serializer.fromJson<String>(json['factorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recurringTaskId': serializer.toJson<String>(recurringTaskId),
      'factorId': serializer.toJson<String>(factorId),
    };
  }

  RecurringTaskFactorLink copyWith(
          {String? recurringTaskId, String? factorId}) =>
      RecurringTaskFactorLink(
        recurringTaskId: recurringTaskId ?? this.recurringTaskId,
        factorId: factorId ?? this.factorId,
      );
  RecurringTaskFactorLink copyWithCompanion(
      RecurringTaskFactorLinksCompanion data) {
    return RecurringTaskFactorLink(
      recurringTaskId: data.recurringTaskId.present
          ? data.recurringTaskId.value
          : this.recurringTaskId,
      factorId: data.factorId.present ? data.factorId.value : this.factorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTaskFactorLink(')
          ..write('recurringTaskId: $recurringTaskId, ')
          ..write('factorId: $factorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(recurringTaskId, factorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTaskFactorLink &&
          other.recurringTaskId == this.recurringTaskId &&
          other.factorId == this.factorId);
}

class RecurringTaskFactorLinksCompanion
    extends UpdateCompanion<RecurringTaskFactorLink> {
  final Value<String> recurringTaskId;
  final Value<String> factorId;
  final Value<int> rowid;
  const RecurringTaskFactorLinksCompanion({
    this.recurringTaskId = const Value.absent(),
    this.factorId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTaskFactorLinksCompanion.insert({
    required String recurringTaskId,
    required String factorId,
    this.rowid = const Value.absent(),
  })  : recurringTaskId = Value(recurringTaskId),
        factorId = Value(factorId);
  static Insertable<RecurringTaskFactorLink> custom({
    Expression<String>? recurringTaskId,
    Expression<String>? factorId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recurringTaskId != null) 'recurring_task_id': recurringTaskId,
      if (factorId != null) 'factor_id': factorId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTaskFactorLinksCompanion copyWith(
      {Value<String>? recurringTaskId,
      Value<String>? factorId,
      Value<int>? rowid}) {
    return RecurringTaskFactorLinksCompanion(
      recurringTaskId: recurringTaskId ?? this.recurringTaskId,
      factorId: factorId ?? this.factorId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recurringTaskId.present) {
      map['recurring_task_id'] = Variable<String>(recurringTaskId.value);
    }
    if (factorId.present) {
      map['factor_id'] = Variable<String>(factorId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTaskFactorLinksCompanion(')
          ..write('recurringTaskId: $recurringTaskId, ')
          ..write('factorId: $factorId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTaskLogsTable extends RecurringTaskLogs
    with TableInfo<$RecurringTaskLogsTable, RecurringTaskLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTaskLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recurringTaskIdMeta =
      const VerificationMeta('recurringTaskId');
  @override
  late final GeneratedColumn<String> recurringTaskId = GeneratedColumn<String>(
      'recurring_task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_tasks (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checklistCompletedJsonMeta =
      const VerificationMeta('checklistCompletedJson');
  @override
  late final GeneratedColumn<String> checklistCompletedJson =
      GeneratedColumn<String>('checklist_completed_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _numericValueMeta =
      const VerificationMeta('numericValue');
  @override
  late final GeneratedColumn<int> numericValue = GeneratedColumn<int>(
      'numeric_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        recurringTaskId,
        date,
        completed,
        note,
        checklistCompletedJson,
        numericValue
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_task_logs';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecurringTaskLogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recurring_task_id')) {
      context.handle(
          _recurringTaskIdMeta,
          recurringTaskId.isAcceptableOrUnknown(
              data['recurring_task_id']!, _recurringTaskIdMeta));
    } else if (isInserting) {
      context.missing(_recurringTaskIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('checklist_completed_json')) {
      context.handle(
          _checklistCompletedJsonMeta,
          checklistCompletedJson.isAcceptableOrUnknown(
              data['checklist_completed_json']!, _checklistCompletedJsonMeta));
    }
    if (data.containsKey('numeric_value')) {
      context.handle(
          _numericValueMeta,
          numericValue.isAcceptableOrUnknown(
              data['numeric_value']!, _numericValueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTaskLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTaskLogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recurringTaskId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurring_task_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      checklistCompletedJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}checklist_completed_json']),
      numericValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}numeric_value']),
    );
  }

  @override
  $RecurringTaskLogsTable createAlias(String alias) {
    return $RecurringTaskLogsTable(attachedDatabase, alias);
  }
}

class RecurringTaskLogEntry extends DataClass
    implements Insertable<RecurringTaskLogEntry> {
  final int id;
  final String recurringTaskId;
  final DateTime date;
  final bool completed;
  final String? note;
  final String? checklistCompletedJson;
  final int? numericValue;
  const RecurringTaskLogEntry(
      {required this.id,
      required this.recurringTaskId,
      required this.date,
      required this.completed,
      this.note,
      this.checklistCompletedJson,
      this.numericValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recurring_task_id'] = Variable<String>(recurringTaskId);
    map['date'] = Variable<DateTime>(date);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || checklistCompletedJson != null) {
      map['checklist_completed_json'] =
          Variable<String>(checklistCompletedJson);
    }
    if (!nullToAbsent || numericValue != null) {
      map['numeric_value'] = Variable<int>(numericValue);
    }
    return map;
  }

  RecurringTaskLogsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTaskLogsCompanion(
      id: Value(id),
      recurringTaskId: Value(recurringTaskId),
      date: Value(date),
      completed: Value(completed),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      checklistCompletedJson: checklistCompletedJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checklistCompletedJson),
      numericValue: numericValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numericValue),
    );
  }

  factory RecurringTaskLogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTaskLogEntry(
      id: serializer.fromJson<int>(json['id']),
      recurringTaskId: serializer.fromJson<String>(json['recurringTaskId']),
      date: serializer.fromJson<DateTime>(json['date']),
      completed: serializer.fromJson<bool>(json['completed']),
      note: serializer.fromJson<String?>(json['note']),
      checklistCompletedJson:
          serializer.fromJson<String?>(json['checklistCompletedJson']),
      numericValue: serializer.fromJson<int?>(json['numericValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recurringTaskId': serializer.toJson<String>(recurringTaskId),
      'date': serializer.toJson<DateTime>(date),
      'completed': serializer.toJson<bool>(completed),
      'note': serializer.toJson<String?>(note),
      'checklistCompletedJson':
          serializer.toJson<String?>(checklistCompletedJson),
      'numericValue': serializer.toJson<int?>(numericValue),
    };
  }

  RecurringTaskLogEntry copyWith(
          {int? id,
          String? recurringTaskId,
          DateTime? date,
          bool? completed,
          Value<String?> note = const Value.absent(),
          Value<String?> checklistCompletedJson = const Value.absent(),
          Value<int?> numericValue = const Value.absent()}) =>
      RecurringTaskLogEntry(
        id: id ?? this.id,
        recurringTaskId: recurringTaskId ?? this.recurringTaskId,
        date: date ?? this.date,
        completed: completed ?? this.completed,
        note: note.present ? note.value : this.note,
        checklistCompletedJson: checklistCompletedJson.present
            ? checklistCompletedJson.value
            : this.checklistCompletedJson,
        numericValue:
            numericValue.present ? numericValue.value : this.numericValue,
      );
  RecurringTaskLogEntry copyWithCompanion(RecurringTaskLogsCompanion data) {
    return RecurringTaskLogEntry(
      id: data.id.present ? data.id.value : this.id,
      recurringTaskId: data.recurringTaskId.present
          ? data.recurringTaskId.value
          : this.recurringTaskId,
      date: data.date.present ? data.date.value : this.date,
      completed: data.completed.present ? data.completed.value : this.completed,
      note: data.note.present ? data.note.value : this.note,
      checklistCompletedJson: data.checklistCompletedJson.present
          ? data.checklistCompletedJson.value
          : this.checklistCompletedJson,
      numericValue: data.numericValue.present
          ? data.numericValue.value
          : this.numericValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTaskLogEntry(')
          ..write('id: $id, ')
          ..write('recurringTaskId: $recurringTaskId, ')
          ..write('date: $date, ')
          ..write('completed: $completed, ')
          ..write('note: $note, ')
          ..write('checklistCompletedJson: $checklistCompletedJson, ')
          ..write('numericValue: $numericValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recurringTaskId, date, completed, note,
      checklistCompletedJson, numericValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTaskLogEntry &&
          other.id == this.id &&
          other.recurringTaskId == this.recurringTaskId &&
          other.date == this.date &&
          other.completed == this.completed &&
          other.note == this.note &&
          other.checklistCompletedJson == this.checklistCompletedJson &&
          other.numericValue == this.numericValue);
}

class RecurringTaskLogsCompanion
    extends UpdateCompanion<RecurringTaskLogEntry> {
  final Value<int> id;
  final Value<String> recurringTaskId;
  final Value<DateTime> date;
  final Value<bool> completed;
  final Value<String?> note;
  final Value<String?> checklistCompletedJson;
  final Value<int?> numericValue;
  const RecurringTaskLogsCompanion({
    this.id = const Value.absent(),
    this.recurringTaskId = const Value.absent(),
    this.date = const Value.absent(),
    this.completed = const Value.absent(),
    this.note = const Value.absent(),
    this.checklistCompletedJson = const Value.absent(),
    this.numericValue = const Value.absent(),
  });
  RecurringTaskLogsCompanion.insert({
    this.id = const Value.absent(),
    required String recurringTaskId,
    required DateTime date,
    this.completed = const Value.absent(),
    this.note = const Value.absent(),
    this.checklistCompletedJson = const Value.absent(),
    this.numericValue = const Value.absent(),
  })  : recurringTaskId = Value(recurringTaskId),
        date = Value(date);
  static Insertable<RecurringTaskLogEntry> custom({
    Expression<int>? id,
    Expression<String>? recurringTaskId,
    Expression<DateTime>? date,
    Expression<bool>? completed,
    Expression<String>? note,
    Expression<String>? checklistCompletedJson,
    Expression<int>? numericValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recurringTaskId != null) 'recurring_task_id': recurringTaskId,
      if (date != null) 'date': date,
      if (completed != null) 'completed': completed,
      if (note != null) 'note': note,
      if (checklistCompletedJson != null)
        'checklist_completed_json': checklistCompletedJson,
      if (numericValue != null) 'numeric_value': numericValue,
    });
  }

  RecurringTaskLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? recurringTaskId,
      Value<DateTime>? date,
      Value<bool>? completed,
      Value<String?>? note,
      Value<String?>? checklistCompletedJson,
      Value<int?>? numericValue}) {
    return RecurringTaskLogsCompanion(
      id: id ?? this.id,
      recurringTaskId: recurringTaskId ?? this.recurringTaskId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      note: note ?? this.note,
      checklistCompletedJson:
          checklistCompletedJson ?? this.checklistCompletedJson,
      numericValue: numericValue ?? this.numericValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recurringTaskId.present) {
      map['recurring_task_id'] = Variable<String>(recurringTaskId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (checklistCompletedJson.present) {
      map['checklist_completed_json'] =
          Variable<String>(checklistCompletedJson.value);
    }
    if (numericValue.present) {
      map['numeric_value'] = Variable<int>(numericValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTaskLogsCompanion(')
          ..write('id: $id, ')
          ..write('recurringTaskId: $recurringTaskId, ')
          ..write('date: $date, ')
          ..write('completed: $completed, ')
          ..write('note: $note, ')
          ..write('checklistCompletedJson: $checklistCompletedJson, ')
          ..write('numericValue: $numericValue')
          ..write(')'))
        .toString();
  }
}

class $FactorHabitLinksTable extends FactorHabitLinks
    with TableInfo<$FactorHabitLinksTable, FactorHabitLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactorHabitLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _factorIdMeta =
      const VerificationMeta('factorId');
  @override
  late final GeneratedColumn<String> factorId = GeneratedColumn<String>(
      'factor_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES factors (id)'));
  static const VerificationMeta _habitIdMeta =
      const VerificationMeta('habitId');
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
      'habit_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES habits (id)'));
  @override
  List<GeneratedColumn> get $columns => [factorId, habitId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'factor_habit_links';
  @override
  VerificationContext validateIntegrity(Insertable<FactorHabitLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('factor_id')) {
      context.handle(_factorIdMeta,
          factorId.isAcceptableOrUnknown(data['factor_id']!, _factorIdMeta));
    } else if (isInserting) {
      context.missing(_factorIdMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(_habitIdMeta,
          habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta));
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {factorId, habitId};
  @override
  FactorHabitLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FactorHabitLink(
      factorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}factor_id'])!,
      habitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}habit_id'])!,
    );
  }

  @override
  $FactorHabitLinksTable createAlias(String alias) {
    return $FactorHabitLinksTable(attachedDatabase, alias);
  }
}

class FactorHabitLink extends DataClass implements Insertable<FactorHabitLink> {
  final String factorId;
  final String habitId;
  const FactorHabitLink({required this.factorId, required this.habitId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['factor_id'] = Variable<String>(factorId);
    map['habit_id'] = Variable<String>(habitId);
    return map;
  }

  FactorHabitLinksCompanion toCompanion(bool nullToAbsent) {
    return FactorHabitLinksCompanion(
      factorId: Value(factorId),
      habitId: Value(habitId),
    );
  }

  factory FactorHabitLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FactorHabitLink(
      factorId: serializer.fromJson<String>(json['factorId']),
      habitId: serializer.fromJson<String>(json['habitId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'factorId': serializer.toJson<String>(factorId),
      'habitId': serializer.toJson<String>(habitId),
    };
  }

  FactorHabitLink copyWith({String? factorId, String? habitId}) =>
      FactorHabitLink(
        factorId: factorId ?? this.factorId,
        habitId: habitId ?? this.habitId,
      );
  FactorHabitLink copyWithCompanion(FactorHabitLinksCompanion data) {
    return FactorHabitLink(
      factorId: data.factorId.present ? data.factorId.value : this.factorId,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactorHabitLink(')
          ..write('factorId: $factorId, ')
          ..write('habitId: $habitId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(factorId, habitId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactorHabitLink &&
          other.factorId == this.factorId &&
          other.habitId == this.habitId);
}

class FactorHabitLinksCompanion extends UpdateCompanion<FactorHabitLink> {
  final Value<String> factorId;
  final Value<String> habitId;
  final Value<int> rowid;
  const FactorHabitLinksCompanion({
    this.factorId = const Value.absent(),
    this.habitId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FactorHabitLinksCompanion.insert({
    required String factorId,
    required String habitId,
    this.rowid = const Value.absent(),
  })  : factorId = Value(factorId),
        habitId = Value(habitId);
  static Insertable<FactorHabitLink> custom({
    Expression<String>? factorId,
    Expression<String>? habitId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (factorId != null) 'factor_id': factorId,
      if (habitId != null) 'habit_id': habitId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FactorHabitLinksCompanion copyWith(
      {Value<String>? factorId, Value<String>? habitId, Value<int>? rowid}) {
    return FactorHabitLinksCompanion(
      factorId: factorId ?? this.factorId,
      habitId: habitId ?? this.habitId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (factorId.present) {
      map['factor_id'] = Variable<String>(factorId.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactorHabitLinksCompanion(')
          ..write('factorId: $factorId, ')
          ..write('habitId: $habitId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalFactorLinksTable extends GoalFactorLinks
    with TableInfo<$GoalFactorLinksTable, GoalFactorLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalFactorLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
      'goal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES goals (id)'));
  static const VerificationMeta _factorIdMeta =
      const VerificationMeta('factorId');
  @override
  late final GeneratedColumn<String> factorId = GeneratedColumn<String>(
      'factor_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES factors (id)'));
  @override
  List<GeneratedColumn> get $columns => [goalId, factorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_factor_links';
  @override
  VerificationContext validateIntegrity(Insertable<GoalFactorLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('factor_id')) {
      context.handle(_factorIdMeta,
          factorId.isAcceptableOrUnknown(data['factor_id']!, _factorIdMeta));
    } else if (isInserting) {
      context.missing(_factorIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {goalId, factorId};
  @override
  GoalFactorLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalFactorLink(
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal_id'])!,
      factorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}factor_id'])!,
    );
  }

  @override
  $GoalFactorLinksTable createAlias(String alias) {
    return $GoalFactorLinksTable(attachedDatabase, alias);
  }
}

class GoalFactorLink extends DataClass implements Insertable<GoalFactorLink> {
  final String goalId;
  final String factorId;
  const GoalFactorLink({required this.goalId, required this.factorId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['goal_id'] = Variable<String>(goalId);
    map['factor_id'] = Variable<String>(factorId);
    return map;
  }

  GoalFactorLinksCompanion toCompanion(bool nullToAbsent) {
    return GoalFactorLinksCompanion(
      goalId: Value(goalId),
      factorId: Value(factorId),
    );
  }

  factory GoalFactorLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalFactorLink(
      goalId: serializer.fromJson<String>(json['goalId']),
      factorId: serializer.fromJson<String>(json['factorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'goalId': serializer.toJson<String>(goalId),
      'factorId': serializer.toJson<String>(factorId),
    };
  }

  GoalFactorLink copyWith({String? goalId, String? factorId}) => GoalFactorLink(
        goalId: goalId ?? this.goalId,
        factorId: factorId ?? this.factorId,
      );
  GoalFactorLink copyWithCompanion(GoalFactorLinksCompanion data) {
    return GoalFactorLink(
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      factorId: data.factorId.present ? data.factorId.value : this.factorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalFactorLink(')
          ..write('goalId: $goalId, ')
          ..write('factorId: $factorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(goalId, factorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalFactorLink &&
          other.goalId == this.goalId &&
          other.factorId == this.factorId);
}

class GoalFactorLinksCompanion extends UpdateCompanion<GoalFactorLink> {
  final Value<String> goalId;
  final Value<String> factorId;
  final Value<int> rowid;
  const GoalFactorLinksCompanion({
    this.goalId = const Value.absent(),
    this.factorId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalFactorLinksCompanion.insert({
    required String goalId,
    required String factorId,
    this.rowid = const Value.absent(),
  })  : goalId = Value(goalId),
        factorId = Value(factorId);
  static Insertable<GoalFactorLink> custom({
    Expression<String>? goalId,
    Expression<String>? factorId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (goalId != null) 'goal_id': goalId,
      if (factorId != null) 'factor_id': factorId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalFactorLinksCompanion copyWith(
      {Value<String>? goalId, Value<String>? factorId, Value<int>? rowid}) {
    return GoalFactorLinksCompanion(
      goalId: goalId ?? this.goalId,
      factorId: factorId ?? this.factorId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (factorId.present) {
      map['factor_id'] = Variable<String>(factorId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalFactorLinksCompanion(')
          ..write('goalId: $goalId, ')
          ..write('factorId: $factorId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $FactorsTable factors = $FactorsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskFactorLinksTable taskFactorLinks =
      $TaskFactorLinksTable(this);
  late final $SubtasksTable subtasks = $SubtasksTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitLogsTable habitLogs = $HabitLogsTable(this);
  late final $ReflectionsTable reflections = $ReflectionsTable(this);
  late final $ReflectionFactorLinksTable reflectionFactorLinks =
      $ReflectionFactorLinksTable(this);
  late final $ReflectionExperimentLinksTable reflectionExperimentLinks =
      $ReflectionExperimentLinksTable(this);
  late final $ExperimentsTable experiments = $ExperimentsTable(this);
  late final $FocusLogsTable focusLogs = $FocusLogsTable(this);
  late final $ReflectionGroupsTable reflectionGroups =
      $ReflectionGroupsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RecurringTasksTable recurringTasks = $RecurringTasksTable(this);
  late final $RecurringTaskFactorLinksTable recurringTaskFactorLinks =
      $RecurringTaskFactorLinksTable(this);
  late final $RecurringTaskLogsTable recurringTaskLogs =
      $RecurringTaskLogsTable(this);
  late final $FactorHabitLinksTable factorHabitLinks =
      $FactorHabitLinksTable(this);
  late final $GoalFactorLinksTable goalFactorLinks =
      $GoalFactorLinksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        goals,
        factors,
        tasks,
        taskFactorLinks,
        subtasks,
        habits,
        habitLogs,
        reflections,
        reflectionFactorLinks,
        reflectionExperimentLinks,
        experiments,
        focusLogs,
        reflectionGroups,
        categories,
        recurringTasks,
        recurringTaskFactorLinks,
        recurringTaskLogs,
        factorHabitLinks,
        goalFactorLinks
      ];
}

typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  required String id,
  required String title,
  Value<String> description,
  required DateTime targetDate,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<DateTime> targetDate,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalsTable, GoalEntry> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FactorsTable, List<FactorEntry>>
      _factorsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.factors,
              aliasName: $_aliasNameGenerator(db.goals.id, db.factors.goalId));

  $$FactorsTableProcessedTableManager get factorsRefs {
    final manager = $$FactorsTableTableManager($_db, $_db.factors)
        .filter((f) => f.goalId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_factorsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GoalFactorLinksTable, List<GoalFactorLink>>
      _goalFactorLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.goalFactorLinks,
              aliasName:
                  $_aliasNameGenerator(db.goals.id, db.goalFactorLinks.goalId));

  $$GoalFactorLinksTableProcessedTableManager get goalFactorLinksRefs {
    final manager =
        $$GoalFactorLinksTableTableManager($_db, $_db.goalFactorLinks)
            .filter((f) => f.goalId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_goalFactorLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> factorsRefs(
      Expression<bool> Function($$FactorsTableFilterComposer f) f) {
    final $$FactorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.goalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableFilterComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> goalFactorLinksRefs(
      Expression<bool> Function($$GoalFactorLinksTableFilterComposer f) f) {
    final $$GoalFactorLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goalFactorLinks,
        getReferencedColumn: (t) => t.goalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalFactorLinksTableFilterComposer(
              $db: $db,
              $table: $db.goalFactorLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> factorsRefs<T extends Object>(
      Expression<T> Function($$FactorsTableAnnotationComposer a) f) {
    final $$FactorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.goalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableAnnotationComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> goalFactorLinksRefs<T extends Object>(
      Expression<T> Function($$GoalFactorLinksTableAnnotationComposer a) f) {
    final $$GoalFactorLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goalFactorLinks,
        getReferencedColumn: (t) => t.goalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalFactorLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.goalFactorLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalsTable,
    GoalEntry,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (GoalEntry, $$GoalsTableReferences),
    GoalEntry,
    PrefetchHooks Function({bool factorsRefs, bool goalFactorLinksRefs})> {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> targetDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion(
            id: id,
            title: title,
            description: description,
            targetDate: targetDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String> description = const Value.absent(),
            required DateTime targetDate,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion.insert(
            id: id,
            title: title,
            description: description,
            targetDate: targetDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GoalsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {factorsRefs = false, goalFactorLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (factorsRefs) db.factors,
                if (goalFactorLinksRefs) db.goalFactorLinks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (factorsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$GoalsTableReferences._factorsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GoalsTableReferences(db, table, p0).factorsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.goalId == item.id),
                        typedResults: items),
                  if (goalFactorLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$GoalsTableReferences
                            ._goalFactorLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GoalsTableReferences(db, table, p0)
                                .goalFactorLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.goalId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalsTable,
    GoalEntry,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (GoalEntry, $$GoalsTableReferences),
    GoalEntry,
    PrefetchHooks Function({bool factorsRefs, bool goalFactorLinksRefs})>;
typedef $$FactorsTableCreateCompanionBuilder = FactorsCompanion Function({
  required String id,
  required String name,
  required int type,
  Value<int> targetLevel,
  Value<int> currentLevel,
  Value<String> description,
  required String goalId,
  required DateTime lastUpdated,
  Value<String> targetDescription,
  Value<String> currentDescription,
  Value<bool> isActiveFocus,
  Value<DateTime?> lastWorkedOn,
  Value<double> healthPercent,
  Value<int> rowid,
});
typedef $$FactorsTableUpdateCompanionBuilder = FactorsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> type,
  Value<int> targetLevel,
  Value<int> currentLevel,
  Value<String> description,
  Value<String> goalId,
  Value<DateTime> lastUpdated,
  Value<String> targetDescription,
  Value<String> currentDescription,
  Value<bool> isActiveFocus,
  Value<DateTime?> lastWorkedOn,
  Value<double> healthPercent,
  Value<int> rowid,
});

final class $$FactorsTableReferences
    extends BaseReferences<_$AppDatabase, $FactorsTable, FactorEntry> {
  $$FactorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$AppDatabase db) => db.goals
      .createAlias($_aliasNameGenerator(db.factors.goalId, db.goals.id));

  $$GoalsTableProcessedTableManager? get goalId {
    if ($_item.goalId == null) return null;
    final manager = $$GoalsTableTableManager($_db, $_db.goals)
        .filter((f) => f.id($_item.goalId!));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TaskFactorLinksTable, List<TaskFactorLink>>
      _taskFactorLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.taskFactorLinks,
              aliasName: $_aliasNameGenerator(
                  db.factors.id, db.taskFactorLinks.factorId));

  $$TaskFactorLinksTableProcessedTableManager get taskFactorLinksRefs {
    final manager =
        $$TaskFactorLinksTableTableManager($_db, $_db.taskFactorLinks)
            .filter((f) => f.factorId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_taskFactorLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReflectionFactorLinksTable,
      List<ReflectionFactorLink>> _reflectionFactorLinksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.reflectionFactorLinks,
          aliasName: $_aliasNameGenerator(
              db.factors.id, db.reflectionFactorLinks.factorId));

  $$ReflectionFactorLinksTableProcessedTableManager
      get reflectionFactorLinksRefs {
    final manager = $$ReflectionFactorLinksTableTableManager(
            $_db, $_db.reflectionFactorLinks)
        .filter((f) => f.factorId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_reflectionFactorLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecurringTaskFactorLinksTable,
      List<RecurringTaskFactorLink>> _recurringTaskFactorLinksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.recurringTaskFactorLinks,
          aliasName: $_aliasNameGenerator(
              db.factors.id, db.recurringTaskFactorLinks.factorId));

  $$RecurringTaskFactorLinksTableProcessedTableManager
      get recurringTaskFactorLinksRefs {
    final manager = $$RecurringTaskFactorLinksTableTableManager(
            $_db, $_db.recurringTaskFactorLinks)
        .filter((f) => f.factorId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_recurringTaskFactorLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FactorHabitLinksTable, List<FactorHabitLink>>
      _factorHabitLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.factorHabitLinks,
              aliasName: $_aliasNameGenerator(
                  db.factors.id, db.factorHabitLinks.factorId));

  $$FactorHabitLinksTableProcessedTableManager get factorHabitLinksRefs {
    final manager =
        $$FactorHabitLinksTableTableManager($_db, $_db.factorHabitLinks)
            .filter((f) => f.factorId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_factorHabitLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GoalFactorLinksTable, List<GoalFactorLink>>
      _goalFactorLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.goalFactorLinks,
              aliasName: $_aliasNameGenerator(
                  db.factors.id, db.goalFactorLinks.factorId));

  $$GoalFactorLinksTableProcessedTableManager get goalFactorLinksRefs {
    final manager =
        $$GoalFactorLinksTableTableManager($_db, $_db.goalFactorLinks)
            .filter((f) => f.factorId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_goalFactorLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FactorsTableFilterComposer
    extends Composer<_$AppDatabase, $FactorsTable> {
  $$FactorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetLevel => $composableBuilder(
      column: $table.targetLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentLevel => $composableBuilder(
      column: $table.currentLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetDescription => $composableBuilder(
      column: $table.targetDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentDescription => $composableBuilder(
      column: $table.currentDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActiveFocus => $composableBuilder(
      column: $table.isActiveFocus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastWorkedOn => $composableBuilder(
      column: $table.lastWorkedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get healthPercent => $composableBuilder(
      column: $table.healthPercent, builder: (column) => ColumnFilters(column));

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.goals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalsTableFilterComposer(
              $db: $db,
              $table: $db.goals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> taskFactorLinksRefs(
      Expression<bool> Function($$TaskFactorLinksTableFilterComposer f) f) {
    final $$TaskFactorLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskFactorLinks,
        getReferencedColumn: (t) => t.factorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskFactorLinksTableFilterComposer(
              $db: $db,
              $table: $db.taskFactorLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> reflectionFactorLinksRefs(
      Expression<bool> Function($$ReflectionFactorLinksTableFilterComposer f)
          f) {
    final $$ReflectionFactorLinksTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.reflectionFactorLinks,
            getReferencedColumn: (t) => t.factorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ReflectionFactorLinksTableFilterComposer(
                  $db: $db,
                  $table: $db.reflectionFactorLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> recurringTaskFactorLinksRefs(
      Expression<bool> Function($$RecurringTaskFactorLinksTableFilterComposer f)
          f) {
    final $$RecurringTaskFactorLinksTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTaskFactorLinks,
            getReferencedColumn: (t) => t.factorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTaskFactorLinksTableFilterComposer(
                  $db: $db,
                  $table: $db.recurringTaskFactorLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> factorHabitLinksRefs(
      Expression<bool> Function($$FactorHabitLinksTableFilterComposer f) f) {
    final $$FactorHabitLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.factorHabitLinks,
        getReferencedColumn: (t) => t.factorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorHabitLinksTableFilterComposer(
              $db: $db,
              $table: $db.factorHabitLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> goalFactorLinksRefs(
      Expression<bool> Function($$GoalFactorLinksTableFilterComposer f) f) {
    final $$GoalFactorLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goalFactorLinks,
        getReferencedColumn: (t) => t.factorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalFactorLinksTableFilterComposer(
              $db: $db,
              $table: $db.goalFactorLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FactorsTableOrderingComposer
    extends Composer<_$AppDatabase, $FactorsTable> {
  $$FactorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetLevel => $composableBuilder(
      column: $table.targetLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentLevel => $composableBuilder(
      column: $table.currentLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetDescription => $composableBuilder(
      column: $table.targetDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentDescription => $composableBuilder(
      column: $table.currentDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActiveFocus => $composableBuilder(
      column: $table.isActiveFocus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastWorkedOn => $composableBuilder(
      column: $table.lastWorkedOn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get healthPercent => $composableBuilder(
      column: $table.healthPercent,
      builder: (column) => ColumnOrderings(column));

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.goals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalsTableOrderingComposer(
              $db: $db,
              $table: $db.goals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FactorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactorsTable> {
  $$FactorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get targetLevel => $composableBuilder(
      column: $table.targetLevel, builder: (column) => column);

  GeneratedColumn<int> get currentLevel => $composableBuilder(
      column: $table.currentLevel, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<String> get targetDescription => $composableBuilder(
      column: $table.targetDescription, builder: (column) => column);

  GeneratedColumn<String> get currentDescription => $composableBuilder(
      column: $table.currentDescription, builder: (column) => column);

  GeneratedColumn<bool> get isActiveFocus => $composableBuilder(
      column: $table.isActiveFocus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastWorkedOn => $composableBuilder(
      column: $table.lastWorkedOn, builder: (column) => column);

  GeneratedColumn<double> get healthPercent => $composableBuilder(
      column: $table.healthPercent, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.goals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalsTableAnnotationComposer(
              $db: $db,
              $table: $db.goals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> taskFactorLinksRefs<T extends Object>(
      Expression<T> Function($$TaskFactorLinksTableAnnotationComposer a) f) {
    final $$TaskFactorLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskFactorLinks,
        getReferencedColumn: (t) => t.factorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskFactorLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.taskFactorLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> reflectionFactorLinksRefs<T extends Object>(
      Expression<T> Function($$ReflectionFactorLinksTableAnnotationComposer a)
          f) {
    final $$ReflectionFactorLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.reflectionFactorLinks,
            getReferencedColumn: (t) => t.factorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ReflectionFactorLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.reflectionFactorLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> recurringTaskFactorLinksRefs<T extends Object>(
      Expression<T> Function(
              $$RecurringTaskFactorLinksTableAnnotationComposer a)
          f) {
    final $$RecurringTaskFactorLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTaskFactorLinks,
            getReferencedColumn: (t) => t.factorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTaskFactorLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTaskFactorLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> factorHabitLinksRefs<T extends Object>(
      Expression<T> Function($$FactorHabitLinksTableAnnotationComposer a) f) {
    final $$FactorHabitLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.factorHabitLinks,
        getReferencedColumn: (t) => t.factorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorHabitLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.factorHabitLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> goalFactorLinksRefs<T extends Object>(
      Expression<T> Function($$GoalFactorLinksTableAnnotationComposer a) f) {
    final $$GoalFactorLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goalFactorLinks,
        getReferencedColumn: (t) => t.factorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalFactorLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.goalFactorLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FactorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FactorsTable,
    FactorEntry,
    $$FactorsTableFilterComposer,
    $$FactorsTableOrderingComposer,
    $$FactorsTableAnnotationComposer,
    $$FactorsTableCreateCompanionBuilder,
    $$FactorsTableUpdateCompanionBuilder,
    (FactorEntry, $$FactorsTableReferences),
    FactorEntry,
    PrefetchHooks Function(
        {bool goalId,
        bool taskFactorLinksRefs,
        bool reflectionFactorLinksRefs,
        bool recurringTaskFactorLinksRefs,
        bool factorHabitLinksRefs,
        bool goalFactorLinksRefs})> {
  $$FactorsTableTableManager(_$AppDatabase db, $FactorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<int> targetLevel = const Value.absent(),
            Value<int> currentLevel = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> goalId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<String> targetDescription = const Value.absent(),
            Value<String> currentDescription = const Value.absent(),
            Value<bool> isActiveFocus = const Value.absent(),
            Value<DateTime?> lastWorkedOn = const Value.absent(),
            Value<double> healthPercent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FactorsCompanion(
            id: id,
            name: name,
            type: type,
            targetLevel: targetLevel,
            currentLevel: currentLevel,
            description: description,
            goalId: goalId,
            lastUpdated: lastUpdated,
            targetDescription: targetDescription,
            currentDescription: currentDescription,
            isActiveFocus: isActiveFocus,
            lastWorkedOn: lastWorkedOn,
            healthPercent: healthPercent,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int type,
            Value<int> targetLevel = const Value.absent(),
            Value<int> currentLevel = const Value.absent(),
            Value<String> description = const Value.absent(),
            required String goalId,
            required DateTime lastUpdated,
            Value<String> targetDescription = const Value.absent(),
            Value<String> currentDescription = const Value.absent(),
            Value<bool> isActiveFocus = const Value.absent(),
            Value<DateTime?> lastWorkedOn = const Value.absent(),
            Value<double> healthPercent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FactorsCompanion.insert(
            id: id,
            name: name,
            type: type,
            targetLevel: targetLevel,
            currentLevel: currentLevel,
            description: description,
            goalId: goalId,
            lastUpdated: lastUpdated,
            targetDescription: targetDescription,
            currentDescription: currentDescription,
            isActiveFocus: isActiveFocus,
            lastWorkedOn: lastWorkedOn,
            healthPercent: healthPercent,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$FactorsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {goalId = false,
              taskFactorLinksRefs = false,
              reflectionFactorLinksRefs = false,
              recurringTaskFactorLinksRefs = false,
              factorHabitLinksRefs = false,
              goalFactorLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (taskFactorLinksRefs) db.taskFactorLinks,
                if (reflectionFactorLinksRefs) db.reflectionFactorLinks,
                if (recurringTaskFactorLinksRefs) db.recurringTaskFactorLinks,
                if (factorHabitLinksRefs) db.factorHabitLinks,
                if (goalFactorLinksRefs) db.goalFactorLinks
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (goalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.goalId,
                    referencedTable: $$FactorsTableReferences._goalIdTable(db),
                    referencedColumn:
                        $$FactorsTableReferences._goalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskFactorLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$FactorsTableReferences
                            ._taskFactorLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FactorsTableReferences(db, table, p0)
                                .taskFactorLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.factorId == item.id),
                        typedResults: items),
                  if (reflectionFactorLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$FactorsTableReferences
                            ._reflectionFactorLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FactorsTableReferences(db, table, p0)
                                .reflectionFactorLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.factorId == item.id),
                        typedResults: items),
                  if (recurringTaskFactorLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$FactorsTableReferences
                            ._recurringTaskFactorLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FactorsTableReferences(db, table, p0)
                                .recurringTaskFactorLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.factorId == item.id),
                        typedResults: items),
                  if (factorHabitLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$FactorsTableReferences
                            ._factorHabitLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FactorsTableReferences(db, table, p0)
                                .factorHabitLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.factorId == item.id),
                        typedResults: items),
                  if (goalFactorLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$FactorsTableReferences
                            ._goalFactorLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FactorsTableReferences(db, table, p0)
                                .goalFactorLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.factorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$FactorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FactorsTable,
    FactorEntry,
    $$FactorsTableFilterComposer,
    $$FactorsTableOrderingComposer,
    $$FactorsTableAnnotationComposer,
    $$FactorsTableCreateCompanionBuilder,
    $$FactorsTableUpdateCompanionBuilder,
    (FactorEntry, $$FactorsTableReferences),
    FactorEntry,
    PrefetchHooks Function(
        {bool goalId,
        bool taskFactorLinksRefs,
        bool reflectionFactorLinksRefs,
        bool recurringTaskFactorLinksRefs,
        bool factorHabitLinksRefs,
        bool goalFactorLinksRefs})>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String title,
  Value<String> description,
  Value<bool> isPriority,
  Value<bool> isCompleted,
  required int source,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<String?> experimentId,
  Value<int> sortOrder,
  required int effort,
  required int impact,
  Value<DateTime?> addedToPriorityAt,
  Value<int?> abandonReason,
  Value<String?> blockedByTaskId,
  Value<String> category,
  Value<DateTime?> deadline,
  Value<String?> customTag,
  Value<String?> marginalGainDescription,
  Value<bool> isResearchTask,
  Value<String?> categoryId,
  Value<String?> checklistItemsJson,
  Value<String?> checklistCompletedJson,
  Value<int> priorityLevel,
  Value<String?> note,
  Value<bool> isPending,
  Value<String> reminderTimesJson,
  required DateTime scheduledDate,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<bool> isPriority,
  Value<bool> isCompleted,
  Value<int> source,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<String?> experimentId,
  Value<int> sortOrder,
  Value<int> effort,
  Value<int> impact,
  Value<DateTime?> addedToPriorityAt,
  Value<int?> abandonReason,
  Value<String?> blockedByTaskId,
  Value<String> category,
  Value<DateTime?> deadline,
  Value<String?> customTag,
  Value<String?> marginalGainDescription,
  Value<bool> isResearchTask,
  Value<String?> categoryId,
  Value<String?> checklistItemsJson,
  Value<String?> checklistCompletedJson,
  Value<int> priorityLevel,
  Value<String?> note,
  Value<bool> isPending,
  Value<String> reminderTimesJson,
  Value<DateTime> scheduledDate,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskEntry> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskFactorLinksTable, List<TaskFactorLink>>
      _taskFactorLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.taskFactorLinks,
              aliasName:
                  $_aliasNameGenerator(db.tasks.id, db.taskFactorLinks.taskId));

  $$TaskFactorLinksTableProcessedTableManager get taskFactorLinksRefs {
    final manager =
        $$TaskFactorLinksTableTableManager($_db, $_db.taskFactorLinks)
            .filter((f) => f.taskId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_taskFactorLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SubtasksTable, List<SubtaskEntry>>
      _subtasksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.subtasks,
              aliasName:
                  $_aliasNameGenerator(db.tasks.id, db.subtasks.parentTaskId));

  $$SubtasksTableProcessedTableManager get subtasksRefs {
    final manager = $$SubtasksTableTableManager($_db, $_db.subtasks)
        .filter((f) => f.parentTaskId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_subtasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPriority => $composableBuilder(
      column: $table.isPriority, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get experimentId => $composableBuilder(
      column: $table.experimentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get effort => $composableBuilder(
      column: $table.effort, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get impact => $composableBuilder(
      column: $table.impact, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedToPriorityAt => $composableBuilder(
      column: $table.addedToPriorityAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get abandonReason => $composableBuilder(
      column: $table.abandonReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get blockedByTaskId => $composableBuilder(
      column: $table.blockedByTaskId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customTag => $composableBuilder(
      column: $table.customTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get marginalGainDescription => $composableBuilder(
      column: $table.marginalGainDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isResearchTask => $composableBuilder(
      column: $table.isResearchTask,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checklistItemsJson => $composableBuilder(
      column: $table.checklistItemsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checklistCompletedJson => $composableBuilder(
      column: $table.checklistCompletedJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPending => $composableBuilder(
      column: $table.isPending, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderTimesJson => $composableBuilder(
      column: $table.reminderTimesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => ColumnFilters(column));

  Expression<bool> taskFactorLinksRefs(
      Expression<bool> Function($$TaskFactorLinksTableFilterComposer f) f) {
    final $$TaskFactorLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskFactorLinks,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskFactorLinksTableFilterComposer(
              $db: $db,
              $table: $db.taskFactorLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> subtasksRefs(
      Expression<bool> Function($$SubtasksTableFilterComposer f) f) {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subtasks,
        getReferencedColumn: (t) => t.parentTaskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubtasksTableFilterComposer(
              $db: $db,
              $table: $db.subtasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPriority => $composableBuilder(
      column: $table.isPriority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get experimentId => $composableBuilder(
      column: $table.experimentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get effort => $composableBuilder(
      column: $table.effort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get impact => $composableBuilder(
      column: $table.impact, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedToPriorityAt => $composableBuilder(
      column: $table.addedToPriorityAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get abandonReason => $composableBuilder(
      column: $table.abandonReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blockedByTaskId => $composableBuilder(
      column: $table.blockedByTaskId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customTag => $composableBuilder(
      column: $table.customTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get marginalGainDescription => $composableBuilder(
      column: $table.marginalGainDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isResearchTask => $composableBuilder(
      column: $table.isResearchTask,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checklistItemsJson => $composableBuilder(
      column: $table.checklistItemsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checklistCompletedJson => $composableBuilder(
      column: $table.checklistCompletedJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPending => $composableBuilder(
      column: $table.isPending, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderTimesJson => $composableBuilder(
      column: $table.reminderTimesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate,
      builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isPriority => $composableBuilder(
      column: $table.isPriority, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get experimentId => $composableBuilder(
      column: $table.experimentId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get effort =>
      $composableBuilder(column: $table.effort, builder: (column) => column);

  GeneratedColumn<int> get impact =>
      $composableBuilder(column: $table.impact, builder: (column) => column);

  GeneratedColumn<DateTime> get addedToPriorityAt => $composableBuilder(
      column: $table.addedToPriorityAt, builder: (column) => column);

  GeneratedColumn<int> get abandonReason => $composableBuilder(
      column: $table.abandonReason, builder: (column) => column);

  GeneratedColumn<String> get blockedByTaskId => $composableBuilder(
      column: $table.blockedByTaskId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get customTag =>
      $composableBuilder(column: $table.customTag, builder: (column) => column);

  GeneratedColumn<String> get marginalGainDescription => $composableBuilder(
      column: $table.marginalGainDescription, builder: (column) => column);

  GeneratedColumn<bool> get isResearchTask => $composableBuilder(
      column: $table.isResearchTask, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get checklistItemsJson => $composableBuilder(
      column: $table.checklistItemsJson, builder: (column) => column);

  GeneratedColumn<String> get checklistCompletedJson => $composableBuilder(
      column: $table.checklistCompletedJson, builder: (column) => column);

  GeneratedColumn<int> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isPending =>
      $composableBuilder(column: $table.isPending, builder: (column) => column);

  GeneratedColumn<String> get reminderTimesJson => $composableBuilder(
      column: $table.reminderTimesJson, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => column);

  Expression<T> taskFactorLinksRefs<T extends Object>(
      Expression<T> Function($$TaskFactorLinksTableAnnotationComposer a) f) {
    final $$TaskFactorLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskFactorLinks,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskFactorLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.taskFactorLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> subtasksRefs<T extends Object>(
      Expression<T> Function($$SubtasksTableAnnotationComposer a) f) {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subtasks,
        getReferencedColumn: (t) => t.parentTaskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubtasksTableAnnotationComposer(
              $db: $db,
              $table: $db.subtasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskEntry,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskEntry, $$TasksTableReferences),
    TaskEntry,
    PrefetchHooks Function({bool taskFactorLinksRefs, bool subtasksRefs})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isPriority = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int> source = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> experimentId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> effort = const Value.absent(),
            Value<int> impact = const Value.absent(),
            Value<DateTime?> addedToPriorityAt = const Value.absent(),
            Value<int?> abandonReason = const Value.absent(),
            Value<String?> blockedByTaskId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String?> customTag = const Value.absent(),
            Value<String?> marginalGainDescription = const Value.absent(),
            Value<bool> isResearchTask = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> checklistItemsJson = const Value.absent(),
            Value<String?> checklistCompletedJson = const Value.absent(),
            Value<int> priorityLevel = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> isPending = const Value.absent(),
            Value<String> reminderTimesJson = const Value.absent(),
            Value<DateTime> scheduledDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            title: title,
            description: description,
            isPriority: isPriority,
            isCompleted: isCompleted,
            source: source,
            createdAt: createdAt,
            completedAt: completedAt,
            experimentId: experimentId,
            sortOrder: sortOrder,
            effort: effort,
            impact: impact,
            addedToPriorityAt: addedToPriorityAt,
            abandonReason: abandonReason,
            blockedByTaskId: blockedByTaskId,
            category: category,
            deadline: deadline,
            customTag: customTag,
            marginalGainDescription: marginalGainDescription,
            isResearchTask: isResearchTask,
            categoryId: categoryId,
            checklistItemsJson: checklistItemsJson,
            checklistCompletedJson: checklistCompletedJson,
            priorityLevel: priorityLevel,
            note: note,
            isPending: isPending,
            reminderTimesJson: reminderTimesJson,
            scheduledDate: scheduledDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String> description = const Value.absent(),
            Value<bool> isPriority = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            required int source,
            required DateTime createdAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> experimentId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required int effort,
            required int impact,
            Value<DateTime?> addedToPriorityAt = const Value.absent(),
            Value<int?> abandonReason = const Value.absent(),
            Value<String?> blockedByTaskId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String?> customTag = const Value.absent(),
            Value<String?> marginalGainDescription = const Value.absent(),
            Value<bool> isResearchTask = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> checklistItemsJson = const Value.absent(),
            Value<String?> checklistCompletedJson = const Value.absent(),
            Value<int> priorityLevel = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> isPending = const Value.absent(),
            Value<String> reminderTimesJson = const Value.absent(),
            required DateTime scheduledDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            title: title,
            description: description,
            isPriority: isPriority,
            isCompleted: isCompleted,
            source: source,
            createdAt: createdAt,
            completedAt: completedAt,
            experimentId: experimentId,
            sortOrder: sortOrder,
            effort: effort,
            impact: impact,
            addedToPriorityAt: addedToPriorityAt,
            abandonReason: abandonReason,
            blockedByTaskId: blockedByTaskId,
            category: category,
            deadline: deadline,
            customTag: customTag,
            marginalGainDescription: marginalGainDescription,
            isResearchTask: isResearchTask,
            categoryId: categoryId,
            checklistItemsJson: checklistItemsJson,
            checklistCompletedJson: checklistCompletedJson,
            priorityLevel: priorityLevel,
            note: note,
            isPending: isPending,
            reminderTimesJson: reminderTimesJson,
            scheduledDate: scheduledDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {taskFactorLinksRefs = false, subtasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (taskFactorLinksRefs) db.taskFactorLinks,
                if (subtasksRefs) db.subtasks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskFactorLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$TasksTableReferences
                            ._taskFactorLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .taskFactorLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (subtasksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._subtasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).subtasksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.parentTaskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskEntry,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskEntry, $$TasksTableReferences),
    TaskEntry,
    PrefetchHooks Function({bool taskFactorLinksRefs, bool subtasksRefs})>;
typedef $$TaskFactorLinksTableCreateCompanionBuilder = TaskFactorLinksCompanion
    Function({
  required String taskId,
  required String factorId,
  Value<int> rowid,
});
typedef $$TaskFactorLinksTableUpdateCompanionBuilder = TaskFactorLinksCompanion
    Function({
  Value<String> taskId,
  Value<String> factorId,
  Value<int> rowid,
});

final class $$TaskFactorLinksTableReferences extends BaseReferences<
    _$AppDatabase, $TaskFactorLinksTable, TaskFactorLink> {
  $$TaskFactorLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias(
      $_aliasNameGenerator(db.taskFactorLinks.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager? get taskId {
    if ($_item.taskId == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id($_item.taskId!));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $FactorsTable _factorIdTable(_$AppDatabase db) =>
      db.factors.createAlias(
          $_aliasNameGenerator(db.taskFactorLinks.factorId, db.factors.id));

  $$FactorsTableProcessedTableManager? get factorId {
    if ($_item.factorId == null) return null;
    final manager = $$FactorsTableTableManager($_db, $_db.factors)
        .filter((f) => f.id($_item.factorId!));
    final item = $_typedResult.readTableOrNull(_factorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TaskFactorLinksTableFilterComposer
    extends Composer<_$AppDatabase, $TaskFactorLinksTable> {
  $$TaskFactorLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableFilterComposer get factorId {
    final $$FactorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableFilterComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskFactorLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskFactorLinksTable> {
  $$TaskFactorLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableOrderingComposer get factorId {
    final $$FactorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableOrderingComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskFactorLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskFactorLinksTable> {
  $$TaskFactorLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableAnnotationComposer get factorId {
    final $$FactorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableAnnotationComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskFactorLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskFactorLinksTable,
    TaskFactorLink,
    $$TaskFactorLinksTableFilterComposer,
    $$TaskFactorLinksTableOrderingComposer,
    $$TaskFactorLinksTableAnnotationComposer,
    $$TaskFactorLinksTableCreateCompanionBuilder,
    $$TaskFactorLinksTableUpdateCompanionBuilder,
    (TaskFactorLink, $$TaskFactorLinksTableReferences),
    TaskFactorLink,
    PrefetchHooks Function({bool taskId, bool factorId})> {
  $$TaskFactorLinksTableTableManager(
      _$AppDatabase db, $TaskFactorLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskFactorLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskFactorLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskFactorLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> taskId = const Value.absent(),
            Value<String> factorId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskFactorLinksCompanion(
            taskId: taskId,
            factorId: factorId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String taskId,
            required String factorId,
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskFactorLinksCompanion.insert(
            taskId: taskId,
            factorId: factorId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TaskFactorLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false, factorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$TaskFactorLinksTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$TaskFactorLinksTableReferences._taskIdTable(db).id,
                  ) as T;
                }
                if (factorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.factorId,
                    referencedTable:
                        $$TaskFactorLinksTableReferences._factorIdTable(db),
                    referencedColumn:
                        $$TaskFactorLinksTableReferences._factorIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TaskFactorLinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskFactorLinksTable,
    TaskFactorLink,
    $$TaskFactorLinksTableFilterComposer,
    $$TaskFactorLinksTableOrderingComposer,
    $$TaskFactorLinksTableAnnotationComposer,
    $$TaskFactorLinksTableCreateCompanionBuilder,
    $$TaskFactorLinksTableUpdateCompanionBuilder,
    (TaskFactorLink, $$TaskFactorLinksTableReferences),
    TaskFactorLink,
    PrefetchHooks Function({bool taskId, bool factorId})>;
typedef $$SubtasksTableCreateCompanionBuilder = SubtasksCompanion Function({
  required String id,
  required String title,
  Value<bool> isCompleted,
  required String parentTaskId,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SubtasksTableUpdateCompanionBuilder = SubtasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<bool> isCompleted,
  Value<String> parentTaskId,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SubtasksTableReferences
    extends BaseReferences<_$AppDatabase, $SubtasksTable, SubtaskEntry> {
  $$SubtasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _parentTaskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.subtasks.parentTaskId, db.tasks.id));

  $$TasksTableProcessedTableManager? get parentTaskId {
    if ($_item.parentTaskId == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id($_item.parentTaskId!));
    final item = $_typedResult.readTableOrNull(_parentTaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get parentTaskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentTaskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get parentTaskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentTaskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get parentTaskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentTaskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubtasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubtasksTable,
    SubtaskEntry,
    $$SubtasksTableFilterComposer,
    $$SubtasksTableOrderingComposer,
    $$SubtasksTableAnnotationComposer,
    $$SubtasksTableCreateCompanionBuilder,
    $$SubtasksTableUpdateCompanionBuilder,
    (SubtaskEntry, $$SubtasksTableReferences),
    SubtaskEntry,
    PrefetchHooks Function({bool parentTaskId})> {
  $$SubtasksTableTableManager(_$AppDatabase db, $SubtasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<String> parentTaskId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubtasksCompanion(
            id: id,
            title: title,
            isCompleted: isCompleted,
            parentTaskId: parentTaskId,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<bool> isCompleted = const Value.absent(),
            required String parentTaskId,
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SubtasksCompanion.insert(
            id: id,
            title: title,
            isCompleted: isCompleted,
            parentTaskId: parentTaskId,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SubtasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({parentTaskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (parentTaskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentTaskId,
                    referencedTable:
                        $$SubtasksTableReferences._parentTaskIdTable(db),
                    referencedColumn:
                        $$SubtasksTableReferences._parentTaskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SubtasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubtasksTable,
    SubtaskEntry,
    $$SubtasksTableFilterComposer,
    $$SubtasksTableOrderingComposer,
    $$SubtasksTableAnnotationComposer,
    $$SubtasksTableCreateCompanionBuilder,
    $$SubtasksTableUpdateCompanionBuilder,
    (SubtaskEntry, $$SubtasksTableReferences),
    SubtaskEntry,
    PrefetchHooks Function({bool parentTaskId})>;
typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  required String id,
  required String name,
  required int type,
  Value<String?> triggerResponse,
  Value<int> currentStreak,
  Value<int> bestStreak,
  Value<int> completionCount,
  required DateTime createdAt,
  Value<bool> isActive,
  Value<String?> factorId,
  Value<String> scheduledDaysJson,
  Value<int> targetFrequency,
  Value<String> motivation,
  Value<int?> timerMinutes,
  Value<int> streakFreezes,
  Value<int> freezesUsed,
  Value<String?> categoryId,
  Value<int?> evaluationType,
  Value<int?> frequencyType,
  Value<int?> targetValue,
  Value<String?> unit,
  Value<String?> checklistItemsJson,
  Value<int?> priorityLevel,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String?> reminderTimesJson,
  Value<bool> isArchived,
  Value<int?> daysPerPeriod,
  Value<int?> repeatInterval,
  Value<String?> specificDatesJson,
  Value<String?> description,
  Value<int?> extraGoal,
  Value<int> sortOrder,
  Value<bool> scoringEnabled,
  Value<int> priority,
  Value<int> rowid,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> type,
  Value<String?> triggerResponse,
  Value<int> currentStreak,
  Value<int> bestStreak,
  Value<int> completionCount,
  Value<DateTime> createdAt,
  Value<bool> isActive,
  Value<String?> factorId,
  Value<String> scheduledDaysJson,
  Value<int> targetFrequency,
  Value<String> motivation,
  Value<int?> timerMinutes,
  Value<int> streakFreezes,
  Value<int> freezesUsed,
  Value<String?> categoryId,
  Value<int?> evaluationType,
  Value<int?> frequencyType,
  Value<int?> targetValue,
  Value<String?> unit,
  Value<String?> checklistItemsJson,
  Value<int?> priorityLevel,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String?> reminderTimesJson,
  Value<bool> isArchived,
  Value<int?> daysPerPeriod,
  Value<int?> repeatInterval,
  Value<String?> specificDatesJson,
  Value<String?> description,
  Value<int?> extraGoal,
  Value<int> sortOrder,
  Value<bool> scoringEnabled,
  Value<int> priority,
  Value<int> rowid,
});

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, HabitEntry> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitLogsTable, List<HabitLogEntry>>
      _habitLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.habitLogs,
          aliasName: $_aliasNameGenerator(db.habits.id, db.habitLogs.habitId));

  $$HabitLogsTableProcessedTableManager get habitLogsRefs {
    final manager = $$HabitLogsTableTableManager($_db, $_db.habitLogs)
        .filter((f) => f.habitId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_habitLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FactorHabitLinksTable, List<FactorHabitLink>>
      _factorHabitLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.factorHabitLinks,
              aliasName: $_aliasNameGenerator(
                  db.habits.id, db.factorHabitLinks.habitId));

  $$FactorHabitLinksTableProcessedTableManager get factorHabitLinksRefs {
    final manager =
        $$FactorHabitLinksTableTableManager($_db, $_db.factorHabitLinks)
            .filter((f) => f.habitId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_factorHabitLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggerResponse => $composableBuilder(
      column: $table.triggerResponse,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentStreak => $composableBuilder(
      column: $table.currentStreak, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bestStreak => $composableBuilder(
      column: $table.bestStreak, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completionCount => $composableBuilder(
      column: $table.completionCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get factorId => $composableBuilder(
      column: $table.factorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduledDaysJson => $composableBuilder(
      column: $table.scheduledDaysJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetFrequency => $composableBuilder(
      column: $table.targetFrequency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motivation => $composableBuilder(
      column: $table.motivation, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timerMinutes => $composableBuilder(
      column: $table.timerMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get streakFreezes => $composableBuilder(
      column: $table.streakFreezes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get freezesUsed => $composableBuilder(
      column: $table.freezesUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get evaluationType => $composableBuilder(
      column: $table.evaluationType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get frequencyType => $composableBuilder(
      column: $table.frequencyType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checklistItemsJson => $composableBuilder(
      column: $table.checklistItemsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderTimesJson => $composableBuilder(
      column: $table.reminderTimesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get daysPerPeriod => $composableBuilder(
      column: $table.daysPerPeriod, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repeatInterval => $composableBuilder(
      column: $table.repeatInterval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specificDatesJson => $composableBuilder(
      column: $table.specificDatesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get extraGoal => $composableBuilder(
      column: $table.extraGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get scoringEnabled => $composableBuilder(
      column: $table.scoringEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  Expression<bool> habitLogsRefs(
      Expression<bool> Function($$HabitLogsTableFilterComposer f) f) {
    final $$HabitLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.habitLogs,
        getReferencedColumn: (t) => t.habitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HabitLogsTableFilterComposer(
              $db: $db,
              $table: $db.habitLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> factorHabitLinksRefs(
      Expression<bool> Function($$FactorHabitLinksTableFilterComposer f) f) {
    final $$FactorHabitLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.factorHabitLinks,
        getReferencedColumn: (t) => t.habitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorHabitLinksTableFilterComposer(
              $db: $db,
              $table: $db.factorHabitLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggerResponse => $composableBuilder(
      column: $table.triggerResponse,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentStreak => $composableBuilder(
      column: $table.currentStreak,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bestStreak => $composableBuilder(
      column: $table.bestStreak, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completionCount => $composableBuilder(
      column: $table.completionCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get factorId => $composableBuilder(
      column: $table.factorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduledDaysJson => $composableBuilder(
      column: $table.scheduledDaysJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetFrequency => $composableBuilder(
      column: $table.targetFrequency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motivation => $composableBuilder(
      column: $table.motivation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timerMinutes => $composableBuilder(
      column: $table.timerMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get streakFreezes => $composableBuilder(
      column: $table.streakFreezes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get freezesUsed => $composableBuilder(
      column: $table.freezesUsed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get evaluationType => $composableBuilder(
      column: $table.evaluationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequencyType => $composableBuilder(
      column: $table.frequencyType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checklistItemsJson => $composableBuilder(
      column: $table.checklistItemsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderTimesJson => $composableBuilder(
      column: $table.reminderTimesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get daysPerPeriod => $composableBuilder(
      column: $table.daysPerPeriod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repeatInterval => $composableBuilder(
      column: $table.repeatInterval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specificDatesJson => $composableBuilder(
      column: $table.specificDatesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get extraGoal => $composableBuilder(
      column: $table.extraGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get scoringEnabled => $composableBuilder(
      column: $table.scoringEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get triggerResponse => $composableBuilder(
      column: $table.triggerResponse, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
      column: $table.currentStreak, builder: (column) => column);

  GeneratedColumn<int> get bestStreak => $composableBuilder(
      column: $table.bestStreak, builder: (column) => column);

  GeneratedColumn<int> get completionCount => $composableBuilder(
      column: $table.completionCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get factorId =>
      $composableBuilder(column: $table.factorId, builder: (column) => column);

  GeneratedColumn<String> get scheduledDaysJson => $composableBuilder(
      column: $table.scheduledDaysJson, builder: (column) => column);

  GeneratedColumn<int> get targetFrequency => $composableBuilder(
      column: $table.targetFrequency, builder: (column) => column);

  GeneratedColumn<String> get motivation => $composableBuilder(
      column: $table.motivation, builder: (column) => column);

  GeneratedColumn<int> get timerMinutes => $composableBuilder(
      column: $table.timerMinutes, builder: (column) => column);

  GeneratedColumn<int> get streakFreezes => $composableBuilder(
      column: $table.streakFreezes, builder: (column) => column);

  GeneratedColumn<int> get freezesUsed => $composableBuilder(
      column: $table.freezesUsed, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<int> get evaluationType => $composableBuilder(
      column: $table.evaluationType, builder: (column) => column);

  GeneratedColumn<int> get frequencyType => $composableBuilder(
      column: $table.frequencyType, builder: (column) => column);

  GeneratedColumn<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get checklistItemsJson => $composableBuilder(
      column: $table.checklistItemsJson, builder: (column) => column);

  GeneratedColumn<int> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get reminderTimesJson => $composableBuilder(
      column: $table.reminderTimesJson, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<int> get daysPerPeriod => $composableBuilder(
      column: $table.daysPerPeriod, builder: (column) => column);

  GeneratedColumn<int> get repeatInterval => $composableBuilder(
      column: $table.repeatInterval, builder: (column) => column);

  GeneratedColumn<String> get specificDatesJson => $composableBuilder(
      column: $table.specificDatesJson, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get extraGoal =>
      $composableBuilder(column: $table.extraGoal, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get scoringEnabled => $composableBuilder(
      column: $table.scoringEnabled, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  Expression<T> habitLogsRefs<T extends Object>(
      Expression<T> Function($$HabitLogsTableAnnotationComposer a) f) {
    final $$HabitLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.habitLogs,
        getReferencedColumn: (t) => t.habitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HabitLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.habitLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> factorHabitLinksRefs<T extends Object>(
      Expression<T> Function($$FactorHabitLinksTableAnnotationComposer a) f) {
    final $$FactorHabitLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.factorHabitLinks,
        getReferencedColumn: (t) => t.habitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorHabitLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.factorHabitLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$HabitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HabitsTable,
    HabitEntry,
    $$HabitsTableFilterComposer,
    $$HabitsTableOrderingComposer,
    $$HabitsTableAnnotationComposer,
    $$HabitsTableCreateCompanionBuilder,
    $$HabitsTableUpdateCompanionBuilder,
    (HabitEntry, $$HabitsTableReferences),
    HabitEntry,
    PrefetchHooks Function({bool habitLogsRefs, bool factorHabitLinksRefs})> {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<String?> triggerResponse = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
            Value<int> bestStreak = const Value.absent(),
            Value<int> completionCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> factorId = const Value.absent(),
            Value<String> scheduledDaysJson = const Value.absent(),
            Value<int> targetFrequency = const Value.absent(),
            Value<String> motivation = const Value.absent(),
            Value<int?> timerMinutes = const Value.absent(),
            Value<int> streakFreezes = const Value.absent(),
            Value<int> freezesUsed = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int?> evaluationType = const Value.absent(),
            Value<int?> frequencyType = const Value.absent(),
            Value<int?> targetValue = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String?> checklistItemsJson = const Value.absent(),
            Value<int?> priorityLevel = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String?> reminderTimesJson = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int?> daysPerPeriod = const Value.absent(),
            Value<int?> repeatInterval = const Value.absent(),
            Value<String?> specificDatesJson = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int?> extraGoal = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> scoringEnabled = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HabitsCompanion(
            id: id,
            name: name,
            type: type,
            triggerResponse: triggerResponse,
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            completionCount: completionCount,
            createdAt: createdAt,
            isActive: isActive,
            factorId: factorId,
            scheduledDaysJson: scheduledDaysJson,
            targetFrequency: targetFrequency,
            motivation: motivation,
            timerMinutes: timerMinutes,
            streakFreezes: streakFreezes,
            freezesUsed: freezesUsed,
            categoryId: categoryId,
            evaluationType: evaluationType,
            frequencyType: frequencyType,
            targetValue: targetValue,
            unit: unit,
            checklistItemsJson: checklistItemsJson,
            priorityLevel: priorityLevel,
            startDate: startDate,
            endDate: endDate,
            reminderTimesJson: reminderTimesJson,
            isArchived: isArchived,
            daysPerPeriod: daysPerPeriod,
            repeatInterval: repeatInterval,
            specificDatesJson: specificDatesJson,
            description: description,
            extraGoal: extraGoal,
            sortOrder: sortOrder,
            scoringEnabled: scoringEnabled,
            priority: priority,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int type,
            Value<String?> triggerResponse = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
            Value<int> bestStreak = const Value.absent(),
            Value<int> completionCount = const Value.absent(),
            required DateTime createdAt,
            Value<bool> isActive = const Value.absent(),
            Value<String?> factorId = const Value.absent(),
            Value<String> scheduledDaysJson = const Value.absent(),
            Value<int> targetFrequency = const Value.absent(),
            Value<String> motivation = const Value.absent(),
            Value<int?> timerMinutes = const Value.absent(),
            Value<int> streakFreezes = const Value.absent(),
            Value<int> freezesUsed = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int?> evaluationType = const Value.absent(),
            Value<int?> frequencyType = const Value.absent(),
            Value<int?> targetValue = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String?> checklistItemsJson = const Value.absent(),
            Value<int?> priorityLevel = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String?> reminderTimesJson = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int?> daysPerPeriod = const Value.absent(),
            Value<int?> repeatInterval = const Value.absent(),
            Value<String?> specificDatesJson = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int?> extraGoal = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> scoringEnabled = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HabitsCompanion.insert(
            id: id,
            name: name,
            type: type,
            triggerResponse: triggerResponse,
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            completionCount: completionCount,
            createdAt: createdAt,
            isActive: isActive,
            factorId: factorId,
            scheduledDaysJson: scheduledDaysJson,
            targetFrequency: targetFrequency,
            motivation: motivation,
            timerMinutes: timerMinutes,
            streakFreezes: streakFreezes,
            freezesUsed: freezesUsed,
            categoryId: categoryId,
            evaluationType: evaluationType,
            frequencyType: frequencyType,
            targetValue: targetValue,
            unit: unit,
            checklistItemsJson: checklistItemsJson,
            priorityLevel: priorityLevel,
            startDate: startDate,
            endDate: endDate,
            reminderTimesJson: reminderTimesJson,
            isArchived: isArchived,
            daysPerPeriod: daysPerPeriod,
            repeatInterval: repeatInterval,
            specificDatesJson: specificDatesJson,
            description: description,
            extraGoal: extraGoal,
            sortOrder: sortOrder,
            scoringEnabled: scoringEnabled,
            priority: priority,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$HabitsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {habitLogsRefs = false, factorHabitLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (habitLogsRefs) db.habitLogs,
                if (factorHabitLinksRefs) db.factorHabitLinks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitLogsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$HabitsTableReferences._habitLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HabitsTableReferences(db, table, p0)
                                .habitLogsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.habitId == item.id),
                        typedResults: items),
                  if (factorHabitLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$HabitsTableReferences
                            ._factorHabitLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HabitsTableReferences(db, table, p0)
                                .factorHabitLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.habitId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$HabitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HabitsTable,
    HabitEntry,
    $$HabitsTableFilterComposer,
    $$HabitsTableOrderingComposer,
    $$HabitsTableAnnotationComposer,
    $$HabitsTableCreateCompanionBuilder,
    $$HabitsTableUpdateCompanionBuilder,
    (HabitEntry, $$HabitsTableReferences),
    HabitEntry,
    PrefetchHooks Function({bool habitLogsRefs, bool factorHabitLinksRefs})>;
typedef $$HabitLogsTableCreateCompanionBuilder = HabitLogsCompanion Function({
  Value<int> id,
  required String habitId,
  required DateTime date,
  Value<bool> completed,
  Value<String?> note,
  Value<int?> moodRating,
  Value<String?> barrierTag,
  Value<int?> numericValue,
  Value<String?> checklistCompletedJson,
  Value<int?> timerSeconds,
  Value<int?> score,
});
typedef $$HabitLogsTableUpdateCompanionBuilder = HabitLogsCompanion Function({
  Value<int> id,
  Value<String> habitId,
  Value<DateTime> date,
  Value<bool> completed,
  Value<String?> note,
  Value<int?> moodRating,
  Value<String?> barrierTag,
  Value<int?> numericValue,
  Value<String?> checklistCompletedJson,
  Value<int?> timerSeconds,
  Value<int?> score,
});

final class $$HabitLogsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLogEntry> {
  $$HabitLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) => db.habits
      .createAlias($_aliasNameGenerator(db.habitLogs.habitId, db.habits.id));

  $$HabitsTableProcessedTableManager? get habitId {
    if ($_item.habitId == null) return null;
    final manager = $$HabitsTableTableManager($_db, $_db.habits)
        .filter((f) => f.id($_item.habitId!));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$HabitLogsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get moodRating => $composableBuilder(
      column: $table.moodRating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barrierTag => $composableBuilder(
      column: $table.barrierTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numericValue => $composableBuilder(
      column: $table.numericValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checklistCompletedJson => $composableBuilder(
      column: $table.checklistCompletedJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timerSeconds => $composableBuilder(
      column: $table.timerSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.habitId,
        referencedTable: $db.habits,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HabitsTableFilterComposer(
              $db: $db,
              $table: $db.habits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HabitLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get moodRating => $composableBuilder(
      column: $table.moodRating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barrierTag => $composableBuilder(
      column: $table.barrierTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numericValue => $composableBuilder(
      column: $table.numericValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checklistCompletedJson => $composableBuilder(
      column: $table.checklistCompletedJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timerSeconds => $composableBuilder(
      column: $table.timerSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.habitId,
        referencedTable: $db.habits,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HabitsTableOrderingComposer(
              $db: $db,
              $table: $db.habits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HabitLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get moodRating => $composableBuilder(
      column: $table.moodRating, builder: (column) => column);

  GeneratedColumn<String> get barrierTag => $composableBuilder(
      column: $table.barrierTag, builder: (column) => column);

  GeneratedColumn<int> get numericValue => $composableBuilder(
      column: $table.numericValue, builder: (column) => column);

  GeneratedColumn<String> get checklistCompletedJson => $composableBuilder(
      column: $table.checklistCompletedJson, builder: (column) => column);

  GeneratedColumn<int> get timerSeconds => $composableBuilder(
      column: $table.timerSeconds, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.habitId,
        referencedTable: $db.habits,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HabitsTableAnnotationComposer(
              $db: $db,
              $table: $db.habits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HabitLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HabitLogsTable,
    HabitLogEntry,
    $$HabitLogsTableFilterComposer,
    $$HabitLogsTableOrderingComposer,
    $$HabitLogsTableAnnotationComposer,
    $$HabitLogsTableCreateCompanionBuilder,
    $$HabitLogsTableUpdateCompanionBuilder,
    (HabitLogEntry, $$HabitLogsTableReferences),
    HabitLogEntry,
    PrefetchHooks Function({bool habitId})> {
  $$HabitLogsTableTableManager(_$AppDatabase db, $HabitLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> habitId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int?> moodRating = const Value.absent(),
            Value<String?> barrierTag = const Value.absent(),
            Value<int?> numericValue = const Value.absent(),
            Value<String?> checklistCompletedJson = const Value.absent(),
            Value<int?> timerSeconds = const Value.absent(),
            Value<int?> score = const Value.absent(),
          }) =>
              HabitLogsCompanion(
            id: id,
            habitId: habitId,
            date: date,
            completed: completed,
            note: note,
            moodRating: moodRating,
            barrierTag: barrierTag,
            numericValue: numericValue,
            checklistCompletedJson: checklistCompletedJson,
            timerSeconds: timerSeconds,
            score: score,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String habitId,
            required DateTime date,
            Value<bool> completed = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int?> moodRating = const Value.absent(),
            Value<String?> barrierTag = const Value.absent(),
            Value<int?> numericValue = const Value.absent(),
            Value<String?> checklistCompletedJson = const Value.absent(),
            Value<int?> timerSeconds = const Value.absent(),
            Value<int?> score = const Value.absent(),
          }) =>
              HabitLogsCompanion.insert(
            id: id,
            habitId: habitId,
            date: date,
            completed: completed,
            note: note,
            moodRating: moodRating,
            barrierTag: barrierTag,
            numericValue: numericValue,
            checklistCompletedJson: checklistCompletedJson,
            timerSeconds: timerSeconds,
            score: score,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$HabitLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (habitId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.habitId,
                    referencedTable:
                        $$HabitLogsTableReferences._habitIdTable(db),
                    referencedColumn:
                        $$HabitLogsTableReferences._habitIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$HabitLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HabitLogsTable,
    HabitLogEntry,
    $$HabitLogsTableFilterComposer,
    $$HabitLogsTableOrderingComposer,
    $$HabitLogsTableAnnotationComposer,
    $$HabitLogsTableCreateCompanionBuilder,
    $$HabitLogsTableUpdateCompanionBuilder,
    (HabitLogEntry, $$HabitLogsTableReferences),
    HabitLogEntry,
    PrefetchHooks Function({bool habitId})>;
typedef $$ReflectionsTableCreateCompanionBuilder = ReflectionsCompanion
    Function({
  required String id,
  Value<String> experience,
  Value<String> reflection,
  Value<String> abstraction,
  Value<bool> isFollowUp,
  Value<String?> previousReflectionId,
  required DateTime createdAt,
  Value<String?> rawMarkdown,
  Value<String?> targetFactorId,
  Value<String?> previousExperimentId,
  Value<String?> groupId,
  Value<String?> marginalGainDescription,
  Value<String?> eventSequence,
  Value<String?> feelings,
  Value<String?> difficulties,
  Value<String?> challengeResponse,
  Value<String?> triggers,
  Value<String?> whyBehavior,
  Value<String?> crossLifePatterns,
  Value<bool> isManualEntry,
  Value<int> rowid,
});
typedef $$ReflectionsTableUpdateCompanionBuilder = ReflectionsCompanion
    Function({
  Value<String> id,
  Value<String> experience,
  Value<String> reflection,
  Value<String> abstraction,
  Value<bool> isFollowUp,
  Value<String?> previousReflectionId,
  Value<DateTime> createdAt,
  Value<String?> rawMarkdown,
  Value<String?> targetFactorId,
  Value<String?> previousExperimentId,
  Value<String?> groupId,
  Value<String?> marginalGainDescription,
  Value<String?> eventSequence,
  Value<String?> feelings,
  Value<String?> difficulties,
  Value<String?> challengeResponse,
  Value<String?> triggers,
  Value<String?> whyBehavior,
  Value<String?> crossLifePatterns,
  Value<bool> isManualEntry,
  Value<int> rowid,
});

final class $$ReflectionsTableReferences
    extends BaseReferences<_$AppDatabase, $ReflectionsTable, ReflectionEntry> {
  $$ReflectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReflectionFactorLinksTable,
      List<ReflectionFactorLink>> _reflectionFactorLinksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.reflectionFactorLinks,
          aliasName: $_aliasNameGenerator(
              db.reflections.id, db.reflectionFactorLinks.reflectionId));

  $$ReflectionFactorLinksTableProcessedTableManager
      get reflectionFactorLinksRefs {
    final manager = $$ReflectionFactorLinksTableTableManager(
            $_db, $_db.reflectionFactorLinks)
        .filter((f) => f.reflectionId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_reflectionFactorLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReflectionExperimentLinksTable,
      List<ReflectionExperimentLink>> _reflectionExperimentLinksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.reflectionExperimentLinks,
          aliasName: $_aliasNameGenerator(
              db.reflections.id, db.reflectionExperimentLinks.reflectionId));

  $$ReflectionExperimentLinksTableProcessedTableManager
      get reflectionExperimentLinksRefs {
    final manager = $$ReflectionExperimentLinksTableTableManager(
            $_db, $_db.reflectionExperimentLinks)
        .filter((f) => f.reflectionId.id($_item.id));

    final cache = $_typedResult
        .readTableOrNull(_reflectionExperimentLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ReflectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get experience => $composableBuilder(
      column: $table.experience, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reflection => $composableBuilder(
      column: $table.reflection, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get abstraction => $composableBuilder(
      column: $table.abstraction, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFollowUp => $composableBuilder(
      column: $table.isFollowUp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previousReflectionId => $composableBuilder(
      column: $table.previousReflectionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawMarkdown => $composableBuilder(
      column: $table.rawMarkdown, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetFactorId => $composableBuilder(
      column: $table.targetFactorId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previousExperimentId => $composableBuilder(
      column: $table.previousExperimentId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get marginalGainDescription => $composableBuilder(
      column: $table.marginalGainDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventSequence => $composableBuilder(
      column: $table.eventSequence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feelings => $composableBuilder(
      column: $table.feelings, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulties => $composableBuilder(
      column: $table.difficulties, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get challengeResponse => $composableBuilder(
      column: $table.challengeResponse,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggers => $composableBuilder(
      column: $table.triggers, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get whyBehavior => $composableBuilder(
      column: $table.whyBehavior, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get crossLifePatterns => $composableBuilder(
      column: $table.crossLifePatterns,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManualEntry => $composableBuilder(
      column: $table.isManualEntry, builder: (column) => ColumnFilters(column));

  Expression<bool> reflectionFactorLinksRefs(
      Expression<bool> Function($$ReflectionFactorLinksTableFilterComposer f)
          f) {
    final $$ReflectionFactorLinksTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.reflectionFactorLinks,
            getReferencedColumn: (t) => t.reflectionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ReflectionFactorLinksTableFilterComposer(
                  $db: $db,
                  $table: $db.reflectionFactorLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> reflectionExperimentLinksRefs(
      Expression<bool> Function(
              $$ReflectionExperimentLinksTableFilterComposer f)
          f) {
    final $$ReflectionExperimentLinksTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.reflectionExperimentLinks,
            getReferencedColumn: (t) => t.reflectionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ReflectionExperimentLinksTableFilterComposer(
                  $db: $db,
                  $table: $db.reflectionExperimentLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ReflectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get experience => $composableBuilder(
      column: $table.experience, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reflection => $composableBuilder(
      column: $table.reflection, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get abstraction => $composableBuilder(
      column: $table.abstraction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFollowUp => $composableBuilder(
      column: $table.isFollowUp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previousReflectionId => $composableBuilder(
      column: $table.previousReflectionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawMarkdown => $composableBuilder(
      column: $table.rawMarkdown, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetFactorId => $composableBuilder(
      column: $table.targetFactorId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previousExperimentId => $composableBuilder(
      column: $table.previousExperimentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get marginalGainDescription => $composableBuilder(
      column: $table.marginalGainDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventSequence => $composableBuilder(
      column: $table.eventSequence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feelings => $composableBuilder(
      column: $table.feelings, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulties => $composableBuilder(
      column: $table.difficulties,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get challengeResponse => $composableBuilder(
      column: $table.challengeResponse,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggers => $composableBuilder(
      column: $table.triggers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get whyBehavior => $composableBuilder(
      column: $table.whyBehavior, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get crossLifePatterns => $composableBuilder(
      column: $table.crossLifePatterns,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManualEntry => $composableBuilder(
      column: $table.isManualEntry,
      builder: (column) => ColumnOrderings(column));
}

class $$ReflectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get experience => $composableBuilder(
      column: $table.experience, builder: (column) => column);

  GeneratedColumn<String> get reflection => $composableBuilder(
      column: $table.reflection, builder: (column) => column);

  GeneratedColumn<String> get abstraction => $composableBuilder(
      column: $table.abstraction, builder: (column) => column);

  GeneratedColumn<bool> get isFollowUp => $composableBuilder(
      column: $table.isFollowUp, builder: (column) => column);

  GeneratedColumn<String> get previousReflectionId => $composableBuilder(
      column: $table.previousReflectionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get rawMarkdown => $composableBuilder(
      column: $table.rawMarkdown, builder: (column) => column);

  GeneratedColumn<String> get targetFactorId => $composableBuilder(
      column: $table.targetFactorId, builder: (column) => column);

  GeneratedColumn<String> get previousExperimentId => $composableBuilder(
      column: $table.previousExperimentId, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get marginalGainDescription => $composableBuilder(
      column: $table.marginalGainDescription, builder: (column) => column);

  GeneratedColumn<String> get eventSequence => $composableBuilder(
      column: $table.eventSequence, builder: (column) => column);

  GeneratedColumn<String> get feelings =>
      $composableBuilder(column: $table.feelings, builder: (column) => column);

  GeneratedColumn<String> get difficulties => $composableBuilder(
      column: $table.difficulties, builder: (column) => column);

  GeneratedColumn<String> get challengeResponse => $composableBuilder(
      column: $table.challengeResponse, builder: (column) => column);

  GeneratedColumn<String> get triggers =>
      $composableBuilder(column: $table.triggers, builder: (column) => column);

  GeneratedColumn<String> get whyBehavior => $composableBuilder(
      column: $table.whyBehavior, builder: (column) => column);

  GeneratedColumn<String> get crossLifePatterns => $composableBuilder(
      column: $table.crossLifePatterns, builder: (column) => column);

  GeneratedColumn<bool> get isManualEntry => $composableBuilder(
      column: $table.isManualEntry, builder: (column) => column);

  Expression<T> reflectionFactorLinksRefs<T extends Object>(
      Expression<T> Function($$ReflectionFactorLinksTableAnnotationComposer a)
          f) {
    final $$ReflectionFactorLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.reflectionFactorLinks,
            getReferencedColumn: (t) => t.reflectionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ReflectionFactorLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.reflectionFactorLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> reflectionExperimentLinksRefs<T extends Object>(
      Expression<T> Function(
              $$ReflectionExperimentLinksTableAnnotationComposer a)
          f) {
    final $$ReflectionExperimentLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.reflectionExperimentLinks,
            getReferencedColumn: (t) => t.reflectionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ReflectionExperimentLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.reflectionExperimentLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ReflectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReflectionsTable,
    ReflectionEntry,
    $$ReflectionsTableFilterComposer,
    $$ReflectionsTableOrderingComposer,
    $$ReflectionsTableAnnotationComposer,
    $$ReflectionsTableCreateCompanionBuilder,
    $$ReflectionsTableUpdateCompanionBuilder,
    (ReflectionEntry, $$ReflectionsTableReferences),
    ReflectionEntry,
    PrefetchHooks Function(
        {bool reflectionFactorLinksRefs, bool reflectionExperimentLinksRefs})> {
  $$ReflectionsTableTableManager(_$AppDatabase db, $ReflectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> experience = const Value.absent(),
            Value<String> reflection = const Value.absent(),
            Value<String> abstraction = const Value.absent(),
            Value<bool> isFollowUp = const Value.absent(),
            Value<String?> previousReflectionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> rawMarkdown = const Value.absent(),
            Value<String?> targetFactorId = const Value.absent(),
            Value<String?> previousExperimentId = const Value.absent(),
            Value<String?> groupId = const Value.absent(),
            Value<String?> marginalGainDescription = const Value.absent(),
            Value<String?> eventSequence = const Value.absent(),
            Value<String?> feelings = const Value.absent(),
            Value<String?> difficulties = const Value.absent(),
            Value<String?> challengeResponse = const Value.absent(),
            Value<String?> triggers = const Value.absent(),
            Value<String?> whyBehavior = const Value.absent(),
            Value<String?> crossLifePatterns = const Value.absent(),
            Value<bool> isManualEntry = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReflectionsCompanion(
            id: id,
            experience: experience,
            reflection: reflection,
            abstraction: abstraction,
            isFollowUp: isFollowUp,
            previousReflectionId: previousReflectionId,
            createdAt: createdAt,
            rawMarkdown: rawMarkdown,
            targetFactorId: targetFactorId,
            previousExperimentId: previousExperimentId,
            groupId: groupId,
            marginalGainDescription: marginalGainDescription,
            eventSequence: eventSequence,
            feelings: feelings,
            difficulties: difficulties,
            challengeResponse: challengeResponse,
            triggers: triggers,
            whyBehavior: whyBehavior,
            crossLifePatterns: crossLifePatterns,
            isManualEntry: isManualEntry,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> experience = const Value.absent(),
            Value<String> reflection = const Value.absent(),
            Value<String> abstraction = const Value.absent(),
            Value<bool> isFollowUp = const Value.absent(),
            Value<String?> previousReflectionId = const Value.absent(),
            required DateTime createdAt,
            Value<String?> rawMarkdown = const Value.absent(),
            Value<String?> targetFactorId = const Value.absent(),
            Value<String?> previousExperimentId = const Value.absent(),
            Value<String?> groupId = const Value.absent(),
            Value<String?> marginalGainDescription = const Value.absent(),
            Value<String?> eventSequence = const Value.absent(),
            Value<String?> feelings = const Value.absent(),
            Value<String?> difficulties = const Value.absent(),
            Value<String?> challengeResponse = const Value.absent(),
            Value<String?> triggers = const Value.absent(),
            Value<String?> whyBehavior = const Value.absent(),
            Value<String?> crossLifePatterns = const Value.absent(),
            Value<bool> isManualEntry = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReflectionsCompanion.insert(
            id: id,
            experience: experience,
            reflection: reflection,
            abstraction: abstraction,
            isFollowUp: isFollowUp,
            previousReflectionId: previousReflectionId,
            createdAt: createdAt,
            rawMarkdown: rawMarkdown,
            targetFactorId: targetFactorId,
            previousExperimentId: previousExperimentId,
            groupId: groupId,
            marginalGainDescription: marginalGainDescription,
            eventSequence: eventSequence,
            feelings: feelings,
            difficulties: difficulties,
            challengeResponse: challengeResponse,
            triggers: triggers,
            whyBehavior: whyBehavior,
            crossLifePatterns: crossLifePatterns,
            isManualEntry: isManualEntry,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReflectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {reflectionFactorLinksRefs = false,
              reflectionExperimentLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (reflectionFactorLinksRefs) db.reflectionFactorLinks,
                if (reflectionExperimentLinksRefs) db.reflectionExperimentLinks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reflectionFactorLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ReflectionsTableReferences
                            ._reflectionFactorLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ReflectionsTableReferences(db, table, p0)
                                .reflectionFactorLinksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.reflectionId == item.id),
                        typedResults: items),
                  if (reflectionExperimentLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ReflectionsTableReferences
                            ._reflectionExperimentLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ReflectionsTableReferences(db, table, p0)
                                .reflectionExperimentLinksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.reflectionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ReflectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReflectionsTable,
    ReflectionEntry,
    $$ReflectionsTableFilterComposer,
    $$ReflectionsTableOrderingComposer,
    $$ReflectionsTableAnnotationComposer,
    $$ReflectionsTableCreateCompanionBuilder,
    $$ReflectionsTableUpdateCompanionBuilder,
    (ReflectionEntry, $$ReflectionsTableReferences),
    ReflectionEntry,
    PrefetchHooks Function(
        {bool reflectionFactorLinksRefs, bool reflectionExperimentLinksRefs})>;
typedef $$ReflectionFactorLinksTableCreateCompanionBuilder
    = ReflectionFactorLinksCompanion Function({
  required String reflectionId,
  required String factorId,
  Value<int> rowid,
});
typedef $$ReflectionFactorLinksTableUpdateCompanionBuilder
    = ReflectionFactorLinksCompanion Function({
  Value<String> reflectionId,
  Value<String> factorId,
  Value<int> rowid,
});

final class $$ReflectionFactorLinksTableReferences extends BaseReferences<
    _$AppDatabase, $ReflectionFactorLinksTable, ReflectionFactorLink> {
  $$ReflectionFactorLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ReflectionsTable _reflectionIdTable(_$AppDatabase db) =>
      db.reflections.createAlias($_aliasNameGenerator(
          db.reflectionFactorLinks.reflectionId, db.reflections.id));

  $$ReflectionsTableProcessedTableManager? get reflectionId {
    if ($_item.reflectionId == null) return null;
    final manager = $$ReflectionsTableTableManager($_db, $_db.reflections)
        .filter((f) => f.id($_item.reflectionId!));
    final item = $_typedResult.readTableOrNull(_reflectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $FactorsTable _factorIdTable(_$AppDatabase db) =>
      db.factors.createAlias($_aliasNameGenerator(
          db.reflectionFactorLinks.factorId, db.factors.id));

  $$FactorsTableProcessedTableManager? get factorId {
    if ($_item.factorId == null) return null;
    final manager = $$FactorsTableTableManager($_db, $_db.factors)
        .filter((f) => f.id($_item.factorId!));
    final item = $_typedResult.readTableOrNull(_factorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReflectionFactorLinksTableFilterComposer
    extends Composer<_$AppDatabase, $ReflectionFactorLinksTable> {
  $$ReflectionFactorLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ReflectionsTableFilterComposer get reflectionId {
    final $$ReflectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reflectionId,
        referencedTable: $db.reflections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReflectionsTableFilterComposer(
              $db: $db,
              $table: $db.reflections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableFilterComposer get factorId {
    final $$FactorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableFilterComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReflectionFactorLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $ReflectionFactorLinksTable> {
  $$ReflectionFactorLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ReflectionsTableOrderingComposer get reflectionId {
    final $$ReflectionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reflectionId,
        referencedTable: $db.reflections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReflectionsTableOrderingComposer(
              $db: $db,
              $table: $db.reflections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableOrderingComposer get factorId {
    final $$FactorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableOrderingComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReflectionFactorLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReflectionFactorLinksTable> {
  $$ReflectionFactorLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ReflectionsTableAnnotationComposer get reflectionId {
    final $$ReflectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reflectionId,
        referencedTable: $db.reflections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReflectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.reflections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableAnnotationComposer get factorId {
    final $$FactorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableAnnotationComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReflectionFactorLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReflectionFactorLinksTable,
    ReflectionFactorLink,
    $$ReflectionFactorLinksTableFilterComposer,
    $$ReflectionFactorLinksTableOrderingComposer,
    $$ReflectionFactorLinksTableAnnotationComposer,
    $$ReflectionFactorLinksTableCreateCompanionBuilder,
    $$ReflectionFactorLinksTableUpdateCompanionBuilder,
    (ReflectionFactorLink, $$ReflectionFactorLinksTableReferences),
    ReflectionFactorLink,
    PrefetchHooks Function({bool reflectionId, bool factorId})> {
  $$ReflectionFactorLinksTableTableManager(
      _$AppDatabase db, $ReflectionFactorLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflectionFactorLinksTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflectionFactorLinksTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflectionFactorLinksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> reflectionId = const Value.absent(),
            Value<String> factorId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReflectionFactorLinksCompanion(
            reflectionId: reflectionId,
            factorId: factorId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String reflectionId,
            required String factorId,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReflectionFactorLinksCompanion.insert(
            reflectionId: reflectionId,
            factorId: factorId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReflectionFactorLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({reflectionId = false, factorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (reflectionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.reflectionId,
                    referencedTable: $$ReflectionFactorLinksTableReferences
                        ._reflectionIdTable(db),
                    referencedColumn: $$ReflectionFactorLinksTableReferences
                        ._reflectionIdTable(db)
                        .id,
                  ) as T;
                }
                if (factorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.factorId,
                    referencedTable: $$ReflectionFactorLinksTableReferences
                        ._factorIdTable(db),
                    referencedColumn: $$ReflectionFactorLinksTableReferences
                        ._factorIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReflectionFactorLinksTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ReflectionFactorLinksTable,
        ReflectionFactorLink,
        $$ReflectionFactorLinksTableFilterComposer,
        $$ReflectionFactorLinksTableOrderingComposer,
        $$ReflectionFactorLinksTableAnnotationComposer,
        $$ReflectionFactorLinksTableCreateCompanionBuilder,
        $$ReflectionFactorLinksTableUpdateCompanionBuilder,
        (ReflectionFactorLink, $$ReflectionFactorLinksTableReferences),
        ReflectionFactorLink,
        PrefetchHooks Function({bool reflectionId, bool factorId})>;
typedef $$ReflectionExperimentLinksTableCreateCompanionBuilder
    = ReflectionExperimentLinksCompanion Function({
  required String reflectionId,
  required String experimentId,
  Value<int> rowid,
});
typedef $$ReflectionExperimentLinksTableUpdateCompanionBuilder
    = ReflectionExperimentLinksCompanion Function({
  Value<String> reflectionId,
  Value<String> experimentId,
  Value<int> rowid,
});

final class $$ReflectionExperimentLinksTableReferences extends BaseReferences<
    _$AppDatabase, $ReflectionExperimentLinksTable, ReflectionExperimentLink> {
  $$ReflectionExperimentLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ReflectionsTable _reflectionIdTable(_$AppDatabase db) =>
      db.reflections.createAlias($_aliasNameGenerator(
          db.reflectionExperimentLinks.reflectionId, db.reflections.id));

  $$ReflectionsTableProcessedTableManager? get reflectionId {
    if ($_item.reflectionId == null) return null;
    final manager = $$ReflectionsTableTableManager($_db, $_db.reflections)
        .filter((f) => f.id($_item.reflectionId!));
    final item = $_typedResult.readTableOrNull(_reflectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReflectionExperimentLinksTableFilterComposer
    extends Composer<_$AppDatabase, $ReflectionExperimentLinksTable> {
  $$ReflectionExperimentLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get experimentId => $composableBuilder(
      column: $table.experimentId, builder: (column) => ColumnFilters(column));

  $$ReflectionsTableFilterComposer get reflectionId {
    final $$ReflectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reflectionId,
        referencedTable: $db.reflections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReflectionsTableFilterComposer(
              $db: $db,
              $table: $db.reflections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReflectionExperimentLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $ReflectionExperimentLinksTable> {
  $$ReflectionExperimentLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get experimentId => $composableBuilder(
      column: $table.experimentId,
      builder: (column) => ColumnOrderings(column));

  $$ReflectionsTableOrderingComposer get reflectionId {
    final $$ReflectionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reflectionId,
        referencedTable: $db.reflections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReflectionsTableOrderingComposer(
              $db: $db,
              $table: $db.reflections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReflectionExperimentLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReflectionExperimentLinksTable> {
  $$ReflectionExperimentLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get experimentId => $composableBuilder(
      column: $table.experimentId, builder: (column) => column);

  $$ReflectionsTableAnnotationComposer get reflectionId {
    final $$ReflectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reflectionId,
        referencedTable: $db.reflections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReflectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.reflections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReflectionExperimentLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReflectionExperimentLinksTable,
    ReflectionExperimentLink,
    $$ReflectionExperimentLinksTableFilterComposer,
    $$ReflectionExperimentLinksTableOrderingComposer,
    $$ReflectionExperimentLinksTableAnnotationComposer,
    $$ReflectionExperimentLinksTableCreateCompanionBuilder,
    $$ReflectionExperimentLinksTableUpdateCompanionBuilder,
    (ReflectionExperimentLink, $$ReflectionExperimentLinksTableReferences),
    ReflectionExperimentLink,
    PrefetchHooks Function({bool reflectionId})> {
  $$ReflectionExperimentLinksTableTableManager(
      _$AppDatabase db, $ReflectionExperimentLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflectionExperimentLinksTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflectionExperimentLinksTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflectionExperimentLinksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> reflectionId = const Value.absent(),
            Value<String> experimentId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReflectionExperimentLinksCompanion(
            reflectionId: reflectionId,
            experimentId: experimentId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String reflectionId,
            required String experimentId,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReflectionExperimentLinksCompanion.insert(
            reflectionId: reflectionId,
            experimentId: experimentId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReflectionExperimentLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({reflectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (reflectionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.reflectionId,
                    referencedTable: $$ReflectionExperimentLinksTableReferences
                        ._reflectionIdTable(db),
                    referencedColumn: $$ReflectionExperimentLinksTableReferences
                        ._reflectionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReflectionExperimentLinksTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ReflectionExperimentLinksTable,
        ReflectionExperimentLink,
        $$ReflectionExperimentLinksTableFilterComposer,
        $$ReflectionExperimentLinksTableOrderingComposer,
        $$ReflectionExperimentLinksTableAnnotationComposer,
        $$ReflectionExperimentLinksTableCreateCompanionBuilder,
        $$ReflectionExperimentLinksTableUpdateCompanionBuilder,
        (ReflectionExperimentLink, $$ReflectionExperimentLinksTableReferences),
        ReflectionExperimentLink,
        PrefetchHooks Function({bool reflectionId})>;
typedef $$ExperimentsTableCreateCompanionBuilder = ExperimentsCompanion
    Function({
  required String id,
  required String description,
  required int status,
  required String reflectionId,
  required DateTime createdAt,
  Value<String?> groupId,
  Value<int> cycleCount,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$ExperimentsTableUpdateCompanionBuilder = ExperimentsCompanion
    Function({
  Value<String> id,
  Value<String> description,
  Value<int> status,
  Value<String> reflectionId,
  Value<DateTime> createdAt,
  Value<String?> groupId,
  Value<int> cycleCount,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<String?> notes,
  Value<int> rowid,
});

class $$ExperimentsTableFilterComposer
    extends Composer<_$AppDatabase, $ExperimentsTable> {
  $$ExperimentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reflectionId => $composableBuilder(
      column: $table.reflectionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cycleCount => $composableBuilder(
      column: $table.cycleCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$ExperimentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExperimentsTable> {
  $$ExperimentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reflectionId => $composableBuilder(
      column: $table.reflectionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cycleCount => $composableBuilder(
      column: $table.cycleCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$ExperimentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExperimentsTable> {
  $$ExperimentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reflectionId => $composableBuilder(
      column: $table.reflectionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get cycleCount => $composableBuilder(
      column: $table.cycleCount, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ExperimentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExperimentsTable,
    ExperimentEntry,
    $$ExperimentsTableFilterComposer,
    $$ExperimentsTableOrderingComposer,
    $$ExperimentsTableAnnotationComposer,
    $$ExperimentsTableCreateCompanionBuilder,
    $$ExperimentsTableUpdateCompanionBuilder,
    (
      ExperimentEntry,
      BaseReferences<_$AppDatabase, $ExperimentsTable, ExperimentEntry>
    ),
    ExperimentEntry,
    PrefetchHooks Function()> {
  $$ExperimentsTableTableManager(_$AppDatabase db, $ExperimentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExperimentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExperimentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExperimentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<String> reflectionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> groupId = const Value.absent(),
            Value<int> cycleCount = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExperimentsCompanion(
            id: id,
            description: description,
            status: status,
            reflectionId: reflectionId,
            createdAt: createdAt,
            groupId: groupId,
            cycleCount: cycleCount,
            startedAt: startedAt,
            completedAt: completedAt,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String description,
            required int status,
            required String reflectionId,
            required DateTime createdAt,
            Value<String?> groupId = const Value.absent(),
            Value<int> cycleCount = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExperimentsCompanion.insert(
            id: id,
            description: description,
            status: status,
            reflectionId: reflectionId,
            createdAt: createdAt,
            groupId: groupId,
            cycleCount: cycleCount,
            startedAt: startedAt,
            completedAt: completedAt,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExperimentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExperimentsTable,
    ExperimentEntry,
    $$ExperimentsTableFilterComposer,
    $$ExperimentsTableOrderingComposer,
    $$ExperimentsTableAnnotationComposer,
    $$ExperimentsTableCreateCompanionBuilder,
    $$ExperimentsTableUpdateCompanionBuilder,
    (
      ExperimentEntry,
      BaseReferences<_$AppDatabase, $ExperimentsTable, ExperimentEntry>
    ),
    ExperimentEntry,
    PrefetchHooks Function()>;
typedef $$FocusLogsTableCreateCompanionBuilder = FocusLogsCompanion Function({
  required String id,
  required String taskId,
  required String taskTitle,
  required DateTime startTime,
  required int durationSeconds,
  Value<int> completedPomodoros,
  Value<String> distractionsJson,
  Value<int> rowid,
});
typedef $$FocusLogsTableUpdateCompanionBuilder = FocusLogsCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<String> taskTitle,
  Value<DateTime> startTime,
  Value<int> durationSeconds,
  Value<int> completedPomodoros,
  Value<String> distractionsJson,
  Value<int> rowid,
});

class $$FocusLogsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusLogsTable> {
  $$FocusLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskTitle => $composableBuilder(
      column: $table.taskTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedPomodoros => $composableBuilder(
      column: $table.completedPomodoros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get distractionsJson => $composableBuilder(
      column: $table.distractionsJson,
      builder: (column) => ColumnFilters(column));
}

class $$FocusLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusLogsTable> {
  $$FocusLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskTitle => $composableBuilder(
      column: $table.taskTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedPomodoros => $composableBuilder(
      column: $table.completedPomodoros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get distractionsJson => $composableBuilder(
      column: $table.distractionsJson,
      builder: (column) => ColumnOrderings(column));
}

class $$FocusLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusLogsTable> {
  $$FocusLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get taskTitle =>
      $composableBuilder(column: $table.taskTitle, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get completedPomodoros => $composableBuilder(
      column: $table.completedPomodoros, builder: (column) => column);

  GeneratedColumn<String> get distractionsJson => $composableBuilder(
      column: $table.distractionsJson, builder: (column) => column);
}

class $$FocusLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FocusLogsTable,
    FocusLogEntry,
    $$FocusLogsTableFilterComposer,
    $$FocusLogsTableOrderingComposer,
    $$FocusLogsTableAnnotationComposer,
    $$FocusLogsTableCreateCompanionBuilder,
    $$FocusLogsTableUpdateCompanionBuilder,
    (
      FocusLogEntry,
      BaseReferences<_$AppDatabase, $FocusLogsTable, FocusLogEntry>
    ),
    FocusLogEntry,
    PrefetchHooks Function()> {
  $$FocusLogsTableTableManager(_$AppDatabase db, $FocusLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<String> taskTitle = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> completedPomodoros = const Value.absent(),
            Value<String> distractionsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FocusLogsCompanion(
            id: id,
            taskId: taskId,
            taskTitle: taskTitle,
            startTime: startTime,
            durationSeconds: durationSeconds,
            completedPomodoros: completedPomodoros,
            distractionsJson: distractionsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required String taskTitle,
            required DateTime startTime,
            required int durationSeconds,
            Value<int> completedPomodoros = const Value.absent(),
            Value<String> distractionsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FocusLogsCompanion.insert(
            id: id,
            taskId: taskId,
            taskTitle: taskTitle,
            startTime: startTime,
            durationSeconds: durationSeconds,
            completedPomodoros: completedPomodoros,
            distractionsJson: distractionsJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FocusLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FocusLogsTable,
    FocusLogEntry,
    $$FocusLogsTableFilterComposer,
    $$FocusLogsTableOrderingComposer,
    $$FocusLogsTableAnnotationComposer,
    $$FocusLogsTableCreateCompanionBuilder,
    $$FocusLogsTableUpdateCompanionBuilder,
    (
      FocusLogEntry,
      BaseReferences<_$AppDatabase, $FocusLogsTable, FocusLogEntry>
    ),
    FocusLogEntry,
    PrefetchHooks Function()>;
typedef $$ReflectionGroupsTableCreateCompanionBuilder
    = ReflectionGroupsCompanion Function({
  required String id,
  required String title,
  required DateTime createdAt,
  Value<DateTime?> archivedAt,
  Value<String?> targetFactorId,
  Value<int> rowid,
});
typedef $$ReflectionGroupsTableUpdateCompanionBuilder
    = ReflectionGroupsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
  Value<String?> targetFactorId,
  Value<int> rowid,
});

class $$ReflectionGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $ReflectionGroupsTable> {
  $$ReflectionGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetFactorId => $composableBuilder(
      column: $table.targetFactorId,
      builder: (column) => ColumnFilters(column));
}

class $$ReflectionGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReflectionGroupsTable> {
  $$ReflectionGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetFactorId => $composableBuilder(
      column: $table.targetFactorId,
      builder: (column) => ColumnOrderings(column));
}

class $$ReflectionGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReflectionGroupsTable> {
  $$ReflectionGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);

  GeneratedColumn<String> get targetFactorId => $composableBuilder(
      column: $table.targetFactorId, builder: (column) => column);
}

class $$ReflectionGroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReflectionGroupsTable,
    ReflectionGroupEntry,
    $$ReflectionGroupsTableFilterComposer,
    $$ReflectionGroupsTableOrderingComposer,
    $$ReflectionGroupsTableAnnotationComposer,
    $$ReflectionGroupsTableCreateCompanionBuilder,
    $$ReflectionGroupsTableUpdateCompanionBuilder,
    (
      ReflectionGroupEntry,
      BaseReferences<_$AppDatabase, $ReflectionGroupsTable,
          ReflectionGroupEntry>
    ),
    ReflectionGroupEntry,
    PrefetchHooks Function()> {
  $$ReflectionGroupsTableTableManager(
      _$AppDatabase db, $ReflectionGroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflectionGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflectionGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflectionGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<String?> targetFactorId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReflectionGroupsCompanion(
            id: id,
            title: title,
            createdAt: createdAt,
            archivedAt: archivedAt,
            targetFactorId: targetFactorId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required DateTime createdAt,
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<String?> targetFactorId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReflectionGroupsCompanion.insert(
            id: id,
            title: title,
            createdAt: createdAt,
            archivedAt: archivedAt,
            targetFactorId: targetFactorId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReflectionGroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReflectionGroupsTable,
    ReflectionGroupEntry,
    $$ReflectionGroupsTableFilterComposer,
    $$ReflectionGroupsTableOrderingComposer,
    $$ReflectionGroupsTableAnnotationComposer,
    $$ReflectionGroupsTableCreateCompanionBuilder,
    $$ReflectionGroupsTableUpdateCompanionBuilder,
    (
      ReflectionGroupEntry,
      BaseReferences<_$AppDatabase, $ReflectionGroupsTable,
          ReflectionGroupEntry>
    ),
    ReflectionGroupEntry,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  required int iconCodePoint,
  Value<String> iconFontFamily,
  required int colorValue,
  Value<bool> isDefault,
  required DateTime createdAt,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> iconCodePoint,
  Value<String> iconFontFamily,
  Value<int> colorValue,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconFontFamily => $composableBuilder(
      column: $table.iconFontFamily,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconFontFamily => $composableBuilder(
      column: $table.iconFontFamily,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => column);

  GeneratedColumn<String> get iconFontFamily => $composableBuilder(
      column: $table.iconFontFamily, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryEntry,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (
      CategoryEntry,
      BaseReferences<_$AppDatabase, $CategoriesTable, CategoryEntry>
    ),
    CategoryEntry,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> iconCodePoint = const Value.absent(),
            Value<String> iconFontFamily = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            iconCodePoint: iconCodePoint,
            iconFontFamily: iconFontFamily,
            colorValue: colorValue,
            isDefault: isDefault,
            createdAt: createdAt,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int iconCodePoint,
            Value<String> iconFontFamily = const Value.absent(),
            required int colorValue,
            Value<bool> isDefault = const Value.absent(),
            required DateTime createdAt,
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            iconCodePoint: iconCodePoint,
            iconFontFamily: iconFontFamily,
            colorValue: colorValue,
            isDefault: isDefault,
            createdAt: createdAt,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryEntry,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (
      CategoryEntry,
      BaseReferences<_$AppDatabase, $CategoriesTable, CategoryEntry>
    ),
    CategoryEntry,
    PrefetchHooks Function()>;
typedef $$RecurringTasksTableCreateCompanionBuilder = RecurringTasksCompanion
    Function({
  required String id,
  required String name,
  required String categoryId,
  required int evaluationType,
  Value<String?> checklistItemsJson,
  required int frequencyType,
  Value<String> scheduledDaysJson,
  Value<int?> daysPerPeriod,
  Value<int?> repeatInterval,
  Value<String?> specificDatesJson,
  required DateTime startDate,
  Value<DateTime?> endDate,
  Value<String> reminderTimesJson,
  required int priorityLevel,
  Value<String?> description,
  required DateTime createdAt,
  Value<bool> isArchived,
  Value<int> sortOrder,
  Value<int> priority,
  Value<int> rowid,
});
typedef $$RecurringTasksTableUpdateCompanionBuilder = RecurringTasksCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> categoryId,
  Value<int> evaluationType,
  Value<String?> checklistItemsJson,
  Value<int> frequencyType,
  Value<String> scheduledDaysJson,
  Value<int?> daysPerPeriod,
  Value<int?> repeatInterval,
  Value<String?> specificDatesJson,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<String> reminderTimesJson,
  Value<int> priorityLevel,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<bool> isArchived,
  Value<int> sortOrder,
  Value<int> priority,
  Value<int> rowid,
});

final class $$RecurringTasksTableReferences extends BaseReferences<
    _$AppDatabase, $RecurringTasksTable, RecurringTaskEntry> {
  $$RecurringTasksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecurringTaskFactorLinksTable,
      List<RecurringTaskFactorLink>> _recurringTaskFactorLinksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.recurringTaskFactorLinks,
          aliasName: $_aliasNameGenerator(db.recurringTasks.id,
              db.recurringTaskFactorLinks.recurringTaskId));

  $$RecurringTaskFactorLinksTableProcessedTableManager
      get recurringTaskFactorLinksRefs {
    final manager = $$RecurringTaskFactorLinksTableTableManager(
            $_db, $_db.recurringTaskFactorLinks)
        .filter((f) => f.recurringTaskId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_recurringTaskFactorLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecurringTaskLogsTable,
      List<RecurringTaskLogEntry>> _recurringTaskLogsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.recurringTaskLogs,
          aliasName: $_aliasNameGenerator(
              db.recurringTasks.id, db.recurringTaskLogs.recurringTaskId));

  $$RecurringTaskLogsTableProcessedTableManager get recurringTaskLogsRefs {
    final manager =
        $$RecurringTaskLogsTableTableManager($_db, $_db.recurringTaskLogs)
            .filter((f) => f.recurringTaskId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_recurringTaskLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RecurringTasksTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTasksTable> {
  $$RecurringTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get evaluationType => $composableBuilder(
      column: $table.evaluationType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checklistItemsJson => $composableBuilder(
      column: $table.checklistItemsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get frequencyType => $composableBuilder(
      column: $table.frequencyType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduledDaysJson => $composableBuilder(
      column: $table.scheduledDaysJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get daysPerPeriod => $composableBuilder(
      column: $table.daysPerPeriod, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repeatInterval => $composableBuilder(
      column: $table.repeatInterval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specificDatesJson => $composableBuilder(
      column: $table.specificDatesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderTimesJson => $composableBuilder(
      column: $table.reminderTimesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  Expression<bool> recurringTaskFactorLinksRefs(
      Expression<bool> Function($$RecurringTaskFactorLinksTableFilterComposer f)
          f) {
    final $$RecurringTaskFactorLinksTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTaskFactorLinks,
            getReferencedColumn: (t) => t.recurringTaskId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTaskFactorLinksTableFilterComposer(
                  $db: $db,
                  $table: $db.recurringTaskFactorLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> recurringTaskLogsRefs(
      Expression<bool> Function($$RecurringTaskLogsTableFilterComposer f) f) {
    final $$RecurringTaskLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringTaskLogs,
        getReferencedColumn: (t) => t.recurringTaskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTaskLogsTableFilterComposer(
              $db: $db,
              $table: $db.recurringTaskLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecurringTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTasksTable> {
  $$RecurringTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get evaluationType => $composableBuilder(
      column: $table.evaluationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checklistItemsJson => $composableBuilder(
      column: $table.checklistItemsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequencyType => $composableBuilder(
      column: $table.frequencyType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduledDaysJson => $composableBuilder(
      column: $table.scheduledDaysJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get daysPerPeriod => $composableBuilder(
      column: $table.daysPerPeriod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repeatInterval => $composableBuilder(
      column: $table.repeatInterval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specificDatesJson => $composableBuilder(
      column: $table.specificDatesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderTimesJson => $composableBuilder(
      column: $table.reminderTimesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));
}

class $$RecurringTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTasksTable> {
  $$RecurringTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<int> get evaluationType => $composableBuilder(
      column: $table.evaluationType, builder: (column) => column);

  GeneratedColumn<String> get checklistItemsJson => $composableBuilder(
      column: $table.checklistItemsJson, builder: (column) => column);

  GeneratedColumn<int> get frequencyType => $composableBuilder(
      column: $table.frequencyType, builder: (column) => column);

  GeneratedColumn<String> get scheduledDaysJson => $composableBuilder(
      column: $table.scheduledDaysJson, builder: (column) => column);

  GeneratedColumn<int> get daysPerPeriod => $composableBuilder(
      column: $table.daysPerPeriod, builder: (column) => column);

  GeneratedColumn<int> get repeatInterval => $composableBuilder(
      column: $table.repeatInterval, builder: (column) => column);

  GeneratedColumn<String> get specificDatesJson => $composableBuilder(
      column: $table.specificDatesJson, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get reminderTimesJson => $composableBuilder(
      column: $table.reminderTimesJson, builder: (column) => column);

  GeneratedColumn<int> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  Expression<T> recurringTaskFactorLinksRefs<T extends Object>(
      Expression<T> Function(
              $$RecurringTaskFactorLinksTableAnnotationComposer a)
          f) {
    final $$RecurringTaskFactorLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTaskFactorLinks,
            getReferencedColumn: (t) => t.recurringTaskId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTaskFactorLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTaskFactorLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> recurringTaskLogsRefs<T extends Object>(
      Expression<T> Function($$RecurringTaskLogsTableAnnotationComposer a) f) {
    final $$RecurringTaskLogsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTaskLogs,
            getReferencedColumn: (t) => t.recurringTaskId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTaskLogsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTaskLogs,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$RecurringTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringTasksTable,
    RecurringTaskEntry,
    $$RecurringTasksTableFilterComposer,
    $$RecurringTasksTableOrderingComposer,
    $$RecurringTasksTableAnnotationComposer,
    $$RecurringTasksTableCreateCompanionBuilder,
    $$RecurringTasksTableUpdateCompanionBuilder,
    (RecurringTaskEntry, $$RecurringTasksTableReferences),
    RecurringTaskEntry,
    PrefetchHooks Function(
        {bool recurringTaskFactorLinksRefs, bool recurringTaskLogsRefs})> {
  $$RecurringTasksTableTableManager(
      _$AppDatabase db, $RecurringTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<int> evaluationType = const Value.absent(),
            Value<String?> checklistItemsJson = const Value.absent(),
            Value<int> frequencyType = const Value.absent(),
            Value<String> scheduledDaysJson = const Value.absent(),
            Value<int?> daysPerPeriod = const Value.absent(),
            Value<int?> repeatInterval = const Value.absent(),
            Value<String?> specificDatesJson = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String> reminderTimesJson = const Value.absent(),
            Value<int> priorityLevel = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTasksCompanion(
            id: id,
            name: name,
            categoryId: categoryId,
            evaluationType: evaluationType,
            checklistItemsJson: checklistItemsJson,
            frequencyType: frequencyType,
            scheduledDaysJson: scheduledDaysJson,
            daysPerPeriod: daysPerPeriod,
            repeatInterval: repeatInterval,
            specificDatesJson: specificDatesJson,
            startDate: startDate,
            endDate: endDate,
            reminderTimesJson: reminderTimesJson,
            priorityLevel: priorityLevel,
            description: description,
            createdAt: createdAt,
            isArchived: isArchived,
            sortOrder: sortOrder,
            priority: priority,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String categoryId,
            required int evaluationType,
            Value<String?> checklistItemsJson = const Value.absent(),
            required int frequencyType,
            Value<String> scheduledDaysJson = const Value.absent(),
            Value<int?> daysPerPeriod = const Value.absent(),
            Value<int?> repeatInterval = const Value.absent(),
            Value<String?> specificDatesJson = const Value.absent(),
            required DateTime startDate,
            Value<DateTime?> endDate = const Value.absent(),
            Value<String> reminderTimesJson = const Value.absent(),
            required int priorityLevel,
            Value<String?> description = const Value.absent(),
            required DateTime createdAt,
            Value<bool> isArchived = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTasksCompanion.insert(
            id: id,
            name: name,
            categoryId: categoryId,
            evaluationType: evaluationType,
            checklistItemsJson: checklistItemsJson,
            frequencyType: frequencyType,
            scheduledDaysJson: scheduledDaysJson,
            daysPerPeriod: daysPerPeriod,
            repeatInterval: repeatInterval,
            specificDatesJson: specificDatesJson,
            startDate: startDate,
            endDate: endDate,
            reminderTimesJson: reminderTimesJson,
            priorityLevel: priorityLevel,
            description: description,
            createdAt: createdAt,
            isArchived: isArchived,
            sortOrder: sortOrder,
            priority: priority,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringTasksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {recurringTaskFactorLinksRefs = false,
              recurringTaskLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recurringTaskFactorLinksRefs) db.recurringTaskFactorLinks,
                if (recurringTaskLogsRefs) db.recurringTaskLogs
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recurringTaskFactorLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$RecurringTasksTableReferences
                            ._recurringTaskFactorLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurringTasksTableReferences(db, table, p0)
                                .recurringTaskFactorLinksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.recurringTaskId == item.id),
                        typedResults: items),
                  if (recurringTaskLogsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$RecurringTasksTableReferences
                            ._recurringTaskLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurringTasksTableReferences(db, table, p0)
                                .recurringTaskLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.recurringTaskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RecurringTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringTasksTable,
    RecurringTaskEntry,
    $$RecurringTasksTableFilterComposer,
    $$RecurringTasksTableOrderingComposer,
    $$RecurringTasksTableAnnotationComposer,
    $$RecurringTasksTableCreateCompanionBuilder,
    $$RecurringTasksTableUpdateCompanionBuilder,
    (RecurringTaskEntry, $$RecurringTasksTableReferences),
    RecurringTaskEntry,
    PrefetchHooks Function(
        {bool recurringTaskFactorLinksRefs, bool recurringTaskLogsRefs})>;
typedef $$RecurringTaskFactorLinksTableCreateCompanionBuilder
    = RecurringTaskFactorLinksCompanion Function({
  required String recurringTaskId,
  required String factorId,
  Value<int> rowid,
});
typedef $$RecurringTaskFactorLinksTableUpdateCompanionBuilder
    = RecurringTaskFactorLinksCompanion Function({
  Value<String> recurringTaskId,
  Value<String> factorId,
  Value<int> rowid,
});

final class $$RecurringTaskFactorLinksTableReferences extends BaseReferences<
    _$AppDatabase, $RecurringTaskFactorLinksTable, RecurringTaskFactorLink> {
  $$RecurringTaskFactorLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RecurringTasksTable _recurringTaskIdTable(_$AppDatabase db) =>
      db.recurringTasks.createAlias($_aliasNameGenerator(
          db.recurringTaskFactorLinks.recurringTaskId, db.recurringTasks.id));

  $$RecurringTasksTableProcessedTableManager? get recurringTaskId {
    if ($_item.recurringTaskId == null) return null;
    final manager = $$RecurringTasksTableTableManager($_db, $_db.recurringTasks)
        .filter((f) => f.id($_item.recurringTaskId!));
    final item = $_typedResult.readTableOrNull(_recurringTaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $FactorsTable _factorIdTable(_$AppDatabase db) =>
      db.factors.createAlias($_aliasNameGenerator(
          db.recurringTaskFactorLinks.factorId, db.factors.id));

  $$FactorsTableProcessedTableManager? get factorId {
    if ($_item.factorId == null) return null;
    final manager = $$FactorsTableTableManager($_db, $_db.factors)
        .filter((f) => f.id($_item.factorId!));
    final item = $_typedResult.readTableOrNull(_factorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecurringTaskFactorLinksTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTaskFactorLinksTable> {
  $$RecurringTaskFactorLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RecurringTasksTableFilterComposer get recurringTaskId {
    final $$RecurringTasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurringTaskId,
        referencedTable: $db.recurringTasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTasksTableFilterComposer(
              $db: $db,
              $table: $db.recurringTasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableFilterComposer get factorId {
    final $$FactorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableFilterComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTaskFactorLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTaskFactorLinksTable> {
  $$RecurringTaskFactorLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RecurringTasksTableOrderingComposer get recurringTaskId {
    final $$RecurringTasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurringTaskId,
        referencedTable: $db.recurringTasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTasksTableOrderingComposer(
              $db: $db,
              $table: $db.recurringTasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableOrderingComposer get factorId {
    final $$FactorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableOrderingComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTaskFactorLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTaskFactorLinksTable> {
  $$RecurringTaskFactorLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RecurringTasksTableAnnotationComposer get recurringTaskId {
    final $$RecurringTasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurringTaskId,
        referencedTable: $db.recurringTasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTasksTableAnnotationComposer(
              $db: $db,
              $table: $db.recurringTasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableAnnotationComposer get factorId {
    final $$FactorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableAnnotationComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTaskFactorLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringTaskFactorLinksTable,
    RecurringTaskFactorLink,
    $$RecurringTaskFactorLinksTableFilterComposer,
    $$RecurringTaskFactorLinksTableOrderingComposer,
    $$RecurringTaskFactorLinksTableAnnotationComposer,
    $$RecurringTaskFactorLinksTableCreateCompanionBuilder,
    $$RecurringTaskFactorLinksTableUpdateCompanionBuilder,
    (RecurringTaskFactorLink, $$RecurringTaskFactorLinksTableReferences),
    RecurringTaskFactorLink,
    PrefetchHooks Function({bool recurringTaskId, bool factorId})> {
  $$RecurringTaskFactorLinksTableTableManager(
      _$AppDatabase db, $RecurringTaskFactorLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTaskFactorLinksTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringTaskFactorLinksTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringTaskFactorLinksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> recurringTaskId = const Value.absent(),
            Value<String> factorId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTaskFactorLinksCompanion(
            recurringTaskId: recurringTaskId,
            factorId: factorId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String recurringTaskId,
            required String factorId,
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTaskFactorLinksCompanion.insert(
            recurringTaskId: recurringTaskId,
            factorId: factorId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringTaskFactorLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({recurringTaskId = false, factorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (recurringTaskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.recurringTaskId,
                    referencedTable: $$RecurringTaskFactorLinksTableReferences
                        ._recurringTaskIdTable(db),
                    referencedColumn: $$RecurringTaskFactorLinksTableReferences
                        ._recurringTaskIdTable(db)
                        .id,
                  ) as T;
                }
                if (factorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.factorId,
                    referencedTable: $$RecurringTaskFactorLinksTableReferences
                        ._factorIdTable(db),
                    referencedColumn: $$RecurringTaskFactorLinksTableReferences
                        ._factorIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecurringTaskFactorLinksTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RecurringTaskFactorLinksTable,
        RecurringTaskFactorLink,
        $$RecurringTaskFactorLinksTableFilterComposer,
        $$RecurringTaskFactorLinksTableOrderingComposer,
        $$RecurringTaskFactorLinksTableAnnotationComposer,
        $$RecurringTaskFactorLinksTableCreateCompanionBuilder,
        $$RecurringTaskFactorLinksTableUpdateCompanionBuilder,
        (RecurringTaskFactorLink, $$RecurringTaskFactorLinksTableReferences),
        RecurringTaskFactorLink,
        PrefetchHooks Function({bool recurringTaskId, bool factorId})>;
typedef $$RecurringTaskLogsTableCreateCompanionBuilder
    = RecurringTaskLogsCompanion Function({
  Value<int> id,
  required String recurringTaskId,
  required DateTime date,
  Value<bool> completed,
  Value<String?> note,
  Value<String?> checklistCompletedJson,
  Value<int?> numericValue,
});
typedef $$RecurringTaskLogsTableUpdateCompanionBuilder
    = RecurringTaskLogsCompanion Function({
  Value<int> id,
  Value<String> recurringTaskId,
  Value<DateTime> date,
  Value<bool> completed,
  Value<String?> note,
  Value<String?> checklistCompletedJson,
  Value<int?> numericValue,
});

final class $$RecurringTaskLogsTableReferences extends BaseReferences<
    _$AppDatabase, $RecurringTaskLogsTable, RecurringTaskLogEntry> {
  $$RecurringTaskLogsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RecurringTasksTable _recurringTaskIdTable(_$AppDatabase db) =>
      db.recurringTasks.createAlias($_aliasNameGenerator(
          db.recurringTaskLogs.recurringTaskId, db.recurringTasks.id));

  $$RecurringTasksTableProcessedTableManager? get recurringTaskId {
    if ($_item.recurringTaskId == null) return null;
    final manager = $$RecurringTasksTableTableManager($_db, $_db.recurringTasks)
        .filter((f) => f.id($_item.recurringTaskId!));
    final item = $_typedResult.readTableOrNull(_recurringTaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecurringTaskLogsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTaskLogsTable> {
  $$RecurringTaskLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checklistCompletedJson => $composableBuilder(
      column: $table.checklistCompletedJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numericValue => $composableBuilder(
      column: $table.numericValue, builder: (column) => ColumnFilters(column));

  $$RecurringTasksTableFilterComposer get recurringTaskId {
    final $$RecurringTasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurringTaskId,
        referencedTable: $db.recurringTasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTasksTableFilterComposer(
              $db: $db,
              $table: $db.recurringTasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTaskLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTaskLogsTable> {
  $$RecurringTaskLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checklistCompletedJson => $composableBuilder(
      column: $table.checklistCompletedJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numericValue => $composableBuilder(
      column: $table.numericValue,
      builder: (column) => ColumnOrderings(column));

  $$RecurringTasksTableOrderingComposer get recurringTaskId {
    final $$RecurringTasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurringTaskId,
        referencedTable: $db.recurringTasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTasksTableOrderingComposer(
              $db: $db,
              $table: $db.recurringTasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTaskLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTaskLogsTable> {
  $$RecurringTaskLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get checklistCompletedJson => $composableBuilder(
      column: $table.checklistCompletedJson, builder: (column) => column);

  GeneratedColumn<int> get numericValue => $composableBuilder(
      column: $table.numericValue, builder: (column) => column);

  $$RecurringTasksTableAnnotationComposer get recurringTaskId {
    final $$RecurringTasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurringTaskId,
        referencedTable: $db.recurringTasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTasksTableAnnotationComposer(
              $db: $db,
              $table: $db.recurringTasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTaskLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringTaskLogsTable,
    RecurringTaskLogEntry,
    $$RecurringTaskLogsTableFilterComposer,
    $$RecurringTaskLogsTableOrderingComposer,
    $$RecurringTaskLogsTableAnnotationComposer,
    $$RecurringTaskLogsTableCreateCompanionBuilder,
    $$RecurringTaskLogsTableUpdateCompanionBuilder,
    (RecurringTaskLogEntry, $$RecurringTaskLogsTableReferences),
    RecurringTaskLogEntry,
    PrefetchHooks Function({bool recurringTaskId})> {
  $$RecurringTaskLogsTableTableManager(
      _$AppDatabase db, $RecurringTaskLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTaskLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringTaskLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringTaskLogsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> recurringTaskId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> checklistCompletedJson = const Value.absent(),
            Value<int?> numericValue = const Value.absent(),
          }) =>
              RecurringTaskLogsCompanion(
            id: id,
            recurringTaskId: recurringTaskId,
            date: date,
            completed: completed,
            note: note,
            checklistCompletedJson: checklistCompletedJson,
            numericValue: numericValue,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String recurringTaskId,
            required DateTime date,
            Value<bool> completed = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> checklistCompletedJson = const Value.absent(),
            Value<int?> numericValue = const Value.absent(),
          }) =>
              RecurringTaskLogsCompanion.insert(
            id: id,
            recurringTaskId: recurringTaskId,
            date: date,
            completed: completed,
            note: note,
            checklistCompletedJson: checklistCompletedJson,
            numericValue: numericValue,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringTaskLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({recurringTaskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (recurringTaskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.recurringTaskId,
                    referencedTable: $$RecurringTaskLogsTableReferences
                        ._recurringTaskIdTable(db),
                    referencedColumn: $$RecurringTaskLogsTableReferences
                        ._recurringTaskIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecurringTaskLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringTaskLogsTable,
    RecurringTaskLogEntry,
    $$RecurringTaskLogsTableFilterComposer,
    $$RecurringTaskLogsTableOrderingComposer,
    $$RecurringTaskLogsTableAnnotationComposer,
    $$RecurringTaskLogsTableCreateCompanionBuilder,
    $$RecurringTaskLogsTableUpdateCompanionBuilder,
    (RecurringTaskLogEntry, $$RecurringTaskLogsTableReferences),
    RecurringTaskLogEntry,
    PrefetchHooks Function({bool recurringTaskId})>;
typedef $$FactorHabitLinksTableCreateCompanionBuilder
    = FactorHabitLinksCompanion Function({
  required String factorId,
  required String habitId,
  Value<int> rowid,
});
typedef $$FactorHabitLinksTableUpdateCompanionBuilder
    = FactorHabitLinksCompanion Function({
  Value<String> factorId,
  Value<String> habitId,
  Value<int> rowid,
});

final class $$FactorHabitLinksTableReferences extends BaseReferences<
    _$AppDatabase, $FactorHabitLinksTable, FactorHabitLink> {
  $$FactorHabitLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $FactorsTable _factorIdTable(_$AppDatabase db) =>
      db.factors.createAlias(
          $_aliasNameGenerator(db.factorHabitLinks.factorId, db.factors.id));

  $$FactorsTableProcessedTableManager? get factorId {
    if ($_item.factorId == null) return null;
    final manager = $$FactorsTableTableManager($_db, $_db.factors)
        .filter((f) => f.id($_item.factorId!));
    final item = $_typedResult.readTableOrNull(_factorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $HabitsTable _habitIdTable(_$AppDatabase db) => db.habits.createAlias(
      $_aliasNameGenerator(db.factorHabitLinks.habitId, db.habits.id));

  $$HabitsTableProcessedTableManager? get habitId {
    if ($_item.habitId == null) return null;
    final manager = $$HabitsTableTableManager($_db, $_db.habits)
        .filter((f) => f.id($_item.habitId!));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FactorHabitLinksTableFilterComposer
    extends Composer<_$AppDatabase, $FactorHabitLinksTable> {
  $$FactorHabitLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$FactorsTableFilterComposer get factorId {
    final $$FactorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableFilterComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.habitId,
        referencedTable: $db.habits,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HabitsTableFilterComposer(
              $db: $db,
              $table: $db.habits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FactorHabitLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $FactorHabitLinksTable> {
  $$FactorHabitLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$FactorsTableOrderingComposer get factorId {
    final $$FactorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableOrderingComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.habitId,
        referencedTable: $db.habits,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HabitsTableOrderingComposer(
              $db: $db,
              $table: $db.habits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FactorHabitLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactorHabitLinksTable> {
  $$FactorHabitLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$FactorsTableAnnotationComposer get factorId {
    final $$FactorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableAnnotationComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.habitId,
        referencedTable: $db.habits,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HabitsTableAnnotationComposer(
              $db: $db,
              $table: $db.habits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FactorHabitLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FactorHabitLinksTable,
    FactorHabitLink,
    $$FactorHabitLinksTableFilterComposer,
    $$FactorHabitLinksTableOrderingComposer,
    $$FactorHabitLinksTableAnnotationComposer,
    $$FactorHabitLinksTableCreateCompanionBuilder,
    $$FactorHabitLinksTableUpdateCompanionBuilder,
    (FactorHabitLink, $$FactorHabitLinksTableReferences),
    FactorHabitLink,
    PrefetchHooks Function({bool factorId, bool habitId})> {
  $$FactorHabitLinksTableTableManager(
      _$AppDatabase db, $FactorHabitLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactorHabitLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactorHabitLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactorHabitLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> factorId = const Value.absent(),
            Value<String> habitId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FactorHabitLinksCompanion(
            factorId: factorId,
            habitId: habitId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String factorId,
            required String habitId,
            Value<int> rowid = const Value.absent(),
          }) =>
              FactorHabitLinksCompanion.insert(
            factorId: factorId,
            habitId: habitId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FactorHabitLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({factorId = false, habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (factorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.factorId,
                    referencedTable:
                        $$FactorHabitLinksTableReferences._factorIdTable(db),
                    referencedColumn:
                        $$FactorHabitLinksTableReferences._factorIdTable(db).id,
                  ) as T;
                }
                if (habitId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.habitId,
                    referencedTable:
                        $$FactorHabitLinksTableReferences._habitIdTable(db),
                    referencedColumn:
                        $$FactorHabitLinksTableReferences._habitIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FactorHabitLinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FactorHabitLinksTable,
    FactorHabitLink,
    $$FactorHabitLinksTableFilterComposer,
    $$FactorHabitLinksTableOrderingComposer,
    $$FactorHabitLinksTableAnnotationComposer,
    $$FactorHabitLinksTableCreateCompanionBuilder,
    $$FactorHabitLinksTableUpdateCompanionBuilder,
    (FactorHabitLink, $$FactorHabitLinksTableReferences),
    FactorHabitLink,
    PrefetchHooks Function({bool factorId, bool habitId})>;
typedef $$GoalFactorLinksTableCreateCompanionBuilder = GoalFactorLinksCompanion
    Function({
  required String goalId,
  required String factorId,
  Value<int> rowid,
});
typedef $$GoalFactorLinksTableUpdateCompanionBuilder = GoalFactorLinksCompanion
    Function({
  Value<String> goalId,
  Value<String> factorId,
  Value<int> rowid,
});

final class $$GoalFactorLinksTableReferences extends BaseReferences<
    _$AppDatabase, $GoalFactorLinksTable, GoalFactorLink> {
  $$GoalFactorLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$AppDatabase db) => db.goals.createAlias(
      $_aliasNameGenerator(db.goalFactorLinks.goalId, db.goals.id));

  $$GoalsTableProcessedTableManager? get goalId {
    if ($_item.goalId == null) return null;
    final manager = $$GoalsTableTableManager($_db, $_db.goals)
        .filter((f) => f.id($_item.goalId!));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $FactorsTable _factorIdTable(_$AppDatabase db) =>
      db.factors.createAlias(
          $_aliasNameGenerator(db.goalFactorLinks.factorId, db.factors.id));

  $$FactorsTableProcessedTableManager? get factorId {
    if ($_item.factorId == null) return null;
    final manager = $$FactorsTableTableManager($_db, $_db.factors)
        .filter((f) => f.id($_item.factorId!));
    final item = $_typedResult.readTableOrNull(_factorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GoalFactorLinksTableFilterComposer
    extends Composer<_$AppDatabase, $GoalFactorLinksTable> {
  $$GoalFactorLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.goals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalsTableFilterComposer(
              $db: $db,
              $table: $db.goals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableFilterComposer get factorId {
    final $$FactorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableFilterComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalFactorLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalFactorLinksTable> {
  $$GoalFactorLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.goals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalsTableOrderingComposer(
              $db: $db,
              $table: $db.goals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableOrderingComposer get factorId {
    final $$FactorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableOrderingComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalFactorLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalFactorLinksTable> {
  $$GoalFactorLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.goals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalsTableAnnotationComposer(
              $db: $db,
              $table: $db.goals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$FactorsTableAnnotationComposer get factorId {
    final $$FactorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.factorId,
        referencedTable: $db.factors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FactorsTableAnnotationComposer(
              $db: $db,
              $table: $db.factors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalFactorLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalFactorLinksTable,
    GoalFactorLink,
    $$GoalFactorLinksTableFilterComposer,
    $$GoalFactorLinksTableOrderingComposer,
    $$GoalFactorLinksTableAnnotationComposer,
    $$GoalFactorLinksTableCreateCompanionBuilder,
    $$GoalFactorLinksTableUpdateCompanionBuilder,
    (GoalFactorLink, $$GoalFactorLinksTableReferences),
    GoalFactorLink,
    PrefetchHooks Function({bool goalId, bool factorId})> {
  $$GoalFactorLinksTableTableManager(
      _$AppDatabase db, $GoalFactorLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalFactorLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalFactorLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalFactorLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> goalId = const Value.absent(),
            Value<String> factorId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalFactorLinksCompanion(
            goalId: goalId,
            factorId: factorId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String goalId,
            required String factorId,
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalFactorLinksCompanion.insert(
            goalId: goalId,
            factorId: factorId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GoalFactorLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({goalId = false, factorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (goalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.goalId,
                    referencedTable:
                        $$GoalFactorLinksTableReferences._goalIdTable(db),
                    referencedColumn:
                        $$GoalFactorLinksTableReferences._goalIdTable(db).id,
                  ) as T;
                }
                if (factorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.factorId,
                    referencedTable:
                        $$GoalFactorLinksTableReferences._factorIdTable(db),
                    referencedColumn:
                        $$GoalFactorLinksTableReferences._factorIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GoalFactorLinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalFactorLinksTable,
    GoalFactorLink,
    $$GoalFactorLinksTableFilterComposer,
    $$GoalFactorLinksTableOrderingComposer,
    $$GoalFactorLinksTableAnnotationComposer,
    $$GoalFactorLinksTableCreateCompanionBuilder,
    $$GoalFactorLinksTableUpdateCompanionBuilder,
    (GoalFactorLink, $$GoalFactorLinksTableReferences),
    GoalFactorLink,
    PrefetchHooks Function({bool goalId, bool factorId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$FactorsTableTableManager get factors =>
      $$FactorsTableTableManager(_db, _db.factors);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskFactorLinksTableTableManager get taskFactorLinks =>
      $$TaskFactorLinksTableTableManager(_db, _db.taskFactorLinks);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db, _db.subtasks);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitLogsTableTableManager get habitLogs =>
      $$HabitLogsTableTableManager(_db, _db.habitLogs);
  $$ReflectionsTableTableManager get reflections =>
      $$ReflectionsTableTableManager(_db, _db.reflections);
  $$ReflectionFactorLinksTableTableManager get reflectionFactorLinks =>
      $$ReflectionFactorLinksTableTableManager(_db, _db.reflectionFactorLinks);
  $$ReflectionExperimentLinksTableTableManager get reflectionExperimentLinks =>
      $$ReflectionExperimentLinksTableTableManager(
          _db, _db.reflectionExperimentLinks);
  $$ExperimentsTableTableManager get experiments =>
      $$ExperimentsTableTableManager(_db, _db.experiments);
  $$FocusLogsTableTableManager get focusLogs =>
      $$FocusLogsTableTableManager(_db, _db.focusLogs);
  $$ReflectionGroupsTableTableManager get reflectionGroups =>
      $$ReflectionGroupsTableTableManager(_db, _db.reflectionGroups);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RecurringTasksTableTableManager get recurringTasks =>
      $$RecurringTasksTableTableManager(_db, _db.recurringTasks);
  $$RecurringTaskFactorLinksTableTableManager get recurringTaskFactorLinks =>
      $$RecurringTaskFactorLinksTableTableManager(
          _db, _db.recurringTaskFactorLinks);
  $$RecurringTaskLogsTableTableManager get recurringTaskLogs =>
      $$RecurringTaskLogsTableTableManager(_db, _db.recurringTaskLogs);
  $$FactorHabitLinksTableTableManager get factorHabitLinks =>
      $$FactorHabitLinksTableTableManager(_db, _db.factorHabitLinks);
  $$GoalFactorLinksTableTableManager get goalFactorLinks =>
      $$GoalFactorLinksTableTableManager(_db, _db.goalFactorLinks);
}
