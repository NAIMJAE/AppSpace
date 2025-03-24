import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/ui/pages/repeat_page/repeat_page.dart';
import 'package:todo/ui/widgets/date_picker_widget.dart';
import 'package:todo/util/parse_date.dart';

class DateSelectBox extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) changeDate;
  const DateSelectBox(
      {required this.selectedDate, required this.changeDate, super.key});

  @override
  ConsumerState<DateSelectBox> createState() => _DateSelectBoxState();
}

class _DateSelectBoxState extends ConsumerState<DateSelectBox> {
  late DateTime startDate;

  @override
  void initState() {
    super.initState();
    startDate = ParseDate.dateTimeToStartDate(widget.selectedDate);
  }

  /// 좌우 버튼으로 주단위 변경 함수
  /// @param
  /// - value : 변경할 값 (-7 : 일주일 전, 7: 일주일 후)
  void _changeWeek({required int value}) {
    startDate =
        DateTime(startDate.year, startDate.month, startDate.day + value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double cntWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: cntWidth * 0.28,
                  child: const Text(
                    'NEMOJIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => DatePickerWidget(
                      selectedDate: widget.selectedDate,
                      getDateFunction: (value) {
                        widget.changeDate(value);
                        startDate = ParseDate.dateTimeToStartDate(value);
                      },
                    ),
                  ),
                  child: SizedBox(
                    width: cntWidth * 0.28,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${startDate.year}. ${startDate.month}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF222831),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: cntWidth * 0.28,
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RepeatPage(),
                        ),
                      );
                      widget.changeDate(widget.selectedDate);
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0XFFB2B2B2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '반복 관리',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0XFF222831),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _changeWeek(value: -7),
                child: SizedBox(
                  width: cntWidth / 9,
                  height: cntWidth / 6,
                  child: const Icon(
                    Icons.arrow_back_ios_sharp,
                    size: 18,
                    color: Color(0XFF222831),
                  ),
                ),
              ),
              _weekGroup(width: cntWidth, start: 0),
              GestureDetector(
                onTap: () => _changeWeek(value: 7),
                child: SizedBox(
                  width: cntWidth / 9,
                  height: cntWidth / 6,
                  child: const Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 18,
                    color: Color(0XFF222831),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weekGroup({required double width, required int start}) {
    return Row(
      key: UniqueKey(),
      children: [
        ...List.generate(
          7,
          (index) {
            return _eachDate(
              width: width,
              date: DateTime(startDate.year, startDate.month,
                  startDate.day + start + index),
            );
          },
        ),
      ],
    );
  }

  Widget _eachDate({required double width, required DateTime date}) {
    return GestureDetector(
      onTap: () {
        widget.changeDate(date);
      },
      child: SizedBox(
        width: width / 9,
        height: width / 6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              ParseDate.dateTimeToWeekday(date),
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0XFFB2B2B2),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              width: width / 14,
              height: width / 14,
              decoration: BoxDecoration(
                color: widget.selectedDate == date
                    ? const Color(0XFF27c47d)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(width / 28),
              ),
              child: Center(
                child: Text(
                  date.day == 1 ? '${date.month}.${date.day}' : '${date.day}',
                  style: TextStyle(
                    color: widget.selectedDate == date
                        ? Colors.white
                        : const Color(0XFF222831),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
