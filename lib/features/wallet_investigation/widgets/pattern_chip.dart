import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/wallet.dart';

IconData _iconFor(SuspiciousPattern p) {
  switch (p) {
    case SuspiciousPattern.rapidFundMovement:
      return LucideIcons.zap;
    case SuspiciousPattern.fundSplitting:
      return LucideIcons.gitFork;
    case SuspiciousPattern.fundConsolidation:
      return LucideIcons.merge;
    case SuspiciousPattern.highRiskInteraction:
      return LucideIcons.skull;
    case SuspiciousPattern.unusualFrequency:
      return LucideIcons.timer;
  }
}

class PatternChip extends StatelessWidget {
  final SuspiciousPattern pattern;

  const PatternChip({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.riskHigh.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.riskHigh.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(pattern), size: 14, color: AppColors.riskHigh),
          const SizedBox(width: 7),
          Text(pattern.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.riskHigh,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
