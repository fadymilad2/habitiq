import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_iq/features/habit/data/models/habit_model.dart';
import 'package:habit_iq/features/sync/data/sync_repository.dart';
import 'package:habit_iq/features/auth/presentation/manager/auth_cubit.dart';
import 'package:habit_iq/features/auth/presentation/manager/auth_state.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_cubit.dart';
import 'package:habit_iq/features/analytics/presentation/manager/analytics_cubit.dart';
import 'package:habit_iq/features/mood/presentation/manager/ai_cubit.dart';

/// Wraps the app and listens for day-boundary crossings.
///
/// When the user brings the app to the foreground on a new calendar day:
///  1. Resets `isCompletedToday` flags for all habits (clears yesterday's ticks).
///  2. Re-computes the overall streak — if yesterday had no completions, the
///     gap-based [HabitsCubit._computeOverallStreak] returns 0 automatically.
///  3. Refreshes analytics and resets the AI mood card.
class DailyResetObserver extends StatefulWidget {
  final Widget child;
  const DailyResetObserver({super.key, required this.child});

  @override
  State<DailyResetObserver> createState() => _DailyResetObserverState();
}

class _DailyResetObserverState extends State<DailyResetObserver>
    with WidgetsBindingObserver {
  /// The calendar date when the app was last active.
  late DateTime _lastActiveDate;

  @override
  void initState() {
    super.initState();
    _lastActiveDate = _today();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = _today();
      if (now != _lastActiveDate) {
        // A new calendar day has started since we last ran.
        _lastActiveDate = now;
        _triggerNewDayReset();
      }
    }
  }

  /// Called once per new calendar day when the app resumes.
  ///
  /// Order matters:
  ///  - Reset daily flags → the streak re-computation inside
  ///    [HabitsCubit.loadTodayHabits] (called by [resetDailyFlags]) will now
  ///    see yesterday as a missed day if no habits were completed.
  Future<void> _triggerNewDayReset() async {
    // 0. Auto-Sync yesterday's data to cloud before resetting
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated && !authState.user.isAnonymous) {
      try {
        final habitsBox = Hive.box<HabitModel>('habitsBox');
        final habits = habitsBox.values.toList();
        // Fire and forget, don't block the UI
        SyncRepository.pushToCloud(authState.user.uid, habits);
      } catch (e) {
        // Safe to ignore
      }
    }

    // 1. Reset completion flags for habits not completed today.
    //    This also calls loadTodayHabits() which re-computes the streak.
    //    If yesterday had no completions, the gap-based streak → 0.
    context.read<HabitsCubit>().resetDailyFlags();

    // 2. Refresh analytics graphs.
    context.read<AnalyticsCubit>().loadAnalytics();

    // 3. Reset the AI mood card so the user gets a fresh insight today.
    context.read<AICubit>().resetToInitial();
  }

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
