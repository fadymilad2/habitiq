import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart'; // مسارك الصح

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background, // لون احتياطي
        image: DecorationImage(
          image: AssetImage(
            'assets/images/bg_glow.png',
          ), // صورة الخلفية الناعمة من فِجما
          fit: BoxFit.cover,
        ),
      ),
      // لو في محتوى هنعرضه، مفيش خلاص
      child: child,
    );
  }
}
