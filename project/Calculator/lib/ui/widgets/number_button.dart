import 'package:flutter/material.dart';

class NumButton extends StatefulWidget {
  final int number;
  final double width;
  final double height;
  final Color btnColor;
  final Color textColor;
  final Function(int) function;

  const NumButton({
    super.key,
    required this.number,
    required this.width,
    required this.height,
    required this.btnColor,
    required this.textColor,
    required this.function,
  });

  @override
  State<NumButton> createState() => _NumButtonState();
}

class _NumButtonState extends State<NumButton> {
  bool isPressed = false;
  late Color pushedColor;

  /// 주어진 색상의 RGB 값을 조정하여 어둡게 만드는 함수.
  /// - [color]: 변경할 원본 색상.
  /// - 반환값: 원본 색상보다 80%의 밝기를 가진 어두운 `Color` 객체.
  ///
  /// **동작 원리**
  /// 1. 원본 색상의 RGB 값(Red, Green, Blue)에 `factor`(0.8)를 곱함.
  /// 2. 이를 통해 색상을 기존보다 20% 어둡게 만듦.
  /// 3. `toInt()`를 사용하여 정수 값으로 변환 후, 새로운 `Color` 객체를 생성.
  ///
  /// **주의 사항**
  /// - RGB 값이 너무 낮아지면 검은색에 가까워질 수 있음.
  /// - 특정 색상(예: 아주 밝은 색)은 어둡게 변할 때 색상이 탁해질 가능성이 있음.
  /// - HSL 색상 모델을 사용하는 방식도 있음.
  Color darkenColor(Color color) {
    double factor = 0.8; // 80% 밝기 조절
    return Color.fromARGB(
      color.alpha,
      (color.red * factor).toInt(),
      (color.green * factor).toInt(),
      (color.blue * factor).toInt(),
    );
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      isPressed = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        isPressed = false;
      });
    });
    widget.function(widget.number);
  }

  @override
  Widget build(BuildContext context) {
    pushedColor = darkenColor(widget.btnColor);

    return GestureDetector(
      onTapDown: _onTapDown,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(4),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isPressed ? pushedColor : widget.btnColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: widget.textColor,
              blurRadius: 2,
              spreadRadius: -1,
              offset: Offset(-1, -1),
            )
          ],
        ),
        child: Center(
          child: Text(
            '${widget.number}',
            style: TextStyle(
              color: widget.textColor,
              fontSize: 28,
            ),
          ),
        ),
      ),
    );
  }
}
