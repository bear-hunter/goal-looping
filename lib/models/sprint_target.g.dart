// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_target.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SprintTargetAdapter extends TypeAdapter<SprintTarget> {
  @override
  final int typeId = 2;

  @override
  SprintTarget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SprintTarget(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      duration: fields[3] as SprintDuration,
      isCompleted: fields[4] as bool,
      isFailed: fields[8] == null ? false : fields[8] as bool,
      completedAt: fields[9] as DateTime?,
      createdAt: fields[5] as DateTime?,
      targetDate: fields[6] as DateTime?,
      linkedFactorIds: (fields[7] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SprintTarget obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.targetDate)
      ..writeByte(7)
      ..write(obj.linkedFactorIds)
      ..writeByte(8)
      ..write(obj.isFailed)
      ..writeByte(9)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SprintTargetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SprintDurationAdapter extends TypeAdapter<SprintDuration> {
  @override
  final int typeId = 11;

  @override
  SprintDuration read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SprintDuration.thirtyDays;
      case 1:
        return SprintDuration.fourteenDays;
      default:
        return SprintDuration.thirtyDays;
    }
  }

  @override
  void write(BinaryWriter writer, SprintDuration obj) {
    switch (obj) {
      case SprintDuration.thirtyDays:
        writer.writeByte(0);
        break;
      case SprintDuration.fourteenDays:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SprintDurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
