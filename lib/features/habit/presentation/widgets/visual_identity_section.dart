import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Selectable icon grid + color circle row for the habit's visual identity.
///
/// Manages its own [_selectedIconIndex] and [_selectedColorIndex] state.
/// Reports changes to the parent via [onIconChanged] and [onColorChanged].
class VisualIdentitySection extends StatefulWidget {
  const VisualIdentitySection({
    super.key,
    this.onIconChanged,
    this.onColorChanged,
  });

  /// Called whenever the user selects a different icon.
  final ValueChanged<IconData>? onIconChanged;

  /// Called whenever the user selects a different colour.
  final ValueChanged<Color>? onColorChanged;

  @override
  State<VisualIdentitySection> createState() => _VisualIdentitySectionState();
}

class _VisualIdentitySectionState extends State<VisualIdentitySection> {
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;

  // ── Data ──────────────────────────────────────────────────────────────────

  static const _icons = [
    Icons.menu_book_rounded,
    Icons.fitness_center_rounded,
    Icons.water_drop_outlined,
    Icons.code_rounded,
    Icons.self_improvement_rounded,
    Icons.nightlight_round,
    Icons.directions_bike_rounded,
    Icons.savings_outlined,
    Icons.palette_outlined,
    Icons.more_horiz_rounded,
  ];

  static const _colors = [
    Color(0xFF590DF2), // Neon Purple (primary)
    Color(0xFF00D4FF), // Cyan
    Color(0xFFFF2D78), // Hot Pink
    Color(0xFFB8FF00), // Lime
    Color(0xFFFF7A00), // Orange
    Color(0xFF6C6C80), // Grey
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ──────────────────────────────────────────────────
        _SectionLabel('VISUAL IDENTITY'),
        const SizedBox(height: 12),

        // ── Icon grid ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _icons.length,
            itemBuilder: (_, i) {
              final selected = i == _selectedIconIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIconIndex = i);
                  widget.onIconChanged?.call(_icons[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _icons[i],
                    color: selected ? Colors.white : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // ── Color circles ──────────────────────────────────────────────────
        Row(
          children: [
            ..._colors.asMap().entries.map((entry) {
              final i = entry.key;
              final color = entry.value;
              final selected = i == _selectedColorIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColorIndex = i);
                  widget.onColorChanged?.call(color);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.white, width: 2.5)
                        : Border.all(color: Colors.transparent, width: 2.5),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.55),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),

            // "+" add custom colour
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Shared section label ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
}
