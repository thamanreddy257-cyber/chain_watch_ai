import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/wallet.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/risk_badge.dart';

class NodeInfoPanel extends StatelessWidget {
  final Wallet wallet;
  final int connectionCount;
  final VoidCallback onClose;

  const NodeInfoPanel({
    super.key,
    required this.wallet,
    required this.connectionCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hoverGlow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(wallet.label, style: AppTextStyles.headlineSmall),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(LucideIcons.x, size: 16),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(wallet.shortAddress, style: AppTextStyles.monoSmall),
          const SizedBox(height: 14),
          Row(
            children: [
              RiskBadge(level: wallet.riskLevel),
              const SizedBox(width: 8),
              if (wallet.isKnownHighRisk)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.riskCritical.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('HIGH-RISK',
                      style: AppTextStyles.label.copyWith(color: AppColors.riskCritical, fontSize: 9)),
                ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoRow(label: 'Risk Score', value: '${wallet.riskScore} / 100'),
          _InfoRow(label: 'Balance', value: '${wallet.balanceBtc.toStringAsFixed(4)} BTC'),
          _InfoRow(label: 'Cluster', value: wallet.cluster),
          _InfoRow(label: 'Connections', value: '$connectionCount'),
          if (wallet.patterns.isNotEmpty)
            _InfoRow(label: 'Patterns', value: wallet.patterns.map((p) => p.label).join(', ')),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go('/wallet?address=${wallet.address}'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(LucideIcons.search, size: 15),
              label: const Text('Investigate Wallet'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.05, end: 0);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: AppTextStyles.bodySmall)),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
