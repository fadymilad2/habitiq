import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashTitle extends StatelessWidget {
  const SplashTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // اسم التطبيق (HabitIQ)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Habit',
              style: AppTextStyles.heading1.copyWith(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                color: AppColors.textPrimary,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.primaryGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
              child: Text(
                'IQ',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Subtitle
        Text(
          'REDEFINING DISCIPLINE',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
            color: AppColors.primaryVariant,
          ),
        ),
      ],
    );
  }
}
