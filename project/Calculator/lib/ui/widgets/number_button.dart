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
    widget.function(widget.number);
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
          color: isPressed ? Colors.white.withOpacity(0.5) : widget.btnColor,
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
