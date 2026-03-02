import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/features/analytics/presentation/manager/analytics_cubit.dart';
import 'package:habit_iq/features/analytics/presentation/manager/analytics_state.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        String consistencyStr = '0%';
        String streakStr = '0';
        String totalDaysStr = '0';

        if (state is AnalyticsLoaded) {
          consistencyStr = '${(state.allTimeAverage * 100).toInt()}%';
          streakStr = state.currentStreak.toString();
          totalDaysStr = state.totalActiveDays.toString();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _StatCard(value: consistencyStr, label: 'Consistency'),
              const SizedBox(width: 10),
              _StatCard(value: streakStr, label: 'Streak'),
              const SizedBox(width: 10),
              _StatCard(value: totalDaysStr, label: 'Total Days'),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
