import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TrophyRoom {
  final String roomId;
  final String trophyId;
  final DateTime date;

  TrophyRoom({
    required this.roomId,
    required this.trophyId,
    required this.date,
  });

  static String createRoomId() {
    var uuid = const Uuid();
    return 'RM${uuid.v4().substring(0, 8)}';
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'trophyId': trophyId,
      'date': DateFormat('yyyy-MM-dd').format(date),
    };
  }

  factory TrophyRoom.fromMap(Map<String, dynamic> map) {
    return TrophyRoom(
      roomId: map['roomId'],
      trophyId: map['trophyId'],
      date: DateTime.parse(map['date']),
    );
  }
}
