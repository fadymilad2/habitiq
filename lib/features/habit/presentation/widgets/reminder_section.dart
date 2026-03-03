import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Reminder time card with a toggle switch and an interactive time display.
///
/// Tapping anywhere on the card (or the time text) opens Flutter's native
/// [showTimePicker] so the user can pick an exact reminder time.
class ReminderSection extends StatefulWidget {
  const ReminderSection({super.key});

  @override
  State<ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<ReminderSection> {
  bool _enabled = true;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  String get _formattedTime {
    final hour = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final minute = _time.minute.toString().padLeft(2, '0');
    final period = _time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        // Match app dark theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              dialBackgroundColor: AppColors.surfaceHighlight,
              hourMinuteColor: AppColors.surfaceHighlight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _enabled ? _pickTime : null,
      child: Container(
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

            // Label + tappable time
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
                    _enabled ? _formattedTime : 'Tap to enable',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: _enabled
                          ? AppColors.primary
                          : AppColors.textSecondary,
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
