// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_availability.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeAvailabilityAdapter extends TypeAdapter<TimeAvailability> {
  @override
  final int typeId = 17;

  @override
  TimeAvailability read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TimeAvailability.absolutelyZero;
      case 1:
        return TimeAvailability.veryLittle;
      case 2:
        return TimeAvailability.some;
      case 3:
        return TimeAvailability.decent;
      case 4:
        return TimeAvailability.free;
      default:
        return TimeAvailability.absolutelyZero;
    }
  }

  @override
  void write(BinaryWriter writer, TimeAvailability obj) {
    switch (obj) {
      case TimeAvailability.absolutelyZero:
        writer.writeByte(0);
        break;
      case TimeAvailability.veryLittle:
        writer.writeByte(1);
        break;
      case TimeAvailability.some:
        writer.writeByte(2);
        break;
      case TimeAvailability.decent:
        writer.writeByte(3);
        break;
      case TimeAvailability.free:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeAvailabilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
