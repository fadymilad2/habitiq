import 'package:flutter/material.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/core/theme/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakCards extends StatelessWidget {
  const StreakCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StreakCard(
              icon: '🔥',
              iconBgColor: const Color(0xFFFF6B2B).withValues(alpha: 0.15),
              value: '12',
              label: 'Current Streak',
              glowColor: const Color(0xFFFF6B2B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StreakCard(
              icon: '🏆',
              iconBgColor: const Color(0xFFFFBF24).withValues(alpha: 0.15),
              value: '45',
              label: 'Best Streak',
              glowColor: const Color(0xFFFFBF24),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.icon,
    required this.iconBgColor,
    required this.value,
    required this.label,
    required this.glowColor,
  });

  final String icon;
  final Color iconBgColor;
  final String value;
  final String label;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
