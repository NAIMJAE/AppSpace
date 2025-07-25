import 'package:tracking/data/database/dao/trophy_dao.dart';
import 'package:tracking/data/models/trophy.dart';
import 'package:tracking/data/models/trophy_room.dart';

class TrophyHelper {
  /// 조건을 만족하는 Trophy 검색
  static Future<List<Trophy>> checkTrophy(double distance, int time) async {
    Map<String, List<Trophy>> trophyMap = trophyCondition;
    final TrophyDao tpyDao = TrophyDao();
    List<Trophy> nowTpy = [];

    nowTpy.addAll(await _findTrophies('distance', distance, tpyDao, trophyMap));
    nowTpy.addAll(await _findTrophies('time', time, tpyDao, trophyMap));

    return nowTpy;
  }

  /// Trophy 조건 검사
  static Future<List<Trophy>> _findTrophies(String type, num value,
      TrophyDao tpyDao, Map<String, List<Trophy>> trophyMap) async {
    List<Trophy> earnedTrophies = [];

    if (trophyMap[type] == null) return earnedTrophies;
    List<Trophy> list = trophyMap[type]!;

    for (var each in list) {
      if (value >= each.conditionValue &&
          !(await tpyDao.selectTrophyRoom(trophyId: each.trophyId))) {
        earnedTrophies.add(each);
      }
    }

    return earnedTrophies;
  }

  // Trophy -> TrophyRoom 변환
  static List<TrophyRoom> parseTrophyRoom(List<Trophy> nowTpy) {
    List<TrophyRoom> roomList = [];

    if (nowTpy.isNotEmpty) {
      for (var each in nowTpy) {
        roomList.add(
          TrophyRoom(
            roomId: TrophyRoom.createRoomId(),
            trophyId: each.trophyId,
            date: DateTime.now(),
          ),
        );
      }
    }

    return roomList;
  }
}
