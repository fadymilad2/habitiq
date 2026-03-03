import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_cubit.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_state.dart';
import 'package:habit_iq/features/mood/presentation/manager/ai_cubit.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_cubit.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_state.dart';

// ---------------------------------------------------------------------------
// Data model — ordered: Sad → Happy → Stressed → Calm → Tired
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
  _MoodOption(label: 'Sad', emoji: '😢', baseColor: Color(0xFF818CF8)),
  _MoodOption(label: 'Happy', emoji: '😊', baseColor: Color(0xFFFF8C42)),
  _MoodOption(label: 'Stressed', emoji: '😫', baseColor: Color(0xFFEF4444)),
  _MoodOption(label: 'Calm', emoji: '🌿', baseColor: Color(0xFF2DD4BF)),
  _MoodOption(label: 'Tired', emoji: '😴', baseColor: Color(0xFF60A5FA)),
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

  void _onMoodTapped(int index) {
    final isAlreadySelected = _selectedIndex == index;
    setState(() => _selectedIndex = isAlreadySelected ? null : index);

    if (isAlreadySelected) {
      context.read<AICubit>().resetToInitial();
      return;
    }

    final mood = _moods[index].label;

    // ── User name ───────────────────────────────────────────────────────────
    final userState = context.read<UserCubit>().state;
    final userName = userState is UserAuthenticated
        ? userState.user.name.split(' ').first
        : 'صديقي';

    // ── Habits progress ─────────────────────────────────────────────────────
    final habitsState = context.read<HabitsCubit>().state;
    double progress = 0.0;
    List<String> completedTitles = [];
    if (habitsState is HabitsLoaded) {
      progress = habitsState.dailyProgress;
      completedTitles = habitsState.habits
          .where((h) => h.isCompleted)
          .map((h) => h.title)
          .toList();
    }

    context.read<AICubit>().logMoodAndGenerateInsight(
      userName,
      progress,
      mood,
      3, // Explicitly passing 3 as fallback for mood intensity
      completedTitles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
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
        ),

        const SizedBox(height: 16),

        // ── Horizontal circular mood strip ─────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_moods.length, (i) {
              final gap = i < _moods.length - 1
                  ? const SizedBox(width: 14)
                  : const SizedBox.shrink();
              return Row(
                children: [
                  _MoodChip(
                    mood: _moods[i],
                    isSelected: _selectedIndex == i,
                    onTap: () => _onMoodTapped(i),
                  ),
                  gap,
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Circular mood chip
// ---------------------------------------------------------------------------
class _MoodChip extends StatelessWidget {
  const _MoodChip({
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Circular emoji button ────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? mood.baseColor.withValues(alpha: 0.20)
                  : AppColors.surface,
              border: Border.all(
                color: isSelected
                    ? mood.baseColor
                    : AppColors.primary.withValues(alpha: 0.15),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: mood.baseColor.withValues(alpha: 0.45),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                mood.emoji,
                style: TextStyle(fontSize: isSelected ? 26 : 22),
              ),
            ),
          ),

          const SizedBox(height: 7),

          // ── Label ────────────────────────────────────────────────────────
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? mood.baseColor : AppColors.textSecondary,
            ),
            child: Text(mood.label),
          ),
        ],
      ),
    );
  }
}
