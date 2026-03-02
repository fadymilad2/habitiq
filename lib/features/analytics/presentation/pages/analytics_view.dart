import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/features/analytics/presentation/manager/analytics_cubit.dart';
import 'package:habit_iq/features/analytics/presentation/manager/analytics_state.dart';
import 'package:habit_iq/features/analytics/presentation/widgets/analytics_header.dart';
import 'package:habit_iq/features/analytics/presentation/widgets/consistency_map.dart';
import 'package:habit_iq/features/analytics/presentation/widgets/streak_cards.dart';
import 'package:habit_iq/features/analytics/presentation/widgets/total_habits_card.dart';
import 'package:habit_iq/features/analytics/presentation/widgets/weekly_completion_chart.dart';

/// [AnalyticsView] is designed to be used as a child inside an [IndexedStack]
/// on the Main Dashboard. It has NO [Scaffold] or its own bottom nav bar.
///
/// The entire body is driven by [AnalyticsCubit] state:
///  • [AnalyticsLoading]  → centered progress indicator
///  • [AnalyticsLoaded]   → full analytics dashboard with real data
///  • [AnalyticsError]    → error message with retry button
///  • [AnalyticsInitial]  → same as loading (shouldn't be visible long)
class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    // ── BlocBuilder wires the entire analytics dashboard to live cubit state.
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        return switch (state) {
          // ── Loading / Initial ─────────────────────────────────────────────
          AnalyticsInitial() || AnalyticsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),

          // ── Error ─────────────────────────────────────────────────────────
          AnalyticsError(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<AnalyticsCubit>().loadAnalytics(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),

          // ── Loaded ────────────────────────────────────────────────────────
          // All widgets receive their data as constructor parameters,
          // keeping them pure and stateless — no BlocBuilder nesting needed.
          AnalyticsLoaded() => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header ─────────────────────────────────────────────
                    const AnalyticsHeader(),

                    const SizedBox(height: 8),

                    // 2. Weekly Completion Chart ─────────────────────────────
                    // Chart receives all three period datasets from the cubit.
                    WeeklyCompletionChart(
                      weeklyData: state.periodicWeekly,
                      monthlyData: state.periodicMonthly,
                      allTimeData: state.allTimeMonthly,
                      weeklyAverage: state.weeklyAverage,
                      monthlyAverage: state.monthlyAverage,
                      allTimeAverage: state.allTimeAverage,
                    ),

                    const SizedBox(height: 24),

                    // 3. Consistency / Heat-map ─────────────────────────────
                    ConsistencyMap(heatMapData: state.heatMapData),

                    const SizedBox(height: 16),

                    // 4. Streak Cards (Current + Best) ──────────────────────
                    StreakCards(
                      currentStreak: state.currentStreak,
                      bestStreak: state.bestStreak,
                    ),

                    const SizedBox(height: 16),

                    // 5. Total Habits Done ───────────────────────────────────
                    TotalHabitsCard(totalCompletions: state.totalCompletions),

                    // Extra bottom padding so the floating nav bar doesn't
                    // cover the last card.
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        };
      },
    );
  }
}
