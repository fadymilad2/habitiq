import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';

/// Large circular progress indicator for the daily goal.
///
/// Uses `CircularPercentIndicator` from the `percent_indicator` package,
/// wrapped with a neon glow shadow and a motivational quote below.
class DailyProgressRing extends StatelessWidget {
  const DailyProgressRing({
    super.key,
    required this.percent,
    this.quote = '"Consistency is the key to mastery."',
  });

  /// Completion ratio 0.0 – 1.0.
  final double percent;
  final String quote;

  @override
  Widget build(BuildContext context) {
    final pct = percent.clamp(0.0, 1.0);

    return Column(
      children: [
        // ── Glow wrapper ────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 40,
                spreadRadius: 6,
              ),
            ],
          ),
          child: CircularPercentIndicator(
            radius: 110,
            lineWidth: 14,
            percent: pct,
            animation: true,
            animationDuration: 1200,
            animateFromLastPercent: true,
            backgroundColor: AppColors.surfaceHighlight,
            linearGradient: const LinearGradient(
              colors: [Color(0xFFA78BFA), AppColors.primary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(pct * 100).round()}%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'DAILY GOAL',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Motivational quote ───────────────────────────────────────────────
        Text(
          quote,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,

            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
