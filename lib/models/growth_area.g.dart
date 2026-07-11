// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_area.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GrowthAreaAdapter extends TypeAdapter<GrowthArea> {
  @override
  final int typeId = 1;

  @override
  GrowthArea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GrowthArea(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as GrowthAreaType,
      targetLevel: fields[3] as int,
      currentLevel: fields[4] as int,
      description: fields[5] as String,
      goalId: fields[6] as String,
      lastUpdated: fields[7] as DateTime?,
      targetDescription: fields[8] == null ? '' : fields[8] as String,
      currentDescription: fields[9] == null ? '' : fields[9] as String,
      linkedHabitIds: (fields[10] as List?)?.cast<String>(),
      isActiveFocus: fields[11] == null ? false : fields[11] as bool,
      lastWorkedOn: fields[12] as DateTime?,
      healthPercent: fields[13] == null ? 100.0 : fields[13] as double,
      treeDesignId: fields[14] == null ? 'oak' : fields[14] as String,
      confidenceLevel: fields[15] == null ? 3 : fields[15] as int,
      needsResearch: fields[16] == null ? false : fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GrowthArea obj) {
    writer
      ..writeByte(17)
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
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.targetDescription)
      ..writeByte(9)
      ..write(obj.currentDescription)
      ..writeByte(10)
      ..write(obj.linkedHabitIds)
      ..writeByte(11)
      ..write(obj.isActiveFocus)
      ..writeByte(12)
      ..write(obj.lastWorkedOn)
      ..writeByte(13)
      ..write(obj.healthPercent)
      ..writeByte(14)
      ..write(obj.treeDesignId)
      ..writeByte(15)
      ..write(obj.confidenceLevel)
      ..writeByte(16)
      ..write(obj.needsResearch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthAreaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GrowthAreaTypeAdapter extends TypeAdapter<GrowthAreaType> {
  @override
  final int typeId = 10;

  @override
  GrowthAreaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GrowthAreaType.knowledge;
      case 1:
        return GrowthAreaType.skill;
      case 2:
        return GrowthAreaType.attribute;
      case 3:
        return GrowthAreaType.process;
      case 4:
        return GrowthAreaType.resource;
      default:
        return GrowthAreaType.knowledge;
    }
  }

  @override
  void write(BinaryWriter writer, GrowthAreaType obj) {
    switch (obj) {
      case GrowthAreaType.knowledge:
        writer.writeByte(0);
        break;
      case GrowthAreaType.skill:
        writer.writeByte(1);
        break;
      case GrowthAreaType.attribute:
        writer.writeByte(2);
        break;
      case GrowthAreaType.process:
        writer.writeByte(3);
        break;
      case GrowthAreaType.resource:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthAreaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
