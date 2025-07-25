import 'package:flutter/material.dart';

class NormalBtn extends StatefulWidget {
  final String text;
  final Color textColor;
  final Color color;

  const NormalBtn({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  State<NormalBtn> createState() => _NormalBtnState();
}

class _NormalBtnState extends State<NormalBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 18,
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}
