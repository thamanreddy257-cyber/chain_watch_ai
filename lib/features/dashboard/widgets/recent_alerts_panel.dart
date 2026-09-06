import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/alert.dart';
import '../../../shared/models/wallet.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/risk_badge.dart';

class RecentAlertsPanel extends StatelessWidget {
  const RecentAlertsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = MockData.alerts.take(5).toList();

    return GlassCard(
      hoverGlow: false,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(LucideIcons.shieldAlert, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('Recent Alerts', style: AppTextStyles.headlineSmall),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/alerts'),
                  child: Text('View all', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...alerts.map((a) => _AlertRow(alert: a)),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08, end: 0);
  }
}

class _AlertRow extends StatelessWidget {
  final ThreatAlert alert;
  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(alert.severity.asRiskLevel.label);
    return InkWell(
      onTap: () => context.go('/wallet?address=${alert.walletAddress}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(DateFormat('MMM d, HH:mm').format(alert.timestamp),
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            RiskBadge(level: alert.severity.asRiskLevel, dense: true),
          ],
        ),
      ),
    );
  }
}
