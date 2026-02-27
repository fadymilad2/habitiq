import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Duration section: Count / Date toggle, target-days display, and a custom
/// glowing Slider. The Save FAB is rendered at Scaffold level so it stays fixed.
class DurationSection extends StatefulWidget {
  const DurationSection({super.key});

  @override
  State<DurationSection> createState() => _DurationSectionState();
}

class _DurationSectionState extends State<DurationSection> {
  bool _isCount = true; // true = Count tab, false = Date tab
  double _sliderValue = 66;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ───────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DURATION',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            _CountDateToggle(
              isCount: _isCount,
              onTap: () => setState(() => _isCount = !_isCount),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Duration card ─────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sub-label pill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Choose up to 365 days or select end date',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Target days row
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${_sliderValue.round()}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'days target',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Glowing custom slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.surfaceHighlight,
                  thumbColor: Colors.white,
                  thumbShape: _GlowingThumbShape(),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: _sliderValue,
                  min: 1,
                  max: 365,
                  onChanged: (v) => setState(() => _sliderValue = v),
                ),
              ),

              // Min / max labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1 day',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '365 days',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Count / Date mini-toggle ──────────────────────────────────────────────────

class _CountDateToggle extends StatelessWidget {
  const _CountDateToggle({required this.isCount, required this.onTap});
  final bool isCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Tab(label: 'Count', active: isCount),
            _Tab(label: 'Date', active: !isCount),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Glowing thumb shape ────────────────────────────────────────────────────────

class _GlowingThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 20);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Neon glow ring
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 13, glowPaint);

    // Purple border ring
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 10, borderPaint);

    // White core
    final corePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 8, corePaint);
  }
}
