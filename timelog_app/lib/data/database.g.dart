// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TimeEntriesTable extends TimeEntries
    with TableInfo<$TimeEntriesTable, TimeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityTypeMeta = const VerificationMeta(
    'activityType',
  );
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Práce'),
  );
  static const VerificationMeta _projectMeta = const VerificationMeta(
    'project',
  );
  @override
  late final GeneratedColumn<String> project = GeneratedColumn<String>(
    'project',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entertainmentTypeMeta = const VerificationMeta(
    'entertainmentType',
  );
  @override
  late final GeneratedColumn<String> entertainmentType =
      GeneratedColumn<String>(
        'entertainment_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _subtypeMeta = const VerificationMeta(
    'subtype',
  );
  @override
  late final GeneratedColumn<String> subtype = GeneratedColumn<String>(
    'subtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTime,
    endTime,
    description,
    activityType,
    project,
    entertainmentType,
    subtype,
    customName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('activity_type')) {
      context.handle(
        _activityTypeMeta,
        activityType.isAcceptableOrUnknown(
          data['activity_type']!,
          _activityTypeMeta,
        ),
      );
    }
    if (data.containsKey('project')) {
      context.handle(
        _projectMeta,
        project.isAcceptableOrUnknown(data['project']!, _projectMeta),
      );
    }
    if (data.containsKey('entertainment_type')) {
      context.handle(
        _entertainmentTypeMeta,
        entertainmentType.isAcceptableOrUnknown(
          data['entertainment_type']!,
          _entertainmentTypeMeta,
        ),
      );
    }
    if (data.containsKey('subtype')) {
      context.handle(
        _subtypeMeta,
        subtype.isAcceptableOrUnknown(data['subtype']!, _subtypeMeta),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      activityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_type'],
      )!,
      project: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project'],
      ),
      entertainmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entertainment_type'],
      ),
      subtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TimeEntriesTable createAlias(String alias) {
    return $TimeEntriesTable(attachedDatabase, alias);
  }
}

class TimeEntry extends DataClass implements Insertable<TimeEntry> {
  final int id;
  final String startTime;
  final String endTime;
  final String description;
  final String activityType;
  final String? project;
  final String? entertainmentType;
  final String? subtype;
  final String? customName;
  final DateTime createdAt;
  const TimeEntry({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.activityType,
    this.project,
    this.entertainmentType,
    this.subtype,
    this.customName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['description'] = Variable<String>(description);
    map['activity_type'] = Variable<String>(activityType);
    if (!nullToAbsent || project != null) {
      map['project'] = Variable<String>(project);
    }
    if (!nullToAbsent || entertainmentType != null) {
      map['entertainment_type'] = Variable<String>(entertainmentType);
    }
    if (!nullToAbsent || subtype != null) {
      map['subtype'] = Variable<String>(subtype);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TimeEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimeEntriesCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime: Value(endTime),
      description: Value(description),
      activityType: Value(activityType),
      project: project == null && nullToAbsent
          ? const Value.absent()
          : Value(project),
      entertainmentType: entertainmentType == null && nullToAbsent
          ? const Value.absent()
          : Value(entertainmentType),
      subtype: subtype == null && nullToAbsent
          ? const Value.absent()
          : Value(subtype),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      createdAt: Value(createdAt),
    );
  }

  factory TimeEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeEntry(
      id: serializer.fromJson<int>(json['id']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      description: serializer.fromJson<String>(json['description']),
      activityType: serializer.fromJson<String>(json['activityType']),
      project: serializer.fromJson<String?>(json['project']),
      entertainmentType: serializer.fromJson<String?>(
        json['entertainmentType'],
      ),
      subtype: serializer.fromJson<String?>(json['subtype']),
      customName: serializer.fromJson<String?>(json['customName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'description': serializer.toJson<String>(description),
      'activityType': serializer.toJson<String>(activityType),
      'project': serializer.toJson<String?>(project),
      'entertainmentType': serializer.toJson<String?>(entertainmentType),
      'subtype': serializer.toJson<String?>(subtype),
      'customName': serializer.toJson<String?>(customName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TimeEntry copyWith({
    int? id,
    String? startTime,
    String? endTime,
    String? description,
    String? activityType,
    Value<String?> project = const Value.absent(),
    Value<String?> entertainmentType = const Value.absent(),
    Value<String?> subtype = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    DateTime? createdAt,
  }) => TimeEntry(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    description: description ?? this.description,
    activityType: activityType ?? this.activityType,
    project: project.present ? project.value : this.project,
    entertainmentType: entertainmentType.present
        ? entertainmentType.value
        : this.entertainmentType,
    subtype: subtype.present ? subtype.value : this.subtype,
    customName: customName.present ? customName.value : this.customName,
    createdAt: createdAt ?? this.createdAt,
  );
  TimeEntry copyWithCompanion(TimeEntriesCompanion data) {
    return TimeEntry(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      description: data.description.present
          ? data.description.value
          : this.description,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      project: data.project.present ? data.project.value : this.project,
      entertainmentType: data.entertainmentType.present
          ? data.entertainmentType.value
          : this.entertainmentType,
      subtype: data.subtype.present ? data.subtype.value : this.subtype,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeEntry(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('description: $description, ')
          ..write('activityType: $activityType, ')
          ..write('project: $project, ')
          ..write('entertainmentType: $entertainmentType, ')
          ..write('subtype: $subtype, ')
          ..write('customName: $customName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startTime,
    endTime,
    description,
    activityType,
    project,
    entertainmentType,
    subtype,
    customName,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeEntry &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.description == this.description &&
          other.activityType == this.activityType &&
          other.project == this.project &&
          other.entertainmentType == this.entertainmentType &&
          other.subtype == this.subtype &&
          other.customName == this.customName &&
          other.createdAt == this.createdAt);
}

class TimeEntriesCompanion extends UpdateCompanion<TimeEntry> {
  final Value<int> id;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> description;
  final Value<String> activityType;
  final Value<String?> project;
  final Value<String?> entertainmentType;
  final Value<String?> subtype;
  final Value<String?> customName;
  final Value<DateTime> createdAt;
  const TimeEntriesCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.description = const Value.absent(),
    this.activityType = const Value.absent(),
    this.project = const Value.absent(),
    this.entertainmentType = const Value.absent(),
    this.subtype = const Value.absent(),
    this.customName = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TimeEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String startTime,
    required String endTime,
    required String description,
    this.activityType = const Value.absent(),
    this.project = const Value.absent(),
    this.entertainmentType = const Value.absent(),
    this.subtype = const Value.absent(),
    this.customName = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : startTime = Value(startTime),
       endTime = Value(endTime),
       description = Value(description);
  static Insertable<TimeEntry> custom({
    Expression<int>? id,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? description,
    Expression<String>? activityType,
    Expression<String>? project,
    Expression<String>? entertainmentType,
    Expression<String>? subtype,
    Expression<String>? customName,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (description != null) 'description': description,
      if (activityType != null) 'activity_type': activityType,
      if (project != null) 'project': project,
      if (entertainmentType != null) 'entertainment_type': entertainmentType,
      if (subtype != null) 'subtype': subtype,
      if (customName != null) 'custom_name': customName,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TimeEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<String>? description,
    Value<String>? activityType,
    Value<String?>? project,
    Value<String?>? entertainmentType,
    Value<String?>? subtype,
    Value<String?>? customName,
    Value<DateTime>? createdAt,
  }) {
    return TimeEntriesCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      activityType: activityType ?? this.activityType,
      project: project ?? this.project,
      entertainmentType: entertainmentType ?? this.entertainmentType,
      subtype: subtype ?? this.subtype,
      customName: customName ?? this.customName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (project.present) {
      map['project'] = Variable<String>(project.value);
    }
    if (entertainmentType.present) {
      map['entertainment_type'] = Variable<String>(entertainmentType.value);
    }
    if (subtype.present) {
      map['subtype'] = Variable<String>(subtype.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('description: $description, ')
          ..write('activityType: $activityType, ')
          ..write('project: $project, ')
          ..write('entertainmentType: $entertainmentType, ')
          ..write('subtype: $subtype, ')
          ..write('customName: $customName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecurringRemindersTable extends RecurringReminders
    with TableInfo<$RecurringRemindersTable, RecurringReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRemindersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 300,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatIntervalMeta = const VerificationMeta(
    'repeatInterval',
  );
  @override
  late final GeneratedColumn<int> repeatInterval = GeneratedColumn<int>(
    'repeat_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeDaysMeta = const VerificationMeta(
    'activeDays',
  );
  @override
  late final GeneratedColumn<int> activeDays = GeneratedColumn<int>(
    'active_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    startTime,
    endTime,
    repeatInterval,
    activeDays,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('repeat_interval')) {
      context.handle(
        _repeatIntervalMeta,
        repeatInterval.isAcceptableOrUnknown(
          data['repeat_interval']!,
          _repeatIntervalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repeatIntervalMeta);
    }
    if (data.containsKey('active_days')) {
      context.handle(
        _activeDaysMeta,
        activeDays.isAcceptableOrUnknown(data['active_days']!, _activeDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_activeDaysMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time'],
      )!,
      repeatInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_interval'],
      )!,
      activeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_days'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $RecurringRemindersTable createAlias(String alias) {
    return $RecurringRemindersTable(attachedDatabase, alias);
  }
}

class RecurringReminder extends DataClass
    implements Insertable<RecurringReminder> {
  final int id;
  final String name;
  final String? description;
  final int startTime;
  final int endTime;
  final int repeatInterval;
  final int activeDays;
  final bool isActive;
  const RecurringReminder({
    required this.id,
    required this.name,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.repeatInterval,
    required this.activeDays,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_time'] = Variable<int>(startTime);
    map['end_time'] = Variable<int>(endTime);
    map['repeat_interval'] = Variable<int>(repeatInterval);
    map['active_days'] = Variable<int>(activeDays);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RecurringRemindersCompanion toCompanion(bool nullToAbsent) {
    return RecurringRemindersCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startTime: Value(startTime),
      endTime: Value(endTime),
      repeatInterval: Value(repeatInterval),
      activeDays: Value(activeDays),
      isActive: Value(isActive),
    );
  }

  factory RecurringReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringReminder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      startTime: serializer.fromJson<int>(json['startTime']),
      endTime: serializer.fromJson<int>(json['endTime']),
      repeatInterval: serializer.fromJson<int>(json['repeatInterval']),
      activeDays: serializer.fromJson<int>(json['activeDays']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'startTime': serializer.toJson<int>(startTime),
      'endTime': serializer.toJson<int>(endTime),
      'repeatInterval': serializer.toJson<int>(repeatInterval),
      'activeDays': serializer.toJson<int>(activeDays),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  RecurringReminder copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? startTime,
    int? endTime,
    int? repeatInterval,
    int? activeDays,
    bool? isActive,
  }) => RecurringReminder(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    repeatInterval: repeatInterval ?? this.repeatInterval,
    activeDays: activeDays ?? this.activeDays,
    isActive: isActive ?? this.isActive,
  );
  RecurringReminder copyWithCompanion(RecurringRemindersCompanion data) {
    return RecurringReminder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      repeatInterval: data.repeatInterval.present
          ? data.repeatInterval.value
          : this.repeatInterval,
      activeDays: data.activeDays.present
          ? data.activeDays.value
          : this.activeDays,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringReminder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('activeDays: $activeDays, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    startTime,
    endTime,
    repeatInterval,
    activeDays,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringReminder &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.repeatInterval == this.repeatInterval &&
          other.activeDays == this.activeDays &&
          other.isActive == this.isActive);
}

class RecurringRemindersCompanion extends UpdateCompanion<RecurringReminder> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> startTime;
  final Value<int> endTime;
  final Value<int> repeatInterval;
  final Value<int> activeDays;
  final Value<bool> isActive;
  const RecurringRemindersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.activeDays = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  RecurringRemindersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required int startTime,
    required int endTime,
    required int repeatInterval,
    required int activeDays,
    this.isActive = const Value.absent(),
  }) : name = Value(name),
       startTime = Value(startTime),
       endTime = Value(endTime),
       repeatInterval = Value(repeatInterval),
       activeDays = Value(activeDays);
  static Insertable<RecurringReminder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? startTime,
    Expression<int>? endTime,
    Expression<int>? repeatInterval,
    Expression<int>? activeDays,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (repeatInterval != null) 'repeat_interval': repeatInterval,
      if (activeDays != null) 'active_days': activeDays,
      if (isActive != null) 'is_active': isActive,
    });
  }

  RecurringRemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? startTime,
    Value<int>? endTime,
    Value<int>? repeatInterval,
    Value<int>? activeDays,
    Value<bool>? isActive,
  }) {
    return RecurringRemindersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      activeDays: activeDays ?? this.activeDays,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (repeatInterval.present) {
      map['repeat_interval'] = Variable<int>(repeatInterval.value);
    }
    if (activeDays.present) {
      map['active_days'] = Variable<int>(activeDays.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRemindersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('activeDays: $activeDays, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $CompletionRecordsTable extends CompletionRecords
    with TableInfo<$CompletionRecordsTable, CompletionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<int> reminderId = GeneratedColumn<int>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_reminders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _completionDateMeta = const VerificationMeta(
    'completionDate',
  );
  @override
  late final GeneratedColumn<String> completionDate = GeneratedColumn<String>(
    'completion_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionTimestampMeta =
      const VerificationMeta('completionTimestamp');
  @override
  late final GeneratedColumn<String> completionTimestamp =
      GeneratedColumn<String>(
        'completion_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reminderId,
    completionDate,
    completionTimestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completion_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('completion_date')) {
      context.handle(
        _completionDateMeta,
        completionDate.isAcceptableOrUnknown(
          data['completion_date']!,
          _completionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completionDateMeta);
    }
    if (data.containsKey('completion_timestamp')) {
      context.handle(
        _completionTimestampMeta,
        completionTimestamp.isAcceptableOrUnknown(
          data['completion_timestamp']!,
          _completionTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completionTimestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {reminderId, completionDate},
  ];
  @override
  CompletionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_id'],
      )!,
      completionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_date'],
      )!,
      completionTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_timestamp'],
      )!,
    );
  }

  @override
  $CompletionRecordsTable createAlias(String alias) {
    return $CompletionRecordsTable(attachedDatabase, alias);
  }
}

class CompletionRecord extends DataClass
    implements Insertable<CompletionRecord> {
  final int id;
  final int reminderId;
  final String completionDate;
  final String completionTimestamp;
  const CompletionRecord({
    required this.id,
    required this.reminderId,
    required this.completionDate,
    required this.completionTimestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['reminder_id'] = Variable<int>(reminderId);
    map['completion_date'] = Variable<String>(completionDate);
    map['completion_timestamp'] = Variable<String>(completionTimestamp);
    return map;
  }

  CompletionRecordsCompanion toCompanion(bool nullToAbsent) {
    return CompletionRecordsCompanion(
      id: Value(id),
      reminderId: Value(reminderId),
      completionDate: Value(completionDate),
      completionTimestamp: Value(completionTimestamp),
    );
  }

  factory CompletionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionRecord(
      id: serializer.fromJson<int>(json['id']),
      reminderId: serializer.fromJson<int>(json['reminderId']),
      completionDate: serializer.fromJson<String>(json['completionDate']),
      completionTimestamp: serializer.fromJson<String>(
        json['completionTimestamp'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reminderId': serializer.toJson<int>(reminderId),
      'completionDate': serializer.toJson<String>(completionDate),
      'completionTimestamp': serializer.toJson<String>(completionTimestamp),
    };
  }

  CompletionRecord copyWith({
    int? id,
    int? reminderId,
    String? completionDate,
    String? completionTimestamp,
  }) => CompletionRecord(
    id: id ?? this.id,
    reminderId: reminderId ?? this.reminderId,
    completionDate: completionDate ?? this.completionDate,
    completionTimestamp: completionTimestamp ?? this.completionTimestamp,
  );
  CompletionRecord copyWithCompanion(CompletionRecordsCompanion data) {
    return CompletionRecord(
      id: data.id.present ? data.id.value : this.id,
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      completionDate: data.completionDate.present
          ? data.completionDate.value
          : this.completionDate,
      completionTimestamp: data.completionTimestamp.present
          ? data.completionTimestamp.value
          : this.completionTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionRecord(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('completionDate: $completionDate, ')
          ..write('completionTimestamp: $completionTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, reminderId, completionDate, completionTimestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionRecord &&
          other.id == this.id &&
          other.reminderId == this.reminderId &&
          other.completionDate == this.completionDate &&
          other.completionTimestamp == this.completionTimestamp);
}

class CompletionRecordsCompanion extends UpdateCompanion<CompletionRecord> {
  final Value<int> id;
  final Value<int> reminderId;
  final Value<String> completionDate;
  final Value<String> completionTimestamp;
  const CompletionRecordsCompanion({
    this.id = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.completionDate = const Value.absent(),
    this.completionTimestamp = const Value.absent(),
  });
  CompletionRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int reminderId,
    required String completionDate,
    required String completionTimestamp,
  }) : reminderId = Value(reminderId),
       completionDate = Value(completionDate),
       completionTimestamp = Value(completionTimestamp);
  static Insertable<CompletionRecord> custom({
    Expression<int>? id,
    Expression<int>? reminderId,
    Expression<String>? completionDate,
    Expression<String>? completionTimestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reminderId != null) 'reminder_id': reminderId,
      if (completionDate != null) 'completion_date': completionDate,
      if (completionTimestamp != null)
        'completion_timestamp': completionTimestamp,
    });
  }

  CompletionRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? reminderId,
    Value<String>? completionDate,
    Value<String>? completionTimestamp,
  }) {
    return CompletionRecordsCompanion(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      completionDate: completionDate ?? this.completionDate,
      completionTimestamp: completionTimestamp ?? this.completionTimestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<int>(reminderId.value);
    }
    if (completionDate.present) {
      map['completion_date'] = Variable<String>(completionDate.value);
    }
    if (completionTimestamp.present) {
      map['completion_timestamp'] = Variable<String>(completionTimestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionRecordsCompanion(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('completionDate: $completionDate, ')
          ..write('completionTimestamp: $completionTimestamp')
          ..write(')'))
        .toString();
  }
}

class $TaskProjectsTable extends TaskProjects
    with TableInfo<$TaskProjectsTable, TaskProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskProjectsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('workUnpaid'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, scope, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskProject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskProject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TaskProjectsTable createAlias(String alias) {
    return $TaskProjectsTable(attachedDatabase, alias);
  }
}

class TaskProject extends DataClass implements Insertable<TaskProject> {
  final int id;
  final String name;
  final String scope;
  final DateTime createdAt;
  const TaskProject({
    required this.id,
    required this.name,
    required this.scope,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['scope'] = Variable<String>(scope);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TaskProjectsCompanion toCompanion(bool nullToAbsent) {
    return TaskProjectsCompanion(
      id: Value(id),
      name: Value(name),
      scope: Value(scope),
      createdAt: Value(createdAt),
    );
  }

  factory TaskProject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskProject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      scope: serializer.fromJson<String>(json['scope']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'scope': serializer.toJson<String>(scope),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaskProject copyWith({
    int? id,
    String? name,
    String? scope,
    DateTime? createdAt,
  }) => TaskProject(
    id: id ?? this.id,
    name: name ?? this.name,
    scope: scope ?? this.scope,
    createdAt: createdAt ?? this.createdAt,
  );
  TaskProject copyWithCompanion(TaskProjectsCompanion data) {
    return TaskProject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      scope: data.scope.present ? data.scope.value : this.scope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskProject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, scope, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskProject &&
          other.id == this.id &&
          other.name == this.name &&
          other.scope == this.scope &&
          other.createdAt == this.createdAt);
}

class TaskProjectsCompanion extends UpdateCompanion<TaskProject> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> scope;
  final Value<DateTime> createdAt;
  const TaskProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.scope = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TaskProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.scope = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TaskProject> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? scope,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (scope != null) 'scope': scope,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TaskProjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? scope,
    Value<DateTime>? createdAt,
  }) {
    return TaskProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 1000,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<String> deadline = GeneratedColumn<String>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES task_projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortPositionMeta = const VerificationMeta(
    'sortPosition',
  );
  @override
  late final GeneratedColumn<int> sortPosition = GeneratedColumn<int>(
    'sort_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    deadline,
    projectId,
    sortPosition,
    isCompleted,
    completedAt,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('sort_position')) {
      context.handle(
        _sortPositionMeta,
        sortPosition.isAcceptableOrUnknown(
          data['sort_position']!,
          _sortPositionMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      ),
      sortPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_position'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskItem extends DataClass implements Insertable<TaskItem> {
  final int id;
  final String title;
  final String? description;
  final String? deadline;
  final int? projectId;
  final int sortPosition;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isArchived;
  final DateTime createdAt;
  const TaskItem({
    required this.id,
    required this.title,
    this.description,
    this.deadline,
    this.projectId,
    required this.sortPosition,
    required this.isCompleted,
    this.completedAt,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<String>(deadline);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<int>(projectId);
    }
    map['sort_position'] = Variable<int>(sortPosition);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      sortPosition: Value(sortPosition),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory TaskItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskItem(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      deadline: serializer.fromJson<String?>(json['deadline']),
      projectId: serializer.fromJson<int?>(json['projectId']),
      sortPosition: serializer.fromJson<int>(json['sortPosition']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'deadline': serializer.toJson<String?>(deadline),
      'projectId': serializer.toJson<int?>(projectId),
      'sortPosition': serializer.toJson<int>(sortPosition),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaskItem copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> deadline = const Value.absent(),
    Value<int?> projectId = const Value.absent(),
    int? sortPosition,
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    bool? isArchived,
    DateTime? createdAt,
  }) => TaskItem(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    deadline: deadline.present ? deadline.value : this.deadline,
    projectId: projectId.present ? projectId.value : this.projectId,
    sortPosition: sortPosition ?? this.sortPosition,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  TaskItem copyWithCompanion(TasksCompanion data) {
    return TaskItem(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      sortPosition: data.sortPosition.present
          ? data.sortPosition.value
          : this.sortPosition,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskItem(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('deadline: $deadline, ')
          ..write('projectId: $projectId, ')
          ..write('sortPosition: $sortPosition, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    deadline,
    projectId,
    sortPosition,
    isCompleted,
    completedAt,
    isArchived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskItem &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.deadline == this.deadline &&
          other.projectId == this.projectId &&
          other.sortPosition == this.sortPosition &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<TaskItem> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> deadline;
  final Value<int?> projectId;
  final Value<int> sortPosition;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.deadline = const Value.absent(),
    this.projectId = const Value.absent(),
    this.sortPosition = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.deadline = const Value.absent(),
    this.projectId = const Value.absent(),
    this.sortPosition = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<TaskItem> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? deadline,
    Expression<int>? projectId,
    Expression<int>? sortPosition,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (deadline != null) 'deadline': deadline,
      if (projectId != null) 'project_id': projectId,
      if (sortPosition != null) 'sort_position': sortPosition,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? deadline,
    Value<int?>? projectId,
    Value<int>? sortPosition,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      projectId: projectId ?? this.projectId,
      sortPosition: sortPosition ?? this.sortPosition,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<String>(deadline.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (sortPosition.present) {
      map['sort_position'] = Variable<int>(sortPosition.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('deadline: $deadline, ')
          ..write('projectId: $projectId, ')
          ..write('sortPosition: $sortPosition, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TimeEntriesTable timeEntries = $TimeEntriesTable(this);
  late final $RecurringRemindersTable recurringReminders =
      $RecurringRemindersTable(this);
  late final $CompletionRecordsTable completionRecords =
      $CompletionRecordsTable(this);
  late final $TaskProjectsTable taskProjects = $TaskProjectsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    timeEntries,
    recurringReminders,
    completionRecords,
    taskProjects,
    tasks,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_reminders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('completion_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'task_projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TimeEntriesTableCreateCompanionBuilder =
    TimeEntriesCompanion Function({
      Value<int> id,
      required String startTime,
      required String endTime,
      required String description,
      Value<String> activityType,
      Value<String?> project,
      Value<String?> entertainmentType,
      Value<String?> subtype,
      Value<String?> customName,
      Value<DateTime> createdAt,
    });
typedef $$TimeEntriesTableUpdateCompanionBuilder =
    TimeEntriesCompanion Function({
      Value<int> id,
      Value<String> startTime,
      Value<String> endTime,
      Value<String> description,
      Value<String> activityType,
      Value<String?> project,
      Value<String?> entertainmentType,
      Value<String?> subtype,
      Value<String?> customName,
      Value<DateTime> createdAt,
    });

class $$TimeEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TimeEntriesTable> {
  $$TimeEntriesTableFilterComposer({
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

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get project => $composableBuilder(
    column: $table.project,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entertainmentType => $composableBuilder(
    column: $table.entertainmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimeEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeEntriesTable> {
  $$TimeEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get project => $composableBuilder(
    column: $table.project,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entertainmentType => $composableBuilder(
    column: $table.entertainmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimeEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeEntriesTable> {
  $$TimeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get project =>
      $composableBuilder(column: $table.project, builder: (column) => column);

  GeneratedColumn<String> get entertainmentType => $composableBuilder(
    column: $table.entertainmentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subtype =>
      $composableBuilder(column: $table.subtype, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TimeEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimeEntriesTable,
          TimeEntry,
          $$TimeEntriesTableFilterComposer,
          $$TimeEntriesTableOrderingComposer,
          $$TimeEntriesTableAnnotationComposer,
          $$TimeEntriesTableCreateCompanionBuilder,
          $$TimeEntriesTableUpdateCompanionBuilder,
          (
            TimeEntry,
            BaseReferences<_$AppDatabase, $TimeEntriesTable, TimeEntry>,
          ),
          TimeEntry,
          PrefetchHooks Function()
        > {
  $$TimeEntriesTableTableManager(_$AppDatabase db, $TimeEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> activityType = const Value.absent(),
                Value<String?> project = const Value.absent(),
                Value<String?> entertainmentType = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TimeEntriesCompanion(
                id: id,
                startTime: startTime,
                endTime: endTime,
                description: description,
                activityType: activityType,
                project: project,
                entertainmentType: entertainmentType,
                subtype: subtype,
                customName: customName,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String startTime,
                required String endTime,
                required String description,
                Value<String> activityType = const Value.absent(),
                Value<String?> project = const Value.absent(),
                Value<String?> entertainmentType = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TimeEntriesCompanion.insert(
                id: id,
                startTime: startTime,
                endTime: endTime,
                description: description,
                activityType: activityType,
                project: project,
                entertainmentType: entertainmentType,
                subtype: subtype,
                customName: customName,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimeEntriesTable, TimeEntry>(table),
                  BaseReferences<_$AppDatabase, $TimeEntriesTable, TimeEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimeEntriesTable,
      TimeEntry,
      $$TimeEntriesTableFilterComposer,
      $$TimeEntriesTableOrderingComposer,
      $$TimeEntriesTableAnnotationComposer,
      $$TimeEntriesTableCreateCompanionBuilder,
      $$TimeEntriesTableUpdateCompanionBuilder,
      (TimeEntry, BaseReferences<_$AppDatabase, $TimeEntriesTable, TimeEntry>),
      TimeEntry,
      PrefetchHooks Function()
    >;
typedef $$RecurringRemindersTableCreateCompanionBuilder =
    RecurringRemindersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      required int startTime,
      required int endTime,
      required int repeatInterval,
      required int activeDays,
      Value<bool> isActive,
    });
typedef $$RecurringRemindersTableUpdateCompanionBuilder =
    RecurringRemindersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<int> startTime,
      Value<int> endTime,
      Value<int> repeatInterval,
      Value<int> activeDays,
      Value<bool> isActive,
    });

final class $$RecurringRemindersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringRemindersTable,
          RecurringReminder
        > {
  $$RecurringRemindersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CompletionRecordsTable, List<CompletionRecord>>
  _completionRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.completionRecords,
        aliasName: 'recurring_reminders__id__completion_records__reminder_id',
      );

  $$CompletionRecordsTableProcessedTableManager get completionRecordsRefs {
    final manager = $$CompletionRecordsTableTableManager(
      $_db,
      $_db.completionRecords,
    ).filter((f) => f.reminderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _completionRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRemindersTable> {
  $$RecurringRemindersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeDays => $composableBuilder(
    column: $table.activeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> completionRecordsRefs(
    Expression<bool> Function($$CompletionRecordsTableFilterComposer f) f,
  ) {
    final $$CompletionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.completionRecords,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompletionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.completionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRemindersTable> {
  $$RecurringRemindersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeDays => $composableBuilder(
    column: $table.activeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRemindersTable> {
  $$RecurringRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeDays => $composableBuilder(
    column: $table.activeDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> completionRecordsRefs<T extends Object>(
    Expression<T> Function($$CompletionRecordsTableAnnotationComposer a) f,
  ) {
    final $$CompletionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.completionRecords,
          getReferencedColumn: (t) => t.reminderId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompletionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.completionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RecurringRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringRemindersTable,
          RecurringReminder,
          $$RecurringRemindersTableFilterComposer,
          $$RecurringRemindersTableOrderingComposer,
          $$RecurringRemindersTableAnnotationComposer,
          $$RecurringRemindersTableCreateCompanionBuilder,
          $$RecurringRemindersTableUpdateCompanionBuilder,
          (RecurringReminder, $$RecurringRemindersTableReferences),
          RecurringReminder,
          PrefetchHooks Function({bool completionRecordsRefs})
        > {
  $$RecurringRemindersTableTableManager(
    _$AppDatabase db,
    $RecurringRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRemindersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> startTime = const Value.absent(),
                Value<int> endTime = const Value.absent(),
                Value<int> repeatInterval = const Value.absent(),
                Value<int> activeDays = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => RecurringRemindersCompanion(
                id: id,
                name: name,
                description: description,
                startTime: startTime,
                endTime: endTime,
                repeatInterval: repeatInterval,
                activeDays: activeDays,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                required int startTime,
                required int endTime,
                required int repeatInterval,
                required int activeDays,
                Value<bool> isActive = const Value.absent(),
              }) => RecurringRemindersCompanion.insert(
                id: id,
                name: name,
                description: description,
                startTime: startTime,
                endTime: endTime,
                repeatInterval: repeatInterval,
                activeDays: activeDays,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringRemindersTable, RecurringReminder>(
                    table,
                  ),
                  $$RecurringRemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({completionRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (completionRecordsRefs) db.completionRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (completionRecordsRefs)
                    await $_getPrefetchedData<
                      RecurringReminder,
                      $RecurringRemindersTable,
                      CompletionRecord
                    >(
                      currentTable: table,
                      referencedTable: $$RecurringRemindersTableReferences
                          ._completionRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RecurringRemindersTableReferences(
                            db,
                            table,
                            p0,
                          ).completionRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.reminderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RecurringRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringRemindersTable,
      RecurringReminder,
      $$RecurringRemindersTableFilterComposer,
      $$RecurringRemindersTableOrderingComposer,
      $$RecurringRemindersTableAnnotationComposer,
      $$RecurringRemindersTableCreateCompanionBuilder,
      $$RecurringRemindersTableUpdateCompanionBuilder,
      (RecurringReminder, $$RecurringRemindersTableReferences),
      RecurringReminder,
      PrefetchHooks Function({bool completionRecordsRefs})
    >;
typedef $$CompletionRecordsTableCreateCompanionBuilder =
    CompletionRecordsCompanion Function({
      Value<int> id,
      required int reminderId,
      required String completionDate,
      required String completionTimestamp,
    });
typedef $$CompletionRecordsTableUpdateCompanionBuilder =
    CompletionRecordsCompanion Function({
      Value<int> id,
      Value<int> reminderId,
      Value<String> completionDate,
      Value<String> completionTimestamp,
    });

final class $$CompletionRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CompletionRecordsTable,
          CompletionRecord
        > {
  $$CompletionRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecurringRemindersTable _reminderIdTable(_$AppDatabase db) => db
      .recurringReminders
      .createAlias('completion_records__reminder_id__recurring_reminders__id');

  $$RecurringRemindersTableProcessedTableManager get reminderId {
    final $_column = $_itemColumn<int>('reminder_id')!;

    final manager = $$RecurringRemindersTableTableManager(
      $_db,
      $_db.recurringReminders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reminderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompletionRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionRecordsTable> {
  $$CompletionRecordsTableFilterComposer({
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

  ColumnFilters<String> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionTimestamp => $composableBuilder(
    column: $table.completionTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$RecurringRemindersTableFilterComposer get reminderId {
    final $$RecurringRemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.recurringReminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRemindersTableFilterComposer(
            $db: $db,
            $table: $db.recurringReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionRecordsTable> {
  $$CompletionRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionTimestamp => $composableBuilder(
    column: $table.completionTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecurringRemindersTableOrderingComposer get reminderId {
    final $$RecurringRemindersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.recurringReminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRemindersTableOrderingComposer(
            $db: $db,
            $table: $db.recurringReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionRecordsTable> {
  $$CompletionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completionTimestamp => $composableBuilder(
    column: $table.completionTimestamp,
    builder: (column) => column,
  );

  $$RecurringRemindersTableAnnotationComposer get reminderId {
    final $$RecurringRemindersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reminderId,
          referencedTable: $db.recurringReminders,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringRemindersTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringReminders,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CompletionRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionRecordsTable,
          CompletionRecord,
          $$CompletionRecordsTableFilterComposer,
          $$CompletionRecordsTableOrderingComposer,
          $$CompletionRecordsTableAnnotationComposer,
          $$CompletionRecordsTableCreateCompanionBuilder,
          $$CompletionRecordsTableUpdateCompanionBuilder,
          (CompletionRecord, $$CompletionRecordsTableReferences),
          CompletionRecord,
          PrefetchHooks Function({bool reminderId})
        > {
  $$CompletionRecordsTableTableManager(
    _$AppDatabase db,
    $CompletionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> reminderId = const Value.absent(),
                Value<String> completionDate = const Value.absent(),
                Value<String> completionTimestamp = const Value.absent(),
              }) => CompletionRecordsCompanion(
                id: id,
                reminderId: reminderId,
                completionDate: completionDate,
                completionTimestamp: completionTimestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int reminderId,
                required String completionDate,
                required String completionTimestamp,
              }) => CompletionRecordsCompanion.insert(
                id: id,
                reminderId: reminderId,
                completionDate: completionDate,
                completionTimestamp: completionTimestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionRecordsTable, CompletionRecord>(table),
                  $$CompletionRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reminderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (reminderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reminderId,
                                referencedTable:
                                    $$CompletionRecordsTableReferences
                                        ._reminderIdTable(db),
                                referencedColumn:
                                    $$CompletionRecordsTableReferences
                                        ._reminderIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CompletionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionRecordsTable,
      CompletionRecord,
      $$CompletionRecordsTableFilterComposer,
      $$CompletionRecordsTableOrderingComposer,
      $$CompletionRecordsTableAnnotationComposer,
      $$CompletionRecordsTableCreateCompanionBuilder,
      $$CompletionRecordsTableUpdateCompanionBuilder,
      (CompletionRecord, $$CompletionRecordsTableReferences),
      CompletionRecord,
      PrefetchHooks Function({bool reminderId})
    >;
typedef $$TaskProjectsTableCreateCompanionBuilder =
    TaskProjectsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> scope,
      Value<DateTime> createdAt,
    });
typedef $$TaskProjectsTableUpdateCompanionBuilder =
    TaskProjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> scope,
      Value<DateTime> createdAt,
    });

final class $$TaskProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $TaskProjectsTable, TaskProject> {
  $$TaskProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<TaskItem>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'task_projects__id__tasks__project_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TaskProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskProjectsTable> {
  $$TaskProjectsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TaskProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskProjectsTable> {
  $$TaskProjectsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskProjectsTable> {
  $$TaskProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TaskProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskProjectsTable,
          TaskProject,
          $$TaskProjectsTableFilterComposer,
          $$TaskProjectsTableOrderingComposer,
          $$TaskProjectsTableAnnotationComposer,
          $$TaskProjectsTableCreateCompanionBuilder,
          $$TaskProjectsTableUpdateCompanionBuilder,
          (TaskProject, $$TaskProjectsTableReferences),
          TaskProject,
          PrefetchHooks Function({bool tasksRefs})
        > {
  $$TaskProjectsTableTableManager(_$AppDatabase db, $TaskProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TaskProjectsCompanion(
                id: id,
                name: name,
                scope: scope,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> scope = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TaskProjectsCompanion.insert(
                id: id,
                name: name,
                scope: scope,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskProjectsTable, TaskProject>(table),
                  $$TaskProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<
                      TaskProject,
                      $TaskProjectsTable,
                      TaskItem
                    >(
                      currentTable: table,
                      referencedTable: $$TaskProjectsTableReferences
                          ._tasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TaskProjectsTableReferences(
                            db,
                            table,
                            p0,
                          ).tasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.projectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TaskProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskProjectsTable,
      TaskProject,
      $$TaskProjectsTableFilterComposer,
      $$TaskProjectsTableOrderingComposer,
      $$TaskProjectsTableAnnotationComposer,
      $$TaskProjectsTableCreateCompanionBuilder,
      $$TaskProjectsTableUpdateCompanionBuilder,
      (TaskProject, $$TaskProjectsTableReferences),
      TaskProject,
      PrefetchHooks Function({bool tasksRefs})
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      Value<String?> deadline,
      Value<int?> projectId,
      Value<int> sortPosition,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<String?> deadline,
      Value<int?> projectId,
      Value<int> sortPosition,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskItem> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TaskProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.taskProjects.createAlias('tasks__project_id__task_projects__id');

  $$TaskProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<int>('project_id');
    if ($_column == null) return null;
    final manager = $$TaskProjectsTableTableManager(
      $_db,
      $_db.taskProjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortPosition => $composableBuilder(
    column: $table.sortPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TaskProjectsTableFilterComposer get projectId {
    final $$TaskProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.taskProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskProjectsTableFilterComposer(
            $db: $db,
            $table: $db.taskProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortPosition => $composableBuilder(
    column: $table.sortPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TaskProjectsTableOrderingComposer get projectId {
    final $$TaskProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.taskProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.taskProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<int> get sortPosition => $composableBuilder(
    column: $table.sortPosition,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TaskProjectsTableAnnotationComposer get projectId {
    final $$TaskProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.taskProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskItem,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskItem, $$TasksTableReferences),
          TaskItem,
          PrefetchHooks Function({bool projectId})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> deadline = const Value.absent(),
                Value<int?> projectId = const Value.absent(),
                Value<int> sortPosition = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                description: description,
                deadline: deadline,
                projectId: projectId,
                sortPosition: sortPosition,
                isCompleted: isCompleted,
                completedAt: completedAt,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> deadline = const Value.absent(),
                Value<int?> projectId = const Value.absent(),
                Value<int> sortPosition = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                description: description,
                deadline: deadline,
                projectId: projectId,
                sortPosition: sortPosition,
                isCompleted: isCompleted,
                completedAt: completedAt,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskItem>(table),
                  $$TasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$TasksTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$TasksTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskItem,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskItem, $$TasksTableReferences),
      TaskItem,
      PrefetchHooks Function({bool projectId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TimeEntriesTableTableManager get timeEntries =>
      $$TimeEntriesTableTableManager(_db, _db.timeEntries);
  $$RecurringRemindersTableTableManager get recurringReminders =>
      $$RecurringRemindersTableTableManager(_db, _db.recurringReminders);
  $$CompletionRecordsTableTableManager get completionRecords =>
      $$CompletionRecordsTableTableManager(_db, _db.completionRecords);
  $$TaskProjectsTableTableManager get taskProjects =>
      $$TaskProjectsTableTableManager(_db, _db.taskProjects);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
