import 'package:flutter/material.dart';

/// Lightweight data model representing a single habit entry.
///
/// Used by [HabitCard] and [HomeView] to drive the habits list.
/// Swap this out for a proper domain entity once the data layer is wired.
class HabitModel {
  const HabitModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isCompleted = false,
    this.isAIPick = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final bool isAIPick;

  HabitModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    bool? isCompleted,
    bool? isAIPick,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      isCompleted: isCompleted ?? this.isCompleted,
      isAIPick: isAIPick ?? this.isAIPick,
    );
  }

  // ── Sample data ────────────────────────────────────────────────────────────
  static List<HabitModel> get samples => const [
    HabitModel(
      id: '1',
      title: 'Morning Meditation',
      subtitle: '15 minutes completed',
      icon: Icons.self_improvement_rounded,
      isCompleted: true,
    ),
    HabitModel(
      id: '2',
      title: 'Deep Work Session',
      subtitle: 'Recommended: 09:00 AM',
      icon: Icons.work_outline_rounded,
      isAIPick: true,
    ),
    HabitModel(
      id: '3',
      title: 'HIIT Workout',
      subtitle: '30 mins cardio',
      icon: Icons.fitness_center_rounded,
    ),
    HabitModel(
      id: '4',
      title: 'Read 10 Pages',
      subtitle: '0 / 10 pages',
      icon: Icons.menu_book_rounded,
    ),
    HabitModel(
      id: '5',
      title: 'Hydration',
      subtitle: '2.5L / 3L',
      icon: Icons.water_drop_outlined,
    ),
  ];
}
