import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/services/backend_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/card_grid.dart';
import 'widgets/metric_card.dart';
import 'widgets/volume_chart.dart';
import 'widgets/risk_donut.dart';
import 'widgets/recent_alerts_panel.dart';
import 'widgets/live_activity_feed.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    _dashboardFuture = BackendApi.fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 900;
    final isMedium = width < 1300;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<DashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.serverCrash,
                      color: AppColors.riskHigh,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load dashboard data',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => setState(_loadDashboard),
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final dashboard = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isNarrow ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Command Center',
                        style: AppTextStyles.displayMedium.copyWith(
                          fontSize: isNarrow ? 26 : 32,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh dashboard',
                      onPressed: () => setState(_loadDashboard),
                      icon: const Icon(LucideIcons.refreshCw, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Real-time overview of network-wide blockchain intelligence',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth < 700
                        ? 1
                        : (constraints.maxWidth < 1050 ? 2 : 3);
                    final cards = [
                      MetricCard(
                        label: 'Transactions Analyzed',
                        value: dashboard.transactionsAnalyzed,
                        icon: LucideIcons.activity,
                        accentColor: AppColors.primary,
                      ),
                      MetricCard(
                        label: 'Entities Clustered',
                        value: dashboard.entitiesClustered,
                        icon: LucideIcons.shieldAlert,
                        accentColor: AppColors.secondary,
                      ),
                      MetricCard(
                        label: 'High-Risk Alerts',
                        value: dashboard.highRiskAlerts,
                        icon: LucideIcons.siren,
                        accentColor: AppColors.riskHigh,
                      ),
                    ];
                    return CardGrid(
                      cards: cards,
                      columns: cols,
                      spacing: 20,
                      runSpacing: 20,
                    );
                  },
                ),
                const SizedBox(height: 24),
                isMedium
                    ? Column(
                        children: [
                          VolumeChart(series: dashboard.volumeSeries),
                          const SizedBox(height: 24),
                          RiskDonut(distribution: dashboard.riskDistribution),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: VolumeChart(series: dashboard.volumeSeries),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: RiskDonut(
                              distribution: dashboard.riskDistribution,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                isMedium
                    ? Column(
                        children: [
                          RecentAlertsPanel(alerts: dashboard.recentAlerts),
                          const SizedBox(height: 24),
                          const LiveActivityFeed(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RecentAlertsPanel(
                              alerts: dashboard.recentAlerts,
                            ),
                          ),
                          const SizedBox(width: 24),
                          const Expanded(child: LiveActivityFeed()),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
