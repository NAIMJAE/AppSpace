import 'package:todo/data/models/task_model/task.dart';
import 'package:todo/data/models/task_model/task_detail.dart';

class TaskGroup {
  final Task task;
  final List<TaskDetail> taskDetails;

  TaskGroup({
    required this.task,
    required this.taskDetails,
  });

  @override
  String toString() {
    return 'TaskGroup{task: $task, taskDetails: $taskDetails}';
  }
}
