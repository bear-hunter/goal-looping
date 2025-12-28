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
      effort: fields[11] as TaskEffort,
      impact: fields[12] as TaskImpact,
      addedToPriorityAt: fields[13] as DateTime?,
      abandonReason: fields[14] as TaskAbandonReason?,
      blockedByTaskId: fields[15] as String?,
      category: fields[16] as String,
      deadline: fields[17] as DateTime?,
      customTag: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(19)
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
      ..write(obj.sortOrder)
      ..writeByte(11)
      ..write(obj.effort)
      ..writeByte(12)
      ..write(obj.impact)
      ..writeByte(13)
      ..write(obj.addedToPriorityAt)
      ..writeByte(14)
      ..write(obj.abandonReason)
      ..writeByte(15)
      ..write(obj.blockedByTaskId)
      ..writeByte(16)
      ..write(obj.category)
      ..writeByte(17)
      ..write(obj.deadline)
      ..writeByte(18)
      ..write(obj.customTag);
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

class TaskEffortAdapter extends TypeAdapter<TaskEffort> {
  @override
  final int typeId = 20;

  @override
  TaskEffort read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskEffort.quick;
      case 1:
        return TaskEffort.deep;
      default:
        return TaskEffort.quick;
    }
  }

  @override
  void write(BinaryWriter writer, TaskEffort obj) {
    switch (obj) {
      case TaskEffort.quick:
        writer.writeByte(0);
        break;
      case TaskEffort.deep:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskEffortAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskImpactAdapter extends TypeAdapter<TaskImpact> {
  @override
  final int typeId = 21;

  @override
  TaskImpact read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskImpact.high;
      case 1:
        return TaskImpact.maintenance;
      default:
        return TaskImpact.high;
    }
  }

  @override
  void write(BinaryWriter writer, TaskImpact obj) {
    switch (obj) {
      case TaskImpact.high:
        writer.writeByte(0);
        break;
      case TaskImpact.maintenance:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskImpactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskAbandonReasonAdapter extends TypeAdapter<TaskAbandonReason> {
  @override
  final int typeId = 22;

  @override
  TaskAbandonReason read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskAbandonReason.noTime;
      case 1:
        return TaskAbandonReason.tooHard;
      case 2:
        return TaskAbandonReason.notImportant;
      case 3:
        return TaskAbandonReason.completed;
      default:
        return TaskAbandonReason.noTime;
    }
  }

  @override
  void write(BinaryWriter writer, TaskAbandonReason obj) {
    switch (obj) {
      case TaskAbandonReason.noTime:
        writer.writeByte(0);
        break;
      case TaskAbandonReason.tooHard:
        writer.writeByte(1);
        break;
      case TaskAbandonReason.notImportant:
        writer.writeByte(2);
        break;
      case TaskAbandonReason.completed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAbandonReasonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
