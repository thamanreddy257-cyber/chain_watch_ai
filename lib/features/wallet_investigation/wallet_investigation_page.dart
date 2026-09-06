import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'widgets/risk_gauge.dart';
import 'widgets/pattern_chip.dart';
import 'widgets/transaction_row.dart';
import 'widgets/connected_wallet_tile.dart';
import 'widgets/wallet_search_bar.dart';

class WalletInvestigationPage extends StatefulWidget {
  final String? initialAddress;
  const WalletInvestigationPage({super.key, this.initialAddress});

  @override
  State<WalletInvestigationPage> createState() => _WalletInvestigationPageState();
}

class _WalletInvestigationPageState extends State<WalletInvestigationPage> {
  Wallet? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _selected = MockData.walletByAddress(widget.initialAddress!);
    }
  }

  @override
  void didUpdateWidget(covariant WalletInvestigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAddress != oldWidget.initialAddress &&
        widget.initialAddress != null) {
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
            Text('Wallet Investigation', style: AppTextStyles.displayMedium.copyWith(fontSize: isNarrow ? 26 : 32)),
            const SizedBox(height: 6),
            Text('Search any address to pull its full risk profile and transaction history',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: WalletSearchBar(onSelect: (w) => setState(() => _selected = w)),
            ),
            const SizedBox(height: 28),
            if (_selected == null)
              _EmptyState(onPickExample: (w) => setState(() => _selected = w))
            else
              _WalletDetail(key: ValueKey(_selected!.address), wallet: _selected!, isNarrow: isNarrow),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<Wallet> onPickExample;
  const _EmptyState({required this.onPickExample});

  @override
  Widget build(BuildContext context) {
    final examples = MockData.wallets.take(4).toList();
    return GlassCard(
      hoverGlow: false,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(LucideIcons.searchCode, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No wallet selected', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text('Search above, or try one of these flagged wallets:',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: examples.map((w) {
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => onPickExample(w),
                child: Text(w.label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WalletDetail extends StatelessWidget {
  final Wallet wallet;
  final bool isNarrow;
  const _WalletDetail({super.key, required this.wallet, required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    final txs = MockData.transactionsFor(wallet.address);
    final connected = wallet.connectedAddresses
        .map(MockData.walletByAddress)
        .whereType<Wallet>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderCard(wallet: wallet, isNarrow: isNarrow),
        const SizedBox(height: 20),
        if (wallet.patterns.isNotEmpty) ...[
          Text('Detected Patterns', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: wallet.patterns.map((p) => PatternChip(pattern: p)).toList(),
          ),
          const SizedBox(height: 24),
        ],
        _AiAnalysisPanel(wallet: wallet),
        const SizedBox(height: 24),
        isNarrow
            ? Column(
                children: [
                  _TransactionHistoryCard(txs: txs, address: wallet.address),
                  const SizedBox(height: 20),
                  _ConnectedWalletsCard(wallets: connected),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _TransactionHistoryCard(txs: txs, address: wallet.address)),
                  const SizedBox(width: 20),
                  Expanded(flex: 1, child: _ConnectedWalletsCard(wallets: connected)),
                ],
              ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => context.go('/reports?address=${wallet.address}'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(LucideIcons.fileText, size: 16),
            label: const Text('Generate Investigation Report'),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }
}

class _HeaderCard extends StatefulWidget {
  final Wallet wallet;
  final bool isNarrow;
  const _HeaderCard({required this.wallet, required this.isNarrow});

  @override
  State<_HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<_HeaderCard> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.wallet;
    return GlassCard(
      hoverGlow: false,
      child: Flex(
        direction: widget.isNarrow ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: widget.isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          RiskGauge(score: w.riskScore, level: w.riskLevel),
          SizedBox(width: widget.isNarrow ? 0 : 28, height: widget.isNarrow ? 20 : 0),
          Expanded(
            child: Column(
              crossAxisAlignment: widget.isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: [
                    Text(w.label, style: AppTextStyles.headlineLarge),
                    RiskBadge(level: w.riskLevel),
                    if (w.isKnownHighRisk)
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
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: w.address));
                    setState(() => _copied = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _copied = false);
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Text(w.address, style: AppTextStyles.mono, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Icon(_copied ? LucideIcons.check : LucideIcons.copy,
                          size: 14, color: _copied ? AppColors.secondary : AppColors.textMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 28,
                  runSpacing: 12,
                  children: [
                    _Stat(label: 'Balance', value: '${w.balanceBtc.toStringAsFixed(4)} BTC'),
                    _Stat(label: 'Transactions', value: '${w.totalTransactions}'),
                    _Stat(label: 'First Seen', value: DateFormat('MMM d, yyyy').format(w.firstSeen)),
                    _Stat(label: 'Cluster', value: w.cluster),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _AiAnalysisPanel extends StatelessWidget {
  final Wallet wallet;
  const _AiAnalysisPanel({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.brainCircuit, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('AI Analysis', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          Text(wallet.aiAnalysis, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary, height: 1.65)),
        ],
      ),
    );
  }
}

class _TransactionHistoryCard extends StatelessWidget {
  final List txs;
  final String address;
  const _TransactionHistoryCard({required this.txs, required this.address});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hoverGlow: false,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Transaction History (${txs.length})', style: AppTextStyles.headlineSmall),
          ),
          const SizedBox(height: 8),
          if (txs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No transactions found for this address.', style: AppTextStyles.bodyMedium),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 480),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: txs.length,
                itemBuilder: (context, i) => TransactionRow(tx: txs[i], focusAddress: address),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConnectedWalletsCard extends StatelessWidget {
  final List<Wallet> wallets;
  const _ConnectedWalletsCard({required this.wallets});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hoverGlow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Connected Wallets (${wallets.length})', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          if (wallets.isEmpty)
            Text('No known connections in this dataset.', style: AppTextStyles.bodyMedium)
          else
            Column(
              children: wallets
                  .map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ConnectedWalletTile(
                          wallet: w,
                          onTap: () => context.go('/wallet?address=${w.address}'),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
