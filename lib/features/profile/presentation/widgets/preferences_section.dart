import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────
class _PrefTile {
  const _PrefTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.trailingLabel,
  });
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? trailingLabel;
}

const _tiles = [
  _PrefTile(
    icon: Icons.notifications_outlined,
    iconBg: Color(0xFFFF6B35),
    title: 'Notifications',
    subtitle: 'Manage alerts & reminders',
  ),
  _PrefTile(
    icon: Icons.palette_outlined,
    iconBg: Color(0xFF590DF2),
    title: 'Theme',
    subtitle: 'Dark mode & colors',
    trailingLabel: 'Deep Purple',
  ),
  _PrefTile(
    icon: Icons.lock_outline_rounded,
    iconBg: Color(0xFF3B82F6),
    title: 'Privacy & Security',
    subtitle: 'Passcode & FaceID',
  ),
  _PrefTile(
    icon: Icons.extension_outlined,
    iconBg: Color(0xFF22C55E),
    title: 'Integrations',
    subtitle: 'Health Kit, Calendar',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────
class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Text(
            'PREFERENCES',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Glassmorphism container
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: List.generate(_tiles.length, (i) {
                    final tile = _tiles[i];
                    final isLast = i == _tiles.length - 1;
                    return _PreferenceTile(tile: tile, isLast: isLast);
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual tile
// ─────────────────────────────────────────────────────────────────────────────
class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({required this.tile, required this.isLast});
  final _PrefTile tile;
  final bool isLast;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tile.iconBg.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tile.icon, color: tile.iconBg, size: 19),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tile.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tile.subtitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trailing: optional label + chevron
                if (tile.trailingLabel != null) ...[
                  Text(
                    tile.trailingLabel!,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        // Divider (except after last tile)
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 68,
            endIndent: 16,
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}

