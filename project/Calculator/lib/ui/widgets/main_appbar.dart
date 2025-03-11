import 'package:flutter/material.dart';

AppBar mainAppbar({
  required BuildContext context,
  required themeState,
  required Function showHistory,
  required Function showSetting,
}) {
  return AppBar(
    backgroundColor: themeState.backgroundColor,
    title: Text(
      '계산기',
      style: TextStyle(color: themeState.displayColor),
    ),
    actions: [
      InkWell(
        onTap: () => showHistory(),
        child: Icon(
          Icons.history,
          color: themeState.displayColor,
        ),
      ),
      const SizedBox(width: 12),
      InkWell(
        onTap: () => showSetting(),
        child: Icon(
          Icons.settings,
          color: themeState.displayColor,
        ),
      ),
      const SizedBox(width: 20),
    ],
  );
}
