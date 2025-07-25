import 'package:tracking/data/models/recode.dart';
import 'package:tracking/data/models/recode_group.dart';

class RecodeHistory {
  List<RecodeGroup> historyList;

  RecodeHistory({required this.historyList});

  /// DB 조회 후 초기화
  static RecodeHistory createRecodeHistory(List<Map<String, dynamic>> list) {
    List<RecodeGroup> result = [];

    for (var each in list) {
      result.add(RecodeGroup(recode: Recode.fromMap(each), detailList: []));
    }
    return RecodeHistory(historyList: result);
  }
}
