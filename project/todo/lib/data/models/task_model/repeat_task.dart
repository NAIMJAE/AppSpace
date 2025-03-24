import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class RepeatTask {
  final String repeatId;
  final String title;
  final DateTime startDate;
  final DateTime? time;
  final String color;
  final int type; // 0 : day / 1 : week / 2 : month
  final String? interval;

  RepeatTask({
    required this.repeatId,
    required this.title,
    required this.startDate,
    this.time,
    required this.color,
    required this.type,
    required this.interval,
  });

  Map<String, dynamic> toMap() {
    return {
      'repeatId': repeatId,
      'title': title,
      'startDate': DateFormat('yyyy-MM-dd').format(startDate), // 날짜를 TEXT로 변환
      'time': time != null ? DateFormat('HH:mm').format(time!) : null,
      'color': color,
      'type': type,
      'interval': interval,
    };
  }

  factory RepeatTask.fromMap(Map<String, dynamic> map) {
    return RepeatTask(
      repeatId: map['repeatId'],
      title: map['title'],
      startDate: DateTime.parse(map['startDate']), // TEXT → DateTime 변환
      time: map['time'] != null
          ? DateFormat('HH:mm').parse(map['time']) // TEXT → DateTime 변환
          : null,
      color: map['color'],
      type: map['type'],
      interval: map['interval'],
    );
  }

  /// repeatId 생성
  static String createRepeatId() {
    var uuid = const Uuid();
    return 'rp${uuid.v4().substring(0, 8)}';
  }

  @override
  String toString() {
    return 'RepeatTask{repeatId: $repeatId, title: $title, startDate: $startDate, time: $time, color: $color, type: $type, interval: $interval}';
  }
}
