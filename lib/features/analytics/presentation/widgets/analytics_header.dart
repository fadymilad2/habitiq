import 'package:flutter/material.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/core/theme/app_text_styles.dart';
import 'package:habit_iq/features/profile/presentation/pages/profile_view.dart';

class AnalyticsHeader extends StatelessWidget {
  const AnalyticsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Analytics', style: AppTextStyles.heading2),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child:  IconButton(
                icon: const Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileView(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
