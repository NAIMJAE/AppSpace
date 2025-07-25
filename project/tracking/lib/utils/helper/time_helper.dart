import 'package:tracking/data/models/tracking.dart';

class TimeHelper {
  static int validTimeCalculation(DateTime time, List<Tracking> list) {
    DateTime prev = time;
    Duration total = Duration.zero;

    for (var each in list) {
      if (each.verification) {
        total += each.time.difference(prev).abs();
        prev = each.time;
      }
    }

    return total.inSeconds;
  }

  static String transferTimeIntToString(int value) {
    int hour = 0;
    int min = 0;
    int sec = 0;

    if (value >= 3600) {
      hour = value ~/ 3600;
      value = value % 3600;
    }

    if (value >= 60) {
      min = value ~/ 60;
      sec = value % 60;
    } else {
      sec = value;
    }

    String hourStr = hour.toString().padLeft(2, '0');
    String minStr = min.toString().padLeft(2, '0');
    String secStr = sec.toString().padLeft(2, '0');

    return '$hourStr:$minStr:$secStr';
  }
}
