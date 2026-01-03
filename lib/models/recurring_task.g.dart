// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringTaskLogAdapter extends TypeAdapter<RecurringTaskLog> {
  @override
  final int typeId = 35;

  @override
  RecurringTaskLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringTaskLog(
      date: fields[0] as DateTime,
      completed: fields[1] as bool,
      note: fields[2] as String?,
      checklistCompleted: (fields[3] as List?)?.cast<bool>(),
      numericValue: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringTaskLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.completed)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.checklistCompleted)
      ..writeByte(4)
      ..write(obj.numericValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTaskLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringTaskAdapter extends TypeAdapter<RecurringTask> {
  @override
  final int typeId = 39;

  @override
  RecurringTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringTask(
      id: fields[0] as String,
      name: fields[1] as String,
      categoryId: fields[2] as String,
      evaluationType: fields[3] as HabitEvaluationType,
      checklistItems: (fields[4] as List?)?.cast<String>(),
      frequencyType: fields[5] as HabitFrequencyType,
      scheduledDays: (fields[6] as List?)?.cast<int>(),
      daysPerPeriod: fields[7] as int?,
      repeatInterval: fields[8] as int?,
      specificDates: (fields[9] as List?)?.cast<DateTime>(),
      startDate: fields[10] as DateTime?,
      endDate: fields[11] as DateTime?,
      reminderTimes: (fields[12] as List?)?.cast<String>(),
      priorityLevel: fields[13] as PriorityLevel,
      linkedFactorIds: (fields[14] as List?)?.cast<String>(),
      logs: (fields[15] as List?)?.cast<RecurringTaskLog>(),
      description: fields[16] as String?,
      createdAt: fields[17] as DateTime?,
      isArchived: fields[18] as bool,
      sortOrder: fields[19] as int,
      priority: fields[20] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringTask obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.evaluationType)
      ..writeByte(4)
      ..write(obj.checklistItems)
      ..writeByte(5)
      ..write(obj.frequencyType)
      ..writeByte(6)
      ..write(obj.scheduledDays)
      ..writeByte(7)
      ..write(obj.daysPerPeriod)
      ..writeByte(8)
      ..write(obj.repeatInterval)
      ..writeByte(9)
      ..write(obj.specificDates)
      ..writeByte(10)
      ..write(obj.startDate)
      ..writeByte(11)
      ..write(obj.endDate)
      ..writeByte(12)
      ..write(obj.reminderTimes)
      ..writeByte(13)
      ..write(obj.priorityLevel)
      ..writeByte(14)
      ..write(obj.linkedFactorIds)
      ..writeByte(15)
      ..write(obj.logs)
      ..writeByte(16)
      ..write(obj.description)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.isArchived)
      ..writeByte(19)
      ..write(obj.sortOrder)
      ..writeByte(20)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
