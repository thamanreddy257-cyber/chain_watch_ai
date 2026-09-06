import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:graphview/GraphView.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/mock/mock_data.dart';
import '../../shared/models/wallet.dart';
import '../../shared/widgets/glass_card.dart';
import 'widgets/graph_node_widget.dart';
import 'widgets/graph_legend.dart';
import 'widgets/node_info_panel.dart';

class _WeightedEdge {
  final String from;
  final String to;
  final double volume;
  const _WeightedEdge(this.from, this.to, this.volume);
}

class NetworkGraphPage extends StatefulWidget {
  const NetworkGraphPage({super.key});

  @override
  State<NetworkGraphPage> createState() => _NetworkGraphPageState();
}

class _NetworkGraphPageState extends State<NetworkGraphPage> {
  late final Graph _graph;
  late final FruchtermanReingoldAlgorithm _algorithm;
  late final Map<String, Wallet> _walletByAddress;
  late final Map<String, Set<String>> _adjacency;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _buildGraph();
  }

  void _buildGraph() {
    // Curate a legible subset: the hand-authored story wallets plus any
    // bulk wallet that participates in one of their transactions.
    final storyAddresses = MockData.wallets.map((w) => w.address).toSet();
    final relevantTx = MockData.transactions
        .where((t) =>
            storyAddresses.contains(t.fromAddress) ||
            storyAddresses.contains(t.toAddress))
        .toList();

    final includedAddresses = <String>{...storyAddresses};
    for (final t in relevantTx) {
      includedAddresses.add(t.fromAddress);
      includedAddresses.add(t.toAddress);
    }
    // Cap total nodes for a legible graph.
    if (includedAddresses.length > 24) {
      final extras = includedAddresses.difference(storyAddresses).take(24 - storyAddresses.length);
      includedAddresses
        ..clear()
        ..addAll(storyAddresses)
        ..addAll(extras);
    }

    _walletByAddress = {
      for (final addr in includedAddresses)
        if (MockData.walletByAddress(addr) != null) addr: MockData.walletByAddress(addr)!,
    };

    // Aggregate volume per undirected pair.
    final pairVolume = <String, double>{};
    for (final t in relevantTx) {
      if (!_walletByAddress.containsKey(t.fromAddress) ||
          !_walletByAddress.containsKey(t.toAddress)) {
        continue;
      }
      final key = ([t.fromAddress, t.toAddress]..sort()).join('|');
      pairVolume[key] = (pairVolume[key] ?? 0) + t.amountBtc;
    }

    final weightedEdges = pairVolume.entries.map((e) {
      final parts = e.key.split('|');
      return _WeightedEdge(parts[0], parts[1], e.value);
    }).toList();

    final maxVolume = weightedEdges.isEmpty
        ? 1.0
        : weightedEdges.map((e) => e.volume).reduce((a, b) => a > b ? a : b);

    _adjacency = {for (final addr in _walletByAddress.keys) addr: <String>{}};

    _graph = Graph()..isTree = false;
    final nodeMap = <String, Node>{};
    for (final addr in _walletByAddress.keys) {
      final node = Node.Id(addr);
      nodeMap[addr] = node;
      _graph.addNode(node);
    }

    for (final e in weightedEdges) {
      final intensity = (e.volume / maxVolume).clamp(0.15, 1.0);
      final wallet = _walletByAddress[e.from]!;
      final otherWallet = _walletByAddress[e.to]!;
      final isHighRiskLink = wallet.isKnownHighRisk || otherWallet.isKnownHighRisk;
      final color = isHighRiskLink
          ? AppColors.riskCritical.withValues(alpha: 0.35 + intensity * 0.4)
          : AppColors.primary.withValues(alpha: 0.15 + intensity * 0.35);
      _graph.addEdge(
        nodeMap[e.from]!,
        nodeMap[e.to]!,
        paint: Paint()
          ..color = color
          ..strokeWidth = 1 + intensity * 4
          ..style = PaintingStyle.stroke,
      );
      _adjacency[e.from]!.add(e.to);
      _adjacency[e.to]!.add(e.from);
    }

    _algorithm = FruchtermanReingoldAlgorithm(
      FruchtermanReingoldConfiguration(
        iterations: 600,
        repulsionRate: 0.6,
        attractionRate: 0.15,
      ),
    );
  }

  void _selectNode(String address) {
    setState(() {
      _selectedAddress = _selectedAddress == address ? null : address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 900;
    final selectedWallet =
        _selectedAddress != null ? _walletByAddress[_selectedAddress] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(isNarrow ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network Graph', style: AppTextStyles.displayMedium.copyWith(fontSize: isNarrow ? 26 : 32)),
            const SizedBox(height: 6),
            Text('Trace fund flow between wallets — tap any node to inspect its connections',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GlassCard(
                      hoverGlow: false,
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Container(color: AppColors.surface),
                            InteractiveViewer(
                              constrained: false,
                              boundaryMargin: const EdgeInsets.all(400),
                              minScale: 0.25,
                              maxScale: 2.5,
                              child: Padding(
                                padding: const EdgeInsets.all(120),
                                child: GraphView(
                                  graph: _graph,
                                  algorithm: _algorithm,
                                  paint: Paint()
                                    ..color = AppColors.border
                                    ..strokeWidth = 1
                                    ..style = PaintingStyle.stroke,
                                  builder: (node) {
                                    final address = node.key!.value as String;
                                    final wallet = _walletByAddress[address]!;
                                    final isDimmed = _selectedAddress != null &&
                                        _selectedAddress != address &&
                                        !(_adjacency[_selectedAddress]?.contains(address) ?? false);
                                    return GraphNodeWidget(
                                      wallet: wallet,
                                      isSelected: _selectedAddress == address,
                                      isDimmed: isDimmed,
                                      onTap: () => _selectNode(address),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Positioned(top: 16, left: 16, child: GraphLegend()),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.move, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text('Drag to pan · Pinch/scroll to zoom',
                                        style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 300,
                      child: selectedWallet != null
                          ? NodeInfoPanel(
                              key: ValueKey(selectedWallet.address),
                              wallet: selectedWallet,
                              connectionCount: _adjacency[selectedWallet.address]?.length ?? 0,
                              onClose: () => setState(() => _selectedAddress = null),
                            )
                          : GlassCard(
                              hoverGlow: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(LucideIcons.mousePointerClick, size: 20, color: AppColors.textMuted),
                                  const SizedBox(height: 12),
                                  Text('Select a node', style: AppTextStyles.headlineSmall),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap any wallet in the graph to see its risk profile, connections, and quick actions.',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
            if (isNarrow && selectedWallet != null) ...[
              const SizedBox(height: 16),
              NodeInfoPanel(
                key: ValueKey(selectedWallet.address),
                wallet: selectedWallet,
                connectionCount: _adjacency[selectedWallet.address]?.length ?? 0,
                onClose: () => setState(() => _selectedAddress = null),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
