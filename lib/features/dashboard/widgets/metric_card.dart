import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final String? suffix;
  final IconData icon;
  final Color accentColor;
  final String trend;
  final bool trendUp;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.trend,
    required this.trendUp,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    trendUp ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: trendUp ? AppColors.success : AppColors.danger,
                  ),
                  const SizedBox(width: 3),
                  Text(trend,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: trendUp ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return Text(
                '${animatedValue.toInt()}${suffix ?? ''}',
                style: AppTextStyles.statNumber,
              );
            },
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
