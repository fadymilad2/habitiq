import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/features/auth/presentation/manager/auth_cubit.dart';
import 'package:habit_iq/features/auth/presentation/pages/auth_view.dart';
import 'package:habit_iq/features/dashboard/presentation/manager/dashboard_cubit.dart';

class ProfileFooter extends StatelessWidget {
  const ProfileFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Log out button
        TextButton(
          onPressed: () {
            context.read<AuthCubit>().logout();
            context.read<DashboardCubit>().changeTab(0);
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, a, b) => const AuthView(),
                transitionsBuilder: (_, animation, b, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Log Out',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Version
        Text(
          'Version 2.4.0 (Build 349)',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
