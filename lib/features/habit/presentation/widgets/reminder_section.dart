import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom card showing a reminder time with a custom purple toggle Switch.
///
/// Manages its own [_enabled] toggle state.
class ReminderSection extends StatefulWidget {
  const ReminderSection({super.key});

  @override
  State<ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<ReminderSection> {
  bool _enabled = true;
  final String _time = '08:00 AM';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Bell icon container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Label + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _time,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Custom purple toggle
          _PurpleSwitch(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
        ],
      ),
    );
  }
}

// ── Custom purple Switch ───────────────────────────────────────────────────────

class _PurpleSwitch extends StatelessWidget {
  const _PurpleSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.primary,
      inactiveThumbColor: AppColors.textSecondary,
      inactiveTrackColor: AppColors.surfaceHighlight,
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }
}
