import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../analytics/presentation/manager/analytics_cubit.dart';
import '../../../habit/presentation/manager/habits_cubit.dart';
import '../../../habit/presentation/manager/habits_state.dart';
import '../../../profile/presentation/manager/user_cubit.dart';
import '../../../profile/presentation/manager/user_state.dart';
import '../widgets/daily_progress_ring.dart';
import '../widgets/habit_card.dart';
import '../widgets/habits_section_header.dart';
import '../widgets/home_header.dart';

/// The Home Tab content.
/// Fully driven by [HabitsCubit] (habits list + progress) and
/// [UserCubit] (user name + level). Zero local state.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topPadding + 20)),

        // ── Header: live name + level from UserCubit ──────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                final name = state is UserAuthenticated
                    ? state.user.name
                    : 'guest';
                final level = state is UserAuthenticated ? state.user.level : 1;
                final levelProgress = state is UserAuthenticated
                    ? state.user.levelProgress
                    : 0.0;
                final streakCount = state is UserAuthenticated
                    ? state.user.streakCount
                    : 0;
                return HomeHeader(
                  userName: name,
                  level: level,
                  levelProgress: levelProgress,
                  streakCount: streakCount,
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── Daily progress ring: driven by HabitsCubit ────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<HabitsCubit, HabitsState>(
              builder: (context, state) {
                final progress = state is HabitsLoaded
                    ? state.dailyProgress
                    : 0.0;
                return DailyProgressRing(percent: progress);
              },
            ),
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

        // ── Habits list: driven by HabitsCubit ────────────────────────────
        BlocBuilder<HabitsCubit, HabitsState>(
          builder: (context, state) {
            // Show an empty sliver while loading / on error.
            if (state is! HabitsLoaded) {
              return SliverToBoxAdapter(
                child: state is HabitsLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 140),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final habit = state.habits[index];
                  return HabitCard(
                    habit: habit,
                    // Toggle wired to HabitsCubit — persists to Hive.
                    // Also triggers an immediate analytics refresh so the
                    // Analytics tab is always up-to-date in the background.
                    onToggle: () {
                      context.read<HabitsCubit>().toggleHabitCompletion(
                        habit.id,
                      );
                      context.read<AnalyticsCubit>().loadAnalytics();
                    },
                  );
                }, childCount: state.habits.length),
              ),
            );
          },
        ),
      ],
    );
  }
}
