// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitEvaluationTypeAdapter extends TypeAdapter<HabitEvaluationType> {
  @override
  final int typeId = 32;

  @override
  HabitEvaluationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitEvaluationType.yesNo;
      case 1:
        return HabitEvaluationType.numeric;
      case 2:
        return HabitEvaluationType.timer;
      case 3:
        return HabitEvaluationType.checklist;
      default:
        return HabitEvaluationType.yesNo;
    }
  }

  @override
  void write(BinaryWriter writer, HabitEvaluationType obj) {
    switch (obj) {
      case HabitEvaluationType.yesNo:
        writer.writeByte(0);
        break;
      case HabitEvaluationType.numeric:
        writer.writeByte(1);
        break;
      case HabitEvaluationType.timer:
        writer.writeByte(2);
        break;
      case HabitEvaluationType.checklist:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEvaluationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitFrequencyTypeAdapter extends TypeAdapter<HabitFrequencyType> {
  @override
  final int typeId = 33;

  @override
  HabitFrequencyType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitFrequencyType.everyday;
      case 1:
        return HabitFrequencyType.specificDays;
      case 2:
        return HabitFrequencyType.specificDatesOfYear;
      case 3:
        return HabitFrequencyType.someDaysPerPeriod;
      case 4:
        return HabitFrequencyType.repeatEvery;
      default:
        return HabitFrequencyType.everyday;
    }
  }

  @override
  void write(BinaryWriter writer, HabitFrequencyType obj) {
    switch (obj) {
      case HabitFrequencyType.everyday:
        writer.writeByte(0);
        break;
      case HabitFrequencyType.specificDays:
        writer.writeByte(1);
        break;
      case HabitFrequencyType.specificDatesOfYear:
        writer.writeByte(2);
        break;
      case HabitFrequencyType.someDaysPerPeriod:
        writer.writeByte(3);
        break;
      case HabitFrequencyType.repeatEvery:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitFrequencyTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriorityLevelAdapter extends TypeAdapter<PriorityLevel> {
  @override
  final int typeId = 34;

  @override
  PriorityLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PriorityLevel.none;
      case 1:
        return PriorityLevel.low;
      case 2:
        return PriorityLevel.medium;
      case 3:
        return PriorityLevel.high;
      default:
        return PriorityLevel.none;
    }
  }

  @override
  void write(BinaryWriter writer, PriorityLevel obj) {
    switch (obj) {
      case PriorityLevel.none:
        writer.writeByte(0);
        break;
      case PriorityLevel.low:
        writer.writeByte(1);
        break;
      case PriorityLevel.medium:
        writer.writeByte(2);
        break;
      case PriorityLevel.high:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriorityLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
