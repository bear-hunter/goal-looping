// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReflectionAdapter extends TypeAdapter<Reflection> {
  @override
  final int typeId = 6;

  @override
  Reflection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reflection(
      id: fields[0] as String,
      experience: fields[1] as String,
      reflection: fields[2] as String,
      abstraction: fields[3] as String,
      experimentIds: (fields[4] as List?)?.cast<String>(),
      linkedFactorIds: (fields[5] as List?)?.cast<String>(),
      isFollowUp: fields[6] as bool,
      previousReflectionId: fields[7] as String?,
      createdAt: fields[8] as DateTime?,
      rawMarkdown: fields[9] as String?,
      targetFactorId: fields[10] as String?,
      previousExperimentId: fields[11] as String?,
      groupId: fields[12] as String?,
      marginalGainDescription: fields[13] as String?,
      eventSequence: fields[14] as String?,
      feelings: fields[15] as String?,
      difficulties: fields[16] as String?,
      challengeResponse: fields[17] as String?,
      triggers: fields[18] as String?,
      whyBehavior: fields[19] as String?,
      crossLifePatterns: fields[20] as String?,
      isManualEntry: fields[21] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Reflection obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.experience)
      ..writeByte(2)
      ..write(obj.reflection)
      ..writeByte(3)
      ..write(obj.abstraction)
      ..writeByte(4)
      ..write(obj.experimentIds)
      ..writeByte(5)
      ..write(obj.linkedFactorIds)
      ..writeByte(6)
      ..write(obj.isFollowUp)
      ..writeByte(7)
      ..write(obj.previousReflectionId)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.rawMarkdown)
      ..writeByte(10)
      ..write(obj.targetFactorId)
      ..writeByte(11)
      ..write(obj.previousExperimentId)
      ..writeByte(12)
      ..write(obj.groupId)
      ..writeByte(13)
      ..write(obj.marginalGainDescription)
      ..writeByte(14)
      ..write(obj.eventSequence)
      ..writeByte(15)
      ..write(obj.feelings)
      ..writeByte(16)
      ..write(obj.difficulties)
      ..writeByte(17)
      ..write(obj.challengeResponse)
      ..writeByte(18)
      ..write(obj.triggers)
      ..writeByte(19)
      ..write(obj.whyBehavior)
      ..writeByte(20)
      ..write(obj.crossLifePatterns)
      ..writeByte(21)
      ..write(obj.isManualEntry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReflectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
