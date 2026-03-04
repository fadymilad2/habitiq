import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/core/data/services/hive_service.dart';
import 'package:habit_iq/core/theme/app_theme.dart';
import 'package:habit_iq/core/theme/theme_cubit.dart';
import 'package:habit_iq/core/utils/daily_reset_observer.dart';
import 'package:habit_iq/features/auth/data/repositories/user_repository_impl.dart';
import 'package:habit_iq/features/analytics/presentation/manager/analytics_cubit.dart';
import 'package:habit_iq/features/dashboard/presentation/manager/dashboard_cubit.dart';
import 'package:habit_iq/features/habit/data/repositories/habit_repository_impl.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_cubit.dart';
import 'package:habit_iq/features/mood/presentation/manager/ai_cubit.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habit_iq/features/auth/presentation/manager/auth_cubit.dart';
import 'package:habit_iq/features/splash/presentation/pages/splash_view.dart';
import 'package:habit_iq/firebase_options.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Entry point
/// ─────────────────────────────────────────────────────────────────────────────
Future<void> main() async {
  // 1. Ensure Flutter engine is ready before any platform channel calls.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialise Hive — registers adapters and opens all boxes.
  //    Must complete before we create any Cubit that reads from Hive.
  await HiveService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 3. Launch the app.
  runApp(const HabitIq());
}

/// Root widget — keeps the [MaterialApp] completely stateless by delegating
/// theme state to [ThemeCubit] via [BlocBuilder].
class HabitIq extends StatelessWidget {
  const HabitIq({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ThemeCubit: reads persisted theme from Hive on creation.
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        // DashboardCubit: manages the current bottom-nav tab index.
        BlocProvider<DashboardCubit>(create: (_) => DashboardCubit()),
        BlocProvider<UserCubit>(
          create: (_) => UserCubit(UserRepositoryImpl())..checkAuthStatus(),
        ),
        BlocProvider<HabitsCubit>(
          create: (_) => HabitsCubit(HabitRepositoryImpl())..loadTodayHabits(),
        ),
        BlocProvider<AnalyticsCubit>(
          create: (_) => AnalyticsCubit(HabitRepositoryImpl())..loadAnalytics(),
        ),
        BlocProvider<AICubit>(create: (_) => AICubit(HabitRepositoryImpl())),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
      ],
      child: DailyResetObserver(
        child: MaterialApp(
          title: 'HabitIQ',
          debugShowCheckedModeBanner: false,
          // Supply both themes so the OS / cubit can switch seamlessly.
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // SplashView is always the first screen.
          // SplashCubit calls checkAuthStatus() after the animation and then
          // navigates to AuthView or MainDashboardView via pushReplacement.
          home: const SplashView(),
        ),
      ),
    );
  }
}
