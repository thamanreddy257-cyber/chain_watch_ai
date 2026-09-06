import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';

class VolumeChart extends StatelessWidget {
  final List<double> series;

  const VolumeChart({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final maxY = series.reduce((a, b) => a > b ? a : b) * 1.2;

    return GlassCard(
      hoverGlow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Transaction Volume', style: AppTextStyles.headlineSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Last 14 days',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: AppTextStyles.monoSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        final day = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('D-${series.length - day}',
                              style: AppTextStyles.monoSmall),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceElevated,
                    tooltipBorder: const BorderSide(color: AppColors.border),
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '${s.y.toStringAsFixed(0)} tx',
                              AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                            ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < series.length; i++)
                        FlSpot(i.toDouble(), series[i]),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.28),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08, end: 0);
  }
}
