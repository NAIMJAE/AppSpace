import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracking/data/database/dao/recode_dao.dart';
import 'package:tracking/data/models/recode_history.dart';

class HistoryViewModel extends Notifier<RecodeHistory> {
  final RecodeDao _recodeDao = RecodeDao();

  @override
  RecodeHistory build() {
    loadRecodeHistory();
    return RecodeHistory(historyList: []);
  }

  Future<void> loadRecodeHistory() async {
    state = await _recodeDao.selectRecodeForHistory();
  }
}

final historyProvider = NotifierProvider<HistoryViewModel, RecodeHistory>(
  () => HistoryViewModel(),
);
