import 'package:flutter/material.dart';
import '../../domain/models/habit_model.dart';
import '../widgets/daily_progress_ring.dart';
import '../widgets/habit_card.dart';
import '../widgets/habits_section_header.dart';
import '../widgets/home_header.dart';

/// The Home Tab content.
/// Now just responsible for displaying the user's habits and daily progress
/// from within the MainDashboardView.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // ── State ─────────────────────────────────────────────────────────────────
  List<HabitModel> _habits = HabitModel.samples;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  void _toggleHabit(String id) {
    setState(() {
      _habits = _habits.map((h) {
        return h.id == id ? h.copyWith(isCompleted: !h.isCompleted) : h;
      }).toList();
    });
  }

  /// Ratio of completed habits (0.0 – 1.0).
  double get _dailyProgress {
    if (_habits.isEmpty) return 0;
    return _habits.where((h) => h.isCompleted).length / _habits.length;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: topPadding + 20),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HomeHeader(
              userName: 'Alex',
              level: 12,
              levelProgress: 0.45,
              streakCount: 14,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DailyProgressRing(percent: _dailyProgress),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HabitsSectionHeader(
              onViewAll: () {
                // TODO: navigate to full habit list
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            bottomPadding + 140, // Ensure enough space for the floating nav bar and FAB
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => HabitCard(
                habit: _habits[index],
                onToggle: () => _toggleHabit(_habits[index].id),
              ),
              childCount: _habits.length,
            ),
          ),
        ),
      ],
    );
  }
}
