import 'package:isar/isar.dart';

@collection
class PomodoroSession {
  Id id = Isar.autoIncrement; // Auto increment ID
  late DateTime dateTime; // Session date
  late int duration; // Duration in seconds
  late bool isBreak; // If session is a break
  late String breakType; // 'short' or 'long'
}
