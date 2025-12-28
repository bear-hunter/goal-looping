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
    );
  }

  @override
  void write(BinaryWriter writer, Reflection obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.rawMarkdown);
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
