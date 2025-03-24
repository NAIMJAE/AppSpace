import 'package:uuid/uuid.dart';

class TaskDetail {
  final String detailId;
  final String title;
  bool isCompleted; // 0 : 진행 / 1 : 완료
  String taskId;

  TaskDetail({
    required this.detailId,
    required this.title,
    required this.isCompleted,
    required this.taskId,
  });

  Map<String, dynamic> toMap() {
    return {
      'detailId': detailId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'taskId': taskId,
    };
  }

  factory TaskDetail.fromMap(Map<String, dynamic> map) {
    return TaskDetail(
      detailId: map['detailId'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      taskId: map['taskId'],
    );
  }

  /// 반복 일정의 임시 세부 항목
  factory TaskDetail.fromMapToRepeat(Map<String, dynamic> map) {
    return TaskDetail(
      detailId: TaskDetail.createTaskDetailId(),
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      taskId: map['taskId'],
    );
  }

  /// taskDetailId 생성
  static String createTaskDetailId() {
    var uuid = const Uuid();
    return 'td${uuid.v4().substring(0, 8)}';
  }

  /// 완료 상태 변경
  void updateIsCompleted() {
    isCompleted = !isCompleted;
  }

  @override
  String toString() {
    return 'TaskDetail{detailId: $detailId, title: $title, isCompleted: $isCompleted, taskId: $taskId}';
  }
}
