import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/transaction.dart';

class TransactionRow extends StatelessWidget {
  final WalletTransaction tx;
  final String focusAddress;
  final bool isNarrow;

  const TransactionRow({
    super.key,
    required this.tx,
    required this.focusAddress,
    this.isNarrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOutbound = tx.fromAddress == focusAddress;
    final color = isOutbound ? AppColors.riskHigh : AppColors.secondary;
    final amount = Text(
      '${isOutbound ? '-' : '+'}${tx.amountBtc.toStringAsFixed(4)}',
      textAlign: TextAlign.right,
      style: AppTextStyles.mono.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isOutbound ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
              size: 14,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.shortTxId, style: AppTextStyles.mono.copyWith(fontSize: 12)),
                const SizedBox(height: 3),
                Text(
                  isOutbound
                      ? 'to ${_short(tx.toAddress)}'
                      : 'from ${_short(tx.fromAddress)}',
                  style: AppTextStyles.bodySmall,
                ),
                if (isNarrow) ...[
                  const SizedBox(height: 3),
                  Text(DateFormat('MMM d, yyyy · HH:mm').format(tx.timestamp),
                      style: AppTextStyles.bodySmall),
                ],
              ],
            ),
          ),
          if (!isNarrow) ...[
            Expanded(
              flex: 2,
              child: Text(DateFormat('MMM d, yyyy · HH:mm').format(tx.timestamp),
                  style: AppTextStyles.bodySmall),
            ),
            SizedBox(width: 90, child: amount),
          ] else
            amount,
        ],
      ),
    );
  }

  String _short(String address) =>
      '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
}
