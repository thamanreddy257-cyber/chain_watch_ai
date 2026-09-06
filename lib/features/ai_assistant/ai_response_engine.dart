import '../../core/mock/mock_data.dart';
import '../../shared/models/wallet.dart';

/// Purely local, scripted responses — no real LLM call. Matches a handful
/// of common investigator queries and falls back to a generic response.
class AiResponseEngine {
  AiResponseEngine._();

  static const List<String> suggestedQuestions = [
    "What's the riskiest wallet right now?",
    'Explain fund splitting',
    'Which wallets are linked to the darknet market?',
    'How many active threats do we have?',
    'What should I investigate first?',
  ];

  static String respond(String rawQuery) {
    final q = rawQuery.toLowerCase().trim();

    if (q.contains('riskiest') || (q.contains('risk') && q.contains('wallet') && q.contains('now'))) {
      final w = MockData.riskiestWallet;
      return "The riskiest wallet currently being tracked is ${w.label} (${w.shortAddress}) with a risk score of "
          "${w.riskScore}/100. It's classified ${w.riskLevel.label} and exhibits: "
          "${w.patterns.map((p) => p.label).join(', ')}. I'd recommend reviewing its full profile in the "
          "Wallet Investigation view before taking any action.";
    }

    if (q.contains('fund splitting') || q.contains('splitting')) {
      return 'Fund splitting is when a wallet rapidly fragments a large incoming deposit into many smaller '
          "outbound transactions to unrelated-looking addresses — usually within minutes to hours. It's a "
          'classic obfuscation technique used to break the audit trail before funds reach a mixing service or '
          'cash-out point. In this dataset, the Darknet Market Hub and the Ransomware Payout Address both show '
          'strong fund-splitting signatures.';
    }

    if (q.contains('rapid') && q.contains('movement')) {
      return 'Rapid Fund Movement means a wallet holds incoming funds for an unusually short time — often just '
          'minutes — before forwarding them onward. It typically indicates a pass-through or relay wallet used '
          'to add hops between a source and destination, thinning the traceable link. The Layered Mixer Node is '
          'the clearest example of this pattern in the current dataset.';
    }

    if (q.contains('consolidat')) {
      return 'Fund Consolidation is the inverse of splitting: many small deposits from seemingly unrelated '
          'addresses get swept into one wallet, usually followed by a single large withdrawal. It often precedes '
          'a cash-out through an exchange or OTC desk. Consolidation Wallet A in this dataset shows this exact '
          'behavior before transferring 61.2 BTC onward.';
    }

    if (q.contains('darknet') || q.contains('market')) {
      final linked = MockData.allWallets.where((w) => w.cluster == 'Darknet Market' || w.isKnownHighRisk).toList();
      return 'Wallets with confirmed or suspected links to the darknet market cluster: '
          '${linked.map((w) => '${w.label} (${w.shortAddress})').join(', ')}. These accounts show direct '
          'transaction relationships with the Darknet Market Hub or share downstream mixer exposure with it.';
    }

    if (q.contains('active threat') || q.contains('how many') && q.contains('threat')) {
      return 'There are currently ${MockData.activeThreatCount} active high-or-critical severity threats out of '
          '${MockData.alerts.length} total alerts logged. You can review the full breakdown in the Threat Alerts '
          'Center, filterable by severity.';
    }

    if (q.contains('investigate first') || q.contains('where should i start') || q.contains('start')) {
      final w = MockData.riskiestWallet;
      return 'I\'d start with ${w.label} — it has the highest risk score in the network (${w.riskScore}/100) and '
          'is a known high-risk address. From there, follow its connected wallets in the Network Graph to trace '
          'how funds move downstream before they reach an exchange or cash-out point.';
    }

    if (q.contains('pattern')) {
      return 'CHAINWATCH AI currently detects five suspicious behavioral patterns: Rapid Fund Movement, Fund '
          'Splitting, Fund Consolidation, High-Risk Interaction, and Unusual Frequency. Each flagged wallet shows '
          'only the patterns relevant to its actual transaction history — ask me about any one of them for a '
          'plain-language explanation.';
    }

    if (q.contains('hello') || q.contains('hi') || q.contains('hey')) {
      return "Hello — I'm the CHAINWATCH AI assistant. Ask me about a specific wallet, a detection pattern, or "
          'try: "${suggestedQuestions[0]}"';
    }

    return "I don't have a scripted answer for that exact question in this prototype, but here's what I can help "
        'with: risk scores for specific wallets, explanations of detection patterns (fund splitting, '
        'consolidation, rapid movement, unusual frequency), and pointing you toward the highest-priority '
        'wallets to investigate. Try one of the suggested questions below.';
  }
}
