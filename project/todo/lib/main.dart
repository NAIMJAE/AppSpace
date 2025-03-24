import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/ui/pages/home_page/home_page.dart';

void main() {
  runApp(const ProviderScope(child: MyTodo()));
}

class MyTodo extends StatefulWidget {
  const MyTodo({super.key});

  @override
  State<MyTodo> createState() => _MyTodoState();
}

class _MyTodoState extends State<MyTodo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Neo',
      ),
      home: const HomePage(),
    );
  }
}
