import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(
    0xFF161022,
  ); // Deep dark purple/black background
  static const Color surface = Color(
    0xFF1A1635,
  ); // Lighter purple for cards, lists, bottom nav
  static const Color surfaceHighlight = Color(
    0xFF26214A,
  ); // For hovered or selected states

  // Primary & Accents
  static const Color primary = Color(
    0xFF590DF2,
  ); // Bright Neon Purple for primary actions
  static const Color primaryVariant = Color(0xFF4205BB);
  static const Color accentOpacity = Color(0x33590DF2); // For glowing effects

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

  // Custom Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF590DF2), Color(0xFF8B47FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background Glow
  static const Color backgroundGlow = Color(0xFF381E72);

  static const RadialGradient backgroundGlowTopLeft = RadialGradient(
    center: Alignment(-1.0, -1.0),
    radius: 1.2,
    colors: [
      Color(0x99381E72),
      Color(0x80381E72),
      Color(0x66381E72),
      Color(0x4D381E72),
      Color(0x33381E72),
      Color(0x1A381E72),
      Color(0x0D381E72),
      Color(0x00161022),
    ],
    stops: [0.0, 0.12, 0.25, 0.38, 0.52, 0.68, 0.85, 1.0],
  );

  static const RadialGradient backgroundGlowBottomRight = RadialGradient(
    center: Alignment(1.0, 1.0),
    radius: 1.0,
    colors: [
      Color(0x66381E72),
      Color(0x55381E72),
      Color(0x44381E72),
      Color(0x33381E72),
      Color(0x22381E72),
      Color(0x11381E72),
      Color(0x00161022),
    ],
    stops: [0.0, 0.15, 0.3, 0.48, 0.65, 0.82, 1.0],
  );
}
