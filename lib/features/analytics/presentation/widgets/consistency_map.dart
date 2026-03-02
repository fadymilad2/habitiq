import 'package:flutter/material.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/core/theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Intensity → opacity mapping (matches original ConsistencyMap visual design)
// ---------------------------------------------------------------------------
const _opacities = [0.06, 0.25, 0.45, 0.68, 1.0];

/// Maps a completion percentage (0–100) to an intensity bucket (0–4).
///
/// Bucket thresholds:
///  0 = 0%         (no completions that day)
///  1 = 1–24%
///  2 = 25–49%
///  3 = 50–74%
///  4 = 75–100%
int _percentToIntensity(int percent) {
  if (percent == 0) return 0;
  if (percent < 25) return 1;
  if (percent < 50) return 2;
  if (percent < 75) return 3;
  return 4;
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class ConsistencyMap extends StatelessWidget {
  const ConsistencyMap({super.key, required this.heatMapData});

  /// date (time-zeroed) → completion percentage 0–100 for the past 91 days.
  /// Expected to contain exactly 91 entries (7 rows × 13 columns).
  final Map<DateTime, int> heatMapData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
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
                      color: AppColors.primary.withValues(alpha: op),
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

                // Sort the map entries by date (oldest first) so the grid
                // fills left-to-right, oldest column on the left.
                final sortedEntries = heatMapData.entries.toList()
                  ..sort((a, b) => a.key.compareTo(b.key));
                // Reshape flat list into 7 rows × 13 cols (row-major, Mon–Sun).
                // Each column = one week; each row = one weekday.
                // We fill column by column (91 entries / 7 rows = 13 cols).
                final grid = List.generate(rows, (row) {
                  return List.generate(cols, (col) {
                    final idx = col * rows + row;
                    if (idx >= sortedEntries.length) return 0;
                    return _percentToIntensity(sortedEntries[idx].value);
                  });
                });

                return Column(
                  children: List.generate(rows, (rowIdx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: List.generate(cols, (colIdx) {
                          final intensity = grid[rowIdx][colIdx];
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
    final vvalwithValues = _opacities[intensity.clamp(0, 4)];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: vvalwithValues),
        borderRadius: BorderRadius.circular(4),
        boxShadow: intensity >= 3
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.3 * vvalwithValues,
                  ),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
    );
  }
}
