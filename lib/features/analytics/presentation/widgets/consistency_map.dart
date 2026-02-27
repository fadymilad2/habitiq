import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/core/theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Dummy heatmap data — 7 rows × 13 columns (≈ 13 weeks)
// Using values 0–4 to represent intensity buckets, similar to GitHub style.
// ---------------------------------------------------------------------------
final _random = Random(42);

// Generate a realistic-looking pattern seeded so it's deterministic
List<List<int>> _generateData() {
  return List.generate(7, (row) {
    return List.generate(13, (col) {
      // Recent weeks (right side) → higher values
      final recency = col / 12.0; // 0 = oldest, 1 = newest
      final rand = _random.nextDouble();
      if (rand < 0.08) return 0;
      if (rand < 0.22 + recency * 0.1) return 1;
      if (rand < 0.55 + recency * 0.2) return 2;
      if (rand < 0.78 + recency * 0.1) return 3;
      return 4;
    });
  });
}

final _heatmapData = _generateData();

// ---------------------------------------------------------------------------
// Intensity → opacity mapping
// ---------------------------------------------------------------------------
const _opacities = [0.06, 0.25, 0.45, 0.68, 1.0];

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class ConsistencyMap extends StatelessWidget {
  const ConsistencyMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text('Consistency', style: AppTextStyles.heading3),
            const SizedBox(height: 16),

            // Legend row
            Row(
              children: [
                Text('Less', style: AppTextStyles.bodySmall),
                const SizedBox(width: 6),
                ..._opacities.map(
                  (op) => Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(op),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Text('More', style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 12),

            // Grid
            LayoutBuilder(
              builder: (context, constraints) {
                const cols = 13;
                const rows = 7;
                const spacing = 4.0;
                final cellSize =
                    (constraints.maxWidth - spacing * (cols - 1)) / cols;

                return Column(
                  children: List.generate(rows, (rowIdx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: List.generate(cols, (colIdx) {
                          final intensity = _heatmapData[rowIdx][colIdx];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: colIdx < cols - 1 ? spacing : 0,
                            ),
                            child: _HeatCell(
                              size: cellSize,
                              intensity: intensity,
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual cell
// ---------------------------------------------------------------------------
class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.size, required this.intensity});

  final double size;
  final int intensity; // 0–4

  @override
  Widget build(BuildContext context) {
    final opacity = _opacities[intensity.clamp(0, 4)];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(opacity),
        borderRadius: BorderRadius.circular(4),
        boxShadow: intensity >= 3
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3 * opacity),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
    );
  }
}
