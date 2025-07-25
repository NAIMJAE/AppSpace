import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo/data/models/task_model/task.dart';
import 'package:todo/data/models/task_model/task_detail.dart';
import 'package:todo/data/models/task_model/task_group.dart';
import 'package:todo/data/view_models/task_view_model.dart';
import 'package:todo/ui/pages/modify_page/modify_page.dart';
import 'package:todo/ui/widgets/task_remove_widget.dart';

class EachTaskBox extends ConsumerStatefulWidget {
  final TaskGroup taskGroup;
  final Function(DateTime) modifyFunction;
  final Function() countingFunction;
  const EachTaskBox(
      {super.key,
      required this.taskGroup,
      required this.modifyFunction,
      required this.countingFunction});

  @override
  ConsumerState<EachTaskBox> createState() => _EachTaskBoxState();
}

class _EachTaskBoxState extends ConsumerState<EachTaskBox> {
  late Task task;
  late List<TaskDetail> subTasks = [];
  late TaskViewModel taskVM;
  bool checkState = true;
  bool isMore = false;

  @override
  void initState() {
    super.initState();
    task = widget.taskGroup.task;
    subTasks.addAll(widget.taskGroup.taskDetails);
    taskVM = ref.read(taskProvider.notifier);
  }

  /// 세부 일정 체크 박스 클릭 함수
  void _clickDetailCheckBox({required TaskDetail taskDetail}) async {
    if (!checkState) return;
    checkState = false;

    try {
      await taskVM.modifyTaskDetailToComplete(
          task: task, taskDetail: subTasks, clickDetail: taskDetail);

      setState(() {});
      await Future.delayed(
          const Duration(milliseconds: 300)); // 0.3초 동안 추가 클릭 방지
    } finally {
      checkState = true;
    }
    widget.countingFunction();
  }

  /// 일정 체크 박스 클릭 함수
  void _clickTaskCheckBox() async {
    if (!checkState) return;
    checkState = false;

    try {
      String result =
          await taskVM.modifyTaskToComplete(task: task, taskDetail: subTasks);

      if (result != '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            // 화면 위쪽에 표시
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
    } finally {
      checkState = true;
    }
    widget.countingFunction();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isMore = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(top: 16, left: 12, right: 12),
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
                  color: Color(int.parse(task.color)),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: subTasks.isNotEmpty
                              ? const BorderSide(
                                  color: Color(0XFFB2B2B2), width: 0.5)
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _doingBtn(),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: task.isCompleted
                                          ? const Color(0XFFB2B2B2)
                                          : const Color(0XFF222831),
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      decorationColor: const Color(0XFF222831),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                                if (task.repeatId != null)
                                  const SizedBox(width: 4),
                                if (task.repeatId != null)
                                  const Icon(
                                    Icons.repeat,
                                    size: 16,
                                    color: Color(0XFFB2B2B2),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (task.time != null)
                                Text(
                                  DateFormat('HH:mm').format(task.time!),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0XFF222831),
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
                                                taskGroup: widget.taskGroup),
                                          ),
                                        );
                                        widget.modifyFunction(ref
                                            .read(taskProvider.notifier)
                                            .selectedDate);
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
                                            task: task,
                                          ),
                                        );
                                        if (result) {
                                          await taskVM.removeTaskFromEachBox(
                                              taskGroup: widget.taskGroup);
                                          widget.modifyFunction(ref
                                              .read(taskProvider.notifier)
                                              .selectedDate);
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
                        ],
                      ),
                    ),
                    // 카드 내부 세부 일정 Column
                    if (subTasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            ...List.generate(
                              subTasks.length,
                              (index) => Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    _customCheckBox(subTask: subTasks[index]),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        subTasks[index].title,
                                        style: TextStyle(
                                          color: subTasks[index].isCompleted
                                              ? const Color(0XFFB2B2B2)
                                              : const Color(0XFF222831),
                                          decoration:
                                              subTasks[index].isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                          decorationColor:
                                              const Color(0XFF222831),
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

  Widget _doingBtn() {
    return GestureDetector(
      onTap: () => _clickTaskCheckBox(),
      child: Container(
        width: 54,
        height: 28,
        decoration: BoxDecoration(
          color: task.isCompleted
              ? const Color(0XFF27c47d)
              : const Color(0XFFE9E9E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: task.isCompleted
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 2),
                  Text(
                    '완료',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.update,
                    size: 16,
                    color: Color(0XFF222831),
                  ),
                  SizedBox(width: 2),
                  Text(
                    '아직',
                    style: TextStyle(
                      color: Color(0XFF222831),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _customCheckBox({required TaskDetail subTask}) {
    bool isChecked = subTask.isCompleted;
    return GestureDetector(
      onTap: () => _clickDetailCheckBox(taskDetail: subTask),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(
              color: isChecked ? Colors.transparent : const Color(0XFFB2B2B2),
              width: 1),
          borderRadius: BorderRadius.circular(4),
          color: isChecked ? const Color(0XFF27c47d) : Colors.transparent,
        ),
        child: Center(
          child: isChecked
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
      ),
    );
  }
}
