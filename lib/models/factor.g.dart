// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'factor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FactorAdapter extends TypeAdapter<Factor> {
  @override
  final int typeId = 1;

  @override
  Factor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Factor(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as FactorType,
      targetLevel: fields[3] as int,
      currentLevel: fields[4] as int,
      description: fields[5] as String,
      goalId: fields[6] as String,
      lastUpdated: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Factor obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.targetLevel)
      ..writeByte(4)
      ..write(obj.currentLevel)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.goalId)
      ..writeByte(7)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FactorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FactorTypeAdapter extends TypeAdapter<FactorType> {
  @override
  final int typeId = 10;

  @override
  FactorType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FactorType.knowledge;
      case 1:
        return FactorType.skill;
      case 2:
        return FactorType.attribute;
      case 3:
        return FactorType.process;
      case 4:
        return FactorType.resource;
      default:
        return FactorType.knowledge;
    }
  }

  @override
  void write(BinaryWriter writer, FactorType obj) {
    switch (obj) {
      case FactorType.knowledge:
        writer.writeByte(0);
        break;
      case FactorType.skill:
        writer.writeByte(1);
        break;
      case FactorType.attribute:
        writer.writeByte(2);
        break;
      case FactorType.process:
        writer.writeByte(3);
        break;
      case FactorType.resource:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FactorTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
