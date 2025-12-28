// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflection_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReflectionReminderFrequencyAdapter
    extends TypeAdapter<ReflectionReminderFrequency> {
  @override
  final int typeId = 24;

  @override
  ReflectionReminderFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReflectionReminderFrequency.daily;
      case 1:
        return ReflectionReminderFrequency.twiceWeekly;
      case 2:
        return ReflectionReminderFrequency.weekly;
      case 3:
        return ReflectionReminderFrequency.disabled;
      default:
        return ReflectionReminderFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, ReflectionReminderFrequency obj) {
    switch (obj) {
      case ReflectionReminderFrequency.daily:
        writer.writeByte(0);
        break;
      case ReflectionReminderFrequency.twiceWeekly:
        writer.writeByte(1);
        break;
      case ReflectionReminderFrequency.weekly:
        writer.writeByte(2);
        break;
      case ReflectionReminderFrequency.disabled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReflectionReminderFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
