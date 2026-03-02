import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_cubit.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_state.dart';

class UserAvatarSection extends StatelessWidget {
  const UserAvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        // Resolve live data from state; fall back to safe defaults while loading.
        final name = state is UserAuthenticated ? state.user.name : '—';
        final level = state is UserAuthenticated ? state.user.level : 1;
        final avatarUrl =
            (state is UserAuthenticated &&
                state.user.avatarPath != null &&
                state.user.avatarPath!.startsWith('http'))
            ? state.user.avatarPath!
            : 'https://i.pravatar.cc/200?img=11';

        return Column(
          children: [
            // Avatar with glow & camera badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.55),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2E1F4E),
                    child: ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          size: 56,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                // Camera badge
                Positioned(
                  bottom: 2,
                  right: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Name (live from UserCubit) ─────────────────────────────────
            Text(
              name,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // ── Level pill + title (live from UserCubit) ───────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'LEVEL $level',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Habit Master',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
