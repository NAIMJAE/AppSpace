import 'package:flutter/material.dart';

class ThemeSelectBox extends StatelessWidget {
  final Function(String) function;
  final Color backgroundColor;
  final Color textColor;
  final List<String> themeList = ['Light', 'Dark', 'Pastel'];

  ThemeSelectBox({
    required this.function,
    required this.backgroundColor,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: textColor.withOpacity(0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    function('Light');
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.light_mode,
                          size: 30,
                          color: textColor,
                        ),
                        const SizedBox(width: 10),
                        Text('Light',
                            style: TextStyle(fontSize: 20, color: textColor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    function('Dark');
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.dark_mode,
                          size: 30,
                          color: textColor,
                        ),
                        const SizedBox(width: 10),
                        Text('Dark',
                            style: TextStyle(fontSize: 20, color: textColor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    function('Pastel');
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.color_lens,
                          size: 30,
                          color: textColor,
                        ),
                        const SizedBox(width: 10),
                        Text('Pastel',
                            style: TextStyle(fontSize: 20, color: textColor)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
