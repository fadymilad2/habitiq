import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
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
    colors: [
      Color(0xFFA78BFA), // موف فاتح وفاقع من فوق
      Color(0xFF590DF2), // موف أغمق وأزرق شوية من تحت
    ],
    begin: Alignment.topCenter, // نخليه يبدأ من النص فوق
    end: Alignment.bottomCenter, // وينتهي في النص تحت
  );

  // Background Glow
  static const Color backgroundGlow = Color(
    0xFF590DF2,
  ); // لون الإضاءة الناري الموحد
  // إضاءة قوية من فوق شمال
  // إضاءة ناعمة من فوق شمال
  static const RadialGradient backgroundGlowTopLeft = RadialGradient(
    center: Alignment(-1.0, -1.0),
    radius: 1.5, // كبرنا نص القطر عشان تسيح بنعومة أكتر
    colors: [
      Color(0x66590DF2), // 40% شفافة عشان متبقاش فاقعة
      Color(0x00161022), // 0% شفافة (بتختفي تماماً في لون الخلفية)
    ],
    // شيلنا الـ stops الكتير عشان فلاتر يعمل تدرج ناعم لوحده
  );

  // إضاءة أهدى كمان من تحت يمين
  static const RadialGradient backgroundGlowBottomRight = RadialGradient(
    center: Alignment(1.0, 1.0),
    radius: 1.2,
    colors: [
      Color(0x4D590DF2), // 30% شفافة (أهدى من اللي فوق)
      Color(0x00161022), // 0% شفافة
    ],
  );
}
