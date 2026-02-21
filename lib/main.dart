import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const HabitIq());
}

class HabitIq extends StatelessWidget {
  const HabitIq({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Center(
          child: Text(
            'Habit IQ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
      ),
    );
  }
}
