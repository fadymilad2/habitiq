import 'package:flutter/material.dart';

void main() {
  runApp(const HabitIq());
}

class HabitIq extends StatelessWidget {
  const HabitIq({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Habit IQ'),
        ),
      ),
    );
  }
}