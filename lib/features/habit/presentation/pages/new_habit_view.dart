import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/duration_section.dart';
import '../widgets/frequency_selector.dart';
import '../widgets/habit_name_field.dart';
import '../widgets/new_habit_header.dart';
import '../widgets/reminder_section.dart';
import '../widgets/visual_identity_section.dart';

/// Full-screen modal for creating a new habit.
///
/// Pushed via [Navigator.of(context).push] with a slide-up transition.
/// Responsibility: orchestration only — all UI lives in the extracted widgets.
class NewHabitView extends StatefulWidget {
  const NewHabitView({super.key});

  @override
  State<NewHabitView> createState() => _NewHabitViewState();
}

class _NewHabitViewState extends State<NewHabitView> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onCancel() => Navigator.of(context).pop();
  void _onSave() {} // TODO: validate & persist the new habit

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Slightly darker than the main bg to feel like a modal layer
      backgroundColor: const Color(0xFF110C1A),
      resizeToAvoidBottomInset: true,
      // ── Fixed save FAB — never scrolls ──────────────────────────────────
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.60),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: IconButton(
          onPressed: _onSave,
          icon: const Icon(Icons.save_rounded, color: Colors.white, size: 24),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Header ─────────────────────────────────────────────────
              NewHabitHeader(onCancel: _onCancel),
              const SizedBox(height: 24),

              // ── 2. Habit name field ───────────────────────────────────────
              HabitNameField(controller: _nameController),
              const SizedBox(height: 28),

              // ── 3. Visual identity ────────────────────────────────────────
              const VisualIdentitySection(),
              const SizedBox(height: 28),

              // ── 4. Frequency ──────────────────────────────────────────────
              const FrequencySelector(),
              const SizedBox(height: 28),

              // ── 5. Duration card ──────────────────────────────────────────
              const DurationSection(),
              const SizedBox(height: 28),

              // ── 6. Reminder ───────────────────────────────────────────────
              const ReminderSection(),
            ],
          ),
        ),
      ),
    );
  }
}
