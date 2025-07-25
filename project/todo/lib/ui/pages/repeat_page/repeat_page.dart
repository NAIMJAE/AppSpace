import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/data/models/task_model/repeat_task.dart';
import 'package:todo/data/models/task_model/task_detail.dart';
import 'package:todo/data/view_models/task_view_model.dart';
import 'package:todo/ui/pages/modify_page/each_repeat_box.dart';
import 'package:todo/ui/widgets/appbar/repeat_appbar.dart';

class RepeatPage extends ConsumerStatefulWidget {
  const RepeatPage({super.key});

  @override
  ConsumerState<RepeatPage> createState() => _RepeatPageState();
}

class _RepeatPageState extends ConsumerState<RepeatPage> {
  Map<String, Map<RepeatTask, List<TaskDetail>>> repeatTaskMap = {
    '매일': <RepeatTask, List<TaskDetail>>{},
    '요일': <RepeatTask, List<TaskDetail>>{},
    '일자': <RepeatTask, List<TaskDetail>>{},
  };
  late TaskViewModel taskVM;

  @override
  void initState() {
    super.initState();
    taskVM = ref.read(taskProvider.notifier);
    _loadRepeatTask();
  }

  void _loadRepeatTask() async {
    repeatTaskMap = await taskVM.getAllRepeatTask();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double dragStartX = 0.0;
    double dragDistance = 0.0;
    const double swipeThreshold = 50.0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0XFFE9E9E9),
        appBar: repeatAppbar(context: context),
        body: GestureDetector(
          onHorizontalDragStart: (details) {
            dragStartX = details.globalPosition.dx;
          },
          onHorizontalDragUpdate: (details) {
            dragDistance = details.globalPosition.dx - dragStartX;
          },
          onHorizontalDragEnd: (details) {
            if (dragDistance > swipeThreshold) {
              // -> 오른쪽
              Navigator.pop(context);
            }
            // 리셋
            dragDistance = 0;
            dragStartX = 0;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              children: [
                Column(
                  children: [
                    // 매일 반복
                    _titleBox(title: '매일 반복'),
                    if (repeatTaskMap['매일']!.isNotEmpty)
                      ...repeatTaskMap['매일']!.entries.map((entry) {
                        final repeatTask = entry.key;
                        final details = entry.value;
                        return EachRepeatBox(
                          key: UniqueKey(),
                          repeatTask: repeatTask,
                          details: details,
                          loadFunction: () => _loadRepeatTask(),
                        );
                      }).toList(),
                    if (repeatTaskMap['매일']!.isEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('반복 일정이 없습니다.'),
                          Image.asset(
                            'assets/images/nemojin_question.png',
                            scale: 4,
                          ),
                        ],
                      ),

                    // 매주 반복
                    _titleBox(title: '매주 반복'),
                    if (repeatTaskMap['요일']!.isNotEmpty)
                      ...repeatTaskMap['요일']!.entries.map((entry) {
                        final repeatTask = entry.key;
                        final details = entry.value;
                        return EachRepeatBox(
                          key: UniqueKey(),
                          repeatTask: repeatTask,
                          details: details,
                          loadFunction: () => _loadRepeatTask(),
                        );
                      }).toList(),
                    if (repeatTaskMap['요일']!.isEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('반복 일정이 없습니다.'),
                          Image.asset(
                            'assets/images/nemojin_question.png',
                            scale: 4,
                          ),
                        ],
                      ),

                    // 매월 반복
                    _titleBox(title: '매월 반복'),
                    if (repeatTaskMap['일자']!.isNotEmpty)
                      ...repeatTaskMap['일자']!.entries.map((entry) {
                        final repeatTask = entry.key;
                        final details = entry.value;
                        return EachRepeatBox(
                          key: UniqueKey(),
                          repeatTask: repeatTask,
                          details: details,
                          loadFunction: () => _loadRepeatTask(),
                        );
                      }).toList(),
                    if (repeatTaskMap['일자']!.isEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('반복 일정이 없습니다.'),
                          Image.asset(
                            'assets/images/nemojin_question.png',
                            scale: 4,
                          ),
                        ],
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleBox({required String title}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
