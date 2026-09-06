import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/wallet.dart';
import '../../../shared/widgets/glass_card.dart';

class _FeedEntry {
  final String text;
  final DateTime time;
  final Color color;
  const _FeedEntry(this.text, this.time, this.color);
}

class LiveActivityFeed extends StatefulWidget {
  const LiveActivityFeed({super.key});

  @override
  State<LiveActivityFeed> createState() => _LiveActivityFeedState();
}

class _LiveActivityFeedState extends State<LiveActivityFeed> {
  final List<_FeedEntry> _entries = [];
  Timer? _timer;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _seedInitial();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _appendEntry());
  }

  void _seedInitial() {
    final now = DateTime.now();
    for (var i = 0; i < 6; i++) {
      _entries.add(_buildEntry(now.subtract(Duration(seconds: i * 40))));
    }
  }

  _FeedEntry _buildEntry(DateTime time) {
    final wallets = MockData.allWallets;
    final wallet = wallets[_rng.nextInt(wallets.length)];
    final template = MockData
        .liveFeedTemplates[_rng.nextInt(MockData.liveFeedTemplates.length)];
    final patterns = [
      'Rapid Fund Movement',
      'Fund Splitting',
      'Fund Consolidation',
      'High-Risk Interaction',
      'Unusual Frequency',
    ];
    final text = template
        .replaceAll('{wallet}', wallet.shortAddress)
        .replaceAll('{amount}', (0.5 + _rng.nextDouble() * 20).toStringAsFixed(2))
        .replaceAll('{pattern}', patterns[_rng.nextInt(patterns.length)]);
    final color = AppColors.riskColor(wallet.riskLevel.label);
    return _FeedEntry(text, time, color);
  }

  void _appendEntry() {
    if (!mounted) return;
    setState(() {
      _entries.insert(0, _buildEntry(DateTime.now()));
      if (_entries.length > 30) _entries.removeLast();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
            child: Row(
              children: [
                const Icon(LucideIcons.activity, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('Live Activity Feed', style: AppTextStyles.headlineSmall),
                const Spacer(),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: AppColors.secondary, shape: BoxShape.circle),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(
                    duration: 700.ms, curve: Curves.easeInOut),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _entries.length,
              itemBuilder: (context, i) {
                final e = _entries[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: e.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(e.text,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 8),
                      Text(DateFormat('HH:mm:ss').format(e.time),
                          style: AppTextStyles.monoSmall),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08, end: 0);
  }
}
