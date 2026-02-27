import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/core/theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Dummy data per period
// ---------------------------------------------------------------------------
const _weeklyData = [
  FlSpot(0, 62),
  FlSpot(1, 55),
  FlSpot(2, 92),
  FlSpot(3, 70),
  FlSpot(4, 80),
  FlSpot(5, 95),
  FlSpot(6, 85),
];

const _monthlyData = [
  FlSpot(0, 50),
  FlSpot(1, 58),
  FlSpot(2, 72),
  FlSpot(3, 65),
  FlSpot(4, 77),
  FlSpot(5, 80),
  FlSpot(6, 68),
  FlSpot(7, 75),
  FlSpot(8, 85),
  FlSpot(9, 90),
  FlSpot(10, 82),
  FlSpot(11, 88),
];

const _allData = [
  FlSpot(0, 40),
  FlSpot(1, 52),
  FlSpot(2, 60),
  FlSpot(3, 55),
  FlSpot(4, 68),
  FlSpot(5, 72),
  FlSpot(6, 78),
  FlSpot(7, 65),
  FlSpot(8, 80),
  FlSpot(9, 85),
  FlSpot(10, 88),
  FlSpot(11, 92),
];

const _labels7d = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _labels30d = [
  'W1',
  'W2',
  'W3',
  'W4',
  'W5',
  'W6',
  'W7',
  'W8',
  'W9',
  'W10',
  'W11',
  'W12',
];
const _labelsAll = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// Glowing "peak" dot index (highest value) per period
const _peakIndexByPeriod = [5, 10, 11]; // sat for 7D, oct for 30D, dec for ALL

enum _Period { d7, d30, all }

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class WeeklyCompletionChart extends StatefulWidget {
  const WeeklyCompletionChart({super.key});

  @override
  State<WeeklyCompletionChart> createState() => _WeeklyCompletionChartState();
}

class _WeeklyCompletionChartState extends State<WeeklyCompletionChart>
    with SingleTickerProviderStateMixin {
  _Period _selected = _Period.d7;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  List<FlSpot> get _data => switch (_selected) {
    _Period.d7 => _weeklyData,
    _Period.d30 => _monthlyData,
    _Period.all => _allData,
  };

  List<String> get _bottomLabels => switch (_selected) {
    _Period.d7 => _labels7d,
    _Period.d30 => _labels30d,
    _Period.all => _labelsAll,
  };

  int get _peakIndex => _peakIndexByPeriod[_selected.index];

  String get _percentLabel => switch (_selected) {
    _Period.d7 => '85%',
    _Period.d30 => '78%',
    _Period.all => '72%',
  };

  String get _changeLabel => switch (_selected) {
    _Period.d7 => '+12%',
    _Period.d30 => '+8%',
    _Period.all => '+25%',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 32,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ──────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Completion',
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  _percentLabel,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.trending_up,
                                        color: AppColors.success,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        _changeLabel,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Segment toggle
                      _SegmentToggle(
                        selected: _selected,
                        onChanged: (p) => setState(() => _selected = p),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // ── Chart ───────────────────────────────────────────────
                  SizedBox(
                    height: 160,
                    child: AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (_, _) => LineChart(
                        _buildChart(),
                        duration: const Duration(milliseconds: 500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LineChartData _buildChart() {
    final spots = _data;
    final peak = spots[_peakIndex];
    final labels = _bottomLabels;

    return LineChartData(
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= labels.length) return const SizedBox();
              // Show every other label for 30D / ALL to avoid clutter
              if (_selected != _Period.d7 && idx % 2 != 0) {
                return const SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  labels[idx],
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      minY: 30,
      maxY: 105,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.4,
          color: AppColors.primary,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, _) => spot.x == peak.x && spot.y == peak.y,
            getDotPainter: (spot, percent, bar, index) =>
                _GlowDotPainter(glowOpacity: _glowAnim.value),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.35),
                AppColors.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
          shadow: Shadow(
            color: AppColors.primary.withValues(alpha: 0.55 * _glowAnim.value),
            blurRadius: 14,
          ),
        ),
      ],
      // Tooltip on peak
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.surfaceHighlight,
          tooltipRoundedRadius: 10,
          getTooltipItems: (touchedSpots) => touchedSpots
              .map(
                (s) => LineTooltipItem(
                  '${s.y.toInt()}%',
                  GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom glowing dot painter
// ---------------------------------------------------------------------------
class _GlowDotPainter extends FlDotPainter {
  _GlowDotPainter({required this.glowOpacity});

  final double glowOpacity;

  @override
  Color get mainColor => AppColors.primary;

  @override
  List<Object?> get props => [glowOpacity];

  @override
  void draw(Canvas canvas, FlSpot spot, Offset center) {
    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.35 * glowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, 12, glowPaint);

    // Mid ring
    final ringPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 7, ringPaint);

    // Inner dot
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  Size getSize(FlSpot spot) => const Size(24, 24);

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) => b;
}

// ---------------------------------------------------------------------------
// Segment toggle
// ---------------------------------------------------------------------------
class _SegmentToggle extends StatelessWidget {
  const _SegmentToggle({required this.selected, required this.onChanged});

  final _Period selected;
  final ValueChanged<_Period> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            label: '7D',
            active: selected == _Period.d7,
            onTap: () => onChanged(_Period.d7),
          ),
          _Pill(
            label: '30D',
            active: selected == _Period.d30,
            onTap: () => onChanged(_Period.d30),
          ),
          _Pill(
            label: 'ALL',
            active: selected == _Period.all,
            onTap: () => onChanged(_Period.all),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
