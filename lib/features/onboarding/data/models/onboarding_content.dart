class OnboardingContent {
  final String imagePath;
  final String titleStart; // white part of the title
  final String titleAccent; // purple-gradient part of the title
  final String body;

  const OnboardingContent({
    required this.imagePath,
    required this.titleStart,
    required this.titleAccent,
    required this.body,
  });
}

final List<OnboardingContent> onboardingPages = [
  const OnboardingContent(
    imagePath: 'assets/images/onboarding_1.png',
    titleStart: 'Elevate Your Life\nwith ',
    titleAccent: 'HabitIQ',
    body:
        'Harness the power of predictive AI to build habits that stick and optimize your daily routine.',
  ),
  const OnboardingContent(
    imagePath: 'assets/images/onboarding_2.png',
    titleStart: 'AI-Powered\n',
    titleAccent: 'Insights',
    body:
        'Unlock hidden patterns. HabitIQ analyzes correlations between your routine and your mood to suggest impactful changes.',
  ),
  const OnboardingContent(
    imagePath: 'assets/images/onboarding_3.png',
    titleStart: 'Master ',
    titleAccent: 'Consistency',
    body:
        'Build unbreakable streaks and watch your HabitIQ grow. Earn XP, unlock levels, and visualize your progress like never before.',
  ),
];
