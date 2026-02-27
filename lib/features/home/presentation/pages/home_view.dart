import 'package:flutter/material.dart';
import 'package:habit_iq/features/profile/presentation/pages/profile_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../analytics/presentation/pages/analytics_view.dart';
import '../../../mood/presentation/pages/ai_mood_view.dart';
import '../../../habit/presentation/pages/new_habit_view.dart';
import '../../domain/models/habit_model.dart';
import '../widgets/add_habit_fab.dart';
import '../widgets/daily_progress_ring.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/habit_card.dart';
import '../widgets/habits_section_header.dart';
import '../widgets/home_header.dart';

/// The main Home Screen.
///
/// Responsibility: **orchestration only**.
/// - Holds the local UI state (selected nav tab, habits list).
/// - Delegates every visual section to an extracted widget.
/// - Replace the sample data and stubs with BLoC / use-cases as needed.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // ── State ─────────────────────────────────────────────────────────────────
  int _navIndex = 0;
  List<HabitModel> _habits = HabitModel.samples;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  void _toggleHabit(String id) {
    setState(() {
      _habits = _habits.map((h) {
        return h.id == id ? h.copyWith(isCompleted: !h.isCompleted) : h;
      }).toList();
    });
  }

  void _onAddHabit() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NewHabitView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
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

    return Scaffold(
      backgroundColor: AppColors.background,
      // No native FAB / BottomNavBar — we draw them manually in a Stack.
      body: AppBackground(
        child: Stack(
          children: [
            // ── IndexedStack: one page per nav tab ────────────────────────
            IndexedStack(
              index: _navIndex,
              children: [
                // ── 0: Home ───────────────────────────────────────────────
                CustomScrollView(
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
                        bottomPadding + 100,
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
                ),

                // ── 1: Analytics (Stats) ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: const AnalyticsView(),
                ),

                // ── 2: AI Mood & Insights ─────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: const AIMoodView(),
                ),

                // ── 3: Profile (placeholder) ──────────────────────────────
                Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: const ProfileView(),
                ),
              ],
            ),

            // ── Floating NavBar + FAB overlay ──────────────────────────────
            // Clip.none lets the FAB protrude upward beyond the nav bar bounds.
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomPadding + 16,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  // Glass nav bar — all 4 icons evenly visible
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: FloatingNavBar(
                      selectedIndex: _navIndex,
                      onItemTap: (i) => setState(() => _navIndex = i),
                    ),
                  ),

                  // FAB centred, raised so half its height (34px) sits above bar
                  AddHabitFab(onPressed: _onAddHabit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
