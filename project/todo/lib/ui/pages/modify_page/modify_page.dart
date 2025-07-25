import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/data/models/task_model/repeat_task.dart';
import 'package:todo/data/models/task_model/task.dart';
import 'package:todo/data/models/task_model/task_detail.dart';
import 'package:todo/data/models/task_model/task_group.dart';
import 'package:todo/data/view_models/task_view_model.dart';
import 'package:todo/ui/widgets/appbar/modify_appbar.dart';
import 'package:todo/ui/widgets/date_picker_widget.dart';
import 'package:todo/ui/widgets/time_picker_widget.dart';
import 'package:todo/util/logger.dart';
import 'package:todo/util/parse_date.dart';
import 'package:todo/util/parse_repeat.dart';

class ModifyPage extends ConsumerStatefulWidget {
  final TaskGroup taskGroup;
  const ModifyPage({required this.taskGroup, super.key});

  @override
  ConsumerState<ModifyPage> createState() => _ModifyPageState();
}

class _ModifyPageState extends ConsumerState<ModifyPage> {
  late TaskViewModel taskVM;

  late DateTime taskDate; // 할일 날짜
  String? taskTime; // 할일 시간
  TextEditingController _titleController = TextEditingController(); // 할일 제목
  List<TextEditingController> _detailController = []; // 세부 항목 목록
  String taskColor = '0XFF27c47d';
  Map<String, String?> regularMap = {'선택안함': null}; // 반복 여부

  @override
  void initState() {
    super.initState();
    taskVM = ref.read(taskProvider.notifier);
    initMapping(taskGroup: widget.taskGroup);
    logger.i(widget.taskGroup);
  }

  /// init 매핑
  void initMapping({required TaskGroup taskGroup}) async {
    Task task = taskGroup.task;
    List<TaskDetail> taskDetails = taskGroup.taskDetails;

    taskDate = task.date;
    taskTime = ParseDate.dateTimeParseToString(time: task.time);
    _titleController.text = widget.taskGroup.task.title;
    for (TaskDetail each in taskDetails) {
      _detailController.add(TextEditingController(text: each.title));
    }
    taskColor = task.color;

    if (task.repeatId != null) {
      RepeatTask? repeatTask =
          await taskVM.getRepeatTaskById(repeatId: task.repeatId!);

      if (repeatTask == null) return;

      String type = ParseRepeat.repeatTypeIntToString(type: repeatTask.type);
      String? interval = repeatTask.interval;

      regularMap.clear();
      regularMap.addAll({type: interval});
      setState(() {});
    }
  }

  /// 수정 사항 저장
  void _addTaskComplete() async {
    // 필수 항목 체크 날짜, 제목, 색상, 반복설정
    String title = _titleController.text.trim();

    if (title.isEmpty) {
      _writePageSnackBar(content: '제목을 입력해주세요.', color: Colors.red);
      return;
    }

    TaskGroup originTaskGroup = widget.taskGroup;
    String repeatKey = regularMap.entries.first.key;

    bool isOriginRepeat = originTaskGroup.task.repeatId != null; // 원본의 타입
    bool isModifyRepeat = repeatKey != '선택안함'; // 수정본의 타입

    // 반복 일정 -> 반복 일정
    if (isOriginRepeat && isModifyRepeat) {
      RepeatTask repeatTask = RepeatTask(
        repeatId: originTaskGroup.task.repeatId!,
        title: title,
        startDate: taskDate,
        time: ParseDate.stringParseToDateTime(date: taskDate, time: taskTime),
        color: taskColor,
        type: ParseRepeat.repeatTypeStringToInt(type: repeatKey),
        interval: regularMap[repeatKey],
      );

      // 세부 항목 체크
      // 기존의 반복 일정 세부 사항 모두 DB 삭제
      if (originTaskGroup.taskDetails.isNotEmpty) {
        await taskVM.removeTaskDetailByRepeatId(
            repeatId: originTaskGroup.task.repeatId!);
      }

      // 새로운 세부 사항 목록 생성
      List<String> details = _checkTaskDetail();
      List<TaskDetail> taskDetails = _createTaskDetail(
          details: details, taskId: originTaskGroup.task.repeatId!);

      // repeatTask는 수정
      await taskVM.modifyRepeatTask(repeatTask: repeatTask);
      // taskDetails는 삽입
      await taskVM.addTaskDetail(taskDetails: taskDetails);
    }

    // 반복 일정 -> 비정기 일정
    if (isOriginRepeat && !isModifyRepeat) {
      Task task = originTaskGroup.task;

      logger.i(originTaskGroup);

      // 완료처리 되어 비정기 일정 테이블에 저장된 일정에서 repeatId 제거
      await taskVM.removeRepeatIdAtTask(repeatId: task.repeatId!);

      // 반복 일정 테이블에서 반복 일정 삭제
      await taskVM.removeRepeatTaskById(repeatId: task.repeatId!);

      // 수정하고자 하는 반복 일정이 비정기 일정 테이블에 저장된 경우
      await taskVM.removeTaskGroup(taskId: task.taskId);

      // 새로운 비정기 일정 생성
      Task newTask = Task(
        taskId: task.taskId,
        title: title,
        date: taskDate,
        time: ParseDate.stringParseToDateTime(date: taskDate, time: taskTime),
        isCompleted: false,
        color: taskColor,
      );

      // 세부 항목 체크
      // 기존의 반복 일정 세부 사항 모두 DB 삭제
      if (originTaskGroup.taskDetails.isNotEmpty) {
        await taskVM.removeTaskDetailByRepeatId(
            repeatId: originTaskGroup.task.repeatId!);
      }

      // 새로운 세부 사항 목록 생성
      List<String> details = _checkTaskDetail();
      List<TaskDetail> taskDetails =
          _createTaskDetail(details: details, taskId: task.taskId);

      // 새로운 비정기 일정 저장
      await taskVM.addTask(
        taskGroup: TaskGroup(task: newTask, taskDetails: taskDetails),
      );
    }

    // 비정기 일정 -> 반복 일정
    if (!isOriginRepeat && isModifyRepeat) {
      /// - 비정기 -> 반복
      /// -- 기존의 비정기 항목에 repeatId 추가
      /// -- 새로운 반복 일정 생성
      /// --- 이 과정에서 기존의 taskDetail을 복사해서 taskId를 repeatId로 가지게 생성
      Task task = originTaskGroup.task;

      // 새로운 반복 일정 생성
      RepeatTask newRepeatTask = RepeatTask(
        repeatId: RepeatTask.createRepeatId(),
        title: title,
        startDate: taskDate,
        time: ParseDate.stringParseToDateTime(date: taskDate, time: taskTime),
        color: taskColor,
        type: ParseRepeat.repeatTypeStringToInt(type: repeatKey),
        interval: regularMap[repeatKey],
      );

      // 기존의 비정기 일정 수정
      Task newTask = Task(
        taskId: task.taskId,
        title: title,
        date: taskDate,
        time: ParseDate.stringParseToDateTime(date: taskDate, time: taskTime),
        isCompleted: false,
        color: taskColor,
        repeatId: newRepeatTask.repeatId,
      );

      if (originTaskGroup.taskDetails.isNotEmpty) {
        await _removeAllTaskDetail(taskDetails: originTaskGroup.taskDetails);
      }

      // 새로운 반복 일정의 세부 사항 생성
      List<String> details = _checkTaskDetail();
      List<TaskDetail> repeatTaskDetails =
          _createTaskDetail(details: details, taskId: newRepeatTask.repeatId);

      // 새로운 비정기 일정의 세부 사항 생성
      List<TaskDetail> taskDetails =
          _createTaskDetail(details: details, taskId: task.taskId);

      // 저장
      await taskVM.modifyTask(task: newTask);
      await taskVM.addTaskDetail(taskDetails: taskDetails);
      await taskVM.addRepeatTask(
          repeatTask: newRepeatTask, taskDetails: repeatTaskDetails);
    }

    // 비정기 일정 -> 비정기 일정
    if (!isOriginRepeat && !isModifyRepeat) {
      Task task = originTaskGroup.task;
      Task newTask = Task(
        taskId: task.taskId,
        title: title,
        date: taskDate,
        time: ParseDate.stringParseToDateTime(date: taskDate, time: taskTime),
        isCompleted: false,
        color: taskColor,
      );

      // 세부 항목 체크
      // 기존의 세부 사항 모두 DB 삭제
      if (originTaskGroup.taskDetails.isNotEmpty) {
        await _removeAllTaskDetail(taskDetails: originTaskGroup.taskDetails);
      }

      // 새로운 세부 사항 목록 생성
      List<String> details = _checkTaskDetail();
      List<TaskDetail> taskDetails =
          _createTaskDetail(details: details, taskId: task.taskId);

      // Task는 수정
      await taskVM.modifyTask(task: newTask);
      // taskDetails는 삽입
      await taskVM.addTaskDetail(taskDetails: taskDetails);
    }

    _writePageSnackBar(
      content: '일정이 수정되었습니다.',
      color: const Color(0XFF27c47d),
    );
    Navigator.pop(context);
  }

  /// 일정 세부 사항 삭제
  Future<bool> _removeAllTaskDetail(
      {required List<TaskDetail> taskDetails}) async {
    List<String> detailIds = taskDetails.map((each) => each.detailId).toList();
    return await taskVM.removeAllTaskDetail(detailIds: detailIds);
  }

  /// 세부 일정 생성
  List<TaskDetail> _createTaskDetail(
      {required List<String> details, required String taskId}) {
    List<TaskDetail> taskDetails = [];
    for (String each in details) {
      if (each == '') {
        continue;
      }
      taskDetails.add(
        TaskDetail(
          detailId: TaskDetail.createTaskDetailId(),
          title: each,
          isCompleted: false,
          taskId: taskId,
        ),
      );
    }
    return taskDetails;
  }

  /// 세부 일정 체크
  List<String> _checkTaskDetail() {
    List<String> result = [];

    for (TextEditingController each in _detailController) {
      result.add(each.text.trim());
    }
    return result;
  }

  /// 스낵바
  void _writePageSnackBar({required String content, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // 화면 위쪽에 표시
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 선택한 날짜 가져오기
  void getNewDateForModal({required DateTime dateTime}) {
    taskDate = dateTime;
    if (regularMap.entries.first.key == '일주일') {
      regularMap['일주일'] = '${dateTime.weekday}';
    }

    if (regularMap.entries.first.key == '한달') {
      regularMap['한달'] = '${dateTime.day}';
    }
    setState(() {});
  }

  /// 선택한 시간 가져오기
  void getNewTimeForModal({required String? newTime}) {
    taskTime = newTime;
    setState(() {});
  }

  /// 세부 항목 추가
  void _addNewDetail() {
    _detailController.add(TextEditingController());
    setState(() {});
  }

  /// 세부 항목 삭제
  void _removeTaskDetail({required int index}) {
    _detailController.removeAt(index);
    setState(() {});
  }

  /// 반복 설정 선택
  void _selectTaskRegular({required String item}) {
    regularMap.clear();
    switch (item) {
      case '선택안함':
        regularMap.addAll({item: null});
        setState(() {});
        return;
      case '매일':
        regularMap.addAll({item: '1'});
        setState(() {});
        return;
      case '일주일':
        regularMap.addAll({item: '${taskDate.weekday}'});
        setState(() {});
        return;
      case '한달':
        regularMap.addAll({item: '${taskDate.day}'});
        setState(() {});
        return;
      case '요일 반복':
        regularMap.addAll({item: null});
        setState(() {});
        return;
      case '일자 반복':
        regularMap.addAll({item: null});
        setState(() {});
        return;
    }
  }

  /// 반복 설정 요일 선택
  void _selectRegularWeek({required String item}) {
    String? oldWeek = regularMap[regularMap.keys.first];
    bool isGet = oldWeek?.contains(item) ?? false;

    List<String> oldArr = oldWeek?.split(',') ?? [];
    if (isGet) {
      oldArr.remove(item);
    } else {
      oldArr.add(item);
    }
    oldArr.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    regularMap[regularMap.keys.first] =
        oldArr.isEmpty ? null : oldArr.join(',');
    setState(() {});
  }

  /// 반복 설정 일자 선택
  void _selectRegularDay({required String item}) {
    setState(() {
      if (regularMap.containsKey('일자 반복')) {
        List<String> selectedDays = (regularMap['일자 반복']?.split(',') ?? [])
            .where((e) => e.isNotEmpty)
            .toList();

        if (selectedDays.contains(item)) {
          selectedDays.remove(item);
        } else {
          selectedDays.add(item);
        }
        selectedDays.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

        regularMap['일자 반복'] =
            selectedDays.isEmpty ? null : ',${selectedDays.join(',')},';
      }
    });
  }

  /// 일정 색상 선택
  void _selectTaskColor({required String color}) {
    taskColor = color;
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
        appBar: modifyAppbar(context: context),
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
            padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // 일정
                  _modifyCard(childWidget: _dateAndTitle()),
                  const SizedBox(height: 12),

                  // 세부 항목
                  _modifyCard(childWidget: _taskDetailBox()),
                  const SizedBox(height: 12),

                  // 색상 선택
                  _modifyCard(childWidget: _taskColorBox()),
                  const SizedBox(height: 12),

                  // 정기 항목
                  _modifyCard(childWidget: _regularTaskBox()),
                  const SizedBox(height: 12),

                  // 안내 문구
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Color(0XFF222831),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '이미 완료된 반복 일정은 수정되지 않습니다.',
                        style: TextStyle(
                          color: Color(0XFF222831),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () => _addTaskComplete(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0XFF27c47d),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0XFFB2B2B2),
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '일정 수정',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 정기 항목
  Widget _regularTaskBox() {
    List<String> basicList = ['선택안함', '매일', '일주일', '한달'];
    List<String> detailList = ['요일 반복', '일자 반복'];
    List<String> weekList = ['7', '1', '2', '3', '4', '5', '6'];
    double small = (MediaQuery.of(context).size.width - 100);
    double big = (MediaQuery.of(context).size.width - 76);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '반복 설정',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...List.generate(
              basicList.length,
              (index) => _quickBasicItem(item: basicList[index], size: small),
            )
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...List.generate(
              detailList.length,
              (index) => _quickDetailItem(item: detailList[index], size: big),
            )
          ],
        ),
        if (regularMap.entries.first.key == '요일 반복')
          _weekdaySelectBox(weekList: weekList, size: small),
        if (regularMap.entries.first.key == '일자 반복') _daySelectBox(size: small),
        if (!['선택안함', '요일 반복', '일자 반복'].contains(regularMap.entries.first.key))
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _repeatAlarm(weekList: weekList),
            ),
          ),
      ],
    );
  }

  // 반복 알림 멘트
  Widget _repeatAlarm({required List<String> weekList}) {
    if (regularMap.entries.first.key == '매일') {
      return Text('매일 반복됩니다.');
    }
    if (regularMap.entries.first.key == '일주일') {
      String week =
          ParseDate.weekIntParseToString(week: regularMap.entries.first.value);
      return Text('매주 $week요일에 반복됩니다.');
    }
    if (regularMap.entries.first.key == '한달') {
      return Text('매달 ${regularMap.entries.first.value}일에 반복됩니다.');
    }
    return const SizedBox.shrink(); // 빈 공간
  }

  // 일자 반복 선택
  Widget _daySelectBox({required double size}) {
    String? selectedDay = regularMap[regularMap.keys.first];
    List<String> dayList = selectedDay?.split(',') ?? [];

    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ...List.generate(
                31,
                (index) {
                  String day = (index + 1).toString();
                  bool isSelected = dayList.contains(day); // 선택 여부 확인

                  return GestureDetector(
                    onTap: () {
                      _selectRegularDay(item: day);
                    },
                    child: Container(
                      width: size / 9.5,
                      height: size / 9.5,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0XFF27c47d) : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0XFFB2B2B2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0XFF222831),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (regularMap.entries.first.value != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
                '매달 ${regularMap.entries.first.value?.replaceAll(RegExp(r'^,|,$'), '')}일에 반복됩니다.'),
          ),
      ],
    );
  }

  // 요일 반복 선택
  Widget _weekdaySelectBox(
      {required List<String> weekList, required double size}) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...List.generate(
              weekList.length,
              (index) => GestureDetector(
                onTap: () => _selectRegularWeek(item: weekList[index]),
                child: Container(
                  width: size / 7,
                  height: (MediaQuery.of(context).size.width - 32) / 10,
                  decoration: BoxDecoration(
                    color: regularMap.entries.first.value
                                ?.contains(weekList[index]) ??
                            false
                        ? const Color(0XFF27c47d)
                        : Colors.transparent,
                    border: Border.all(
                      color: regularMap.entries.first.value
                                  ?.contains(weekList[index]) ??
                              false
                          ? Colors.transparent
                          : const Color(0XFFB2B2B2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      ParseDate.weekIntParseToString(week: weekList[index]),
                      style: TextStyle(
                        color: regularMap.entries.first.value
                                    ?.contains(weekList[index]) ??
                                false
                            ? Colors.white
                            : const Color(0XFF222831),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (regularMap.entries.first.value != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
                '매주 ${ParseDate.weekIntListParseToString(week: regularMap.entries.first.value)}요일에 반복됩니다.'),
          ),
      ],
    );
  }

  // 반복 항목 중 디테일 선택 항목
  Widget _quickDetailItem({required String item, required double size}) {
    return GestureDetector(
      onTap: () => _selectTaskRegular(item: item),
      child: Container(
        width: size / 2,
        height: (MediaQuery.of(context).size.width - 32) / 10,
        decoration: BoxDecoration(
          color: regularMap.entries.first.key == item
              ? const Color(0XFF27c47d)
              : Colors.transparent,
          border: Border.all(
            color: regularMap.entries.first.key == item
                ? Colors.transparent
                : const Color(0XFFB2B2B2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            item,
            style: TextStyle(
              color: regularMap.entries.first.key == item
                  ? Colors.white
                  : const Color(0XFF222831),
            ),
          ),
        ),
      ),
    );
  }

  // 반복 항목 중 기본 선택 항목
  Widget _quickBasicItem({required String item, required double size}) {
    return GestureDetector(
      onTap: () => _selectTaskRegular(item: item),
      child: Container(
        width: size / 4,
        height: (MediaQuery.of(context).size.width - 32) / 10,
        decoration: BoxDecoration(
          color: regularMap.entries.first.key == item
              ? const Color(0XFF27c47d)
              : Colors.transparent,
          border: Border.all(
            color: regularMap.entries.first.key == item
                ? Colors.transparent
                : const Color(0XFFB2B2B2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            item,
            style: TextStyle(
              color: regularMap.entries.first.key == item
                  ? Colors.white
                  : const Color(0XFF222831),
            ),
          ),
        ),
      ),
    );
  }

  // 색상 선택
  Widget _taskColorBox() {
    List<String> colorList = [
      '0XFF27c47d',
      '0XFFFF6B6B',
      '0XFFFFD93D',
      '0XFF4D96FF',
      '0XFFAA2EE6',
      '0XFF4A4947',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '색상 선택',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...List.generate(
              colorList.length,
              (index) {
                return GestureDetector(
                  onTap: () => _selectTaskColor(color: colorList[index]),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(colorList[index])),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: taskColor == colorList[index]
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // 세부 항목 박스
  Widget _taskDetailBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '세부 항목',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          _detailController.length,
          (index) =>
              _taskDetail(controller: _detailController[index], index: index),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _addNewDetail(),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            padding: const EdgeInsets.all(6),
            color: const Color(0XFFB2B2B2),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: Color(0XFF222831),
                ),
                SizedBox(width: 8),
                Text(
                  '추가',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0XFF222831),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 각각의 세부 항목
  Widget _taskDetail(
      {required TextEditingController controller, required int index}) {
    return _inputStyle(
      childWidget: Row(
        children: [
          const Icon(
            Icons.check,
            size: 24,
            color: Color(0XFF222831),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              strutStyle: StrutStyle.disabled,
              style: const TextStyle(fontSize: 16, color: Color(0XFF222831)),
              decoration: const InputDecoration(
                hintText: '세부 항목',
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _removeTaskDetail(index: index),
            child: const Icon(
              Icons.close,
              size: 24,
              color: Color(0XFF222831),
            ),
          ),
        ],
      ),
    );
  }

  // 날짜와 제목
  Widget _dateAndTitle() {
    double size = (MediaQuery.of(context).size.width - 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '새 일정',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // 날짜와 시간
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (context) => DatePickerWidget(
                  selectedDate: taskDate,
                  getDateFunction: (value) =>
                      getNewDateForModal(dateTime: value),
                ),
              ),
              child: _inputStyle(
                childWidget: SizedBox(
                  width: size / 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.date_range_rounded,
                        size: 24,
                        color: Color(0XFF222831),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ParseDate.dateTimeToString(taskDate),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0XFF222831),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (context) => TimePickerWidget(
                  selectedTime: taskTime,
                  getTimeFunction: (value) =>
                      getNewTimeForModal(newTime: value),
                ),
              ),
              child: _inputStyle(
                childWidget: SizedBox(
                  width: size / 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 24,
                        color: Color(0XFF222831),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        taskTime ?? '선택 안함',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0XFF222831),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 제목
        _inputStyle(
          childWidget: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.work_history_outlined,
                size: 24,
                color: Color(0XFF222831),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _titleController,
                  strutStyle: StrutStyle.disabled,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0XFF222831)),
                  decoration: const InputDecoration(
                    hintText: '제목',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 아래선 Container 스타일
  Widget _inputStyle({required Widget childWidget}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(
            color: Color(0XFFB2B2B2),
            width: 1,
          ),
        ),
      ),
      child: childWidget,
    );
  }

  // 흰 상자
  Widget _modifyCard({required Widget childWidget}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0XFFB2B2B2),
            blurRadius: 4,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: childWidget,
    );
  }
}
