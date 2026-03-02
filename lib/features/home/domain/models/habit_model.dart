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
}