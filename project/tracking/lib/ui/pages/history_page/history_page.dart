import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracking/data/models/recode_history.dart';
import 'package:tracking/data/view_models/history_view_model.dart';
import 'package:tracking/ui/widgets/content_box.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    RecodeHistory recodeHistory = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: const Color(0XFFE9E9E9),
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...List.generate(
                recodeHistory.historyList.length,
                (index) => ContentBox(
                  child: Column(
                    children: [
                      Text(recodeHistory.historyList[index].recode.title),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
