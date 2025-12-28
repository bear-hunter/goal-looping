// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_design.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TreeDesignAdapter extends TypeAdapter<TreeDesign> {
  @override
  final int typeId = 22;

  @override
  TreeDesign read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TreeDesign(
      id: fields[0] as String,
      name: fields[1] as String,
      emoji: fields[2] as String,
      cost: fields[3] as int,
      isUnlocked: fields[4] as bool,
      colorHex: fields[5] as String,
      description: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TreeDesign obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.cost)
      ..writeByte(4)
      ..write(obj.isUnlocked)
      ..writeByte(5)
      ..write(obj.colorHex)
      ..writeByte(6)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeDesignAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
