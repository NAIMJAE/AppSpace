import 'package:intl/intl.dart';
import 'package:path/path.dart';

class ParseDate {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _weekdayFormat = DateFormat('E');

  /// DateTime을 YYYY-MM-DD 형식의 String으로 변환
  static String dateTimeToString(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// YYYY-MM-DD 형식의 String을 DateTime으로 변환
  static DateTime stringToDateTime(String dateString) {
    return _dateFormat.parse(dateString);
  }

  /// DateTime을 String 형식의 요일로 변환
  static String dateTimeToWeekday(DateTime dateTime) {
    return _weekdayFormat.format(dateTime);
  }

  /// DateTime을 통해 한 주의 시작일을 계산
  static DateTime dateTimeToStartDate(DateTime dateTime) {
    int weekday = dateTime.weekday;
    if (weekday == 7) {
      return dateTime;
    }
    return DateTime(dateTime.year, dateTime.month, dateTime.day - weekday);
  }

  static String weekStringParseToInt({required String? week}) {
    switch (week) {
      case '월':
        return '1';
      case '화':
        return '2';
      case '수':
        return '3';
      case '목':
        return '4';
      case '금':
        return '5';
      case '토':
        return '6';
      case '일':
        return '7';
      default:
        return '0';
    }
  }

  /// 정수 형태의 요일을 문자열 요일로 변환
  static String weekIntParseToString({required String? week}) {
    switch (week) {
      case '1':
        return '월';
      case '2':
        return '화';
      case '3':
        return '수';
      case '4':
        return '목';
      case '5':
        return '금';
      case '6':
        return '토';
      case '7':
        return '일';
      default:
        return '';
    }
  }

  static String weekIntListParseToString({required String? week}) {
    List<String> weekArr = week?.split(',') ?? [];

    return weekArr
        .map((map) => weekIntParseToString(week: map))
        .toList()
        .join(',');
  }

  /// 문자열 시간을 DateTime 형식으로 변경
  static DateTime? stringParseToDateTime(
      {required DateTime date, required String? time}) {
    if (time == null || time.isEmpty) {
      return null;
    }
    List<String> timeArr = time.split(' ');

    bool isPm = timeArr[0] == 'PM';
    List<String> hourMinute = timeArr[1].split(':');
    int hour = int.tryParse(hourMinute[0]) ?? 0;
    int minute = int.tryParse(hourMinute[1]) ?? 0;

    if (isPm && hour != 12) {
      hour += 12;
    }
    if (!isPm && hour == 12) {
      hour = 0;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// DateTime을 문자열 형식으로 변경
  static String? dateTimeParseToString({required DateTime? time}) {
    if (time == null) {
      return null;
    }

    bool isPm = time.hour >= 12;
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minute = time.minute.toString().padLeft(2, '0');

    return '${isPm ? 'PM' : 'AM'} $hour:$minute';
  }
}
