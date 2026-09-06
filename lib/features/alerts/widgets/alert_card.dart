import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/alert.dart';
import '../../../shared/models/wallet.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/risk_badge.dart';

IconData _iconForSeverity(AlertSeverity s) {
  switch (s) {
    case AlertSeverity.critical:
      return LucideIcons.siren;
    case AlertSeverity.high:
      return LucideIcons.shieldAlert;
    case AlertSeverity.medium:
      return LucideIcons.alertTriangle;
    case AlertSeverity.info:
      return LucideIcons.info;
  }
}

class AlertCard extends StatelessWidget {
  final ThreatAlert alert;
  final int index;

  const AlertCard({super.key, required this.alert, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(alert.severity.asRiskLevel.label);

    return GlassCard(
      onTap: () => context.go('/wallet?address=${alert.walletAddress}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconForSeverity(alert.severity), color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(alert.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    RiskBadge(level: alert.severity.asRiskLevel, dense: true),
                  ],
                ),
                const SizedBox(height: 8),
                Text(alert.description, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(LucideIcons.wallet, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(_short(alert.walletAddress), style: AppTextStyles.monoSmall),
                    const SizedBox(width: 16),
                    Icon(LucideIcons.clock, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(DateFormat('MMM d, yyyy · HH:mm').format(alert.timestamp),
                        style: AppTextStyles.bodySmall),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(alert.pattern.label,
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
  }

  String _short(String address) =>
      '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
}
