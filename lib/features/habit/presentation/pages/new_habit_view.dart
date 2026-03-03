import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/features/dashboard/presentation/manager/dashboard_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../presentation/manager/habits_cubit.dart';
import '../manager/habit_suggestion_cubit.dart';
import '../manager/habit_suggestion_state.dart';
import '../widgets/duration_section.dart';
import '../widgets/frequency_selector.dart';
import '../widgets/habit_name_field.dart';
import '../widgets/new_habit_header.dart';
import '../widgets/reminder_section.dart';
import '../widgets/visual_identity_section.dart';

/// Full-screen modal for creating a new habit with AI suggestion support.
///
/// Pushed via [Navigator.of(context).push] with a slide-up transition.
class NewHabitView extends StatefulWidget {
  const NewHabitView({super.key});

  @override
  State<NewHabitView> createState() => _NewHabitViewState();
}

class _NewHabitViewState extends State<NewHabitView> {
  final _nameController = TextEditingController();

  // Visual identity — kept in sync via callbacks and AI suggestions.
  IconData _selectedIcon = VisualIdentitySection.icons[0];
  Color _selectedColor = VisualIdentitySection.colors[0];

  // These mirror the widget's internal selection for AI-driven updates.
  int? _aiIconIndex;

  // Frequency index: 0=Daily, 1=Weekly, 2=Custom
  int _frequency = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onCancel() => Navigator.of(context).pop();

  void _onSave() {
    final title = _nameController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a habit name.',
            style: GoogleFonts.spaceGrotesk(),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    context.read<HabitsCubit>().addNewHabit(
      title,
      _selectedIcon,
      _selectedColor,
      frequency: _frequency,
    );
    context.read<DashboardCubit>().changeTab(0);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HabitSuggestionCubit(),
      child: _NewHabitBody(
        nameController: _nameController,
        selectedIcon: _selectedIcon,
        selectedColor: _selectedColor,
        aiIconIndex: _aiIconIndex,
        frequency: _frequency,
        onCancel: _onCancel,
        onSave: _onSave,
        onIconChanged: (icon) => setState(() => _selectedIcon = icon),
        onFrequencyChanged: (f) => setState(() => _frequency = f),
        onAiSuggestionLoaded: (iconIndex, colorIndex) {
          setState(() {
            _aiIconIndex = iconIndex;
            _selectedIcon = VisualIdentitySection.icons[iconIndex];
            _selectedColor = VisualIdentitySection.colors[colorIndex];
          });
        },
      ),
    );
  }
}

// ── Inner body widget — consumes HabitSuggestionCubit ─────────────────────────

class _NewHabitBody extends StatelessWidget {
  const _NewHabitBody({
    required this.nameController,
    required this.selectedIcon,
    required this.selectedColor,
    required this.aiIconIndex,
    required this.frequency,
    required this.onCancel,
    required this.onSave,
    required this.onIconChanged,
    required this.onFrequencyChanged,
    required this.onAiSuggestionLoaded,
  });

  final TextEditingController nameController;
  final IconData selectedIcon;
  final Color selectedColor;
  final int? aiIconIndex;
  final int frequency;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final ValueChanged<IconData> onIconChanged;
  final ValueChanged<int> onFrequencyChanged;
  final void Function(int iconIndex, int colorIndex) onAiSuggestionLoaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF110C1A),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocConsumer<HabitSuggestionCubit, HabitSuggestionState>(
          listener: (context, state) {
            if (state is HabitSuggestionLoaded) {
              // Auto-fill the name field.
              nameController.text = state.suggestedName;
              // Drive icon + color selection in the parent.
              onAiSuggestionLoaded(state.iconIndex, state.colorIndex);
            }
          },
          builder: (context, state) {
            final isLoading = state is HabitSuggestionLoading;
            final errorMsg = state is HabitSuggestionError
                ? state.message
                : null;

            return Column(
              children: [
                // ── Scrollable content ──────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. Header ───────────────────────────────────────
                        NewHabitHeader(onCancel: onCancel),
                        const SizedBox(height: 24),

                        // ── 2. Habit name + AI button ───────────────────────
                        HabitNameField(
                          controller: nameController,
                          isLoading: isLoading,
                          errorMessage: errorMsg,
                          onSuggestTap: () => context
                              .read<HabitSuggestionCubit>()
                              .suggestNewHabit(),
                        ),
                        const SizedBox(height: 28),

                        // ── 3. Visual identity ──────────────────────────────
                        VisualIdentitySection(
                          selectedIconIndex: aiIconIndex,
                          onIconChanged: onIconChanged,
                        ),
                        const SizedBox(height: 28),

                        // ── 4. Frequency ────────────────────────────────────
                        FrequencySelector(onChanged: onFrequencyChanged),
                        const SizedBox(height: 28),

                        // ── 5. Duration card ────────────────────────────────
                        DurationSection(frequency: frequency),
                        const SizedBox(height: 28),

                        // ── 6. Reminder ─────────────────────────────────────
                        const ReminderSection(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // ── Create Habit button (fixed at bottom) ───────────────────
                _CreateHabitButton(controller: nameController, onTap: onSave),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── "Create Habit" bottom button ───────────────────────────────────────────────

class _CreateHabitButton extends StatelessWidget {
  const _CreateHabitButton({required this.controller, required this.onTap});

  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF110C1A),
            border: Border(
              top: BorderSide(color: AppColors.surfaceHighlight, width: 1),
            ),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: hasText ? 1.0 : 0.45,
            child: GestureDetector(
              onTap: hasText ? onTap : null,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: hasText
                      ? AppColors.primaryGradient
                      : const LinearGradient(
                          colors: [Color(0xFF3D3D5C), Color(0xFF3D3D5C)],
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: hasText
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.45),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Create Habit',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
