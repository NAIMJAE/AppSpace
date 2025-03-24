import 'dart:ui';

import 'package:flutter/material.dart';

class IconColor {
  final String name;
  final Color color;

  IconColor({required this.name, required this.color});
}

final List<IconColor> iconColorList = [
  IconColor(name: 'red', color: Color(0xFFFF0000)),
  IconColor(name: 'orange', color: Color(0xFFFFA500)),
  IconColor(name: 'yellow', color: Color(0xFFFFFF00)),
  IconColor(name: 'green', color: Color(0xFF008000)),
  IconColor(name: 'blue', color: Color(0xFF0000FF)),
  IconColor(name: 'indigo', color: Color(0xFF4B0082)),
  IconColor(name: 'violet', color: Color(0xFF8A2BE2)),
];
