import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/data/services/hive_service.dart';
import 'package:habit_iq/core/services/notification_service.dart';
import 'package:habit_iq/core/widgets/glow_toggle.dart';
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
  // Read initial value from Hive (default: false — notifications are NOT paused)
  late bool _switchValue =
      HiveService.settingsBox.get('isNotificationsPaused', defaultValue: false)
          as bool;

  Future<void> _handleToggle(bool val) async {
    setState(() => _switchValue = val);
    // Persist to Hive: true = user wants to pause reminders
    await HiveService.settingsBox.put('isNotificationsPaused', val);

    if (val) {
      // User turned Toggle ON -> Pause reminders
      await NotificationService.instance.cancelAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'All reminders paused 🔕',
              style: GoogleFonts.spaceGrotesk(),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.grey.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // User turned Toggle OFF -> Unpause (Activate reminders)
      await NotificationService.instance.requestPermissions();

      // Reschedule all active habit reminders
      final habitsBox = HiveService.habitsBox;
      int rescheduledCount = 0;
      for (final habit in habitsBox.values) {
        if (habit.hasReminder &&
            habit.reminderTime != null &&
            !habit.isCompletedToday) {
          await NotificationService.instance.scheduleHabitReminder(
            habit.id,
            habit.title,
            habit.reminderTime!.hour,
            habit.reminderTime!.minute,
          );
          rescheduledCount++;
        }
      }

      // Fire an instant test notification so the user sees it works immediately
      await NotificationService.instance.showInstantNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              rescheduledCount > 0
                  ? 'Reminders unpaused! $rescheduledCount habits scheduled. 🌟'
                  : 'Reminders unpaused! Add a reminder to your habits. 🌟',
              style: GoogleFonts.spaceGrotesk(),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF7C3AED),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: widget.tile.isSwitch
              ? () => _handleToggle(!_switchValue)
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
                // Trailing: GlowToggle for switches
                if (widget.tile.isSwitch)
                  GlowToggle(value: _switchValue, onChanged: _handleToggle)
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
