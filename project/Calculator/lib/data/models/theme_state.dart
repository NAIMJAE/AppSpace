import 'package:flutter/material.dart';

class ThemeState {
  final String themeMode;
  final Color backgroundColor;
  final Color displayColor;
  final Color numberBtnColor;
  final Color numberColor;
  final Color operatorBtnColor;
  final Color operatorColor;
  final Color controlBtnColor;

  ThemeState({
    required this.themeMode,
    required this.backgroundColor,
    required this.displayColor,
    required this.numberBtnColor,
    required this.numberColor,
    required this.operatorBtnColor,
    required this.operatorColor,
    required this.controlBtnColor,
  });

  ThemeState copyWith({
    String? themeMode,
    Color? backgroundColor,
    Color? displayColor,
    Color? numberBtnColor,
    Color? numberColor,
    Color? operatorBtnColor,
    Color? operatorColor,
    Color? controlBtnColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      displayColor: displayColor ?? this.displayColor,
      numberBtnColor: numberBtnColor ?? this.numberBtnColor,
      numberColor: numberColor ?? this.numberColor,
      operatorBtnColor: operatorBtnColor ?? this.operatorBtnColor,
      operatorColor: operatorColor ?? this.operatorColor,
      controlBtnColor: controlBtnColor ?? this.controlBtnColor,
    );
  }
}
