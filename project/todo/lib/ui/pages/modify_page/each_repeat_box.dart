import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo/data/models/task_model/repeat_task.dart';
import 'package:todo/data/models/task_model/task.dart';
import 'package:todo/data/models/task_model/task_detail.dart';
import 'package:todo/data/models/task_model/task_group.dart';
import 'package:todo/data/view_models/task_view_model.dart';
import 'package:todo/ui/pages/modify_page/modify_page.dart';
import 'package:todo/ui/widgets/task_remove_widget.dart';
import 'package:todo/util/parse_repeat.dart';

class EachRepeatBox extends ConsumerStatefulWidget {
  final RepeatTask repeatTask;
  final List<TaskDetail> details;
  final Function() loadFunction;

  const EachRepeatBox(
      {required this.repeatTask,
      required this.details,
      required this.loadFunction,
      super.key});

  @override
  ConsumerState<EachRepeatBox> createState() => _EachRepeatBoxState();
}

class _EachRepeatBoxState extends ConsumerState<EachRepeatBox>
    with TickerProviderStateMixin {
  bool isMore = false;
  bool isDetail = false;
  late RepeatTask repeatTask;
  late TaskViewModel taskVM;
  late List<TaskDetail> details;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    repeatTask = widget.repeatTask;
    details = widget.details;
    taskVM = ref.read(taskProvider.notifier);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  /// 반복 일정 수정을 위한 TaskGroup 생성
  TaskGroup _createTaskGroup() {
    Task newTask = Task.fromRepeatTask(repeatTask, repeatTask.startDate);
    List<TaskDetail> newTaskDetails = details.map((map) {
      return TaskDetail(
        detailId: map.detailId,
        title: map.title,
        isCompleted: map.isCompleted,
        taskId: newTask.taskId,
      );
    }).toList();

    return TaskGroup(task: newTask, taskDetails: newTaskDetails);
  }

  /// 반복 일정 수정을 위한 Task 생성
  Task _createTask() {
    return Task.fromRepeatTask(repeatTask, repeatTask.startDate);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isDetail) {
          _slideController.reverse(); // 사라짐 애니메이션
        } else {
          _slideController.forward(); // 나타남 애니메이션
        }

        setState(() {
          isMore = false;
          isDetail = !isDetail;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0XFFB2B2B2),
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 색상 바
              Container(
                width: 8,
                decoration: BoxDecoration(
                  color: Color(int.parse(repeatTask.color)),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    // 카드 내부 일정 제목 Row
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: details.isNotEmpty
                              ? const BorderSide(
                                  color: Color(0xFFB2B2B2), width: 0.5)
                              : BorderSide.none,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  repeatTask.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0XFF222831),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (!isMore)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isMore = !isMore;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.more_vert,
                                    size: 24,
                                    color: Color(0XFFB2B2B2),
                                  ),
                                ),
                              if (isMore)
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ModifyPage(
                                                taskGroup: _createTaskGroup()),
                                          ),
                                        );
                                        widget.loadFunction();
                                      },
                                      child: const Icon(
                                        Icons.mode,
                                        size: 24,
                                        color: Color(0XFF27c47d),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () async {
                                        bool result = await showDialog(
                                          context: context,
                                          builder: (context) =>
                                              TaskRemoveWidget(
                                            task: _createTask(),
                                          ),
                                        );
                                        if (result) {
                                          await taskVM.removeTaskFromEachBox(
                                              taskGroup: _createTaskGroup());
                                          widget.loadFunction();
                                        }
                                      },
                                      child: const Icon(
                                        Icons.delete_forever,
                                        size: 24,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    ParseRepeat.repeatTypeToString(
                                        type: repeatTask.type,
                                        interval: repeatTask.interval!),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFFB2B2B2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (repeatTask.time != null)
                                    Text(
                                      DateFormat('HH:mm')
                                          .format(repeatTask.time!),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFFB2B2B2),
                                      ),
                                    ),
                                ],
                              ),
                              if (details.isNotEmpty)
                                const Icon(
                                  Icons.keyboard_double_arrow_down,
                                  size: 18,
                                  color: Color(0XFFB2B2B2),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 카드 내부 세부 일정 Column
                    if (details.isNotEmpty)
                      SizeTransition(
                        sizeFactor: _slideController,
                        axisAlignment: -1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              ...List.generate(
                                details.length,
                                (index) => Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Color(0XFF222831),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          details[index].title,
                                          style: const TextStyle(
                                            color: Color(0XFF222831),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
