import 'package:sqflite/sqflite.dart';
import 'package:tracking/data/database/database_helper.dart';
import 'package:tracking/data/models/trophy_room.dart';
import 'package:tracking/utils/logger.dart';

class TrophyDao {
  // [▶ SELECT ◀]
  /// SELECT TrophyRoom
  /// @param
  /// - trophyId : trophyId to Search
  /// @return
  /// - true || false
  Future<bool> selectTrophyRoom({required String trophyId}) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT * FROM trophy_room
      WHERE trophyId = ?
      ''',
      [trophyId],
    );

    return result.isNotEmpty ? true : false;
  }

  // [▶ INSERT ◀]
  /// INSERT TrophyRoom - 나중에 삭제
  /// @param
  /// - nowTpy : TrophyRoom List to Insert
  /// @return
  /// - true || false
  Future<bool> insertTrophy({required List<TrophyRoom> nowTpy}) async {
    final db = await DatabaseHelper.instance.database;

    try {
      await db.transaction(
        (txn) async {
          Batch batch = txn.batch();
          for (var each in nowTpy) {
            batch.insert('trophy_room', each.toMap());
          }
          await batch.commit(noResult: true);
        },
      );
      return true;
    } catch (e) {
      logger.e('insertTrophy Exception : $e');
      return false;
    }
  }
}
