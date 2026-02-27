import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------
class _MoodOption {
  const _MoodOption({
    required this.label,
    required this.emoji,
    required this.baseColor,
  });

  final String label;
  final String emoji;
  final Color baseColor;
}

const _moods = [
  _MoodOption(
    label: 'Happy',
    emoji: '😊',
    baseColor: Color(0xFFFF8C42), // Orange
  ),
  _MoodOption(
    label: 'Calm',
    emoji: '🌿',
    baseColor: Color(0xFF2DD4BF), // Teal
  ),
  _MoodOption(
    label: 'Stressed',
    emoji: '😤',
    baseColor: Color(0xFFEF4444), // Red
  ),
  _MoodOption(
    label: 'Tired',
    emoji: '😴',
    baseColor: Color(0xFF60A5FA), // Blue
  ),
];

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class MoodSelectorSection extends StatefulWidget {
  const MoodSelectorSection({super.key});

  @override
  State<MoodSelectorSection> createState() => _MoodSelectorSectionState();
}

class _MoodSelectorSectionState extends State<MoodSelectorSection> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // ── Section header ───────────────────────────────────────────────
          Row(
            children: [
              Text(
                'How are you feeling?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'TODAY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 2×2 Mood grid ────────────────────────────────────────────────
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.0,
            ),
            itemCount: _moods.length,
            itemBuilder: (context, i) {
              final mood = _moods[i];
              final isSelected = _selectedIndex == i;
              return _MoodTile(
                mood: mood,
                isSelected: isSelected,
                onTap: () =>
                    setState(() => _selectedIndex = isSelected ? null : i),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single mood tile
// ---------------------------------------------------------------------------
class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final _MoodOption mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? mood.baseColor.withValues(alpha: 0.18)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? mood.baseColor.withValues(alpha: 0.75)
                : AppColors.primary.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: mood.baseColor.withValues(alpha: 0.28),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: mood.baseColor.withValues(
                  alpha: isSelected ? 0.25 : 0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(mood.emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              mood.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? mood.baseColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
