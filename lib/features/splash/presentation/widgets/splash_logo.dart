import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return SizedBox(
      width: 160,
      height: 160,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Center(
          child: Image.asset('assets/images/logo.png', width: 80, height: 80),
        ),
=======
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: Center(
        child: Image.asset('assets/images/logo.png', width: 80, height: 80),
>>>>>>> d2dbf1e52be77c326b05f18495e874f0eca78399
      ),
    );
  }
}
