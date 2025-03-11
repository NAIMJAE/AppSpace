import 'package:flutter/material.dart';

class CalButton extends StatefulWidget {
  final String operator;
  final double width;
  final double height;
  final Color btnColor;
  final Color textColor;
  final Function(String) function;

  const CalButton({
    super.key,
    required this.operator,
    required this.width,
    required this.height,
    required this.btnColor,
    required this.textColor,
    required this.function,
  });

  @override
  State<CalButton> createState() => _CalButtonState();
}

class _CalButtonState extends State<CalButton> {
  bool isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        isPressed = false;
      });
    });
    widget.function(widget.operator);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(4),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isPressed ? Colors.white.withOpacity(0.1) : widget.btnColor,
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
            widget.operator,
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
