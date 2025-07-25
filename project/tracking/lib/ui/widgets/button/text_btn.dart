import 'package:flutter/material.dart';

class TextBtn extends StatefulWidget {
  final String text;
  final double textSize;
  final Color textColor;

  const TextBtn({
    super.key,
    required this.text,
    required this.textSize,
    required this.textColor,
  });

  @override
  State<TextBtn> createState() => _NormalBtnState();
}

class _NormalBtnState extends State<TextBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Center(
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: widget.textSize,
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}
