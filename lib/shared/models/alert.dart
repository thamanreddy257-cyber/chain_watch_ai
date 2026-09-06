import 'wallet.dart';

enum AlertSeverity { info, medium, high, critical }

extension AlertSeverityX on AlertSeverity {
  String get label {
    switch (this) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  RiskLevel get asRiskLevel {
    switch (this) {
      case AlertSeverity.info:
        return RiskLevel.low;
      case AlertSeverity.medium:
        return RiskLevel.medium;
      case AlertSeverity.high:
        return RiskLevel.high;
      case AlertSeverity.critical:
        return RiskLevel.critical;
    }
  }
}

class ThreatAlert {
  final String id;
  final AlertSeverity severity;
  final String title;
  final String description;
  final String walletAddress;
  final DateTime timestamp;
  final SuspiciousPattern pattern;

  const ThreatAlert({
    required this.id,
    required this.severity,
    required this.title,
    required this.description,
    required this.walletAddress,
    required this.timestamp,
    required this.pattern,
  });
}
