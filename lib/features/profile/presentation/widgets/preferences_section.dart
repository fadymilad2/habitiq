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
    this.isSwitch = false,
  });
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool isSwitch;
}

const _tiles = [
  _PrefTile(
    icon: Icons.notifications_outlined,
    iconBg: Color(0xFFFF6B35),
    title: 'Pause All Reminders',
    subtitle: 'Mute habits notifications',
    isSwitch: true,
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
class _PreferenceTile extends StatefulWidget {
  const _PreferenceTile({required this.tile, required this.isLast});
  final _PrefTile tile;
  final bool isLast;

  @override
  State<_PreferenceTile> createState() => _PreferenceTileState();
}

class _PreferenceTileState extends State<_PreferenceTile> {
  bool _switchValue = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: widget.tile.isSwitch
              ? () => setState(() => _switchValue = !_switchValue)
              : () {},
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
                    color: widget.tile.iconBg.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.tile.icon,
                    color: widget.tile.iconBg,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tile.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.tile.subtitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trailing: Switch OR optional label + chevron
                if (widget.tile.isSwitch)
                  Switch(
                    value: _switchValue,
                    onChanged: (val) => setState(() => _switchValue = val),
                    activeThumbColor: AppColors.primary,
                  )
                else
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
        if (!widget.isLast)
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
