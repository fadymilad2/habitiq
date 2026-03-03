import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/features/dashboard/presentation/manager/dashboard_cubit.dart';
import 'package:habit_iq/features/mood/presentation/manager/ai_cubit.dart';
import 'package:habit_iq/features/mood/presentation/manager/ai_state.dart';

class MoodCorrelationCard extends StatelessWidget {
  const MoodCorrelationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AICubit, AIState>(
      builder: (context, state) {
        if (state is! AILoaded || state.moodChartData.isEmpty) {
          return const SizedBox.shrink(); // Hide if no data yet
        }

        final moodData = state.moodChartData;
        final habitData = state.habitChartData;
        final percent = (state.correlationValue * 100).toInt();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────────
                Row(
                  children: [
                    Text(
                      'Mood vs. Habits',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          context.read<DashboardCubit>().changeTab(
                            1,
                          ); // Go to Analytics
                        },
                        child: Text(
                          'DETAILS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ── Legend ────────────────────────────────────────────────────
                Row(
                  children: [
                    const _LegendDot(color: AppColors.primary, label: 'Mood'),
                    const SizedBox(width: 16),
                    const _LegendDot(
                      color: Color(0xFF2DD4BF),
                      label: 'Habit Score',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Chart ─────────────────────────────────────────────────────
                SizedBox(
                  height: 130,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 22,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0)
                                return const SizedBox.shrink();

                              final offset = 6 - value.toInt();
                              if (offset < 0 || offset > 6)
                                return const SizedBox.shrink();

                              final date = DateTime.now().subtract(
                                Duration(days: offset),
                              );
                              final weekdays = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ];
                              final text = offset == 0
                                  ? 'Today'
                                  : weekdays[date.weekday - 1];

                              return SideTitleWidget(
                                meta: meta,
                                space: 8,
                                child: Text(
                                  text,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      minY: 1,
                      maxY: 5,
                      lineBarsData: [
                        // Mood line (purple)
                        LineChartBarData(
                          spots: moodData,
                          isCurved: true,
                          curveSmoothness: 0.5,
                          color: AppColors.primary,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: AppColors.primary,
                                ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.25),
                                AppColors.primary.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                          shadow: Shadow(
                            color: AppColors.primary.withValues(alpha: 0.45),
                            blurRadius: 10,
                          ),
                        ),
                        // Habit line (teal)
                        LineChartBarData(
                          spots: habitData,
                          isCurved: true,
                          curveSmoothness: 0.5,
                          color: const Color(0xFF2DD4BF),
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Insight row ───────────────────────────────────────────────
                if (percent > 0)
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.primary,
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Insight: When you feel ${state.currentMood}, you tend to complete $percent% of your habits.',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11.5,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
