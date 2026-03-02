import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/features/mood/presentation/manager/ai_cubit.dart';
import 'package:habit_iq/features/mood/presentation/manager/ai_state.dart';

/// AI Suggestion Card — driven by [AICubit].
///
/// States:
///   • [AIInitial]  → friendly prompt to select a mood.
///   • [AILoading]  → animated pulsing dots (shimmer-like).
///   • [AILoaded]   → Gemini message with a fade-in animation.
///   • [AIError]    → error description with a retry hint.
class AISuggestionCard extends StatelessWidget {
  const AISuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.28),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  blurRadius: 28,
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon + Title row ──────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Insight',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        BlocBuilder<AICubit, AIState>(
                          builder: (context, state) {
                            final String subtitle;
                            if (state is AILoaded) {
                              subtitle =
                                  'AI Insight based on your ${state.currentMood} mood';
                            } else if (state is AILoading) {
                              subtitle = 'Thinking…';
                            } else {
                              subtitle = 'Powered by Gemini';
                            }
                            return Text(
                              subtitle,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                color: state is AILoaded
                                    ? AppColors.primary.withValues(alpha: 0.85)
                                    : AppColors.textSecondary,
                                fontWeight: state is AILoaded
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Dynamic content area ──────────────────────────────────
                BlocBuilder<AICubit, AIState>(
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: switch (state) {
                        AIInitial() => _InitialBody(
                          key: const ValueKey('initial'),
                        ),
                        AILoading() => _LoadingBody(
                          key: const ValueKey('loading'),
                        ),
                        AILoaded(:final message) => _LoadedBody(
                          key: const ValueKey('loaded'),
                          message: message,
                        ),
                        AIError(:final error) => _ErrorBody(
                          key: const ValueKey('error'),
                          error: error,
                        ),
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── State body widgets ──────────────────────────────────────────────────────

class _InitialBody extends StatelessWidget {
  const _InitialBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('✨', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Select your mood today to get your personalised AI insight!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              height: 1.65,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingBody extends StatefulWidget {
  const _LoadingBody({super.key});

  @override
  State<_LoadingBody> createState() => _LoadingBodyState();
}

class _LoadingBodyState extends State<_LoadingBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Generating your insight…',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Shimmer placeholder bars
        AnimatedBuilder(
          animation: _anim,
          builder: (context, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBar(1.0, _anim.value),
              const SizedBox(height: 8),
              _shimmerBar(0.85, _anim.value),
              const SizedBox(height: 8),
              _shimmerBar(0.6, _anim.value),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shimmerBar(double widthFactor, double opacity) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: opacity * 0.25),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class _LoadedBody extends StatefulWidget {
  const _LoadedBody({super.key, required this.message});
  final String message;

  @override
  State<_LoadedBody> createState() => _LoadedBodyState();
}

class _LoadedBodyState extends State<_LoadedBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                height: 1.65,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            // Subtle "Powered by Gemini" chip
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 5),
                Text(
                  'Powered by Gemini',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppColors.primary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  height: 1.6,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Try selecting your mood again.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
