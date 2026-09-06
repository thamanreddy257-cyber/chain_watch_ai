import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/wallet.dart';

class GraphLegend extends StatelessWidget {
  const GraphLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final level in RiskLevel.values) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.riskColor(level.label),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(level.label, style: AppTextStyles.bodySmall),
            const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}
