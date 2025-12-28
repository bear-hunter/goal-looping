// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 3;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      isPriority: fields[3] as bool,
      isCompleted: fields[4] as bool,
      source: fields[5] as TaskSource,
      createdAt: fields[6] as DateTime?,
      completedAt: fields[7] as DateTime?,
      linkedFactorIds: (fields[8] as List?)?.cast<String>(),
      experimentId: fields[9] as String?,
      sortOrder: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isPriority)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.source)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.linkedFactorIds)
      ..writeByte(9)
      ..write(obj.experimentId)
      ..writeByte(10)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskSourceAdapter extends TypeAdapter<TaskSource> {
  @override
  final int typeId = 12;

  @override
  TaskSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskSource.newEntry;
      case 1:
        return TaskSource.experiment;
      case 2:
        return TaskSource.backlog;
      default:
        return TaskSource.newEntry;
    }
  }

  @override
  void write(BinaryWriter writer, TaskSource obj) {
    switch (obj) {
      case TaskSource.newEntry:
        writer.writeByte(0);
        break;
      case TaskSource.experiment:
        writer.writeByte(1);
        break;
      case TaskSource.backlog:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
