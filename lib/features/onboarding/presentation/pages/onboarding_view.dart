import 'package:flutter/material.dart';
import '../../../../core/widgets/app_background.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/onboarding_top_bar.dart';
import '../widgets/onboarding_dots_indicator.dart';
import '../widgets/onboarding_action_button.dart';
import '../../data/models/onboarding_content.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextTapped() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      debugPrint('🚀 Onboarding complete — navigate to auth/home');
    }
  }

  void _onSkipTapped() {
    debugPrint('⏭ Skipped onboarding — navigate to auth/home');
  }

  bool get _isLastPage => _currentPage == onboardingPages.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ─── Top bar ────────────────────────────────────────────
              OnboardingTopBar(isLastPage: _isLastPage, onSkip: _onSkipTapped),

              // ─── PageView ───────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingPages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) =>
                      OnboardingPage(content: onboardingPages[index]),
                ),
              ),

              // ─── Bottom: Dots + Button ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OnboardingDotsIndicator(
                      controller: _pageController,
                      count: onboardingPages.length,
                    ),
                    const SizedBox(height: 24),
                    OnboardingActionButton(
                      isLastPage: _isLastPage,
                      currentPage: _currentPage,
                      onTap: _onNextTapped,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
