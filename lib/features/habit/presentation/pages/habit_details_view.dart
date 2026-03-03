import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/core/widgets/app_background.dart';
import 'package:habit_iq/features/habit/presentation/widgets/reminder_section.dart';
import 'package:habit_iq/features/habit/data/models/habit_model.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_cubit.dart';

class HabitDetailsView extends StatelessWidget {
  const HabitDetailsView({super.key, required this.habit});
  final HabitModel habit;

  @override
  Widget build(BuildContext context) {
    final createdDaysAgo = DateTime.now().difference(habit.createdAt).inDays;

    // 0 = Daily, 1 = Weekly, 2 = Custom
    String frequencyStr = 'Daily';
    if (habit.frequency == 1) frequencyStr = 'Weekly';
    if (habit.frequency == 2) frequencyStr = 'Custom';

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Habit Details',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // ── Header (Icon + Title) ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceHighlight),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        IconData(habit.icon, fontFamily: 'MaterialIcons'),
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      habit.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        frequencyStr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Analytics ──────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceHighlight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildStatRow(
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.orange, // Safe hex fallback
                      iconColor: const Color(0xFFFF8C42),
                      title: 'Current Streak',
                      value: '${habit.currentStreak} Days',
                    ),
                    const Divider(
                      color: AppColors.surfaceHighlight,
                      height: 32,
                    ),

                    _buildStatRow(
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
                      iconColor: const Color(0xFF4ADE80),
                      title: 'Total Completions',
                      value: '${habit.totalCompletions} Times',
                    ),
                    const Divider(
                      color: AppColors.surfaceHighlight,
                      height: 32,
                    ),

                    _buildStatRow(
                      icon: Icons.flag_rounded,
                      color: Colors.purple,
                      iconColor: const Color(0xFFC084FC),
                      title: 'Days Left',
                      value:
                          '${max(0, habit.targetDays - habit.totalCompletions)} Days',
                    ),
                    const Divider(
                      color: AppColors.surfaceHighlight,
                      height: 32,
                    ),

                    _buildStatRow(
                      icon: Icons.calendar_today_rounded,
                      color: Colors.blue,
                      iconColor: const Color(0xFF60A5FA),
                      title: 'Created',
                      value: createdDaysAgo == 0
                          ? 'Today'
                          : '$createdDaysAgo days ago',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Reminder ───────────────────────────────────────────────────────
              ReminderSection(
                initialEnabled: habit.hasReminder,
                initialTime: habit.reminderTime != null
                    ? TimeOfDay.fromDateTime(habit.reminderTime!)
                    : null,
                onChanged: (enabled, time) {
                  final now = DateTime.now();
                  final dt = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    time.hour,
                    time.minute,
                  );
                  context.read<HabitsCubit>().updateReminder(
                    habit.id,
                    enabled,
                    dt,
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () => _confirmDelete(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                foregroundColor: const Color(0xFFEF4444),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline_rounded),
                  const SizedBox(width: 8),
                  Text(
                    'Delete Habit',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Habit',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${habit.title}"? This cannot be undone and all history will be lost.',
          style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<HabitsCubit>().deleteHabit(habit.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close details view
            },
            child: Text(
              'Delete',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
