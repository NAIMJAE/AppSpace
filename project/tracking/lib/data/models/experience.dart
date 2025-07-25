import 'package:uuid/uuid.dart';

class Experience {
  final String expId;
  int level;
  int exp;
  double distance;
  int time;

  Experience({
    required this.expId,
    required this.level,
    required this.exp,
    required this.distance,
    required this.time,
  });

  static Experience createInitExperience() {
    var uuid = const Uuid();
    return Experience(
      expId: 'EX${uuid.v4().substring(0, 8)}',
      level: 1,
      exp: 0,
      distance: 0,
      time: 0,
    );
  }

  void updateExperience({
    required int newExp,
    required double newDistance,
    required int newTime,
  }) {
    exp += newExp;
    distance += newDistance;
    time += newTime;
  }

  void updateLevel({required int value}) {
    if (level < value) {
      level = value;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'expId': expId,
      'level': level,
      'exp': exp,
      'distance': distance,
      'time': time,
    };
  }

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      expId: map['expId'],
      level: map['level'],
      exp: map['exp'],
      distance: map['distance'],
      time: map['time'],
    );
  }

  @override
  String toString() {
    return 'Experience{expId: $expId, level: $level, exp: $exp, distance: $distance, time: $time}';
  }
}
