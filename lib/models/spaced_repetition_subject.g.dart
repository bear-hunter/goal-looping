// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spaced_repetition_subject.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpacedRepetitionSubjectAdapter
    extends TypeAdapter<SpacedRepetitionSubject> {
  @override
  final int typeId = 31;

  @override
  SpacedRepetitionSubject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpacedRepetitionSubject(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCodePoint: fields[2] as int,
      iconFontFamily: fields[3] as String,
      colorValue: fields[4] as int,
      sortOrder: fields[5] as int,
      createdAt: fields[6] as DateTime?,
      isExpanded: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SpacedRepetitionSubject obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.iconFontFamily)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.sortOrder)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isExpanded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpacedRepetitionSubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
