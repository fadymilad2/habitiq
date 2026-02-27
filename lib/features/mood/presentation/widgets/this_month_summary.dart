import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Dummy monthly stats
// ---------------------------------------------------------------------------
class _MonthlyStat {
  const _MonthlyStat({
    required this.label,
    required this.count,
    required this.color,
    required this.fraction,
  });
  final String label;
  final int count;
  final Color color;
  final double fraction; // 0.0 – 1.0 for the multi-segment bar
}

const _stats = [
  _MonthlyStat(
    label: 'Great Days',
    count: 18,
    color: Color(0xFF4ADE80), // Green
    fraction: 0.60,
  ),
  _MonthlyStat(
    label: 'Okay Days',
    count: 5,
    color: Color(0xFFFBBF24), // Yellow
    fraction: 0.17,
  ),
  _MonthlyStat(
    label: 'Low Days',
    count: 2,
    color: Color(0xFFEF4444), // Red
    fraction: 0.07,
  ),
];

class ThisMonthSummary extends StatelessWidget {
  const ThisMonthSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────────────────────────
            Text(
              'This Month',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // ── Stat numbers ──────────────────────────────────────────────
            Row(
              children: _stats
                  .map((s) => Expanded(child: _StatColumn(stat: s)))
                  .toList(),
            ),

            const SizedBox(height: 18),

            // ── Multi-segment progress bar ─────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 8,
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final total = constraints.maxWidth;
                    return Row(
                      children: [
                        ..._stats.map(
                          (s) => Container(
                            width: total * s.fraction,
                            color: s.color,
                          ),
                        ),
                        // Remaining (empty days)
                        Expanded(
                          child: Container(color: AppColors.surfaceHighlight),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Bar legend ────────────────────────────────────────────────
            Row(
              children: _stats
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: s.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            s.label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.stat});
  final _MonthlyStat stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${stat.count}',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: stat.color,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
