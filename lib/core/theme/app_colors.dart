import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(
    0xFF0F0C20,
  ); // Deep dark purple/black background
  static const Color surface = Color(
    0xFF1A1635,
  ); // Lighter purple for cards, lists, bottom nav
  static const Color surfaceHighlight = Color(
    0xFF26214A,
  ); // For hovered or selected states

  // Primary & Accents
  static const Color primary = Color(
    0xFF7E3DFF,
  ); // Bright Neon Purple for primary actions
  static const Color primaryVariant = Color(0xFF5B21D0);
  static const Color accentOpacity = Color(0x337E3DFF); // For glowing effects

  // Text Colors
  static const Color textPrimary = Color(
    0xFFFFFFFF,
  ); // Pure white for headings & primary text
  static const Color textSecondary = Color(
    0xFFA6A6B1,
  ); // Light greyish purple for subtitles & hints

  // Semantic Colors
  static const Color success = Color(
    0xFF4ADE80,
  ); // Green for positive progress/streaks
  static const Color error = Color(0xFFF87171); // Red for errors
  static const Color warning = Color(
    0xFFFBBF24,
  ); // Yellow/Orange for warnings/flames

  // Custom Gradients (Useful for buttons, backgrounds, and charts as seen in the design)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8A2BE2), Color(0xFF4A00E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0F0C20), Color(0xFF1A1635)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
