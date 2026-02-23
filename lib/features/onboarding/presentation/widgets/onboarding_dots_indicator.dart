import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingDotsIndicator extends StatelessWidget {
  final PageController controller;
  final int count;

  const OnboardingDotsIndicator({
    super.key,
    required this.controller,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: ExpandingDotsEffect(
        dotHeight: 6,
        dotWidth: 6,
        expansionFactor: 4,
        spacing: 6,
        activeDotColor: AppColors.primary,
        dotColor: AppColors.surfaceHighlight,
        paintStyle: PaintingStyle.fill,
      ),
    );
  }
}
