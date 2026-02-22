import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/splash_cubit.dart';
import '../manager/splash_state.dart';
import '../../../../core/widgets/app_background.dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_title.dart';
import '../widgets/splash_loading_bar.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToOnboarding) {
            // Navigator.pushReplacementNamed(context, '/onboarding');
          } else if (state is SplashNavigateToLogin) {
            // Navigator.pushReplacementNamed(context, '/login');
          } else if (state is SplashNavigateToHome) {
            // Navigator.pushReplacementNamed(context, '/home');
          }
        },
        child: Scaffold(
          body: AppBackground(
            child: Stack(
              children: [
                Center(
                  // الأنيميشن (Fade-in & Scale)
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (value * 0.2),
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
