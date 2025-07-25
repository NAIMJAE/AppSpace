import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskWidgetStorage {
  Future<void> saveTaskList(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    // 날짜별로 그룹화
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var task in tasks) {
      final date = task['date'];
      if (date == null) continue;

      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(task);
    }

    // 날짜를 key로 하여 각각 저장
    for (final entry in grouped.entries) {
      final dateKey = 'task_list.${entry.key}';
      final jsonString = jsonEncode(entry.value);
      await prefs.setString(dateKey, jsonString);
    }

    // ✅ 저장이 끝난 후 위젯 업데이트 호출 추가
    await HomeWidget.updateWidget(
      name: 'HomeSmallWidgetProvider',
    );

    await HomeWidget.updateWidget(
      name: 'HomeLargeWidgetProvider',
    );

    await HomeWidget.updateWidget(
      name: 'TestWidgetProvider',
    );
  }
}
