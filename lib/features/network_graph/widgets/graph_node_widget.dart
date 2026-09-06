import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/wallet.dart';

class GraphNodeWidget extends StatelessWidget {
  final Wallet wallet;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;

  const GraphNodeWidget({
    super.key,
    required this.wallet,
    required this.isSelected,
    required this.isDimmed,
    required this.onTap,
  });

  double get _size {
    if (wallet.totalTransactions > 250) return 64;
    if (wallet.totalTransactions > 100) return 54;
    if (wallet.totalTransactions > 40) return 46;
    return 38;
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(wallet.riskLevel.label);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isDimmed ? 0.25 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: color,
                  width: isSelected ? 3.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isSelected ? 0.55 : 0.25),
                    blurRadius: isSelected ? 22 : 10,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: wallet.isKnownHighRisk
                  ? Icon(Icons.warning_rounded, color: color, size: _size * 0.4)
                  : Text(
                      wallet.label.substring(0, 1).toUpperCase(),
                      style: AppTextStyles.headlineSmall.copyWith(color: color, fontSize: _size * 0.32),
                    ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 90,
              child: Text(
                wallet.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
