import 'package:flutter/material.dart';

class CollectTrophy extends StatefulWidget {
  const CollectTrophy({super.key});

  @override
  State<CollectTrophy> createState() => _CollectTrophyState();
}

class _CollectTrophyState extends State<CollectTrophy> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _visible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _visible
        ? Container(
            padding: const EdgeInsets.all(16),
            color: Colors.amber,
            child: const Text('5초 동안 보이는 위젯'),
          )
        : const SizedBox(); // 사라졌을 때는 아무것도 안 보임
  }
}
