import 'package:hive/hive.dart';

part 'focus_log.g.dart';

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
