import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/models/alert.dart';
import '../../shared/models/wallet.dart';

class DashboardData {
  final int transactionsAnalyzed;
  final int entitiesClustered;
  final int highRiskAlerts;
  final List<double> volumeSeries;
  final Map<RiskLevel, int> riskDistribution;
  final List<ThreatAlert> recentAlerts;

  const DashboardData({
    required this.transactionsAnalyzed,
    required this.entitiesClustered,
    required this.highRiskAlerts,
    required this.volumeSeries,
    required this.riskDistribution,
    required this.recentAlerts,
  });
}

class BackendApi {
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static Future<DashboardData> fetchDashboard() async {
    final responses = await Future.wait([
      _getJson('/api/stats'),
      _getJson('/api/alerts?entity_type=wallet&limit=5'),
    ]);
    final stats = responses[0];
    final alertResponse = responses[1];
    final risk = stats['risk_distribution'] as Map<String, dynamic>? ?? {};
    final timeline = stats['volume_timeline'] as List<dynamic>? ?? [];
    final alerts = alertResponse['alerts'] as List<dynamic>? ?? [];

    return DashboardData(
      transactionsAnalyzed: _asInt(stats['transactions_ingested']),
      entitiesClustered: _asInt(stats['entities_clustered']),
      highRiskAlerts: _asInt(stats['high_risk_alerts']),
      volumeSeries: timeline
          .map((bucket) => (bucket['count'] as num).toDouble())
          .toList(),
      riskDistribution: {
        RiskLevel.critical: 0,
        RiskLevel.high: _asInt(risk['high']),
        RiskLevel.medium: _asInt(risk['medium']),
        RiskLevel.low: _asInt(risk['low']),
      },
      recentAlerts: alerts
          .map((alert) => _toThreatAlert(alert as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<Map<String, dynamic>> _getJson(String path) async {
    final response = await http
        .get(Uri.parse('$_baseUrl$path'))
        .timeout(const Duration(seconds: 10));
    final body = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = body is Map<String, dynamic> ? body['detail'] : null;
      throw Exception(
        detail ?? 'Backend request failed (${response.statusCode})',
      );
    }
    return body as Map<String, dynamic>;
  }

  static ThreatAlert _toThreatAlert(Map<String, dynamic> data) {
    final riskScore = (data['risk_score'] as num?)?.toDouble() ?? 0;
    final reasons = (data['top_reasons'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final description = reasons
        .map((reason) => reason['text'])
        .whereType<String>()
        .join('; ');
    final featureText = reasons
        .map((reason) => '${reason['feature']} ${reason['text']}')
        .join(' ')
        .toLowerCase();
    final pattern =
        featureText.contains('time_delta') || featureText.contains('rapid')
        ? SuspiciousPattern.rapidFundMovement
        : featureText.contains('num_outputs') || featureText.contains('fan-out')
        ? SuspiciousPattern.fundSplitting
        : featureText.contains('num_inputs') || featureText.contains('fan-in')
        ? SuspiciousPattern.fundConsolidation
        : SuspiciousPattern.highRiskInteraction;
    final severity = riskScore >= 90
        ? AlertSeverity.critical
        : riskScore >= 75
        ? AlertSeverity.high
        : riskScore >= 45
        ? AlertSeverity.medium
        : AlertSeverity.info;

    return ThreatAlert(
      id: '${data['id'] ?? data['entity_id']}',
      severity: severity,
      title: '${pattern.label} detected',
      description: description.isEmpty
          ? 'Risk score: ${riskScore.toStringAsFixed(1)}'
          : description,
      walletAddress: '${data['entity_id'] ?? ''}',
      timestamp:
          DateTime.tryParse('${data['created_at'] ?? ''}') ?? DateTime.now(),
      pattern: pattern,
    );
  }

  static int _asInt(dynamic value) => value is num ? value.toInt() : 0;
}
