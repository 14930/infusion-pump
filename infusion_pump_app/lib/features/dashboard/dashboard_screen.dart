import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/connection_indicator.dart';
import '../../shared/models/pump_data.dart';
import '../../shared/providers/firebase_providers.dart';

/// Screen 1 - Live Dashboard
/// Shows flow rates, circular progress, volume chart, and remaining time.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pumpAsync = ref.watch(pumpDataProvider);
    final connectionAsync = ref.watch(connectionProvider);
    final chartPoints = ref.watch(volumeChartProvider);
    final isConnected = connectionAsync.valueOrNull ?? false;

    // Ensure session auto-save is active
    ref.watch(sessionAutoSaveProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Live Dashboard'),
        actions: [
          ConnectionIndicator(isConnected: isConnected),
        ],
      ),
      body: pumpAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text('Error: $err', style: const TextStyle(color: AppTheme.muted)),
            ],
          ),
        ),
        data: (pump) => _buildContent(context, pump, chartPoints),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, PumpData pump, List<ChartPoint> chartPoints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status chip
          Center(child: StatusChip(status: pump.status)),
          const SizedBox(height: 16),

          // Metric cards row
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Set Flow Rate',
                  value: pump.setFlowRateMLperHR.toStringAsFixed(1),
                  unit: 'mL/hr',
                  icon: Icons.speed_rounded,
                  tooltip:
                      'The flow rate configured by the user for this infusion session.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: 'Dispensed',
                  value: pump.dispensedML.toStringAsFixed(1),
                  unit: 'mL',
                  icon: Icons.water_drop_rounded,
                  valueColor: AppTheme.accent,
                  tooltip:
                      'The actual volume of fluid dispensed so far, as measured by the sensor.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second row: remaining volume & remaining time
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Remaining',
                  value: pump.remainingML.toStringAsFixed(1),
                  unit: 'mL',
                  icon: Icons.hourglass_bottom_rounded,
                  tooltip:
                      'Volume of fluid remaining to be infused.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: 'Time Left',
                  value: pump.remainingTimeMin.toStringAsFixed(0),
                  unit: 'min',
                  icon: Icons.timer_outlined,
                  tooltip:
                      'Estimated time remaining until infusion completion.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Circular progress
          _CircularProgressSection(pump: pump),
          const SizedBox(height: 16),

          // Remaining time estimate
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Row(
              children: [
                const Icon(Icons.timer_outlined,
                    color: AppTheme.muted, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated Completion',
                      style: TextStyle(color: AppTheme.muted, fontSize: 12),
                    ),
                    Text(
                      pump.remainingTimeFormatted,
                      style: GoogleFonts.exo2(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Volume chart
          _VolumeChart(points: chartPoints),
        ],
      ),
    );
  }
}

/// Circular progress indicator showing infusion completion.
class _CircularProgressSection extends StatelessWidget {
  final PumpData pump;

  const _CircularProgressSection({required this.pump});

  @override
  Widget build(BuildContext context) {
    final progress = pump.progress;
    final percentage = (progress * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    backgroundColor: Colors.transparent,
                    color: AppTheme.primaryLight,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.transparent,
                    color: AppTheme.accent,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: GoogleFonts.exo2(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      'delivered',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${pump.dispensedML.toStringAsFixed(1)} mL of ${pump.setVolumeML.toStringAsFixed(1)} mL delivered',
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Real-time volume chart (dispensed vs expected).
class _VolumeChart extends StatelessWidget {
  final List<ChartPoint> points;

  const _VolumeChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Volume Over Time',
                style: TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _legendDot(AppTheme.accent, 'Actual'),
              const SizedBox(width: 12),
              _legendDot(AppTheme.muted, 'Expected'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: points.isEmpty
                ? const Center(
                    child: Text(
                      'Waiting for data...',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: const Color(0x221E88E5),
                          strokeWidth: 0.5,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                  color: AppTheme.muted, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}m',
                              style: const TextStyle(
                                  color: AppTheme.muted, fontSize: 10),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Expected line (dashed)
                        LineChartBarData(
                          spots: points
                              .map((p) => FlSpot(p.timeMinutes, p.expected))
                              .toList(),
                          isCurved: true,
                          color: AppTheme.muted,
                          barWidth: 1.5,
                          dashArray: [5, 3],
                          dotData: const FlDotData(show: false),
                        ),
                        // Actual line (solid)
                        LineChartBarData(
                          spots: points
                              .map((p) => FlSpot(p.timeMinutes, p.actual))
                              .toList(),
                          isCurved: true,
                          color: AppTheme.accent,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0x2242A5F5),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
      ],
    );
  }
}
