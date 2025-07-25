import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Recode {
  final String recodeId;
  final String title;
  final DateTime date;
  final DateTime start;
  final DateTime end;
  final int time;
  final double distance;
  final double speed;
  final int exp;

  Recode({
    required this.recodeId,
    required this.title,
    required this.date,
    required this.start,
    required this.end,
    required this.time,
    required this.distance,
    required this.speed,
    required this.exp,
  });

  factory Recode.empty() {
    return Recode(
      recodeId: '',
      title: '',
      date: DateTime.now(),
      start: DateTime.now(),
      end: DateTime.now(),
      time: 0,
      distance: 0.0,
      speed: 0.0,
      exp: 0,
    );
  }

  static String createRecodeId() {
    var uuid = const Uuid();
    return 'RE${uuid.v4().substring(0, 8)}';
  }

  Map<String, dynamic> toMap() {
    return {
      'recodeId': recodeId,
      'title': title,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'start': DateFormat('yyyy-MM-dd HH:mm:ss').format(start),
      'end': DateFormat('yyyy-MM-dd HH:mm:ss').format(end),
      'time': time,
      'distance': distance,
      'speed': speed,
      'exp': exp,
    };
  }

  factory Recode.fromMap(Map<String, dynamic> map) {
    return Recode(
      recodeId: map['recodeId'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
      time: map['time'],
      distance: map['distance'],
      speed: map['speed'],
      exp: map['exp'],
    );
  }
}
