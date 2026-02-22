import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// خلفية التطبيق الموحدة — 3 طبقات: لون صلب + إضاءتين من الزوايا
/// تستخدم في كل الشاشات عشان تدي إحساس موحد
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الطبقة الأساسية: الخلفية الصلبة
        SizedBox.expand(child: ColoredBox(color: AppColors.background)),
        // طبقة 1: Radial Glow من فوق شمال
        SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGlowTopLeft,
            ),
          ),
        ),
        // طبقة 2: Radial Glow من تحت يمين
        SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGlowBottomRight,
            ),
          ),
        ),
        // المحتوى فوق الخلفية
        ?child,
      ],
    );
  }
}
