import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/data/models/task_model/task_group.dart';
import 'package:todo/data/view_models/task_view_model.dart';
import 'package:todo/ui/pages/home_page/widget/date_select_box.dart';
import 'package:todo/ui/pages/home_page/widget/each_task_box.dart';
import 'package:todo/ui/pages/write_page/write_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late TaskViewModel taskVM;
  late int doneCount;

  @override
  void initState() {
    super.initState();
    taskVM = ref.read(taskProvider.notifier);
  }

  /// 상단 날짜바에서 선택한 날짜로 변경하는 함수
  void changeDate({required DateTime newDateTime}) async {
    await taskVM.modifyNewDate(dateTime: newDateTime);
    setState(() {});
  }

  /// 완료된 일정 개수 계산
  void doneCountCalculation({required List<TaskGroup> taskGroups}) {
    doneCount = taskGroups.where((map) => map.task.isCompleted).length;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = ref.watch(taskProvider.notifier).selectedDate;
    List<TaskGroup> taskGroups = ref.watch(taskProvider);
    doneCountCalculation(taskGroups: taskGroups);

    double dragStartX = 0.0;
    double dragDistance = 0.0;
    const double swipeThreshold = 50.0; // 최소 스와이프 거리 (픽셀)

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0XFFE9E9E9),
        body: Column(
          children: [
            DateSelectBox(
              selectedDate: selectedDate,
              changeDate: (value) => changeDate(newDateTime: value),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              width: double.infinity,
              color: Colors.white,
              alignment: Alignment.center,
              child: taskGroups.isNotEmpty
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${taskGroups.length}개의 일정'),
                            const SizedBox(width: 12),
                            Text(
                                '${(doneCount / taskGroups.length * 100).toInt()}% 완료'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width - 40,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0XFFE9E9E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  width:
                                      (MediaQuery.of(context).size.width - 40) *
                                          (doneCount /
                                              (taskGroups.isEmpty
                                                  ? 1
                                                  : taskGroups.length)),
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0XFF27c47d),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: const Color(0XFFB2B2B2),
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragStart: (details) {
                  dragStartX = details.globalPosition.dx;
                },
                onHorizontalDragUpdate: (details) {
                  dragDistance = details.globalPosition.dx - dragStartX;
                },
                onHorizontalDragEnd: (details) {
                  if (dragDistance > swipeThreshold) {
                    // -> 오른쪽
                    changeDate(
                        newDateTime:
                            selectedDate.add(const Duration(days: -1)));
                  } else if (dragDistance < -swipeThreshold) {
                    // <- 왼쪽
                    changeDate(
                        newDateTime: selectedDate.add(const Duration(days: 1)));
                  }
                  // 리셋
                  dragDistance = 0;
                  dragStartX = 0;
                },
                child: Stack(
                  children: [
                    if (taskGroups.isEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '오늘의 일정이 없습니다.',
                              style: TextStyle(fontSize: 20),
                            ),
                            Image.asset(
                              'assets/images/nemojin_question.png',
                              scale: 2,
                            ),
                          ],
                        ),
                      ),
                    if (taskGroups.isNotEmpty)
                      ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: taskGroups.length,
                        itemBuilder: (context, index) {
                          final TaskGroup taskGroup = taskGroups[index];

                          return EachTaskBox(
                            key: UniqueKey(),
                            taskGroup: taskGroup,
                            modifyFunction: (value) =>
                                changeDate(newDateTime: value),
                            countingFunction: () =>
                                doneCountCalculation(taskGroups: taskGroups),
                          );
                        },
                      ),
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: _addTask(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addTask() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WritePage(),
          ),
        );
        changeDate(newDateTime: ref.read(taskProvider.notifier).selectedDate);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: const Color(0XFF27c47d),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 2,
                spreadRadius: 1,
                offset: Offset(1, 1),
              ),
            ]),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
