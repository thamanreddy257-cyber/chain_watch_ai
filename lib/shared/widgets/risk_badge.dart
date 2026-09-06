import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/wallet.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final bool dense;

  const RiskBadge({super.key, required this.level, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(level.label);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 8 : 12, vertical: dense ? 3 : 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            level.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
