import 'package:flutter/material.dart';
import 'package:tracking/ui/widgets/content_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFE9E9E9),
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ContentBox(child: Text('box1')),
              ContentBox(child: Text('box2')),
              ContentBox(child: Text('box3')),
            ],
          ),
        ),
      ),
    );
  }
}
