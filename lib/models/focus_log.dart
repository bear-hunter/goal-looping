import 'package:hive/hive.dart';

part 'focus_log.g.dart';

/// Hive does not serialize [Duration] as a built-in primitive.
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 40;

  @override
  Duration read(BinaryReader reader) =>
      Duration(microseconds: reader.readInt());

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMicroseconds);
  }
}

@HiveType(typeId: 23)
class FocusLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String taskId;

  @HiveField(2)
  String taskTitle;

  @HiveField(3)
  DateTime startTime;

  @HiveField(4)
  Duration duration;

  @HiveField(5)
  int completedPomodoros;

  @HiveField(6)
  List<String> distractions;

  FocusLog({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.startTime,
    required this.duration,
    this.completedPomodoros = 0,
    List<String>? distractions,
  }) : distractions = distractions ?? [];
}
