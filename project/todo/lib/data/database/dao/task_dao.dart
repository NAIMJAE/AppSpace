import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/data/database/database_helper.dart';
import 'package:todo/data/models/task_model/repeat_task.dart';
import 'package:todo/data/models/task_model/task.dart';
import 'package:todo/data/models/task_model/task_detail.dart';
import 'package:todo/data/models/task_model/task_group.dart';
import 'package:todo/util/logger.dart';
import 'package:todo/util/parse_date.dart';

class TaskDao {
  // [▶ 조회 ◀]
  /// 비정기 일정 조회
  /// @param
  /// - date : 조회할 날짜 (SQLite는 DateTime형식 지원 X -> String으로 변경)
  /// @return
  /// - List<Task> : 해당 일자의 비정기 일정 목록
  Future<List<Task>> selectTaskListForDate({required DateTime date}) async {
    String dateString = ParseDate.dateTimeToString(date);
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT * FROM tasks
      WHERE date = ?
      ''',
      [dateString],
    );

    return result.map((map) => Task.fromMap(map)).toList();
  }

  /// 반복 일정 조회
  /// @param
  /// - day : 조회할 일자 (일자 반복 조회)
  /// - week : 조회할 요일 (요일 반복 조회)
  /// @return
  /// - List<RepeatTask> : 해당 일자의 반복 일정 목록
  Future<List<RepeatTask>> selectRepeatTaskList(
      {required int day, required int week}) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT * FROM repeat_task
      WHERE (type = 0) 
         OR (type = 1 AND interval LIKE ?) 
         OR (type = 2 AND interval LIKE ?)
         OR (type = 3 AND interval LIKE ?)
         OR (type = 4 AND interval LIKE ?)
      ''',
      ['%$week%', '%$week%', '%,$day,%', '%,$day,%'],
    );

    return result.map((map) => RepeatTask.fromMap(map)).toList();
  }

  /// 일정 세부 사항 조회
  /// @param
  /// - taskIds : 조회할 일정의 id값 목록
  /// @return
  /// - List<Map<String, dynamic>> : 조회한 일정 세부 사항 목록 (파싱은 밖에서)
  Future<List<Map<String, dynamic>>> selectDetailTask(
      {required List<String> taskIds}) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT * FROM task_detail
      WHERE taskId IN (${List.filled(taskIds.length, '?').join(', ')})
      ''',
      taskIds,
    );

    return result;
  }

  /// 반복 일정 Id값으로 조회
  /// @param
  /// - repeatId : 조회할 Id값
  Future<RepeatTask?> selectRepeatTaskById({required String repeatId}) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT * FROM repeat_task
      WHERE repeatId = ?
      ''',
      [repeatId],
    );

    if (result.isNotEmpty) {
      return RepeatTask.fromMap(result[0]);
    } else {
      return null;
    }
  }

  /// repeatId로 비정기 일정 조회
  /// @param
  /// - repeatId : 조회할 비정기 일정 Id값
  Future<List<Task>> selectTaskByRepeatId({required String repeatId}) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT * FROM tasks
      WHERE repeatId = ?
      ''',
      [repeatId],
    );

    return result.map((map) => Task.fromMap(map)).toList();
  }

  /// 모든 반복 일정 조회
  Future<List<RepeatTask>> selectAllRepeatTask() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM repeat_task
      ''');
    return result.map((map) => RepeatTask.fromMap(map)).toList();
  }

  /// 홈 위젯 데이터 출력을 위한 일주일치 일정 조회
  Future<List<Map<String, dynamic>>> selectTaskAfter7Day() async {
    final db = await DatabaseHelper.instance.database;

    final now = DateTime.now();
    final today = ParseDate.dateTimeToString(now);
    final sevenDaysLater =
        ParseDate.dateTimeToString(now.add(const Duration(days: 7)));

    final List<Map<String, dynamic>> taskResult = await db.rawQuery(
      '''
      SELECT * FROM tasks
      WHERE date BETWEEN ? AND ?
      ORDER BY date ASC
      ''',
      [today, sevenDaysLater],
    );

    List<Map<String, dynamic>> taskMap = taskResult
        .map(
          (each) => {
            'title': each['title'],
            'date': each['date'],
            'time': each['time'],
            'color': each['color'], //??
            'repeatId': each['repeatId'],
          },
        )
        .toList();

    List<Map<String, dynamic>> repeatMap = [];
    for (int i = 0; i < 8; i++) {
      DateTime targetDate = now.add(Duration(days: i));
      int day = targetDate.day;
      int week = targetDate.weekday % 7;
      final List<Map<String, dynamic>> repeatResult = await db.rawQuery(
        '''
        SELECT * FROM repeat_task
        WHERE (type = 0) 
           OR (type = 1 AND interval LIKE ?) 
           OR (type = 2 AND interval LIKE ?)
           OR (type = 3 AND interval LIKE ?)
           OR (type = 4 AND interval LIKE ?)
        ''',
        ['%$week%', '%$week%', '%$day%', '%$day%'],
      );
      repeatMap.addAll(repeatResult
          .map(
            (each) => {
              'title': each['title'],
              'date': ParseDate.dateTimeToString(targetDate),
              'time': each['time'],
              'color': each['color'], //??
              'repeatId': each['repeatId'],
            },
          )
          .toList());
    }

    return mergeAndSortTasks(taskMap: taskMap, repeatMap: repeatMap);
  }

  /// 합치기
  List<Map<String, dynamic>> mergeAndSortTasks({
    required List<Map<String, dynamic>> taskMap,
    required List<Map<String, dynamic>> repeatMap,
  }) {
    // 1. taskMap에서 사용된 repeatId 목록 추출
    final Set<dynamic> usedRepeatIds =
        taskMap.map((e) => e['repeatId']).where((id) => id != null).toSet();

    // 2. repeatMap 중 중복되지 않은 것만 필터링
    final filteredRepeatMap =
        repeatMap.where((e) => !usedRepeatIds.contains(e['repeatId'])).toList();

    // 3. 두 리스트 합치기
    final mergedList = [...taskMap, ...filteredRepeatMap];

    // 4. 정렬: 날짜 오름차순 → 시간 null 우선 → 시간 오름차순
    mergedList.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);

      if (dateA.isBefore(dateB)) return -1;
      if (dateA.isAfter(dateB)) return 1;

      // 날짜가 같을 경우
      final timeA = a['time'];
      final timeB = b['time'];

      // 시간 null 우선 정렬
      if (timeA == null && timeB != null) return -1;
      if (timeA != null && timeB == null) return 1;
      if (timeA == null && timeB == null) return 0;

      // 시간 비교 (예: "09:00", "14:30" 형식 가정)
      return timeA.compareTo(timeB);
    });

    return mergedList;
  }

  // [▶ 삽입 ◀]
  /// 비정기 일정 삽입
  /// @param
  /// - taskGroup : 삽입할 일정과 일정 세부사항 그룹
  Future<bool> insertTask({required TaskGroup taskGroup}) async {
    final db = await DatabaseHelper.instance.database;
    Map<String, dynamic> task = taskGroup.task.toMap();
    List<TaskDetail> taskDetails = taskGroup.taskDetails;
    int result = 0;

    // Task 삽입
    result += await db.insert('tasks', task);

    // TaskDetail 삽입
    Batch batch = db.batch();
    for (var each in taskDetails) {
      batch.insert('task_detail', each.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();

    if (result > 0) {
      return true;
    } else {
      return false;
    }
  }

  /// 반복 일정 삽입
  /// @param
  /// - repeatTask : 삽입할 비정기 일정
  /// - taskDetails : 삽입할 비정기 일정의 세부 사항 목록
  Future<void> insertRepeatTask(
      {required RepeatTask repeatTask,
      required List<TaskDetail> taskDetails}) async {
    final db = await DatabaseHelper.instance.database;
    Map<String, dynamic> taskMap = repeatTask.toMap();

    // RepeatTask 삽입
    await db.insert('repeat_task', taskMap);

    // TaskDetail 삽입
    Batch batch = db.batch();
    for (var each in taskDetails) {
      batch.insert('task_detail', each.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  /// 세부 일정 삽입
  /// @param
  /// - taskDetails : 삽입할 세부 일정 목록
  Future<bool> insertTaskDetail({required List<TaskDetail> taskDetails}) async {
    final db = await DatabaseHelper.instance.database;

    // transaction : 내부적으로 BEGIN TRANSACTION이 실행
    return await db.transaction((txn) async {
      try {
        Batch batch = txn.batch();
        for (var each in taskDetails) {
          batch.insert('task_detail', each.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        List<Object?> results = await batch.commit();

        if (results.length != taskDetails.length) {
          throw Exception("일부 삽입 실패");
        }
        return true;
      } catch (e) {
        return false;
      }
    });
  }

  // [▶ 수정 ◀]
  /// 일정 상태 수정
  /// @param
  /// - task : 변동할 일정
  Future<bool> updateTask({required Task task}) async {
    final db = await DatabaseHelper.instance.database;
    int count = await db.rawUpdate(
      '''
    UPDATE tasks
    SET title = ?, date = ?, time = ?, isCompleted = ?, color = ?, repeatId = ?
    WHERE taskId = ?
    ''',
      [
        task.title,
        DateFormat('yyyy-MM-dd').format(task.date),
        task.time != null ? DateFormat('HH:mm').format(task.time!) : null,
        task.isCompleted ? 1 : 0,
        task.color,
        task.repeatId,
        task.taskId,
      ],
    );

    return count > 0;
  }

  /// 일정 세부 사항 상태 수정
  /// @param
  /// - taskDetail : 변동할 일정 세부 사항
  Future<bool> updateTaskDetail({required TaskDetail taskDetail}) async {
    final db = await DatabaseHelper.instance.database;
    int count = await db.rawUpdate(
      '''
      UPDATE task_detail
      SET title = ?, isCompleted = ?, taskId = ?
      WHERE detailId = ?
      ''',
      [
        taskDetail.title,
        taskDetail.isCompleted ? 1 : 0,
        taskDetail.taskId,
        taskDetail.detailId,
      ],
    );

    return count > 0;
  }

  /// 반복 일정 수정
  /// @param
  /// - repeatTask : 수정할 반복 일정
  Future<bool> updateRepeatTask({required RepeatTask repeatTask}) async {
    final db = await DatabaseHelper.instance.database;
    Map<String, dynamic> taskMap = repeatTask.toMap();

    int count = await db.rawUpdate(
      '''
      UPDATE repeat_task
      SET title = ?, startDate = ?, time = ?, color = ?, type = ?, interval = ?
      WHERE repeatId = ?
      ''',
      [
        taskMap['title'],
        taskMap['startDate'],
        taskMap['time'],
        taskMap['color'],
        taskMap['type'],
        taskMap['interval'],
        taskMap['repeatId'],
      ],
    );

    return count > 0;
  }

  // [▶ 삭제 ◀]
  /// 일정 삭제
  /// @param
  /// - taskId : 삭제할 일정의 Id값
  Future<bool> deleteTask({required String taskId}) async {
    final db = await DatabaseHelper.instance.database;
    int count = await db.rawDelete(
      '''
      DELETE FROM tasks
      WHERE taskId = ?
      ''',
      [taskId],
    );

    await db.rawDelete(
      '''
      DELETE FROM task_detail
      WHERE taskId = ?
      ''',
      [taskId],
    );

    return count > 0;
  }

  /// 일정 세부 사항들 삭제
  /// @param
  /// - detailIds : 삭제할 세부 사항의 Id값 목록
  Future<bool> deleteAllTaskDetail({required List<String> detailIds}) async {
    final db = await DatabaseHelper.instance.database;
    int count = await db.rawDelete(
      '''
      DELETE FROM task_detail
      WHERE detailId IN (${List.filled(detailIds.length, '?').join(', ')})
      ''',
      detailIds,
    );
    return count > 0;
  }

  /// 일정 세부 사항 삭제
  /// @param
  /// - detailIds : 삭제할 세부 사항의 Id값
  Future<bool> deleteTaskDetailByRepeatId({required String repeatId}) async {
    final db = await DatabaseHelper.instance.database;
    int count = await db.rawDelete(
      '''
      DELETE FROM task_detail
      WHERE taskId = ?
      ''',
      [repeatId],
    );
    return count > 0;
  }

  /// 반복 일정 Id값으로 삭제
  /// @param
  /// - repeatId : 삭제할 반복 일정의 Id값
  Future<bool> deleteRepeatTaskById({required String repeatId}) async {
    final db = await DatabaseHelper.instance.database;
    int count = await db.rawDelete(
      '''
      DELETE FROM repeat_task
      WHERE repeatId = ?
      ''',
      [repeatId],
    );

    return count > 0;
  }

  /// 비정기 일정과 세부 사항 함께 삭제
  /// @param
  /// - taskId : 삭제할 비정기 일정의 Id값
  Future<bool> deleteTaskGroup({required String taskId}) async {
    final db = await DatabaseHelper.instance.database;
    int count = await db.rawDelete(
      '''
      DELETE FROM tasks
      WHERE taskId = ?
      ''',
      [taskId],
    );

    await db.rawDelete(
      '''
      DELETE FROM task_detail
      WHERE taskId = ?
      ''',
      [taskId],
    );
    return count > 0;
  }
}
