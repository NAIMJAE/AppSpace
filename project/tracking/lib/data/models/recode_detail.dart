import 'package:uuid/uuid.dart';

class RecodeDetail {
  final String detailId;
  final String recodeId;
  final int interval;
  final double distance;
  final double speed;
  final int time;

  RecodeDetail({
    required this.detailId,
    required this.recodeId,
    required this.interval,
    required this.distance,
    required this.speed,
    required this.time,
  });

  static String createDetailId() {
    var uuid = const Uuid();
    return 'DE${uuid.v4().substring(0, 8)}';
  }

  Map<String, dynamic> toMap() {
    return {
      'detailId': detailId,
      'recodeId': recodeId,
      'interval': interval,
      'distance': distance,
      'speed': speed,
      'time': time,
    };
  }

  factory RecodeDetail.fromMap(Map<String, dynamic> map) {
    return RecodeDetail(
      detailId: map['detailId'],
      recodeId: map['recodeId'],
      interval: map['interval'],
      distance: map['distance'],
      speed: map['speed'],
      time: map['time'],
    );
  }
}
