import 'package:flutter/material.dart';
import 'second_page.dart';
import '../animations/page_transitions/slide_page_route.dart';
import '../animations/widget_animations/slide_switcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showBox1 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => showBox1 = !showBox1),
              child: SlideSwitcher(
                direction: AxisDirection.right,
                child: showBox1
                    ? Container(
                        key: const ValueKey("box1"),
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.all(12),
                        color: Colors.blue,
                        child: const Center(child: Text('Box1')),
                      )
                    : Container(
                        key: const ValueKey("box2"),
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.all(12),
                        color: Colors.red,
                        child: const Center(child: Text('Box2')),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: const Text('Go to Second Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const SecondPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
