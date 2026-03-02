import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_iq/core/data/services/hive_service.dart';

/// Key used to persist the theme preference in [HiveBoxes.settings].
const _kThemeKey = 'isDarkMode';

/// ─────────────────────────────────────────────────────────────────────────────
/// ThemeCubit
///
/// Emits a [ThemeMode] that the root [MaterialApp] reacts to via BlocBuilder.
///
/// Persistence contract:
///  - On construction: reads [_kThemeKey] from `settingsBox` (defaults to dark).
///  - On [toggleTheme]: flips the mode and immediately writes to `settingsBox`.
/// ─────────────────────────────────────────────────────────────────────────────
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_loadThemeFromStorage());

  /// Reads the persisted theme preference.
  /// Falls back to [ThemeMode.dark] if no value has been saved yet.
  static ThemeMode _loadThemeFromStorage() {
    final isDark =
        HiveService.settingsBox.get(_kThemeKey, defaultValue: true) as bool;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Whether the app is currently in dark mode.
  bool get isDark => state == ThemeMode.dark;

  /// Toggles between [ThemeMode.dark] and [ThemeMode.light], then
  /// persists the new preference so it survives app restarts.
  void toggleTheme() {
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    HiveService.settingsBox.put(_kThemeKey, newMode == ThemeMode.dark);
    emit(newMode);
  }

  /// Explicitly sets the theme to [ThemeMode.dark].
  void setDark() {
    if (!isDark) toggleTheme();
  }

  /// Explicitly sets the theme to [ThemeMode.light].
  void setLight() {
    if (isDark) toggleTheme();
  }
}
