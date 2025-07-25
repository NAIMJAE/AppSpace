import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/data/models/task_model/repeat_task.dart';
import 'package:todo/data/models/task_model/task.dart';
import 'package:todo/data/models/task_model/task_detail.dart';

/// 싱글톤 패턴을 사용하여 DB 인스턴스를 하나만 유지
/// static final을 사용해 전역에서 DatabaseHelper._instance를 호출해 동일한 인스턴스 사용
/// static Database? = _database 는 한 번만 데이터베이스를 생성하고 공유
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// 데이터베이스가 이미 생성되었다면 기존 DB를 반환
  /// 처음 호출될 때 _initDB를 실행해 데이터베이스를 생성 후 저장
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo.db'); // SQLite 파일명
    return _database!;
  }

  /// 데이터베이스 초기화 및 열기
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath(); // 데이터베이스 경로 반환
    final path = join(dbPath, fileName); // 새로운 파일명을 포함한 전체 경로 생성

    // 데이터베이스가 없으면 새로 생성, 존재하면 열기
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
        //await _insertDummyData(db); // 더미 데이터 삽입
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateOldIntervalFormat(db); // 마이그레이션 실행
        }
      },
    );
  }

  Future<void> _migrateOldIntervalFormat(Database db) async {
    final result = await db.query('repeat_task');
    for (final row in result) {
      final id = row['repeatId'];
      final interval = row['interval'] as String?;
      if (interval != null &&
          !interval.startsWith(',') &&
          !interval.endsWith(',')) {
        final newInterval = ',$interval,';
        await db.update(
          'repeat_task',
          {'interval': newInterval},
          where: 'repeatId = ?',
          whereArgs: [id],
        );
      }
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE tasks (
        taskId TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT,
        isCompleted INTEGER NOT NULL,
        color TEXT NOT NULL,
        repeatId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE task_detail (
        detailId TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        taskId TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE repeat_task (
        repeatId TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        startDate TEXT NOT NULL,
        time TEXT,
        color TEXT NOT NULL,
        type INTEGER NOT NULL,
        interval TEXT NOT NULL
      )
    ''');
  }

  Future<void> _insertDummyData(Database db) async {
    // // ✅ 3개의 Task 더미 데이터
    // List<Task> dummyTasks = [
    //   Task(
    //     taskId: Task.createTaskId(),
    //     title: '회의 준비',
    //     date: DateTime(2025, 3, 15),
    //     time: DateTime(2025, 3, 15, 10, 30),
    //     isCompleted: false,
    //     color: '0xFFFF6B6B',
    //     repeatId: null,
    //   ),
    //   Task(
    //     taskId: Task.createTaskId(),
    //     title: '운동하기',
    //     date: DateTime(2025, 3, 17),
    //     time: DateTime(2025, 3, 17, 18, 00),
    //     isCompleted: false,
    //     color: '0xFFFFD93D',
    //     repeatId: null,
    //   ),
    //   Task(
    //     taskId: Task.createTaskId(),
    //     title: '책 읽기',
    //     date: DateTime(2025, 3, 19),
    //     time: DateTime(2025, 3, 19, 21, 00),
    //     isCompleted: false,
    //     color: '0xFF4D96FF',
    //     repeatId: null,
    //   ),
    // ];
    //
    // for (var task in dummyTasks) {
    //   await db.insert('tasks', task.toMap());
    // }
    //
    // // ✅ 3개의 TaskDetail 더미 데이터
    // List<TaskDetail> dummyTaskDetails = [
    //   TaskDetail(
    //     detailId: 'td1',
    //     title: '자료 조사',
    //     isCompleted: false,
    //     taskId: dummyTasks[0].taskId,
    //   ),
    //   TaskDetail(
    //     detailId: 'td2',
    //     title: '운동복 준비',
    //     isCompleted: false,
    //     taskId: dummyTasks[1].taskId,
    //   ),
    //   TaskDetail(
    //     detailId: 'td3',
    //     title: '책갈피 정리',
    //     isCompleted: false,
    //     taskId: dummyTasks[2].taskId,
    //   ),
    // ];
    //
    // for (var detail in dummyTaskDetails) {
    //   await db.insert('task_detail', detail.toMap());
    // }

    // ✅ 2개의 RepeatTask 더미 데이터
    List<RepeatTask> dummyRepeatTasks = [
      RepeatTask(
        repeatId: RepeatTask.createRepeatId(),
        title: '주간 회의',
        startDate: DateTime(2025, 3, 17),
        time: DateTime(2025, 3, 17, 10, 00),
        color: '0XFFFF6B6B',
        type: 1,
        interval: '1',
      ),
    ];

    for (var repeatTask in dummyRepeatTasks) {
      await db.insert('repeat_task', repeatTask.toMap());
    }

    // ✅ 3개의 TaskDetail 더미 데이터
    List<TaskDetail> dummyTaskDetails = [
      TaskDetail(
        detailId: TaskDetail.createTaskDetailId(),
        title: '주간 일정 공유',
        isCompleted: false,
        taskId: dummyRepeatTasks[0].repeatId,
      ),
      TaskDetail(
        detailId: TaskDetail.createTaskDetailId(),
        title: '코드 리뷰',
        isCompleted: false,
        taskId: dummyRepeatTasks[0].repeatId,
      ),
    ];

    for (var detail in dummyTaskDetails) {
      await db.insert('task_detail', detail.toMap());
    }
  }
}
