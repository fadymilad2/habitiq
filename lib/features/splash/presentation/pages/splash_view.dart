import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/splash_cubit.dart';
import '../manager/splash_state.dart';
import '../../../../core/widgets/app_background.dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_title.dart';
import '../widgets/splash_loading_bar.dart';
import '../../../dashboard/presentation/pages/main_dashboard_view.dart';
import '../../../onboarding/presentation/pages/onboarding_view.dart';
import '../../../auth/presentation/pages/auth_view.dart';
import '../../../auth/presentation/manager/auth_cubit.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurveTween(curve: Curves.easeOut).animate(_controller);

    // نفس الكلام هنا، الأنيميشن مش هيبدأ غير لما الشاشة تبقى ظاهرة ومستقرة 100%
    WidgetsBinding.instance.waitUntilFirstFrameRasterized.then((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Pass the UserCubit (already provided at root) into SplashCubit
      // so it can read auth state after the animation delay.
      create: (context) => SplashCubit(context.read<AuthCubit>()),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToOnboarding) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, a, b) => const OnboardingView(),
                transitionsBuilder: (_, animation, b, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          } else if (state is SplashNavigateToLogin) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, a, b) => const AuthView(),
                transitionsBuilder: (_, animation, b, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          } else if (state is SplashNavigateToHome) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, a, b) => const MainDashboardView(),
                transitionsBuilder: (_, animation, b, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          }
        },
        child: Scaffold(
          body: AppBackground(
            child: Stack(
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _animation.value,
                        child: Transform.scale(
                          scale: 0.8 + (_animation.value * 0.2),
                          child: child,
                        ),
                      );
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SplashLogo(),
                        SizedBox(height: 32),
                        SplashTitle(),
                      ],
                    ),
                  ),
                ),
                // شريط التحميل بأسفل الشاشة
                const SplashLoadingBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
