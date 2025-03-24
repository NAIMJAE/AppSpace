import 'package:todo/util/parse_date.dart';

class ParseRepeat {
  /// 문자열 형식의 반복 타입을 정수로 변환
  static int repeatTypeStringToInt({required String type}) {
    switch (type) {
      case '매일':
        return 0;
      case '일주일':
        return 1;
      case '요일 반복':
        return 2;
      case '한달':
        return 3;
      case '일자 반복':
        return 4;
      default:
        return 0;
    }
  }

  /// 정수 형식의 반복 타입을 문자열로 변환
  static String repeatTypeIntToString({required int type}) {
    switch (type) {
      case 0:
        return '매일';
      case 1:
        return '일주일';
      case 2:
        return '요일 반복';
      case 3:
        return '한달';
      case 4:
        return '일자 반복';
      default:
        return '';
    }
  }

  /// 정수 형식의 반복 타입을 문자열로 변환
  static String repeatTypeToString(
      {required int type, required String interval}) {
    String result = '';
    switch (type) {
      case 0:
        result = '매일';
      case 1:
      case 2:
        result = '매주 ${ParseDate.weekIntListParseToString(week: interval)}요일';
      case 3:
      case 4:
        result = '매달 $interval일';
    }
    return result;
  }
}
