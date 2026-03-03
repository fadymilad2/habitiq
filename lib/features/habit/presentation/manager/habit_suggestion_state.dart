import 'package:equatable/equatable.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Sealed state hierarchy for [HabitSuggestionCubit].
///
/// Flow:
///   HabitSuggestionInitial → HabitSuggestionLoading
///                          → HabitSuggestionLoaded(name, iconIndex, colorIndex)
///                          → HabitSuggestionError(message)
/// ─────────────────────────────────────────────────────────────────────────────
sealed class HabitSuggestionState extends Equatable {
  const HabitSuggestionState();
}

/// No suggestion has been requested yet.
final class HabitSuggestionInitial extends HabitSuggestionState {
  const HabitSuggestionInitial();
  @override
  List<Object?> get props => [];
}

/// Groq API call is in-flight — show spinner in place of ✨ icon.
final class HabitSuggestionLoading extends HabitSuggestionState {
  const HabitSuggestionLoading();
  @override
  List<Object?> get props => [];
}

/// Groq responded with a valid suggestion.
///
/// [suggestedName]  — short habit name (≤4 words).
/// [iconIndex]      — index into [VisualIdentitySection._icons] (0-8).
/// [colorIndex]     — index into [VisualIdentitySection._colors] (0-5).
final class HabitSuggestionLoaded extends HabitSuggestionState {
  const HabitSuggestionLoaded({
    required this.suggestedName,
    required this.iconIndex,
    required this.colorIndex,
  });

  final String suggestedName;
  final int iconIndex;
  final int colorIndex;

  @override
  List<Object?> get props => [suggestedName, iconIndex, colorIndex];
}

/// The request failed (network error, bad API key, parse error, etc.).
final class HabitSuggestionError extends HabitSuggestionState {
  const HabitSuggestionError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
