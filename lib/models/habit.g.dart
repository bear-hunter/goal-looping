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
      succumbed: fields[1] as bool,
      note: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.succumbed)
      ..writeByte(2)
      ..write(obj.note);
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
      scriptedUseCount: fields[6] as int,
      logs: (fields[7] as List?)?.cast<HabitLog>(),
      createdAt: fields[8] as DateTime?,
      isActive: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.scriptedUseCount)
      ..writeByte(7)
      ..write(obj.logs)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isActive);
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
    );
  }

  @override
  void write(BinaryWriter writer, BarrierEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.occurredAt)
      ..writeByte(3)
      ..write(obj.response)
      ..writeByte(4)
      ..write(obj.wasHandled);
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
        return HabitType.limiting;
      case 1:
        return HabitType.scripted;
      default:
        return HabitType.limiting;
    }
  }

  @override
  void write(BinaryWriter writer, HabitType obj) {
    switch (obj) {
      case HabitType.limiting:
        writer.writeByte(0);
        break;
      case HabitType.scripted:
        writer.writeByte(1);
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
