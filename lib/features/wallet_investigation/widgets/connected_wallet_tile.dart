import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/wallet.dart';
import '../../../shared/widgets/risk_badge.dart';

class ConnectedWalletTile extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onTap;

  const ConnectedWalletTile({super.key, required this.wallet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.wallet, size: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wallet.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(wallet.shortAddress, style: AppTextStyles.monoSmall),
                ],
              ),
            ),
            RiskBadge(level: wallet.riskLevel, dense: true),
          ],
        ),
      ),
    );
  }
}
