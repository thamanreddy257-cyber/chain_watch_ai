import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/models/wallet.dart';

class RiskDonut extends StatelessWidget {
  final Map<RiskLevel, int> distribution;

  const RiskDonut({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold<int>(0, (a, b) => a + b);

    return GlassCard(
      hoverGlow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Risk Distribution', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 52,
                    sections: RiskLevel.values.map((level) {
                      final count = distribution[level] ?? 0;
                      final color = AppColors.riskColor(level.label);
                      return PieChartSectionData(
                        value: count.toDouble(),
                        color: color,
                        radius: 26,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$total', style: AppTextStyles.statNumber.copyWith(fontSize: 28)),
                    Text('Wallets', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: RiskLevel.values.map((level) {
              final count = distribution[level] ?? 0;
              final pct = total == 0 ? 0 : (count / total * 100);
              final color = AppColors.riskColor(level.label);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(level.label, style: AppTextStyles.bodyMedium),
                    ),
                    Text('$count',
                        style: AppTextStyles.mono.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 42,
                      child: Text('${pct.toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodySmall),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08, end: 0);
  }
}
