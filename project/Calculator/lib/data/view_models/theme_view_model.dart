import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator/data/models/theme_state.dart';

class ThemeViewModel extends AsyncNotifier<ThemeState> {
  @override
  Future<ThemeState> build() async {
    return await _loadTheme(); // 비동기적으로 테마 로드
  }

  Future<ThemeState> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String savedTheme = prefs.getString('theme_mode') ?? 'Light';
    return _getThemeState(savedTheme);
  }

  Future<void> setTheme({required String mode}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
    state = AsyncValue.data(_getThemeState(mode)); // AsyncValue로 감싸야 함
  }

  ThemeState _getThemeState(String mode) {
    switch (mode) {
      case 'Dark':
        return ThemeState(
          themeMode: mode,
          backgroundColor: Color(0xFF1A1A1D),
          displayColor: Colors.white,
          numberBtnColor: Color(0xFF4A4947),
          numberColor: Colors.white,
          operatorBtnColor: Color(0xFFFF8225),
          operatorColor: Colors.white,
          controlBtnColor: Color(0xFF8b8986),
        );
      case 'Light':
        return ThemeState(
          themeMode: mode,
          backgroundColor: Colors.white,
          displayColor: Colors.black,
          numberBtnColor: Color(0xFFb0afad),
          numberColor: Colors.black,
          operatorBtnColor: Color(0xFFFF8225),
          operatorColor: Colors.black,
          controlBtnColor: Color(0xFFe3e3e1),
        );
      case 'Pastel':
        return ThemeState(
          themeMode: mode,
          backgroundColor: Color(0xFFE3F2FD), // 연한 스카이블루
          displayColor: Color(0xFF2E2E2E),
          numberBtnColor: Color(0xFFB3E5FC), // 파스텔 블루
          numberColor: Color(0xFF2E2E2E),
          operatorBtnColor: Color(0xFFFF8A80), // 파스텔 레드
          operatorColor: Color(0xFF2E2E2E),
          controlBtnColor: Color(0xFFB0F1E1), // 더 밝은 민트 그린
        );
      default:
        return ThemeState(
          themeMode: 'Light',
          backgroundColor: Colors.white,
          displayColor: Colors.black,
          numberBtnColor: Color(0xFFb0afad),
          numberColor: Colors.black,
          operatorBtnColor: Color(0xFFFF8225),
          operatorColor: Colors.black,
          controlBtnColor: Color(0xFFe3e3e1),
        );
    }
  }
}

final themeProvider = AsyncNotifierProvider<ThemeViewModel, ThemeState>(
  () => ThemeViewModel(),
);
