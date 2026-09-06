enum TxDirection { inbound, outbound }

class WalletTransaction {
  final String txId;
  final String fromAddress;
  final String toAddress;
  final double amountBtc;
  final DateTime timestamp;
  final int confirmations;

  const WalletTransaction({
    required this.txId,
    required this.fromAddress,
    required this.toAddress,
    required this.amountBtc,
    required this.timestamp,
    this.confirmations = 6,
  });

  String get shortTxId => '${txId.substring(0, 10)}...';
}
