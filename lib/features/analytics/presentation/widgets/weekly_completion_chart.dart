import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_iq/core/theme/app_colors.dart';
import 'package:habit_iq/core/theme/app_text_styles.dart';
import 'package:habit_iq/features/analytics/presentation/manager/analytics_state.dart';

/// Monthly short-hand labels used to annotate the ALL-time axis.
const _monthAbbr = [
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

enum _Period { d7, d30, all }

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

/// A line-chart card that switches between the 7D, 30D, and ALL-time views.
///
/// All data is passed in via constructor parameters; no BlocBuilder here.
/// The parent (`AnalyticsView`) is responsible for reading state and
/// constructing this widget.
class WeeklyCompletionChart extends StatefulWidget {
  const WeeklyCompletionChart({
    super.key,
    required this.weeklyData,
    required this.monthlyData,
    required this.allTimeData,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.allTimeAverage,
  });

  /// Day-stamped values for recent 7 days
  final List<DayEntry> weeklyData;

  /// Day-stamped values for recent 30 days
  final List<DayEntry> monthlyData;

  /// Monthly aggregates
  final List<MonthEntry> allTimeData;

  final double weeklyAverage;
  final double monthlyAverage;
  final double allTimeAverage;

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

  // ── Data helpers ───────────────────────────────────────────────────────────

  List<FlSpot> _toDaySpots(List<DayEntry> entries) {
    return List.generate(
      entries.length,
      (i) => FlSpot(i.toDouble(), (entries[i].value * 100).clamp(0, 100)),
    );
  }

  List<FlSpot> _toMonthSpots(List<MonthEntry> entries) {
    return List.generate(
      entries.length,
      (i) => FlSpot(i.toDouble(), (entries[i].value * 100).clamp(0, 100)),
    );
  }

  /// Returns the `FlSpot` list for the currently selected period.
  List<FlSpot> get _spots {
    return switch (_selected) {
      _Period.d7 => _toDaySpots(widget.weeklyData),
      _Period.d30 => _toDaySpots(widget.monthlyData),
      _Period.all => _toMonthSpots(widget.allTimeData),
    };
  }

  /// Returns index of the spot with the highest y value (for the glow dot).
  int get _peakIndex {
    final spots = _spots;
    if (spots.isEmpty) return 0;
    int best = 0;
    for (int i = 1; i < spots.length; i++) {
      if (spots[i].y > spots[best].y) best = i;
    }
    return best;
  }

  // ── Label helpers ──────────────────────────────────────────────────────────

  /// Returns the x-axis label for a given index in the active period.
  String _labelAt(int index) {
    switch (_selected) {
      case _Period.d7:
        final entries = widget.weeklyData;
        if (index < 0 || index >= entries.length) return '';
        final day = entries[index].date;
        const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return weekdays[day.weekday - 1];

      case _Period.d30:
        if (index % 5 != 0) return '';
        final entries = widget.monthlyData;
        if (index < 0 || index >= entries.length) return '';
        final day = entries[index].date;
        return '${day.day}/${day.month}';

      case _Period.all:
        final entries = widget.allTimeData;
        if (index < 0 || index >= entries.length) return '';
        final targetMonth = entries[index].month;
        if (entries.length > 6 && index % 2 != 0) return '';
        return _monthAbbr[(targetMonth - 1) % 12];
    }
  }

  // ── Summary label (big number in the header) ───────────────────────────────

  String get _averageLabel {
    final double avg = switch (_selected) {
      _Period.d7 => widget.weeklyAverage,
      _Period.d30 => widget.monthlyAverage,
      _Period.all => widget.allTimeAverage,
    };
    return '${(avg * 100).round()}%';
  }

  String get _changeLabelPlaceholder => switch (_selected) {
    _Period.d7 => '7D avg',
    _Period.d30 => '30D avg',
    _Period.all => 'All time',
  };

  // ── Build ──────────────────────────────────────────────────────────────────

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
                              'Completion Rate',
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  _averageLabel,
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
                                    color: AppColors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _changeLabelPlaceholder,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // ── Segment toggle ───────────────────────────────
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
                        duration: const Duration(milliseconds: 400),
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
    final spots = _spots;
    if (spots.isEmpty) {
      // Edge-case: no data yet — show a flat zero line.
      return LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(spots: [FlSpot(0, 0), FlSpot(1, 0)]),
        ],
      );
    }

    final peakIdx = _peakIndex;
    final peakSpot = spots[peakIdx];

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
              if (idx < 0 || idx >= spots.length) return const SizedBox();
              final label = _labelAt(idx);
              if (label.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  label,
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
      minY: 0,
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
            checkToShowDot: (spot, _) =>
                spot.x == peakSpot.x && spot.y == peakSpot.y,
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
