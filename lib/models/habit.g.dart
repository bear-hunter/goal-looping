// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitLogAdapter extends TypeAdapter<HabitLog> {
  @override
  final int typeId = 14;

  @override
  HabitLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitLog(
      date: fields[0] as DateTime,
      completed: fields[1] as bool,
      note: fields[2] as String?,
      moodRating: fields[3] as int?,
      barrierTag: fields[4] as String?,
      numericValue: fields[5] as int?,
      checklistCompleted: (fields[6] as List?)?.cast<bool>(),
      timerSeconds: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.completed)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.moodRating)
      ..writeByte(4)
      ..write(obj.barrierTag)
      ..writeByte(5)
      ..write(obj.numericValue)
      ..writeByte(6)
      ..write(obj.checklistCompleted)
      ..writeByte(7)
      ..write(obj.timerSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 5;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as HabitType,
      triggerResponse: fields[3] as String?,
      currentStreak: fields[4] as int,
      bestStreak: fields[5] as int,
      completionCount: fields[6] as int,
      logs: (fields[7] as List?)?.cast<HabitLog>(),
      createdAt: fields[8] as DateTime?,
      isActive: fields[9] as bool,
      factorId: fields[10] as String?,
      scheduledDays: (fields[11] as List?)?.cast<int>(),
      targetFrequency: fields[12] as int,
      motivation: fields[13] as String,
      timerMinutes: fields[14] as int?,
      streakFreezes: fields[15] as int,
      freezesUsed: fields[16] as int,
      categoryId: fields[17] as String?,
      evaluationType: fields[18] as HabitEvaluationType?,
      frequencyType: fields[19] as HabitFrequencyType?,
      targetValue: fields[20] as int?,
      unit: fields[21] as String?,
      checklistItems: (fields[22] as List?)?.cast<String>(),
      priorityLevel: fields[23] as PriorityLevel?,
      startDate: fields[24] as DateTime?,
      endDate: fields[25] as DateTime?,
      reminderTimes: (fields[26] as List?)?.cast<String>(),
      isArchived: fields[27] as bool,
      daysPerPeriod: fields[28] as int?,
      repeatInterval: fields[29] as int?,
      specificDates: (fields[30] as List?)?.cast<DateTime>(),
      description: fields[31] as String?,
      extraGoal: fields[32] as int?,
      sortOrder: fields[33] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(34)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.triggerResponse)
      ..writeByte(4)
      ..write(obj.currentStreak)
      ..writeByte(5)
      ..write(obj.bestStreak)
      ..writeByte(6)
      ..write(obj.completionCount)
      ..writeByte(7)
      ..write(obj.logs)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.factorId)
      ..writeByte(11)
      ..write(obj.scheduledDays)
      ..writeByte(12)
      ..write(obj.targetFrequency)
      ..writeByte(13)
      ..write(obj.motivation)
      ..writeByte(14)
      ..write(obj.timerMinutes)
      ..writeByte(15)
      ..write(obj.streakFreezes)
      ..writeByte(16)
      ..write(obj.freezesUsed)
      ..writeByte(17)
      ..write(obj.categoryId)
      ..writeByte(18)
      ..write(obj.evaluationType)
      ..writeByte(19)
      ..write(obj.frequencyType)
      ..writeByte(20)
      ..write(obj.targetValue)
      ..writeByte(21)
      ..write(obj.unit)
      ..writeByte(22)
      ..write(obj.checklistItems)
      ..writeByte(23)
      ..write(obj.priorityLevel)
      ..writeByte(24)
      ..write(obj.startDate)
      ..writeByte(25)
      ..write(obj.endDate)
      ..writeByte(26)
      ..write(obj.reminderTimes)
      ..writeByte(27)
      ..write(obj.isArchived)
      ..writeByte(28)
      ..write(obj.daysPerPeriod)
      ..writeByte(29)
      ..write(obj.repeatInterval)
      ..writeByte(30)
      ..write(obj.specificDates)
      ..writeByte(31)
      ..write(obj.description)
      ..writeByte(32)
      ..write(obj.extraGoal)
      ..writeByte(33)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BarrierEntryAdapter extends TypeAdapter<BarrierEntry> {
  @override
  final int typeId = 15;

  @override
  BarrierEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BarrierEntry(
      id: fields[0] as String,
      description: fields[1] as String,
      occurredAt: fields[2] as DateTime?,
      response: fields[3] as String?,
      wasHandled: fields[4] as bool,
      factorId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BarrierEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.occurredAt)
      ..writeByte(3)
      ..write(obj.response)
      ..writeByte(4)
      ..write(obj.wasHandled)
      ..writeByte(5)
      ..write(obj.factorId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarrierEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitTypeAdapter extends TypeAdapter<HabitType> {
  @override
  final int typeId = 13;

  @override
  HabitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitType.build;
      case 1:
        return HabitType.quit;
      case 2:
        return HabitType.timed;
      default:
        return HabitType.build;
    }
  }

  @override
  void write(BinaryWriter writer, HabitType obj) {
    switch (obj) {
      case HabitType.build:
        writer.writeByte(0);
        break;
      case HabitType.quit:
        writer.writeByte(1);
        break;
      case HabitType.timed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
