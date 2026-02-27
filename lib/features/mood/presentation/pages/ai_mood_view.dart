import 'package:flutter/material.dart';
import 'package:habit_iq/features/mood/presentation/widgets/ai_mood_header.dart';
import 'package:habit_iq/features/mood/presentation/widgets/ai_suggestion_card.dart';
import 'package:habit_iq/features/mood/presentation/widgets/mood_correlation_card.dart';
import 'package:habit_iq/features/mood/presentation/widgets/mood_selector_section.dart';
import 'package:habit_iq/features/mood/presentation/widgets/this_month_summary.dart';

/// [AIMoodView] is designed to be used as a child inside an [IndexedStack]
/// on the Main Dashboard. It has NO [Scaffold] or its own bottom nav bar.
class AIMoodView extends StatelessWidget {
  const AIMoodView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header ────────────────────────────────────────────────────
              const AIMoodHeader(),

              const SizedBox(height: 4),

              // 2. Mood Selector ─────────────────────────────────────────────
              const MoodSelectorSection(),

              const SizedBox(height: 20),

              // 3. AI Suggestion Card ─────────────────────────────────────────
              const AISuggestionCard(),

              const SizedBox(height: 20),

              // 4. Mood Correlation Chart ─────────────────────────────────────
              const MoodCorrelationCard(),

              const SizedBox(height: 20),

              // 5. This Month Summary ─────────────────────────────────────────
              const ThisMonthSummary(),

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
