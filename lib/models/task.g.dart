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
      effort: fields[11] == null ? TaskEffort.quick : fields[11] as TaskEffort,
      impact: fields[12] == null ? TaskImpact.high : fields[12] as TaskImpact,
      addedToPriorityAt: fields[13] as DateTime?,
      abandonReason: fields[14] as TaskAbandonReason?,
      blockedByTaskId: fields[15] as String?,
      category: fields[16] == null ? 'General' : fields[16] as String,
      deadline: fields[17] as DateTime?,
      customTag: fields[18] as String?,
      marginalGainDescription: fields[19] as String?,
      isResearchTask: fields[20] == null ? false : fields[20] as bool,
      categoryId: fields[21] as String?,
      checklistItems: (fields[22] as List?)?.cast<String>(),
      checklistCompleted: (fields[23] as List?)?.cast<bool>(),
      priorityLevel:
          fields[24] == null ? PriorityLevel.none : fields[24] as PriorityLevel,
      note: fields[25] as String?,
      isPending: fields[26] == null ? false : fields[26] as bool,
      reminderTimes: (fields[27] as List?)?.cast<String>(),
      scheduledDate: fields[28] as DateTime?,
      scheduledTime: fields[29] as String?,
      isArchived: fields[30] == null ? false : fields[30] as bool,
      priority: fields[31] == null ? 0 : fields[31] as int,
      quadrant: fields[32] == null
          ? EisenhowerQuadrant.inbox
          : fields[32] as EisenhowerQuadrant,
      completionRewardGranted: fields[33] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(34)
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
      ..write(obj.customTag)
      ..writeByte(19)
      ..write(obj.marginalGainDescription)
      ..writeByte(20)
      ..write(obj.isResearchTask)
      ..writeByte(21)
      ..write(obj.categoryId)
      ..writeByte(22)
      ..write(obj.checklistItems)
      ..writeByte(23)
      ..write(obj.checklistCompleted)
      ..writeByte(24)
      ..write(obj.priorityLevel)
      ..writeByte(25)
      ..write(obj.note)
      ..writeByte(26)
      ..write(obj.isPending)
      ..writeByte(27)
      ..write(obj.reminderTimes)
      ..writeByte(28)
      ..write(obj.scheduledDate)
      ..writeByte(29)
      ..write(obj.scheduledTime)
      ..writeByte(30)
      ..write(obj.isArchived)
      ..writeByte(31)
      ..write(obj.priority)
      ..writeByte(32)
      ..write(obj.quadrant)
      ..writeByte(33)
      ..write(obj.completionRewardGranted);
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

class EisenhowerQuadrantAdapter extends TypeAdapter<EisenhowerQuadrant> {
  @override
  final int typeId = 36;

  @override
  EisenhowerQuadrant read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EisenhowerQuadrant.inbox;
      case 1:
        return EisenhowerQuadrant.focus;
      case 2:
        return EisenhowerQuadrant.schedule;
      case 3:
        return EisenhowerQuadrant.branch;
      case 4:
        return EisenhowerQuadrant.delete;
      default:
        return EisenhowerQuadrant.inbox;
    }
  }

  @override
  void write(BinaryWriter writer, EisenhowerQuadrant obj) {
    switch (obj) {
      case EisenhowerQuadrant.inbox:
        writer.writeByte(0);
        break;
      case EisenhowerQuadrant.focus:
        writer.writeByte(1);
        break;
      case EisenhowerQuadrant.schedule:
        writer.writeByte(2);
        break;
      case EisenhowerQuadrant.branch:
        writer.writeByte(3);
        break;
      case EisenhowerQuadrant.delete:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EisenhowerQuadrantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskEffortAdapter extends TypeAdapter<TaskEffort> {
  @override
  final int typeId = 26;

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
  final int typeId = 27;

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
  final int typeId = 28;

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
