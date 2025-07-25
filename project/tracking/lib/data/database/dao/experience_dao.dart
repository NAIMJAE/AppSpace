import 'package:tracking/data/database/database_helper.dart';
import 'package:tracking/data/models/experience.dart';
import 'package:tracking/data/models/trophy_room.dart';
import 'package:tracking/data/models/user_info.dart';
import 'package:tracking/utils/logger.dart';

class ExperienceDao {
  // [▶ SELECT ◀]
  /// SELECT Experience
  /// @return
  /// - Experience || null
  Future<Experience?> selectExperience() async {
    final db = await DatabaseHelper.instance.database;

    try {
      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT * FROM experience
        ''',
      );

      if (result.isEmpty) {
        logger.e('selectExperience Exception : Not Found');
        return null;
      }

      return Experience.fromMap(result.first);
    } catch (e) {
      logger.e('selectExperience Exception : $e');
      return null;
    }
  }

  /// SELECT User Experience & Trophy_Room
  /// @return
  /// - UserInfo
  Future<UserInfo> selectUserInfo() async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> experience = await db.rawQuery(
      '''
      SELECT * FROM experience
      ''',
    );

    final List<Map<String, dynamic>> trophy = await db.rawQuery(
      '''
      SELECT * FROM trophy_room
      ''',
    );

    Experience userExp = Experience.fromMap(experience.first);

    UserInfo userInfo = UserInfo(userExp: userExp, userTrophy: {});

    for (var each in trophy) {
      TrophyRoom room = TrophyRoom.fromMap(each);
      userInfo.userTrophy[room.trophyId] = room;
    }

    return userInfo;
  }

  // [▶ INSERT ◀]
  /// SELECT Experience  - 나중에 삭제
  /// @param
  /// - exp : Experience to Insert
  Future<void> updateExperience({required Experience experience}) async {
    final db = await DatabaseHelper.instance.database;

    db.update('experience', experience.toMap());
  }
}
