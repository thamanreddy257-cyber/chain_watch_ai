import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/mock/mock_data.dart';
import 'widgets/metric_card.dart';
import 'widgets/volume_chart.dart';
import 'widgets/risk_donut.dart';
import 'widgets/recent_alerts_panel.dart';
import 'widgets/live_activity_feed.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 900;
    final isMedium = width < 1300;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isNarrow ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Command Center', style: AppTextStyles.displayMedium.copyWith(fontSize: isNarrow ? 26 : 32)),
            const SizedBox(height: 6),
            Text('Real-time overview of network-wide blockchain intelligence',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 28),
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth < 700 ? 1 : (constraints.maxWidth < 1050 ? 2 : 3);
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: cols == 1 ? 2.4 : 1.7,
                children: [
                  MetricCard(
                    label: 'Total Transactions Analyzed',
                    value: MockData.totalTransactionsAnalyzed,
                    icon: LucideIcons.activity,
                    accentColor: AppColors.primary,
                    trend: '+12.4%',
                    trendUp: true,
                  ),
                  MetricCard(
                    label: 'High-Risk Wallets',
                    value: MockData.highRiskWalletCount,
                    icon: LucideIcons.shieldAlert,
                    accentColor: AppColors.riskHigh,
                    trend: '+3',
                    trendUp: true,
                  ),
                  MetricCard(
                    label: 'Active Threats',
                    value: MockData.activeThreatCount,
                    icon: LucideIcons.siren,
                    accentColor: AppColors.riskCritical,
                    trend: '-2',
                    trendUp: false,
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            isMedium
                ? Column(
                    children: [
                      VolumeChart(series: MockData.volumeSeries),
                      const SizedBox(height: 24),
                      RiskDonut(distribution: MockData.riskDistribution),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: VolumeChart(series: MockData.volumeSeries)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: RiskDonut(distribution: MockData.riskDistribution)),
                    ],
                  ),
            const SizedBox(height: 24),
            isMedium
                ? Column(
                    children: const [
                      RecentAlertsPanel(),
                      SizedBox(height: 24),
                      LiveActivityFeed(),
                    ],
                  )
                : const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: RecentAlertsPanel()),
                      SizedBox(width: 24),
                      Expanded(child: LiveActivityFeed()),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
