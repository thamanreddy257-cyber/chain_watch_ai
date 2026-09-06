import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/wallet.dart';
import '../../../shared/widgets/risk_badge.dart';

class WalletSearchBar extends StatefulWidget {
  final ValueChanged<Wallet> onSelect;

  const WalletSearchBar({super.key, required this.onSelect});

  @override
  State<WalletSearchBar> createState() => _WalletSearchBarState();
}

class _WalletSearchBarState extends State<WalletSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<Wallet> _matches = [];
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _showResults = _focusNode.hasFocus && _matches.isNotEmpty);
    });
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _matches = [];
        _showResults = false;
      });
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _matches = MockData.allWallets
          .where((w) =>
              w.address.toLowerCase().contains(q) ||
              w.label.toLowerCase().contains(q))
          .take(8)
          .toList();
      _showResults = _matches.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: AppTextStyles.mono,
          onChanged: _search,
          decoration: InputDecoration(
            hintText: 'Search by wallet address or label...',
            prefixIcon: const Icon(LucideIcons.search, size: 18),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(LucideIcons.x, size: 16),
                    onPressed: () {
                      _controller.clear();
                      _search('');
                    },
                  )
                : null,
          ),
        ),
        if (_showResults)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _matches.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderSubtle),
              itemBuilder: (context, i) {
                final w = _matches[i];
                return ListTile(
                  dense: true,
                  title: Text(w.label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                  subtitle: Text(w.shortAddress, style: AppTextStyles.monoSmall),
                  trailing: RiskBadge(level: w.riskLevel, dense: true),
                  onTap: () {
                    _controller.text = w.label;
                    setState(() => _showResults = false);
                    _focusNode.unfocus();
                    widget.onSelect(w);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
