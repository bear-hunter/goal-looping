// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spaced_repetition_topic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpacedRepetitionTopicAdapter extends TypeAdapter<SpacedRepetitionTopic> {
  @override
  final int typeId = 38;

  @override
  SpacedRepetitionTopic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpacedRepetitionTopic(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      name: fields[2] as String,
      lastReviewedAt: fields[3] as DateTime?,
      nextReviewAt: fields[4] as DateTime?,
      currentIntervalDays: fields[5] as int?,
      reviewCount: fields[6] as int,
      sortOrder: fields[7] as int,
      createdAt: fields[8] as DateTime?,
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SpacedRepetitionTopic obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.lastReviewedAt)
      ..writeByte(4)
      ..write(obj.nextReviewAt)
      ..writeByte(5)
      ..write(obj.currentIntervalDays)
      ..writeByte(6)
      ..write(obj.reviewCount)
      ..writeByte(7)
      ..write(obj.sortOrder)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpacedRepetitionTopicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
