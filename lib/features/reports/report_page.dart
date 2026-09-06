import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/mock/mock_data.dart';
import '../../shared/models/wallet.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/risk_badge.dart';
import '../wallet_investigation/widgets/wallet_search_bar.dart';
import 'widgets/report_section.dart';

class ReportPage extends StatefulWidget {
  final String? initialAddress;
  const ReportPage({super.key, this.initialAddress});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Wallet? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _selected = MockData.walletByAddress(widget.initialAddress!);
    }
  }

  @override
  void didUpdateWidget(covariant ReportPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAddress != oldWidget.initialAddress && widget.initialAddress != null) {
      setState(() => _selected = MockData.walletByAddress(widget.initialAddress!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isNarrow ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Investigation Report', style: AppTextStyles.displayMedium.copyWith(fontSize: isNarrow ? 26 : 32)),
            const SizedBox(height: 6),
            Text('Compile a wallet\'s full profile into a shareable investigation summary',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: WalletSearchBar(onSelect: (w) => setState(() => _selected = w)),
            ),
            const SizedBox(height: 28),
            if (_selected == null)
              GlassCard(
                hoverGlow: false,
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(LucideIcons.fileText, size: 40, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No wallet selected', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Search for a wallet above to generate its investigation report.',
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
              )
            else
              _ReportDocument(key: ValueKey(_selected!.address), wallet: _selected!),
          ],
        ),
      ),
    );
  }
}

class _ReportDocument extends StatelessWidget {
  final Wallet wallet;
  const _ReportDocument({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final txs = MockData.transactionsFor(wallet.address);
    final connected = wallet.connectedAddresses
        .map(MockData.walletByAddress)
        .whereType<Wallet>()
        .toList();
    final generatedAt = DateTime(2026, 9, 6, 14, 32);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          hoverGlow: false,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.shield, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text('CHAINWATCH AI', style: AppTextStyles.headlineSmall),
                  const Spacer(),
                  Text('Report #CW-${wallet.address.hashCode.abs() % 100000}',
                      style: AppTextStyles.monoSmall),
                ],
              ),
              const SizedBox(height: 4),
              Text('Generated ${DateFormat('MMMM d, yyyy · HH:mm').format(generatedAt)} UTC',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 28),
              Text('Wallet Investigation Report', style: AppTextStyles.displayMedium.copyWith(fontSize: 26)),
              const SizedBox(height: 24),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 28),

              ReportSection(
                title: 'Subject',
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 14,
                  runSpacing: 10,
                  children: [
                    Text(wallet.label, style: AppTextStyles.headlineLarge),
                    RiskBadge(level: wallet.riskLevel),
                    if (wallet.isKnownHighRisk)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.riskCritical.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text('KNOWN HIGH-RISK',
                            style: AppTextStyles.label.copyWith(color: AppColors.riskCritical, fontSize: 10)),
                      ),
                  ],
                ),
              ),

              ReportSection(
                title: 'Key Metrics',
                child: Wrap(
                  spacing: 40,
                  runSpacing: 16,
                  children: [
                    _Metric(label: 'Address', value: wallet.address, mono: true),
                    _Metric(label: 'Risk Score', value: '${wallet.riskScore} / 100'),
                    _Metric(label: 'Balance', value: '${wallet.balanceBtc.toStringAsFixed(4)} BTC'),
                    _Metric(label: 'Total Transactions', value: '${wallet.totalTransactions}'),
                    _Metric(label: 'First Seen', value: DateFormat('MMM d, yyyy').format(wallet.firstSeen)),
                    _Metric(label: 'Cluster Classification', value: wallet.cluster),
                  ],
                ),
              ),

              if (wallet.patterns.isNotEmpty)
                ReportSection(
                  title: 'Detected Behavioral Patterns',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: wallet.patterns.map((p) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.riskHigh.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.riskHigh.withValues(alpha: 0.35)),
                        ),
                        child: Text(p.label,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.riskHigh, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                  ),
                ),

              ReportSection(
                title: 'AI Analysis',
                child: Text(wallet.aiAnalysis, style: AppTextStyles.bodyLarge.copyWith(height: 1.7)),
              ),

              ReportSection(
                title: 'Connected Wallets (${connected.length})',
                child: connected.isEmpty
                    ? Text('No known connections in this dataset.', style: AppTextStyles.bodyMedium)
                    : Column(
                        children: connected.map((w) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.riskColor(w.riskLevel.label),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(w.label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                                const SizedBox(width: 8),
                                Text(w.shortAddress, style: AppTextStyles.monoSmall),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),

              Text('Transaction Summary (most recent ${txs.length > 10 ? 10 : txs.length} of ${txs.length})',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary)),
              const SizedBox(height: 10),
              if (txs.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('No transactions found for this address.', style: AppTextStyles.bodyMedium),
                )
              else
                Column(
                  children: txs.take(10).map((t) {
                    final outbound = t.fromAddress == wallet.address;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(t.shortTxId, style: AppTextStyles.mono.copyWith(fontSize: 12)),
                          ),
                          Expanded(
                            child: Text(DateFormat('MMM d, HH:mm').format(t.timestamp), style: AppTextStyles.bodySmall),
                          ),
                          Text(
                            '${outbound ? '-' : '+'}${t.amountBtc.toStringAsFixed(4)} BTC',
                            style: AppTextStyles.mono.copyWith(
                              color: outbound ? AppColors.riskHigh : AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 28),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 16),
              Text(
                'This report was generated by CHAINWATCH AI for investigative purposes. All findings are based on '
                'on-chain heuristic and behavioral analysis and should be corroborated with independent evidence '
                'before action is taken.',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => context.go('/wallet?address=${wallet.address}'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(LucideIcons.arrowLeft, size: 16, color: AppColors.textPrimary),
              label: const Text('Back to Investigation', style: TextStyle(color: AppColors.textPrimary)),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  const _Metric({required this.label, required this.value, this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: mono
              ? AppTextStyles.mono.copyWith(color: AppColors.textPrimary)
              : AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
