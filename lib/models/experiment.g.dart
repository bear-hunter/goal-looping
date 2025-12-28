// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExperimentAdapter extends TypeAdapter<Experiment> {
  @override
  final int typeId = 7;

  @override
  Experiment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Experiment(
      id: fields[0] as String,
      description: fields[1] as String,
      status: fields[2] as ExperimentStatus,
      reflectionId: fields[3] as String,
      createdAt: fields[4] as DateTime?,
      groupId: fields[5] as String?,
      cycleCount: fields[6] as int,
      startedAt: fields[7] as DateTime?,
      completedAt: fields[8] as DateTime?,
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Experiment obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.reflectionId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.groupId)
      ..writeByte(6)
      ..write(obj.cycleCount)
      ..writeByte(7)
      ..write(obj.startedAt)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExperimentStatusAdapter extends TypeAdapter<ExperimentStatus> {
  @override
  final int typeId = 16;

  @override
  ExperimentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExperimentStatus.pending;
      case 1:
        return ExperimentStatus.inProgress;
      case 2:
        return ExperimentStatus.completed;
      case 3:
        return ExperimentStatus.cycled;
      case 4:
        return ExperimentStatus.archived;
      default:
        return ExperimentStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ExperimentStatus obj) {
    switch (obj) {
      case ExperimentStatus.pending:
        writer.writeByte(0);
        break;
      case ExperimentStatus.inProgress:
        writer.writeByte(1);
        break;
      case ExperimentStatus.completed:
        writer.writeByte(2);
        break;
      case ExperimentStatus.cycled:
        writer.writeByte(3);
        break;
      case ExperimentStatus.archived:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
