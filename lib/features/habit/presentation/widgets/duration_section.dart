import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Duration section with a days-target slider.
///
/// Adapts its secondary picker based on [frequency]:
/// - 0 (Daily)  → slider only
/// - 1 (Weekly) → day-of-week chip selector below the slider
/// - 2 (Custom) → end-date picker button below the slider
class DurationSection extends StatefulWidget {
  const DurationSection({
    super.key,
    this.frequency = 0,
    required this.onChanged,
  });

  /// 0 = Daily, 1 = Weekly, 2 = Custom
  final int frequency;

  /// Triggered whenever the slider tracking "days target" changes.
  final ValueChanged<int> onChanged;

  @override
  State<DurationSection> createState() => _DurationSectionState();
}

class _DurationSectionState extends State<DurationSection> {
  double _sliderValue = 66;

  // Weekly: set of selected day indices (0=Mon … 6=Sun)
  final Set<int> _selectedDays = {0}; // Monday selected by default

  // Custom: chosen end date
  DateTime? _endDate;

  static const _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: AppColors.surface,
              headerBackgroundColor: AppColors.primary,
              headerForegroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  String get _formattedEndDate {
    if (_endDate == null) return 'Pick end date';
    return '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ─────────────────────────────────────────────────
        Text(
          'DURATION',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
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
                  'Choose up to 365 days target',
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
                  onChanged: (v) {
                    setState(() => _sliderValue = v);
                    widget.onChanged(v.round());
                  },
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

              // ── Weekly: day-of-week chip row ───────────────────────────
              if (widget.frequency == 1) ...[
                const SizedBox(height: 20),
                Text(
                  'REPEAT ON',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final active = _selectedDays.contains(i);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (active && _selectedDays.length > 1) {
                            _selectedDays.remove(i);
                          } else {
                            _selectedDays.add(i);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.surfaceHighlight,
                          shape: BoxShape.circle,
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _dayLabels[i],
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: active
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],

              // ── Custom: end-date picker button ─────────────────────────
              if (widget.frequency == 2) ...[
                const SizedBox(height: 20),
                Text(
                  'END DATE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickEndDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _endDate != null
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: _endDate != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formattedEndDate,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: _endDate != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _endDate != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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
