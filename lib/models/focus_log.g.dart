// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusLogAdapter extends TypeAdapter<FocusLog> {
  @override
  final int typeId = 23;

  @override
  FocusLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusLog(
      id: fields[0] as String,
      taskId: fields[1] as String,
      taskTitle: fields[2] as String,
      startTime: fields[3] as DateTime,
      duration: fields[4] as Duration,
      completedPomodoros: fields[5] as int,
      distractions: (fields[6] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FocusLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.taskTitle)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.completedPomodoros)
      ..writeByte(6)
      ..write(obj.distractions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
