import 'package:flutter/material.dart';

AppBar repeatAppbar({required BuildContext context}) {
  return AppBar(
    scrolledUnderElevation: 0,
    backgroundColor: Colors.white,
    leading: GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.arrow_back,
          size: 20,
          color: Color(0XFF222831),
        ),
      ),
    ),
    title: const Text(
      '반복 일정 관리',
      style: TextStyle(
        fontSize: 14,
        color: Color(0XFF222831),
      ),
    ),
  );
}
