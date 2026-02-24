import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Top row of the Home Screen.
///
/// Shows:
/// - User avatar with an online green indicator dot.
/// - Greeting text + LVL progress bar.
/// - Streak counter (fire icon + number).
///
/// All values are passed in via constructor — zero hard-coded state.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.level,
    required this.levelProgress,
    required this.streakCount,
    this.avatarUrl,
  });

  final String userName;
  final int level;

  /// Progress within the current level, 0.0 – 1.0.
  final double levelProgress;
  final int streakCount;

  /// Optional network avatar URL; falls back to initials.
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Avatar ──────────────────────────────────────────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _initialsAvatar(),
                      ),
                    )
                  : _initialsAvatar(),
            ),
            // Online dot
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),

        // ── Greeting + Level bar ─────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'LVL $level',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _LevelProgressBar(progress: levelProgress)),
                ],
              ),
            ],
          ),
        ),

        // ── Streak counter ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceHighlight, width: 1),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF6B35),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '$streakCount',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _initialsAvatar() {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Private sub-widget ─────────────────────────────────────────────────────────

class _LevelProgressBar extends StatelessWidget {
  const _LevelProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          children: [
            // Track
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Fill
            Container(
              height: 5,
              width: constraints.maxWidth * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
