import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/core/widgets/app_background.dart';
import 'package:habit_iq/features/analytics/presentation/manager/analytics_cubit.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_cubit.dart';
import 'package:habit_iq/features/habit/presentation/manager/habits_state.dart';
import 'package:habit_iq/features/home/presentation/widgets/habit_card.dart';
import 'package:habit_iq/features/profile/presentation/manager/user_cubit.dart';

class AllHabitsView extends StatelessWidget {
  const AllHabitsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'All Habits',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<HabitsCubit, HabitsState>(
          builder: (context, state) {
            if (state is! HabitsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.habits.isEmpty) {
              return Center(
                child: Text(
                  'No habits found.',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              itemCount: state.habits.length,
              itemBuilder: (context, index) {
                final habit = state.habits[index];
                return HabitCard(
                  habit: habit,
                  onToggle: () {
                    final wasCompleted = habit.isCompleted;
                    context.read<HabitsCubit>().toggleHabitCompletion(habit.id);
                    context.read<AnalyticsCubit>().loadAnalytics();
                    if (!wasCompleted) {
                      context.read<UserCubit>().addXp(10);
                    } else {
                      context.read<UserCubit>().removeXp(10);
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
