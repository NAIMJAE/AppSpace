import 'package:flutter/material.dart';
import 'package:tracking/ui/pages/history_page/history_page.dart';
import 'package:tracking/ui/pages/home_page/home_page.dart';
import 'package:tracking/ui/pages/tracking_page/tracking_page.dart';
import 'package:tracking/ui/pages/trophy_page/trophy_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  void changeStackPages(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0XFFE9E9E9),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            HomePage(),
            TrackingPage(
              selectedIndex: _selectedIndex,
            ),
            HistoryPage(),
            TrophyPage(),
          ],
        ),
        bottomNavigationBar: _bottomNavigatorBar(),
      ),
    );
  }

  Widget _bottomNavigatorBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        changeStackPages(index);
      },
      items: [
        BottomNavigationBarItem(label: '', icon: Icon(Icons.home_filled)),
        BottomNavigationBarItem(label: '', icon: Icon(Icons.directions_run)),
        BottomNavigationBarItem(label: '', icon: Icon(Icons.history)),
        BottomNavigationBarItem(label: '', icon: Icon(Icons.emoji_events)),
      ],
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }
}
