import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../data/models/onboarding_content.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        children: [
          // ─── Image area ───────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  content.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),

          // ─── Title ────────────────────────────────────────────────
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                  children: [
                    TextSpan(text: content.titleStart),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                        child: Text(
                          content.titleAccent,
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Body ─────────────────────────────────────────────────
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                content.body,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
