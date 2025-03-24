import 'package:flutter/material.dart';

class TimePickerWidget extends StatefulWidget {
  final String? selectedTime;
  final Function(String?) getTimeFunction;
  const TimePickerWidget({
    required this.selectedTime,
    required this.getTimeFunction,
    super.key,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late int selectedAmPmIndex; // 0: AM, 1: PM
  late int selectedHour; // 1 ~ 12
  late int selectedMinute; // 0 ~ 59

  final List<String> amPm = ['AM', 'PM'];

  // Scroll Controllers
  late FixedExtentScrollController amPmController;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();

    if (widget.selectedTime != null) {
      List<String> timeArr = widget.selectedTime!.split(' ');
      selectedAmPmIndex = timeArr[0] == 'AM' ? 0 : 1;

      List<String> timeArr2 = timeArr[1].split(':');
      selectedHour = int.parse(timeArr2[0]);
      selectedMinute = int.parse(timeArr2[1]);
    } else {
      selectedAmPmIndex = 0;
      selectedHour = 1;
      selectedMinute = 0;
    }

    // 컨트롤러 초기화
    amPmController =
        FixedExtentScrollController(initialItem: selectedAmPmIndex);
    hourController = FixedExtentScrollController(initialItem: selectedHour - 1);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);

    // UI 반영을 위해 setState() 호출
    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    amPmController.dispose();
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  /// 선택안함 버튼
  void _clickNotSelected() {
    widget.getTimeFunction(null);
    Navigator.pop(context);
  }

  /// 취소 버튼
  void _clickCancel() {
    Navigator.pop(context);
  }

  /// 확인 버튼
  void _clickComplete() {
    String amPmStr = amPm[selectedAmPmIndex];
    String hourStr = selectedHour.toString();
    String minuteStr = selectedMinute.toString().padLeft(2, '0');
    widget.getTimeFunction('$amPmStr $hourStr:$minuteStr');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double cntWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: cntWidth * 0.75,
        padding: const EdgeInsets.all(16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // AM/PM 선택
                _buildPicker(
                  controller: amPmController,
                  items: amPm,
                  selectedIndex: selectedAmPmIndex,
                  onSelected: (index) =>
                      setState(() => selectedAmPmIndex = index),
                ),
                const SizedBox(width: 16),

                // 시간 선택
                _buildPicker(
                  controller: hourController,
                  items: List.generate(12, (index) => (index + 1).toString()),
                  selectedIndex: selectedHour - 1,
                  onSelected: (index) =>
                      setState(() => selectedHour = index + 1),
                ),
                const SizedBox(width: 16),

                // 분 선택
                _buildPicker(
                  controller: minuteController,
                  items: List.generate(
                      60, (index) => index.toString().padLeft(2, '0')),
                  selectedIndex: selectedMinute,
                  onSelected: (index) => setState(() => selectedMinute = index),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _btnStyle(
                  btnName: '선택 안함',
                  textColor: const Color(0XFFFF6B6B),
                  btnFunction: _clickNotSelected,
                ),
                Row(
                  children: [
                    _btnStyle(
                      btnName: '취소',
                      textColor: const Color(0XFFB2B2B2),
                      btnFunction: _clickCancel,
                    ),
                    const SizedBox(width: 12),
                    _btnStyle(
                      btnName: '확인',
                      textColor: const Color(0XFF27c47d),
                      btnFunction: _clickComplete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btnStyle({
    required String btnName,
    required Color textColor,
    required Function btnFunction,
  }) {
    return GestureDetector(
      onTap: () => btnFunction(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Center(
          child: Text(
            btnName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required List<String> items,
    required int selectedIndex,
    required Function(int) onSelected,
  }) {
    return SizedBox(
      width: 60,
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 0.3,
        perspective: 0.005,
        onSelectedItemChanged: onSelected,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            return Center(
              child: Text(
                items[index],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: selectedIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selectedIndex == index ? Colors.black : Colors.grey,
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
