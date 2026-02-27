import 'package:flutter/material.dart';
import 'package:habit_iq/features/analytics/presentation/widgets/analytics_header.dart';
import 'package:habit_iq/features/analytics/presentation/widgets/consistency_map.dart';
import 'package:habit_iq/features/analytics/presentation/widgets/streak_cards.dart';
import 'package:habit_iq/features/analytics/presentation/widgets/total_habits_card.dart';
import 'package:habit_iq/features/analytics/presentation/widgets/weekly_completion_chart.dart';

/// [AnalyticsView] is designed to be used as a child inside an [IndexedStack]
/// on the Main Dashboard. It has NO [Scaffold] or its own bottom nav bar.
class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header ───────────────────────────────────────────────────
              const AnalyticsHeader(),

              const SizedBox(height: 8),

              // 2. Weekly Completion Chart ──────────────────────────────────
              const WeeklyCompletionChart(),

              const SizedBox(height: 24),

              // 3. Consistency / Heat-map ───────────────────────────────────
              const ConsistencyMap(),

              const SizedBox(height: 16),

              // 4. Streak Cards (Current + Best) ────────────────────────────
              const StreakCards(),

              const SizedBox(height: 16),

              // 5. Total Habits Done ─────────────────────────────────────────
              const TotalHabitsCard(),

              // Extra bottom padding so the floating nav bar doesn't
              // cover the last card.
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}
