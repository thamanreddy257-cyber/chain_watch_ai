enum RiskLevel { low, medium, high, critical }

extension RiskLevelX on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
      case RiskLevel.critical:
        return 'Critical';
    }
  }
}

enum SuspiciousPattern {
  rapidFundMovement,
  fundSplitting,
  fundConsolidation,
  highRiskInteraction,
  unusualFrequency,
}

extension SuspiciousPatternX on SuspiciousPattern {
  String get label {
    switch (this) {
      case SuspiciousPattern.rapidFundMovement:
        return 'Rapid Fund Movement';
      case SuspiciousPattern.fundSplitting:
        return 'Fund Splitting';
      case SuspiciousPattern.fundConsolidation:
        return 'Fund Consolidation';
      case SuspiciousPattern.highRiskInteraction:
        return 'High-Risk Interaction';
      case SuspiciousPattern.unusualFrequency:
        return 'Unusual Frequency';
    }
  }
}

class Wallet {
  final String address;
  final String label;
  final RiskLevel riskLevel;
  final int riskScore; // 0-100
  final double balanceBtc;
  final DateTime firstSeen;
  final List<SuspiciousPattern> patterns;
  final String aiAnalysis;
  final List<String> connectedAddresses;
  final int totalTransactions;
  final bool isKnownHighRisk;
  final String cluster; // e.g. "Exchange", "Mixer", "Darknet Market", "Unknown"

  const Wallet({
    required this.address,
    required this.label,
    required this.riskLevel,
    required this.riskScore,
    required this.balanceBtc,
    required this.firstSeen,
    required this.patterns,
    required this.aiAnalysis,
    required this.connectedAddresses,
    required this.totalTransactions,
    this.isKnownHighRisk = false,
    this.cluster = 'Unknown',
  });

  String get shortAddress =>
      '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
}
