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
  const AIState({
    this.moodChartData = const [],
    this.habitChartData = const [],
    this.monthlyMoodCounts = const {},
    this.correlationValue = 0.0,
  });

  final List<FlSpot> moodChartData;
  final List<FlSpot> habitChartData;
  final Map<String, int> monthlyMoodCounts;
  final double correlationValue;

  @override
  List<Object?> get props => [
    moodChartData,
    habitChartData,
    monthlyMoodCounts,
    correlationValue,
  ];
}

/// No request has been made yet. The UI shows a default prompt.
final class AIInitial extends AIState {
  const AIInitial({
    super.moodChartData,
    super.habitChartData,
    super.monthlyMoodCounts,
    super.correlationValue,
  });
}

/// A Gemini request is in-flight.
final class AILoading extends AIState {
  const AILoading({
    super.moodChartData,
    super.habitChartData,
    super.monthlyMoodCounts,
    super.correlationValue,
  });
}

/// Gemini responded successfully.
final class AILoaded extends AIState {
  const AILoaded({
    required this.message,
    required this.currentMood,
    super.moodChartData,
    super.habitChartData,
    super.monthlyMoodCounts,
    super.correlationValue,
  });

  final String message;
  final String currentMood;

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

/// The request failed.
final class AIError extends AIState {
  const AIError(
    this.error, {
    super.moodChartData,
    super.habitChartData,
    super.monthlyMoodCounts,
    super.correlationValue,
  });

  final String error;

  @override
  List<Object?> get props => [
    error,
    moodChartData,
    habitChartData,
    monthlyMoodCounts,
    correlationValue,
  ];
}
