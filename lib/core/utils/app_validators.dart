import 'package:flutter/material.dart';

/// Centralised form validation logic following the Single Responsibility Principle.
///
/// All methods are pure functions: they take a raw field value and return
/// either an error message [String] or [null] when the value is valid.
class AppValidators {
  AppValidators._();

  // ── Individual field validators ──────────────────────────────────────────

  /// Ensures the value is not null or blank.
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  /// Validates a full name field (non-empty).
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    return null;
  }

  /// Validates an email address: non-empty and must contain `@`.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    if (!value.contains('@')) return 'Enter a valid email address';
    if (!value.contains('.')) return 'Enter a valid email address';

    return null;
  }

  /// Validates a password: non-empty and minimum 8 characters.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Validates a confirmation password field against the [passwordController].
  /// IMPORTANT: accepts a [TextEditingController] so the current text is read
  /// at validation time — not captured at widget build time.
  static String? Function(String?) confirmPassword(
    TextEditingController passwordController,
  ) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (passwordController.text != value) return 'Passwords do not match';
      return null;
    };
  }
}
