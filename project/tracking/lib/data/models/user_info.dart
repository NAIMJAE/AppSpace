import 'package:tracking/data/models/experience.dart';
import 'package:tracking/data/models/trophy_room.dart';

class UserInfo {
  Experience? userExp;
  Map<String, TrophyRoom> userTrophy;

  UserInfo({
    required this.userExp,
    required this.userTrophy,
  });
}
