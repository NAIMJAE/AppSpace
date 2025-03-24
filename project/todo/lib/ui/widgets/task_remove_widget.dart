import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/data/models/task_model/task.dart';

class TaskRemoveWidget extends StatefulWidget {
  final Task task;
  const TaskRemoveWidget({required this.task, super.key});

  @override
  State<TaskRemoveWidget> createState() => _TaskRemoveWidgetState();
}

class _TaskRemoveWidgetState extends State<TaskRemoveWidget> {
  @override
  Widget build(BuildContext context) {
    double cntWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: cntWidth * 0.75,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0XFF222831),
              blurRadius: 4,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: Color(0XFFFF6B6B),
            ),
            const SizedBox(height: 8),
            const Text(
              '일정을 삭제하시겠습니까?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // 안내 문구
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Color(0XFF222831),
                ),
                SizedBox(width: 4),
                Text(
                  '이미 완료된 반복 일정은 유지됩니다.',
                  style: TextStyle(
                    color: Color(0XFF222831),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0XFFB2B2B2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.task.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  if (widget.task.time != null)
                    Text(
                      DateFormat('HH:mm').format(widget.task.time!),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 34, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0XFFE9E9E9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        color: Color(0XFF222831),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 34, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0XFFFF6B6B)),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0XFFFF6B6B),
                    ),
                    child: const Text(
                      '삭제',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
