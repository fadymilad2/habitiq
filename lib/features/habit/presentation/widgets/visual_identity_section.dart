import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Selectable icon grid + colour circle row for the habit's visual identity.
///
/// Supports external index control via [selectedIconIndex] and
/// [selectedColorIndex] so that the AI suggestion cubit can drive the
/// selection without the widget holding its own authoritative state.
class VisualIdentitySection extends StatefulWidget {
  const VisualIdentitySection({
    super.key,
    this.onIconChanged,
    this.selectedIconIndex,
  });

  /// Called whenever the user (or AI) selects a different icon.
  final ValueChanged<IconData>? onIconChanged;

  /// When non-null, overrides the internal selected icon index.
  final int? selectedIconIndex;

  // ── Static data exposed so HabitSuggestionCubit can reference indices ──────
  static const icons = [
    Icons.menu_book_rounded, // 0 – reading
    Icons.fitness_center_rounded, // 1 – fitness
    Icons.water_drop_outlined, // 2 – hydration
    Icons.code_rounded, // 3 – coding
    Icons.self_improvement_rounded, // 4 – meditation
    Icons.nightlight_round, // 5 – sleep
    Icons.directions_bike_rounded, // 6 – cycling
    Icons.savings_outlined, // 7 – finance
    Icons.palette_outlined, // 8 – creativity
    Icons.more_horiz_rounded, // 9 – other (catch-all)
  ];

  static const colors = [
    Color(0xFF590DF2), // 0 – Neon Purple (primary)
    Color(0xFF00D4FF), // 1 – Cyan
    Color(0xFFFF2D78), // 2 – Hot Pink
    Color(0xFFB8FF00), // 3 – Lime
    Color(0xFFFF7A00), // 4 – Orange
    Color(0xFF6C6C80), // 5 – Grey
  ];

  @override
  State<VisualIdentitySection> createState() => _VisualIdentitySectionState();
}

class _VisualIdentitySectionState extends State<VisualIdentitySection> {
  int _iconIndex = 0;

  @override
  void didUpdateWidget(VisualIdentitySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIconIndex != null &&
        widget.selectedIconIndex != _iconIndex) {
      _iconIndex = widget.selectedIconIndex!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconIndex = widget.selectedIconIndex ?? _iconIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ───────────────────────────────────────────────────
        _SectionLabel('VISUAL IDENTITY'),
        const SizedBox(height: 12),

        // ── Icon grid ───────────────────────────────────────────────────────
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
            itemCount: VisualIdentitySection.icons.length,
            itemBuilder: (_, i) {
              final selected = i == effectiveIconIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _iconIndex = i);
                  widget.onIconChanged?.call(VisualIdentitySection.icons[i]);
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
                    VisualIdentitySection.icons[i],
                    color: selected ? Colors.white : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
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
