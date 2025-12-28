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
      promotedToPriority: fields[3] as bool,
      reflectionId: fields[4] as String,
      taskId: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Experiment obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.promotedToPriority)
      ..writeByte(4)
      ..write(obj.reflectionId)
      ..writeByte(5)
      ..write(obj.taskId)
      ..writeByte(6)
      ..write(obj.createdAt);
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
        return ExperimentStatus.promoted;
      case 2:
        return ExperimentStatus.completed;
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
      case ExperimentStatus.promoted:
        writer.writeByte(1);
        break;
      case ExperimentStatus.completed:
        writer.writeByte(2);
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
