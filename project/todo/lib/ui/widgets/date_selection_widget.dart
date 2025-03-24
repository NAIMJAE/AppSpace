import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget dateSelectionWidget(
    {required Function(int) changeSelectedDate,
    required DateTime selectedDate}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: () {
          changeSelectedDate(-1);
        },
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20,
        ),
      ),
      Text(
        '${DateFormat('yy.MM.dd').format(selectedDate)}',
        style: TextStyle(fontSize: 16),
      ),
      IconButton(
        onPressed: () {
          changeSelectedDate(1);
        },
        icon: Icon(
          Icons.arrow_forward_ios,
          size: 20,
        ),
      ),
    ],
  );
}
