import 'package:intl/intl.dart';
import 'package:todo/data/models/task_model/repeat_task.dart';
import 'package:uuid/uuid.dart';

class Task {
  final String taskId;
  final String title;
  final DateTime date; // 날짜 (시간 없이 날짜만 저장)
  final DateTime? time; // 시간을 선택 안하면 NULL
  bool isCompleted; // 0 : 진행 / 1 : 완료
  final String color;
  String? repeatId;

  Task({
    required this.taskId,
    required this.title,
    required this.date,
    this.time,
    required this.isCompleted,
    required this.color,
    this.repeatId,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'title': title,
      'date': DateFormat('yyyy-MM-dd').format(date), // 날짜를 TEXT로 변환
      'time': time != null ? DateFormat('HH:mm').format(time!) : null,
      'isCompleted': isCompleted ? 1 : 0, // Boolean을 1 또는 0으로 변환
      'color': color,
      'repeatId': repeatId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['taskId'],
      title: map['title'],
      date: DateTime.parse(map['date']), // TEXT → DateTime 변환
      time: map['time'] != null
          ? DateFormat('HH:mm').parse(map['time']) // TEXT → DateTime 변환
          : null,
      isCompleted: map['isCompleted'] == 1, // 1이면 true, 0이면 false
      color: map['color'],
      repeatId: map['repeatId'],
    );
  }

  factory Task.fromRepeatTask(RepeatTask repeatTask, DateTime selectedDate) {
    return Task(
      taskId: Task.createTaskId(),
      title: repeatTask.title,
      date: selectedDate,
      time: repeatTask.time,
      isCompleted: false,
      color: repeatTask.color,
      repeatId: repeatTask.repeatId,
    );
  }

  /// taskId 생성
  static String createTaskId() {
    var uuid = const Uuid();
    return 'ta${uuid.v4().substring(0, 8)}';
  }

  /// 완료 상태 변경
  void updateIsCompleted() {
    isCompleted = !isCompleted;
  }

  @override
  String toString() {
    return 'Task{taskId: $taskId, title: $title, date: $date, time: $time, isCompleted: $isCompleted, color: $color, repeatId: $repeatId}';
  }
}
