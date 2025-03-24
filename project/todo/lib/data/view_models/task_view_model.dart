import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/data/database/dao/task_dao.dart';
import 'package:todo/data/models/task_model/repeat_task.dart';
import 'package:todo/data/models/task_model/task.dart';
import 'package:todo/data/models/task_model/task_detail.dart';
import 'package:todo/data/models/task_model/task_group.dart';
import 'package:todo/util/logger.dart';

class TaskViewModel extends Notifier<List<TaskGroup>> {
  final TaskDao _taskDao = TaskDao();

  late DateTime selectedDate;
  late int doneCount;

  @override
  List<TaskGroup> build() {
    selectedDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    getTaskList();
    return [];
  }

  // [▶ 조회 ◀]
  /// 선택한 일자의 일정 목록 조회 메서드
  /// - 비정기 일정과 반복 일정을 각각 조회하고 일정 세부 사항까지 조회하여 List<TaskGroup>로 매핑
  Future<void> getTaskList() async {
    // 비정기 일정 조회
    List<Task> taskList =
        await _taskDao.selectTaskListForDate(date: selectedDate);

    // 반복 일정 조회 (요일, 일)
    List<RepeatTask> repeatTaskList = await _taskDao.selectRepeatTaskList(
        day: selectedDate.day, week: selectedDate.weekday);

    // 비정기 일정의 세부 사항 조회
    Map<String, List<TaskDetail>> taskDetailMap = {};
    List<String> taskIds = taskList.map((task) => task.taskId).toList();
    if (taskIds.isNotEmpty) {
      dynamic result = await _taskDao.selectDetailTask(taskIds: taskIds);

      Map<String, List<TaskDetail>> detailMap = {};
      for (var each in result) {
        TaskDetail taskDetail = TaskDetail.fromMap(each);

        // putIfAbsent : 특정 키가 존재하지 않는 경우에만 추가 (키가 존재하면 아무일도 하지 않음)
        taskDetailMap.putIfAbsent(taskDetail.taskId, () => []);
        taskDetailMap[taskDetail.taskId]!.add(taskDetail);
      }

      taskDetailMap.addAll(detailMap);
    }

    // 반복 일정의 세부 사항 조회
    List<String> repeatIds =
        repeatTaskList.map((task) => task.repeatId).toList();
    if (repeatIds.isNotEmpty) {
      dynamic result = await _taskDao.selectDetailTask(taskIds: repeatIds);

      Map<String, List<TaskDetail>> detailMap = {};
      for (var each in result) {
        TaskDetail taskDetail = TaskDetail.fromMapToRepeat(each);

        // putIfAbsent : 특정 키가 존재하지 않는 경우에만 추가 (키가 존재하면 아무일도 하지 않음)
        taskDetailMap.putIfAbsent(taskDetail.taskId, () => []);
        taskDetailMap[taskDetail.taskId]!.add(taskDetail);
      }

      taskDetailMap.addAll(detailMap);
    }

    // 비정기 일정 TaskGroup로 매핑
    List<TaskGroup> taskGroupList = [];
    taskGroupList.addAll(
      taskList.map((task) {
        return TaskGroup(
          task: task,
          taskDetails: taskDetailMap[task.taskId] ?? [],
        );
      }).toList(),
    );

    // 반복 일정 TaskGroup로 매핑
    for (RepeatTask each in repeatTaskList) {
      bool isAlready = taskList.any((task) => task.repeatId == each.repeatId);
      if (isAlready) {
        continue;
      }

      Task newTask = Task.fromRepeatTask(each, selectedDate);
      List<TaskDetail> newTaskDetail = [];
      for (TaskDetail detail in taskDetailMap[each.repeatId] ?? []) {
        newTaskDetail.add(
          TaskDetail(
              detailId: detail.detailId,
              title: detail.title,
              isCompleted: detail.isCompleted,
              taskId: newTask.taskId),
        );
      }

      taskGroupList.add(
        TaskGroup(
          task: newTask,
          taskDetails: newTaskDetail,
        ),
      );
    }

    taskGroupList.sort((a, b) {
      // 시간이 null이면 우선순위를 높여 맨 위로 정렬
      if (a.task.time == null && b.task.time != null) return -1;
      if (a.task.time != null && b.task.time == null) return 1;

      // 시간이 있는 경우 오름차순(이른 시간 순) 정렬
      if (a.task.time != null && b.task.time != null) {
        return a.task.time!.compareTo(b.task.time!);
      }

      return 0; // 같은 값일 경우 순서 유지
    });

    logger.i('재랜더링');

    state.clear();
    state.addAll(taskGroupList);
  }

  /// Id값으로 반복 일정 조회 메서드
  /// @param
  /// - repeatId : 조회할 반복 일정 Id값
  Future<RepeatTask?> getRepeatTaskById({required String repeatId}) async {
    return await _taskDao.selectRepeatTaskById(repeatId: repeatId);
  }

  /// 모든 반복 일정 조회
  Future<Map<String, Map<RepeatTask, List<TaskDetail>>>>
      getAllRepeatTask() async {
    List<RepeatTask> repeatTasks = await _taskDao.selectAllRepeatTask();
    List<String> repeatIds = repeatTasks.map((map) => map.repeatId).toList();

    List<TaskDetail> taskDetails = [];
    if (repeatIds.isNotEmpty) {
      List<Map<String, dynamic>> detailMap =
          await _taskDao.selectDetailTask(taskIds: repeatIds);

      taskDetails = detailMap.map(TaskDetail.fromMap).toList();
    }

    final repeatTaskMap = {
      '매일': <RepeatTask, List<TaskDetail>>{},
      '요일': <RepeatTask, List<TaskDetail>>{},
      '일자': <RepeatTask, List<TaskDetail>>{},
    };

    for (final task in repeatTasks) {
      final details = taskDetails
          .where((detail) => detail.taskId == task.repeatId)
          .toList();

      switch (task.type) {
        case 0:
          repeatTaskMap['매일']![task] = details;
          break;
        case 1:
        case 2:
          repeatTaskMap['요일']![task] = details;
          break;
        case 3:
        case 4:
          repeatTaskMap['일자']![task] = details;
          break;
      }
    }

    logger.i(repeatTaskMap);
    return repeatTaskMap;
    // Map {'매일' : Map {repeatTask : List<taskDetail>} }
  }

  // [▶ 수정 ◀]
  /// 선택한 날짜 변경 메서드
  /// - 변동시킬 일수를 입력받아 selectedDate를 변경하고 변동된 날짜의 일정 목록을 호출
  /// @param
  /// - value : 변화할 일수 (ex 1, -1)
  void changeSelectedDate({required int value}) {
    DateTime newDate = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day + value);

    selectedDate = newDate;
  }

  /// 선택한 날짜 변경 메서드2
  /// - 변동시킬 일수를 입력받아 selectedDate를 변경하고 변동된 날짜의 일정 목록을 호출
  /// @param
  /// - dateTime : 변동시킬 날짜
  Future<void> modifyNewDate({required DateTime dateTime}) async {
    selectedDate = dateTime;
    await getTaskList();
  }

  /// 세부 일정 상태 변경 메서드에서 TaskDetail List의 상태를 확인하는 메서드
  /// @param
  /// - taskDetail : 상태를 확인할 TaskDetail List
  /// - clickDetail : 클릭한 TaskDetail
  /// - checkStatus : 확인할 상태 (true : 모두 완료인지 확인, false : 모두 미완료인지 확인)
  bool _checkDetailListStatus(
      {required List<TaskDetail> taskDetail,
      required TaskDetail clickDetail,
      required bool checkStatus}) {
    for (TaskDetail each in taskDetail) {
      if (each.detailId == clickDetail.detailId) continue;

      // checkStatus == true (모두 완료인지 확인) → 하나라도 미완료면 false 반환
      if (checkStatus && !each.isCompleted) return false;

      // checkStatus == false (모두 미완료인지 확인) → 하나라도 완료면 false 반환
      if (!checkStatus && each.isCompleted) return false;
    }
    return true; // 위 조건을 통과하면 전체 상태를 만족하는 것
  }

  /// 세부 일정 상태 변경 메서드
  /// @param
  /// - task : 클릭한 세부 일정의 부모 일정
  /// - taskDetail : 클릭한 세부 일정의 다른 세부 일정들
  /// - clickDetail : 클릭한 세부 일정
  Future<void> modifyTaskDetailToComplete({
    required Task task,
    required List<TaskDetail> taskDetail,
    required TaskDetail clickDetail,
  }) async {
    bool isRepeat = task.repeatId != null; // 반복 일정 여부
    bool isTaskCompleted = task.isCompleted; // 부모 일정의 완료 여부
    bool isDetailCompleted = clickDetail.isCompleted; // 클릭한 세부 사항의 완료 여부
    bool allCompleted = _checkDetailListStatus(
        taskDetail: taskDetail, clickDetail: clickDetail, checkStatus: true);
    bool allNotCompleted = _checkDetailListStatus(
        taskDetail: taskDetail, clickDetail: clickDetail, checkStatus: false);

    // 반복 일정 & 클릭한 세부 사항이 완료
    if (isRepeat && isDetailCompleted) {
      clickDetail.updateIsCompleted();

      if (allNotCompleted) {
        // 모두 미완료
        await _taskDao.deleteTask(taskId: task.taskId);
      } else {
        // 다른 항목 중 완료가 있음
        bool result = await _taskDao.updateTaskDetail(taskDetail: clickDetail);

        if (result && isTaskCompleted) {
          // 클릭한 세부 사항만 미완료
          task.updateIsCompleted();
          await _taskDao.updateTask(task: task);
        }
      }
    }

    // 반복 일정 & 클릭한 세부 사항이 미완료
    if (isRepeat && !isDetailCompleted) {
      clickDetail.updateIsCompleted();
      if (allNotCompleted) {
        // 세부 사항들 중 첫번째 완료 처리
        List<TaskDetail> newTaskDetail = taskDetail.map((each) {
          return TaskDetail(
            detailId: each.detailId,
            title: each.title,
            isCompleted: each.detailId == clickDetail.detailId,
            taskId: task.taskId,
          );
        }).toList();

        TaskGroup taskGroup = TaskGroup(
          task: task,
          taskDetails: newTaskDetail,
        );

        await _taskDao.insertTask(taskGroup: taskGroup);
        await _replaceTaskGroup(taskGroup: taskGroup);
      } else {
        // 다른 항목 중 완료가 있음
        bool result = await _taskDao.updateTaskDetail(taskDetail: clickDetail);

        if (result && allCompleted) {
          // 모든 세부 항목이 완료
          task.updateIsCompleted();
          await _taskDao.updateTask(task: task);
        }
      }
    }

    // 비정기 일정 & 클릭한 세부 사항이 완료
    if (!isRepeat && isDetailCompleted) {
      clickDetail.updateIsCompleted();
      bool result = await _taskDao.updateTaskDetail(taskDetail: clickDetail);

      if (result && isTaskCompleted) {
        // 클릭한 세부 사항만 미완료
        task.updateIsCompleted();
        await _taskDao.updateTask(task: task);
      }
    }

    // 비정기 일정 & 클릭한 세부 사항이 미완료
    if (!isRepeat && !isDetailCompleted) {
      clickDetail.updateIsCompleted();
      bool result = await _taskDao.updateTaskDetail(taskDetail: clickDetail);

      if (result && allCompleted) {
        // 모든 세부 사항 완료
        task.updateIsCompleted();
        await _taskDao.updateTask(task: task);
      }
    }
  }

  /// 일정 상태 변경 메서드
  /// @param
  /// - task : 상태를 변경할 일정
  /// - taskDetail : 변경할 일정의 세부 사항
  Future<String> modifyTaskToComplete(
      {required Task task, required List<TaskDetail> taskDetail}) async {
    bool isRepeat = task.repeatId != null; // 반복 일정 여부
    bool isDetail = taskDetail.isNotEmpty; // 세부 사항 존재 여부
    bool isCompleted = task.isCompleted; // 일정 완료 여부

    // 반복 일정 & 세부 사항 존재
    if (isRepeat && isDetail) {
      if (isCompleted) {
        return '';
      } else {
        return '세부 사항을 모두 완료해 주세요!';
      }
    }

    // 반복 일정 & 세부 사항 미존재
    if (isRepeat && !isDetail) {
      task.updateIsCompleted();

      if (isCompleted) {
        await _taskDao.deleteTask(taskId: task.taskId);
      } else {
        await _taskDao.insertTask(
            taskGroup: TaskGroup(task: task, taskDetails: []));
      }
      return '';
    }

    // 비정기 일정 & 세부 사항 존재
    if (!isRepeat && isDetail) {
      if (isCompleted) {
        return '';
      } else {
        return '세부 사항을 모두 완료해 주세요!';
      }
    }

    // 비정기 일정 & 세부 사항 미존재
    if (!isRepeat && !isDetail) {
      task.updateIsCompleted();

      await _taskDao.updateTask(task: task);
      return '';
    }

    return '';
  }

  /// TaskGroup의 상태가 변경되었을 때 DB 조회 없이 state에 상태를 반영하는 메서드
  Future<void> _replaceTaskGroup({required TaskGroup taskGroup}) async {
    state = List.from(state);
    int index =
        state.indexWhere((each) => each.task.taskId == taskGroup.task.taskId);

    if (index != -1) {
      state[index] = taskGroup; // 새로운 값 할당
      state = [...state];
    }
  }

  Future<bool> modifyTask({required Task task}) async {
    return await _taskDao.updateTask(task: task);
  }

  /// 반복 일정 수정
  /// @param
  /// - repeatTask : 수정할 반복 일정
  Future<bool> modifyRepeatTask({required RepeatTask repeatTask}) async {
    return await _taskDao.updateRepeatTask(repeatTask: repeatTask);
  }

  // [▶ 삽입 ◀]
  /// 비정기 일정 삽입
  /// @param
  /// - taskGroup : 삽입할 일정과 일정 세부사항 그룹
  Future<void> addTask({required TaskGroup taskGroup}) async {
    await _taskDao.insertTask(taskGroup: taskGroup);
    await getTaskList();
  }

  /// 반복 일정 삽입
  /// @param
  /// - repeatTask : 삽입할 비정기 일정
  /// - taskDetails : 삽입할 비정기 일정의 세부 사항 목록
  Future<void> addRepeatTask(
      {required RepeatTask repeatTask,
      required List<TaskDetail> taskDetails}) async {
    await _taskDao.insertRepeatTask(
        repeatTask: repeatTask, taskDetails: taskDetails);
    await getTaskList();
  }

  /// 세부 일정 삽입
  /// @param
  /// - taskDetails : 삽입할 세부 일정 목록
  Future<bool> addTaskDetail({required List<TaskDetail> taskDetails}) async {
    return await _taskDao.insertTaskDetail(taskDetails: taskDetails);
  }

  // [▶ 삭제 ◀]
  /// 일정 세부 사항들 삭제
  Future<bool> removeAllTaskDetail({required List<String> detailIds}) async {
    return await _taskDao.deleteAllTaskDetail(detailIds: detailIds);
  }

  /// 반복 일정의 세부 사항 삭제
  Future<bool> removeTaskDetailByRepeatId({required String repeatId}) async {
    return await _taskDao.deleteTaskDetailByRepeatId(repeatId: repeatId);
  }

  /// 완료처리 되어 비정기 일정 테이블에 저장된 일정에서 repeatId 제거
  /// @param
  /// - repeatId : 삭제할 반복 일정 Id값
  Future<void> removeRepeatIdAtTask({required String repeatId}) async {
    List<Task> taskList =
        await _taskDao.selectTaskByRepeatId(repeatId: repeatId);

    List<Task> newTaskList = taskList.map(
      (each) {
        each.repeatId = null;
        return each;
      },
    ).toList();

    for (Task each in newTaskList) {
      await _taskDao.updateTask(task: each);
    }
  }

  /// 반복 일정 테이블에서 반복 일정 삭제
  /// @param
  /// - repeatId : 삭제할 반복 일정 Id값
  Future<bool> removeRepeatTaskById({required String repeatId}) async {
    return await _taskDao.deleteRepeatTaskById(repeatId: repeatId);
  }

  ///
  Future<bool> removeTaskGroup({required String taskId}) async {
    return await _taskDao.deleteTaskGroup(taskId: taskId);
  }

  /// 일정 삭제
  Future<void> removeTaskFromEachBox({required TaskGroup taskGroup}) async {
    String removeTaskId = taskGroup.task.taskId;
    bool isRepeat = taskGroup.task.repeatId != null;

    // 비정기 일정 삭제
    await removeTaskGroup(taskId: removeTaskId);

    // 반복 일정 삭제
    if (isRepeat) {
      String removeRepeatId = taskGroup.task.repeatId!;
      await removeTaskDetailByRepeatId(repeatId: removeRepeatId);
      await removeRepeatTaskById(repeatId: removeRepeatId);
      await removeRepeatIdAtTask(repeatId: removeRepeatId);
    }
  }
}

final taskProvider = NotifierProvider<TaskViewModel, List<TaskGroup>>(
  () => TaskViewModel(),
);
