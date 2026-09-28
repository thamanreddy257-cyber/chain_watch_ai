import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/mock/mock_data.dart';
import '../../shared/models/alert.dart';
import '../../shared/models/wallet.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/card_grid.dart';
import 'widgets/alert_card.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  AlertSeverity? _filter;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 900;
    final alerts = MockData.alerts
        .where((a) => _filter == null || a.severity == _filter)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isNarrow ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Threat Alerts Center',
                style: AppTextStyles.displayMedium.copyWith(fontSize: isNarrow ? 26 : 32)),
            const SizedBox(height: 6),
            Text('Every automated detection across the monitored network, in one place',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            _SummaryRow(alerts: MockData.alerts),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FilterChip(label: 'All', count: MockData.alerts.length, selected: _filter == null, onTap: () => setState(() => _filter = null)),
                for (final s in AlertSeverity.values)
                  _FilterChip(
                    label: s.label,
                    count: MockData.alerts.where((a) => a.severity == s).length,
                    selected: _filter == s,
                    color: AppColors.riskColor(s.asRiskLevel.label),
                    onTap: () => setState(() => _filter = s),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (alerts.isEmpty)
              GlassCard(
                hoverGlow: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No alerts match this filter.', style: AppTextStyles.bodyMedium),
                ),
              )
            else
              Column(
                children: [
                  for (var i = 0; i < alerts.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AlertCard(alert: alerts[i], index: i),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<ThreatAlert> alerts;
  const _SummaryRow({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width < 700 ? 2 : 4;

    final counts = {
      for (final s in AlertSeverity.values) s: alerts.where((a) => a.severity == s).length,
    };

    return CardGrid(
      columns: cols,
      spacing: 16,
      runSpacing: 16,
      cards: AlertSeverity.values.map((s) {
        final color = AppColors.riskColor(s.asRiskLevel.label);
        return GlassCard(
          hoverGlow: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(LucideIcons.shieldAlert, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${counts[s]}', style: AppTextStyles.statNumber.copyWith(fontSize: 22)),
                  Text(s.label, style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms);
      }).toList(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c.withValues(alpha: 0.5) : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? c : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            )),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count', style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
