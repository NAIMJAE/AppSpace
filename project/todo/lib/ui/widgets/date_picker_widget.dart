import 'package:flutter/material.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) getDateFunction;
  const DatePickerWidget(
      {required this.selectedDate, required this.getDateFunction, super.key});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late List<List<DateTime>> monthList; // 현자 달력에 보여지고 있는 월의 일자 목록
  late DateTime viewDate; // 현재 달력에 보여지고 있는 월
  late DateTime taskDate; // 사용자가 선택한 일자

  @override
  void initState() {
    super.initState();
    monthList = _calculationMonth(dateTime: widget.selectedDate);
    taskDate = widget.selectedDate;
  }

  /// 월 계산 함수
  List<List<DateTime>> _calculationMonth({required DateTime dateTime}) {
    int firstWeekday = DateTime(dateTime.year, dateTime.month, 1).weekday;
    DateTime lastDate = DateTime(dateTime.year, dateTime.month + 1, 0);

    viewDate = lastDate;

    List<List<DateTime>> monthList = [];
    List<DateTime> week = [];

    // 첫번째 주
    for (int i = firstWeekday; i > 0; i--) {
      if (firstWeekday == 7) {
        continue;
      }
      DateTime prevDate = DateTime(dateTime.year, dateTime.month, 1 - i);
      week.add(prevDate);
    }

    // 해당 월의 주
    for (int i = 1; i <= lastDate.day; i++) {
      DateTime indexDate = DateTime(dateTime.year, dateTime.month, i);
      week.add(indexDate);
      if (indexDate.weekday == 6) {
        monthList.add(List.from(week));
        week.clear();
      }
    }

    // 마지막 주
    if (week.isNotEmpty) {
      for (int i = 1; week.length < 7; i++) {
        DateTime nextDate = DateTime(dateTime.year, dateTime.month + 1, i);
        week.add(nextDate);
      }
      monthList.add(List.from(week));
    }

    return monthList;
  }

  /// 월 변경 함수
  void _changeMonth({required int value}) {
    viewDate = DateTime(viewDate.year, viewDate.month + value, 1);
    monthList = _calculationMonth(dateTime: viewDate);
    setState(() {});
  }

  /// 일자 선택 함수
  void _changeDay({required DateTime dateTime}) {
    if (viewDate.month != dateTime.month) {
      if (taskDate.month > dateTime.month) {
        _changeMonth(value: -1);
      }
      if (taskDate.month < dateTime.month) {
        _changeMonth(value: 1);
      }
    }
    taskDate = dateTime;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double cntWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: cntWidth * 0.75,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _selectedDate(),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0),
              child: _nowMonth(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _dayRow(),
                  ...List.generate(
                    6,
                    (index) {
                      if (index >= monthList.length) {
                        return SizedBox(
                          height:
                              (MediaQuery.of(context).size.width * 0.75 - 16) /
                                  8,
                        );
                      } else {
                        List<DateTime> weekList = monthList[index];
                        return Row(
                          children: [
                            ...List.generate(
                              weekList.length,
                              (index) => _eachDate(dateTime: weekList[index]),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: Color(0XFFB2B2B2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      widget.getDateFunction(taskDate);
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          color: Color(0XFF27c47d),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectedDate() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0XFF27c47d),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${taskDate.year}년',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            '${taskDate.month}월 ${taskDate.day}일',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nowMonth() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _changeMonth(value: -1),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Color(0XFF222831),
          ),
        ),
        SizedBox(
          width: 90,
          child: Text(
            '${viewDate.year}년 ${viewDate.month}월',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0XFF222831),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () => _changeMonth(value: 1),
          icon: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Color(0XFF222831),
          ),
        ),
      ],
    );
  }

  Widget _dayRow() {
    List<String> dayList = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: [
        ...List.generate(
          dayList.length,
          (index) => SizedBox(
            width: (MediaQuery.of(context).size.width * 0.75 - 16) / 7,
            height: (MediaQuery.of(context).size.width * 0.75 - 16) / 8,
            child: Center(
              child: Text(
                dayList[index],
                style: TextStyle(
                  color: dayList[index] == '일'
                      ? Colors.red
                      : const Color(0XFF222831),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _eachDate({required DateTime dateTime}) {
    return GestureDetector(
      onTap: () => _changeDay(dateTime: dateTime),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width * 0.75 - 16) / 7,
        height: (MediaQuery.of(context).size.width * 0.75 - 16) / 8,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: (MediaQuery.of(context).size.width * 0.75 - 16) / 9,
            height: (MediaQuery.of(context).size.width * 0.75 - 16) / 9,
            decoration: BoxDecoration(
              color: dateTime == taskDate
                  ? const Color(0XFF27c47d)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                (MediaQuery.of(context).size.width * 0.75 - 16) / 14,
              ),
            ),
            child: Center(
              child: Text(
                '${dateTime.day}',
                style: TextStyle(
                  color: dateTime == taskDate
                      ? Colors.white
                      : viewDate.month == dateTime.month
                          ? dateTime.weekday == 7
                              ? Colors.red
                              : const Color(0XFF222831)
                          : const Color(0XFFB2B2B2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
