import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Sealed state hierarchy for [AICubit].
///
/// Flow:
///   AIInitial → AILoading → AILoaded(message, currentMood)
///                         → AIError(error)
/// ─────────────────────────────────────────────────────────────────────────────
sealed class AIState extends Equatable {
  const AIState();
}

/// No request has been made yet. The UI shows a default prompt.
final class AIInitial extends AIState {
  const AIInitial();
  @override
  List<Object?> get props => [];
}

/// A Gemini request is in-flight.
final class AILoading extends AIState {
  const AILoading();
  @override
  List<Object?> get props => [];
}

/// Gemini responded successfully.
///
/// [message]     — the 2-sentence motivational message from the model.
/// [currentMood] — the mood label the user selected (e.g. "Happy").
final class AILoaded extends AIState {
  const AILoaded({
    required this.message,
    required this.currentMood,
    this.moodChartData = const [],
    this.habitChartData = const [],
    this.monthlyMoodCounts = const {},
    this.correlationValue = 0.0,
  });

  final String message;
  final String currentMood;

  // Data for the Analytics UI in Mood Tab
  final List<FlSpot> moodChartData;
  final List<FlSpot> habitChartData;
  final Map<String, int> monthlyMoodCounts;
  final double correlationValue;

  @override
  List<Object?> get props => [
    message,
    currentMood,
    moodChartData,
    habitChartData,
    monthlyMoodCounts,
    correlationValue,
  ];
}

/// The request failed (network error, bad API key, quota exceeded, etc.).
final class AIError extends AIState {
  const AIError(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
