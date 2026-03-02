import 'package:equatable/equatable.dart';
import 'package:habit_iq/features/home/domain/models/habit_model.dart' as ui;

/// ─────────────────────────────────────────────────────────────────────────────
/// Sealed state hierarchy for [HabitsCubit].
///
/// The cubit emits the **UI-layer** [ui.HabitModel] list so widgets can use it
/// directly without any additional mapping in the build tree.
///
/// Flow:
///   HabitsInitial → HabitsLoading → HabitsLoaded(habits, dailyProgress)
///                                 → HabitsError
/// ─────────────────────────────────────────────────────────────────────────────
sealed class HabitsState extends Equatable {
  const HabitsState();
}

/// Initial state before any load has been triggered.
final class HabitsInitial extends HabitsState {
  const HabitsInitial();
  @override
  List<Object?> get props => [];
}

/// A load or toggle operation is in progress.
final class HabitsLoading extends HabitsState {
  const HabitsLoading();
  @override
  List<Object?> get props => [];
}

/// Habits loaded successfully.
///
/// [habits]        — sorted list of UI-ready habit models for today.
/// [dailyProgress] — ratio of completed habits (0.0 – 1.0).
final class HabitsLoaded extends HabitsState {
  const HabitsLoaded({required this.habits, required this.dailyProgress});

  final List<ui.HabitModel> habits;

  /// Completed / total, clamped to [0.0, 1.0].
  final double dailyProgress;

  @override
  List<Object?> get props => [habits, dailyProgress];
}

/// Something went wrong — carry an optional message for the UI.
final class HabitsError extends HabitsState {
  const HabitsError([this.message = 'Something went wrong.']);
  final String message;
  @override
  List<Object?> get props => [message];
}
