import 'package:flutter/material.dart';
import 'package:habit_iq/features/profile/presentation/widgets/data_management_card.dart';
import 'package:habit_iq/features/profile/presentation/widgets/preferences_section.dart';
import 'package:habit_iq/features/profile/presentation/widgets/profile_footer.dart';
import 'package:habit_iq/features/profile/presentation/widgets/profile_header.dart';
import 'package:habit_iq/features/profile/presentation/widgets/profile_stats_row.dart';
import 'package:habit_iq/features/profile/presentation/widgets/user_avatar_section.dart';

/// ProfileView — Tab 4 of the main dashboard.
/// No Scaffold; intended as a child of an [IndexedStack].
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Header ────────────────────────────────────────────
              const ProfileHeader(),
              // ── Avatar + Name + Level ─────────────────────────────
              const SizedBox(height: 8),
              const UserAvatarSection(),
              // ── Stats row ─────────────────────────────────────────
              const SizedBox(height: 24),
              const ProfileStatsRow(),
              // ── Data Management ───────────────────────────────────
              const SizedBox(height: 28),
              const DataManagementCard(),
              // ── Preferences ───────────────────────────────────────
              const SizedBox(height: 28),
              const PreferencesSection(),
              // ── Footer ────────────────────────────────────────────
              const SizedBox(height: 28),
              const ProfileFooter(),
              // Extra bottom padding so content isn't hidden behind
              // the floating nav bar.
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}
