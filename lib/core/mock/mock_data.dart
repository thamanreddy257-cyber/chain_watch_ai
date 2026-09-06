import 'dart:math';
import '../../shared/models/wallet.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/alert.dart';

/// Central mock data source for the CHAINWATCH AI prototype.
/// Everything here is fabricated for demo purposes — no live chain data.
class MockData {
  MockData._();

  static final Random _rng = Random(1337);

  // ---------------------------------------------------------------------
  // Wallets — hand-authored "story" wallets carry the narrative; the rest
  // are generated to bulk out the dataset to ~25 addresses.
  // ---------------------------------------------------------------------

  static final List<Wallet> wallets = [
    Wallet(
      address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
      label: 'Darknet Market Hub',
      riskLevel: RiskLevel.critical,
      riskScore: 96,
      balanceBtc: 142.87301,
      firstSeen: DateTime(2023, 2, 11),
      patterns: const [
        SuspiciousPattern.fundSplitting,
        SuspiciousPattern.highRiskInteraction,
        SuspiciousPattern.unusualFrequency,
      ],
      aiAnalysis:
          'This wallet exhibits a textbook fund-splitting signature: 84.6 BTC received from a single deposit was fragmented into 11 outbound transactions within a 40-minute window, each routed to a previously unseen address. The rapid fan-out, combined with sub-hour timing between hops, is consistent with obfuscation layering used by darknet marketplace operators to break the audit trail before funds reach a mixing service. Three of the fragment addresses have since interacted with wallets already flagged in our high-risk registry, reinforcing the cluster classification. Transaction frequency for this address is 6.2x the network median for wallets of comparable age, which independently trips our unusual-frequency heuristic.',
      connectedAddresses: [
        'bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct',
        'bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h',
        '3FKj8xGh2vLp9nQeR7tYc4mZa1bXsWdV6k',
        '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
      ],
      totalTransactions: 214,
      isKnownHighRisk: true,
      cluster: 'Darknet Market',
    ),
    Wallet(
      address: 'bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct',
      label: 'Layered Mixer Node',
      riskLevel: RiskLevel.critical,
      riskScore: 92,
      balanceBtc: 8.44120,
      firstSeen: DateTime(2022, 11, 3),
      patterns: const [
        SuspiciousPattern.rapidFundMovement,
        SuspiciousPattern.highRiskInteraction,
      ],
      aiAnalysis:
          'Funds entering this address are held for a median of just 4 minutes before being forwarded — far below the network average dwell time of several hours. This near-instant pass-through behavior, paired with inbound links from a confirmed darknet market wallet, strongly suggests this address functions as an intermediate hop inside a mixing or tumbling service rather than a genuine end-user wallet. No outbound transaction has ever returned to a previously-seen address, which is atypical for organic wallet activity and typical of automated laundering infrastructure.',
      connectedAddresses: [
        'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        'bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h',
        '3Nh3nNAcYRvpJyoJvGvZKQeYK1oYqXY4rL',
      ],
      totalTransactions: 356,
      isKnownHighRisk: true,
      cluster: 'Mixer',
    ),
    Wallet(
      address: 'bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h',
      label: 'Consolidation Wallet A',
      riskLevel: RiskLevel.high,
      riskScore: 78,
      balanceBtc: 61.20044,
      firstSeen: DateTime(2023, 5, 20),
      patterns: const [
        SuspiciousPattern.fundConsolidation,
        SuspiciousPattern.highRiskInteraction,
      ],
      aiAnalysis:
          'This address shows a classic consolidation pattern: 17 separate inbound transactions, each between 2.1 and 4.8 BTC, were swept from unrelated-looking source addresses into this single wallet over an 11-day period, followed by one large outbound transfer of 61.2 BTC. Consolidation of many small deposits into one large withdrawal is a common precursor to cashing out through an exchange or OTC desk, and is frequently observed after a fund-splitting stage elsewhere in the same cluster. Two of the source addresses trace back to the Layered Mixer Node, indicating this wallet likely sits downstream in a multi-stage laundering pipeline.',
      connectedAddresses: [
        'bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct',
        'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        '1FfmbHfnpaZjKFvyi1okTjJJusN455paPH',
        '1Q2TWHE3GMdB6BZKafqwxXtWAWgFt5Jvm3',
      ],
      totalTransactions: 89,
      isKnownHighRisk: false,
      cluster: 'Unknown',
    ),
    Wallet(
      address: '3FKj8xGh2vLp9nQeR7tYc4mZa1bXsWdV6k',
      label: 'Rapid Relay Wallet',
      riskLevel: RiskLevel.high,
      riskScore: 74,
      balanceBtc: 3.02981,
      firstSeen: DateTime(2024, 1, 9),
      patterns: const [
        SuspiciousPattern.rapidFundMovement,
        SuspiciousPattern.unusualFrequency,
      ],
      aiAnalysis:
          'Average holding time for incoming funds is 9 minutes, and this wallet has transacted 48 times in the past 7 days alone — a frequency more consistent with automated bot activity than manual use. The rapid-fire in-and-out pattern, without any accumulation of balance, points to a relay or pass-through role designed to add hops between a source and destination wallet, thinning the traceable link between them.',
      connectedAddresses: [
        'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
      ],
      totalTransactions: 163,
      isKnownHighRisk: false,
      cluster: 'Unknown',
    ),
    Wallet(
      address: '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
      label: 'Ransomware Payout Address',
      riskLevel: RiskLevel.critical,
      riskScore: 99,
      balanceBtc: 210.55019,
      firstSeen: DateTime(2021, 8, 17),
      patterns: const [
        SuspiciousPattern.highRiskInteraction,
        SuspiciousPattern.fundSplitting,
      ],
      aiAnalysis:
          'This address has been independently attributed to a known ransomware extortion campaign by multiple threat intelligence feeds. It receives sporadic large single deposits (consistent with individual ransom payments) which are then split across 6-9 downstream wallets within hours of receipt. Every traced downstream branch eventually intersects with either the Layered Mixer Node or the Darknet Market Hub, confirming this address sits at the top of a well-established laundering funnel rather than being an isolated incident.',
      connectedAddresses: [
        '3FKj8xGh2vLp9nQeR7tYc4mZa1bXsWdV6k',
        'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
      ],
      totalTransactions: 47,
      isKnownHighRisk: true,
      cluster: 'Ransomware',
    ),
    Wallet(
      address: '1FfmbHfnpaZjKFvyi1okTjJJusN455paPH',
      label: 'OTC Desk Settlement',
      riskLevel: RiskLevel.medium,
      riskScore: 48,
      balanceBtc: 34.11002,
      firstSeen: DateTime(2022, 6, 2),
      patterns: const [SuspiciousPattern.fundConsolidation],
      aiAnalysis:
          'Behavior here resembles a legitimate over-the-counter settlement desk: periodic consolidations of client deposits followed by scheduled batch withdrawals at regular weekly intervals. Risk is elevated only because one of its historical counterparties (Consolidation Wallet A) has downstream exposure to mixer activity — the desk itself shows no directly suspicious transaction timing or splitting behavior.',
      connectedAddresses: ['bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h'],
      totalTransactions: 122,
      isKnownHighRisk: false,
      cluster: 'Exchange',
    ),
    Wallet(
      address: '1Q2TWHE3GMdB6BZKafqwxXtWAWgFt5Jvm3',
      label: 'Retail Exchange Hot Wallet',
      riskLevel: RiskLevel.low,
      riskScore: 12,
      balanceBtc: 892.40012,
      firstSeen: DateTime(2020, 3, 14),
      patterns: const [],
      aiAnalysis:
          'High transaction volume and large balance are expected here — this address matches known clustering heuristics for a centralized exchange hot wallet servicing thousands of unrelated retail users. Deposit and withdrawal timing is diffuse and uncorrelated, balance turnover follows normal market-driven patterns, and no laundering signatures were detected. Flagged only for elevated monitoring due to its role as a common off-ramp for suspicious funds elsewhere in the network.',
      connectedAddresses: ['1FfmbHfnpaZjKFvyi1okTjJJusN455paPH'],
      totalTransactions: 4821,
      isKnownHighRisk: false,
      cluster: 'Exchange',
    ),
    Wallet(
      address: '3Nh3nNAcYRvpJyoJvGvZKQeYK1oYqXY4rL',
      label: 'Unusual Frequency Bot',
      riskLevel: RiskLevel.high,
      riskScore: 69,
      balanceBtc: 1.98765,
      firstSeen: DateTime(2024, 4, 22),
      patterns: const [
        SuspiciousPattern.unusualFrequency,
        SuspiciousPattern.rapidFundMovement,
      ],
      aiAnalysis:
          'Transaction cadence for this wallet is machine-regular: outbound transfers fire almost exactly every 17 minutes over sustained periods, a level of precision essentially never seen in human-driven wallets. Combined with direct linkage to the Layered Mixer Node, this is most likely automated laundering infrastructure rather than a personal wallet — possibly a scheduled dispersal script.',
      connectedAddresses: ['bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct'],
      totalTransactions: 301,
      isKnownHighRisk: false,
      cluster: 'Unknown',
    ),
  ];

  // Additional bulk wallets to reach ~25 addresses total.
  static final List<Wallet> _bulkWallets = _generateBulkWallets(17);

  static List<Wallet> get allWallets => [...wallets, ..._bulkWallets];

  static List<Wallet> _generateBulkWallets(int count) {
    final labels = [
      'Personal Cold Storage',
      'Savings Wallet',
      'Freelance Payments',
      'DeFi Bridge Relay',
      'Merchant Checkout',
      'NFT Marketplace Escrow',
      'Mining Pool Payout',
      'Custodial Wallet',
      'Long-Term Holder',
      'Peer Payment Wallet',
      'Lightning Channel Funding',
      'Donation Address',
      'Payroll Distribution',
      'Testnet Faucet Relay',
      'Small Business Till',
      'Hardware Wallet Export',
      'Cold Storage Vault',
    ];
    final clusters = ['Unknown', 'Exchange', 'Personal', 'Merchant'];
    final riskWeights = [
      RiskLevel.low,
      RiskLevel.low,
      RiskLevel.low,
      RiskLevel.medium,
      RiskLevel.medium,
      RiskLevel.high,
    ];

    return List.generate(count, (i) {
      final risk = riskWeights[_rng.nextInt(riskWeights.length)];
      final score = switch (risk) {
        RiskLevel.low => 5 + _rng.nextInt(20),
        RiskLevel.medium => 30 + _rng.nextInt(20),
        RiskLevel.high => 55 + _rng.nextInt(20),
        RiskLevel.critical => 85 + _rng.nextInt(15),
      };
      final patterns = <SuspiciousPattern>[];
      if (risk == RiskLevel.high && _rng.nextBool()) {
        patterns.add(SuspiciousPattern
            .values[_rng.nextInt(SuspiciousPattern.values.length)]);
      }
      return Wallet(
        address: _fakeAddress(i + 100),
        label: labels[i % labels.length],
        riskLevel: risk,
        riskScore: score,
        balanceBtc: double.parse(
            (_rng.nextDouble() * (risk == RiskLevel.low ? 15 : 60))
                .toStringAsFixed(5)),
        firstSeen: DateTime(2021, 1, 1)
            .add(Duration(days: _rng.nextInt(1400))),
        patterns: patterns,
        aiAnalysis:
            'Behavioral analysis places this wallet within normal parameters for its cluster type. Transaction timing, amount distribution, and counterparty diversity are consistent with organic usage rather than automated laundering behavior. Continued passive monitoring is recommended given its cluster association.',
        connectedAddresses: [],
        totalTransactions: 8 + _rng.nextInt(400),
        isKnownHighRisk: false,
        cluster: clusters[_rng.nextInt(clusters.length)],
      );
    });
  }

  static String _fakeAddress(int seed) {
    const chars =
        'abcdefghjkmnpqrstuvwxyz023456789ACDEFGHJKLMNPQRSTUVWXYZ';
    final r = Random(seed * 7919 + 13);
    final prefix = r.nextBool() ? 'bc1q' : (r.nextBool() ? '1' : '3');
    final len = 30 + r.nextInt(10);
    final sb = StringBuffer(prefix);
    for (var i = 0; i < len; i++) {
      sb.write(chars[r.nextInt(chars.length)]);
    }
    return sb.toString();
  }

  // ---------------------------------------------------------------------
  // Transactions
  // ---------------------------------------------------------------------

  static final List<WalletTransaction> transactions = _generateTransactions();

  static List<WalletTransaction> _generateTransactions() {
    final txs = <WalletTransaction>[];
    final now = DateTime(2026, 9, 6, 14, 30);
    int seq = 0;
    String txId() {
      seq++;
      final r = Random(seq * 104729);
      const hexChars = '0123456789abcdef';
      return List.generate(64, (_) => hexChars[r.nextInt(16)]).join();
    }

    // --- Story: Ransomware payout -> splitting into darknet hub ---
    txs.add(WalletTransaction(
      txId: txId(),
      fromAddress: '1Q2TWHE3GMdB6BZKafqwxXtWAWgFt5Jvm3',
      toAddress: '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
      amountBtc: 220.0,
      timestamp: now.subtract(const Duration(days: 6, hours: 3)),
    ));
    final splitAmounts = [38.2, 29.4, 24.1, 19.9, 33.5, 17.2, 22.8, 25.0];
    for (var i = 0; i < splitAmounts.length; i++) {
      txs.add(WalletTransaction(
        txId: txId(),
        fromAddress: '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
        toAddress: i.isEven
            ? 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'
            : '3FKj8xGh2vLp9nQeR7tYc4mZa1bXsWdV6k',
        amountBtc: splitAmounts[i],
        timestamp: now.subtract(
            Duration(days: 6, hours: 2, minutes: 55 - i * 6)),
      ));
    }

    // --- Story: Darknet hub fan-out (fund splitting) ---
    final fanoutTargets = [
      'bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct',
      '3FKj8xGh2vLp9nQeR7tYc4mZa1bXsWdV6k',
      'bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h',
      ..._bulkWallets.take(4).map((w) => w.address),
      ..._bulkWallets.skip(4).take(4).map((w) => w.address),
    ];
    for (var i = 0; i < fanoutTargets.length; i++) {
      txs.add(WalletTransaction(
        txId: txId(),
        fromAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        toAddress: fanoutTargets[i],
        amountBtc: 5 + _rng.nextDouble() * 12,
        timestamp: now.subtract(
            Duration(days: 3, hours: 1, minutes: 40 - i * 3)),
      ));
    }

    // --- Story: Rapid pass-through mixer node ---
    for (var i = 0; i < 10; i++) {
      final ts = now.subtract(Duration(hours: 20, minutes: i * 11));
      txs.add(WalletTransaction(
        txId: txId(),
        fromAddress: i.isEven
            ? 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'
            : '3Nh3nNAcYRvpJyoJvGvZKQeYK1oYqXY4rL',
        toAddress: 'bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct',
        amountBtc: 0.5 + _rng.nextDouble() * 2.5,
        timestamp: ts,
      ));
      txs.add(WalletTransaction(
        txId: txId(),
        fromAddress: 'bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct',
        toAddress: 'bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h',
        amountBtc: 0.48 + _rng.nextDouble() * 2.4,
        timestamp: ts.add(const Duration(minutes: 4)),
      ));
    }

    // --- Story: Consolidation into Consolidation Wallet A ---
    final consolidationSources = [
      ..._bulkWallets.skip(8).take(10).map((w) => w.address),
      'bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct',
    ];
    for (var i = 0; i < consolidationSources.length; i++) {
      txs.add(WalletTransaction(
        txId: txId(),
        fromAddress: consolidationSources[i],
        toAddress: 'bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h',
        amountBtc: 2.1 + _rng.nextDouble() * 2.7,
        timestamp: now.subtract(Duration(days: 11 - i, hours: _rng.nextInt(20))),
      ));
    }
    txs.add(WalletTransaction(
      txId: txId(),
      fromAddress: 'bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h',
      toAddress: '1FfmbHfnpaZjKFvyi1okTjJJusN455paPH',
      amountBtc: 61.2,
      timestamp: now.subtract(const Duration(hours: 14)),
    ));
    txs.add(WalletTransaction(
      txId: txId(),
      fromAddress: '1FfmbHfnpaZjKFvyi1okTjJJusN455paPH',
      toAddress: '1Q2TWHE3GMdB6BZKafqwxXtWAWgFt5Jvm3',
      amountBtc: 34.1,
      timestamp: now.subtract(const Duration(hours: 6)),
    ));

    // --- Story: Unusual frequency bot -> mixer, every ~17 min ---
    for (var i = 0; i < 14; i++) {
      txs.add(WalletTransaction(
        txId: txId(),
        fromAddress: '3Nh3nNAcYRvpJyoJvGvZKQeYK1oYqXY4rL',
        toAddress: 'bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct',
        amountBtc: 0.1 + _rng.nextDouble() * 0.3,
        timestamp: now.subtract(Duration(hours: 5, minutes: i * 17)),
      ));
    }

    // --- Bulk random background traffic among remaining wallets ---
    final pool = allWallets.map((w) => w.address).toList();
    while (txs.length < 100) {
      final from = pool[_rng.nextInt(pool.length)];
      var to = pool[_rng.nextInt(pool.length)];
      if (to == from) to = pool[(pool.indexOf(to) + 1) % pool.length];
      txs.add(WalletTransaction(
        txId: txId(),
        fromAddress: from,
        toAddress: to,
        amountBtc: double.parse(
            (0.01 + _rng.nextDouble() * 8).toStringAsFixed(5)),
        timestamp: now.subtract(Duration(
          days: _rng.nextInt(30),
          hours: _rng.nextInt(24),
          minutes: _rng.nextInt(60),
        )),
        confirmations: 1 + _rng.nextInt(400),
      ));
    }

    txs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return txs;
  }

  static List<WalletTransaction> transactionsFor(String address) {
    return transactions
        .where((t) => t.fromAddress == address || t.toAddress == address)
        .toList();
  }

  // ---------------------------------------------------------------------
  // Alerts
  // ---------------------------------------------------------------------

  static final List<ThreatAlert> alerts = [
    ThreatAlert(
      id: 'ALT-1042',
      severity: AlertSeverity.critical,
      title: 'Ransomware payout traced to active extortion campaign',
      description:
          'Address 1BvBMS...aNVN2 received a 220 BTC deposit matching the signature of a known ransomware extortion wallet, then split funds across 8 downstream addresses within 3 hours.',
      walletAddress: '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
      timestamp: DateTime(2026, 8, 31, 11, 12),
      pattern: SuspiciousPattern.fundSplitting,
    ),
    ThreatAlert(
      id: 'ALT-1041',
      severity: AlertSeverity.critical,
      title: 'High-volume fund splitting detected at darknet hub',
      description:
          'bc1qxy2...0wlh fragmented an 84.6 BTC deposit into 11 outbound transfers within a 40-minute window — consistent with obfuscation layering.',
      walletAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
      timestamp: DateTime(2026, 9, 3, 13, 35),
      pattern: SuspiciousPattern.fundSplitting,
    ),
    ThreatAlert(
      id: 'ALT-1040',
      severity: AlertSeverity.high,
      title: 'Rapid pass-through behavior on mixer node',
      description:
          'bc1q9h5...r2ct forwarded 10 inbound deposits with a median dwell time of 4 minutes, indicating automated mixing infrastructure.',
      walletAddress: 'bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct',
      timestamp: DateTime(2026, 9, 5, 18, 47),
      pattern: SuspiciousPattern.rapidFundMovement,
    ),
    ThreatAlert(
      id: 'ALT-1039',
      severity: AlertSeverity.high,
      title: 'Large-scale consolidation preceding likely cash-out',
      description:
          'bc1qm34...s3h swept 11 small deposits (2.1-4.8 BTC each) into a single wallet, followed by a 61.2 BTC outbound transfer to an OTC settlement address.',
      walletAddress: 'bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h',
      timestamp: DateTime(2026, 8, 26, 9, 3),
      pattern: SuspiciousPattern.fundConsolidation,
    ),
    ThreatAlert(
      id: 'ALT-1038',
      severity: AlertSeverity.high,
      title: 'Machine-regular transaction cadence flagged',
      description:
          '3Nh3nN...XY4rL is transacting every 17 minutes with near-perfect precision, a pattern inconsistent with human-driven wallet usage.',
      walletAddress: '3Nh3nNAcYRvpJyoJvGvZKQeYK1oYqXY4rL',
      timestamp: DateTime(2026, 9, 6, 9, 30),
      pattern: SuspiciousPattern.unusualFrequency,
    ),
    ThreatAlert(
      id: 'ALT-1037',
      severity: AlertSeverity.medium,
      title: 'New counterparty linked to flagged cluster',
      description:
          '1FfmbH...55paPH received an inbound transfer from Consolidation Wallet A, which has downstream exposure to mixer activity.',
      walletAddress: '1FfmbHfnpaZjKFvyi1okTjJJusN455paPH',
      timestamp: DateTime(2026, 9, 5, 20, 6),
      pattern: SuspiciousPattern.highRiskInteraction,
    ),
    ThreatAlert(
      id: 'ALT-1036',
      severity: AlertSeverity.medium,
      title: 'Elevated transaction frequency on relay wallet',
      description:
          '3FKj8x...sWdV6k has transacted 48 times in the past 7 days with no balance accumulation, suggesting a relay role.',
      walletAddress: '3FKj8xGh2vLp9nQeR7tYc4mZa1bXsWdV6k',
      timestamp: DateTime(2026, 9, 2, 6, 58),
      pattern: SuspiciousPattern.unusualFrequency,
    ),
    ThreatAlert(
      id: 'ALT-1035',
      severity: AlertSeverity.info,
      title: 'Known exchange hot wallet activity within normal range',
      description:
          '1Q2TWH...t5Jvm3 processed a large batch of withdrawals; volume and timing remain consistent with historical baseline.',
      walletAddress: '1Q2TWHE3GMdB6BZKafqwxXtWAWgFt5Jvm3',
      timestamp: DateTime(2026, 9, 1, 15, 22),
      pattern: SuspiciousPattern.highRiskInteraction,
    ),
    ThreatAlert(
      id: 'ALT-1034',
      severity: AlertSeverity.high,
      title: 'Direct link to darknet market wallet confirmed',
      description:
          'bc1q9h5...r2ct exchanged funds directly with the Darknet Market Hub across 6 separate transactions this week.',
      walletAddress: 'bc1q9h5yjfnl0f9ptx3ce8zw2vwrjyexs36gqmr2ct',
      timestamp: DateTime(2026, 8, 29, 4, 41),
      pattern: SuspiciousPattern.highRiskInteraction,
    ),
  ];

  // ---------------------------------------------------------------------
  // Dashboard aggregate stats
  // ---------------------------------------------------------------------

  static int get totalTransactionsAnalyzed => 48213 + transactions.length;

  static int get highRiskWalletCount => allWallets
      .where((w) =>
          w.riskLevel == RiskLevel.high || w.riskLevel == RiskLevel.critical)
      .length;

  static int get activeThreatCount => alerts
      .where((a) =>
          a.severity == AlertSeverity.high ||
          a.severity == AlertSeverity.critical)
      .length;

  /// Daily transaction volume for the last 14 days, for the dashboard chart.
  static List<double> get volumeSeries {
    final r = Random(42);
    return List.generate(14, (i) => 120 + r.nextDouble() * 260);
  }

  static Map<RiskLevel, int> get riskDistribution {
    final map = <RiskLevel, int>{
      RiskLevel.low: 0,
      RiskLevel.medium: 0,
      RiskLevel.high: 0,
      RiskLevel.critical: 0,
    };
    for (final w in allWallets) {
      map[w.riskLevel] = (map[w.riskLevel] ?? 0) + 1;
    }
    return map;
  }

  static Wallet? walletByAddress(String address) {
    for (final w in allWallets) {
      if (w.address == address) return w;
    }
    return null;
  }

  static Wallet get riskiestWallet =>
      allWallets.reduce((a, b) => a.riskScore >= b.riskScore ? a : b);

  static List<String> liveFeedTemplates = [
    'New transaction cluster detected involving {wallet}',
    'Risk score recalculated for {wallet}',
    'Cross-chain heuristic match flagged on {wallet}',
    'Large transfer ({amount} BTC) observed from {wallet}',
    'Behavioral pattern "{pattern}" newly tagged on {wallet}',
    'Watchlist update: {wallet} added to monitoring queue',
    'Graph analysis linked {wallet} to a known cluster',
  ];
}
