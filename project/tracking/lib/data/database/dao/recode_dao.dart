import 'package:sqflite/sqflite.dart';
import 'package:tracking/data/database/database_helper.dart';
import 'package:tracking/data/models/experience.dart';
import 'package:tracking/data/models/recode_group.dart';
import 'package:tracking/data/models/recode_history.dart';
import 'package:tracking/data/models/trophy_room.dart';
import 'package:tracking/utils/logger.dart';

class RecodeDao {
  // [▶ SELECT ◀]
  /// SELECT Recode
  /// @return
  /// - RecodeHistory
  Future<RecodeHistory> selectRecodeForHistory() async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT * FROM recode
      ORDER BY date DESC
      ''',
    );

    logger.i(result);

    return RecodeHistory.createRecodeHistory(result);
  }

  // [▶ INSERT ◀]
  /// INSERT Recode & Recode_Detail  - 나중에 삭제
  /// @param
  /// - RecodeGroup : Recode & Recode_Detail List
  /// @return
  /// - true || false
  Future<bool> insertRecodeAndDetail({required RecodeGroup recodeGroup}) async {
    final db = await DatabaseHelper.instance.database;

    try {
      await db.transaction((txn) async {
        final int result =
            await txn.insert('recode', recodeGroup.recode.toMap());
        if (result <= 0) throw Exception('Recode Insert Fail');

        Batch batch = txn.batch();
        for (var each in recodeGroup.detailList) {
          batch.insert(
            'recode_detail',
            each.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      });

      return true;
    } catch (e) {
      logger.e('insertRecodeAndDetail Exception : $e');
      return false;
    }
  }

  /// Tracking 정보 저장
  Future<bool> processTrackingDataTransaction(
      {required RecodeGroup recodeGroup,
      required Experience experience,
      required List<TrophyRoom> nowTpy}) async {
    final db = await DatabaseHelper.instance.database;

    try {
      await db.transaction(
        (txn) async {
          // 1. Insert Recode
          final int recodeResult =
              await txn.insert('recode', recodeGroup.recode.toMap());
          if (recodeResult <= 0) throw Exception('Recode Insert Fail');

          // 2. Insert Recode Detail
          Batch batch = txn.batch();
          for (var each in recodeGroup.detailList) {
            batch.insert(
              'recode_detail',
              each.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await batch.commit(noResult: true);

          // 3. Update Experience
          int expResult = await txn.update(
            'experience',
            experience.toMap(),
            where: 'expId = ?',
            whereArgs: [experience.expId],
          );
          if (expResult <= 0) throw Exception('Experience Update Fail');

          // 4. Insert Trophy (Batch 처리)
          batch = txn.batch();
          for (var each in nowTpy) {
            batch.insert(
              'trophy_room',
              each.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await batch.commit(noResult: true);
        },
      );
      return true;
    } catch (e) {
      logger.e('TrackingDataTransaction Exception : $e');
      return false;
    }
  }
}
