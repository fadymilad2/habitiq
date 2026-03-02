import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../analytics/presentation/manager/analytics_cubit.dart';
import '../../../analytics/presentation/pages/analytics_view.dart';
import '../../../home/presentation/pages/home_view.dart';
import '../../../mood/presentation/pages/ai_mood_view.dart';
import '../../../profile/presentation/pages/profile_view.dart';
import '../../../habit/presentation/pages/new_habit_view.dart';
import '../manager/dashboard_cubit.dart';
import '../widgets/custom_floating_nav_bar.dart';

class MainDashboardView extends StatelessWidget {
  const MainDashboardView({super.key});

  void _onAddHabit(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return BlocProvider(
      create: (context) => DashboardCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: BlocBuilder<DashboardCubit, int>(
          builder: (context, currentIndex) {
            return AppBackground(
              child: Stack(
                children: [
                  // ── Main Content Tabs ─────────────────────────────────────────
                  IndexedStack(
                    index: currentIndex,
                    children: [
                      // 0: Home view
                      const HomeView(),

                      // 1: Analytics view
                      Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: const AnalyticsView(),
                      ),

                      // 2: AI Mood view
                      Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: const AIMoodView(),
                      ),

                      // 3: Profile view
                      Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: const ProfileView(),
                      ),
                    ],
                  ),

                  // ── Floating Nav Bar ─────────────────────────────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CustomFloatingNavBar(
                      currentIndex: currentIndex,
                      onTap: (index) {
                        // Switch the active tab.
                        context.read<DashboardCubit>().changeTab(index);
                        // When the user navigates to the Analytics or Profile tab,
                        // immediately refresh analytics so the chart and stats reflect
                        // any habit completions done since the last visit.
                        if (index == 1 || index == 3) {
                          context.read<AnalyticsCubit>().loadAnalytics();
                        }
                      },
                      onFabTap: () => _onAddHabit(context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
