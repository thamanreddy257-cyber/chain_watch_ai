import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/pipeline_strip.dart';
import 'widgets/feature_card.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const _features = [
    FeatureCardData(
      icon: LucideIcons.brainCircuit,
      title: 'AI-Powered Analysis',
      description:
          'Every flagged wallet comes with a plain-language, evidence-backed explanation of why it was flagged — not just a score.',
    ),
    FeatureCardData(
      icon: LucideIcons.share2,
      title: 'Interactive Network Graph',
      description:
          'Trace fund flow across hops in real time. Pan, zoom, and tap any node to reveal its full transaction context.',
    ),
    FeatureCardData(
      icon: LucideIcons.shieldAlert,
      title: 'Real-Time Threat Alerts',
      description:
          'Automated detection of rapid movement, fund splitting, consolidation, and high-risk counterparties as they happen.',
    ),
    FeatureCardData(
      icon: LucideIcons.fileText,
      title: 'Investigation Reports',
      description:
          'Compile a wallet\'s full risk profile, transaction history, and AI findings into a clean, shareable report.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 760;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.3,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.background,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isNarrow ? 20 : 64, vertical: 32),
                child: Column(
                  children: [
                    _TopBar(isNarrow: isNarrow),
                    SizedBox(height: isNarrow ? 48 : 90),
                    _Hero(isNarrow: isNarrow),
                    SizedBox(height: isNarrow ? 40 : 64),
                    const PipelineStrip()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms),
                    SizedBox(height: isNarrow ? 56 : 96),
                    _FeatureGrid(isNarrow: isNarrow, features: _features),
                    SizedBox(height: isNarrow ? 48 : 80),
                    _Footer(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isNarrow;
  const _TopBar({required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Icon(LucideIcons.shield, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text('CHAINWATCH AI', style: AppTextStyles.headlineSmall.copyWith(fontSize: 16)),
        const Spacer(),
        if (!isNarrow)
          Text('NTRO · PS 26146 · SIH 2026',
              style: AppTextStyles.monoSmall.copyWith(letterSpacing: 0.5)),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isNarrow;
  const _Hero({required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: AppColors.secondary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('Blockchain Intelligence Platform',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 28),
        Text(
          'Trace Bitcoin.\nExpose the Network.',
          textAlign: TextAlign.center,
          style: (isNarrow ? AppTextStyles.displayMedium : AppTextStyles.displayLarge),
        ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.15, end: 0),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'CHAINWATCH AI ingests raw wallet and transaction data, detects laundering '
            'patterns with heuristic + AI analysis, and visualizes fund flow across the '
            'entire network — turning a wall of hashes into an investigation you can act on.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.15, end: 0),
        const SizedBox(height: 34),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _PrimaryCta(),
            _SecondaryCta(),
          ],
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
      ],
    );
  }
}

class _PrimaryCta extends StatefulWidget {
  @override
  State<_PrimaryCta> createState() => _PrimaryCtaState();
}

class _PrimaryCtaState extends State<_PrimaryCta> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => context.go('/dashboard'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _hovering ? 0.45 : 0.25),
                blurRadius: _hovering ? 28 : 18,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Launch Dashboard', style: AppTextStyles.button),
              const SizedBox(width: 8),
              Icon(LucideIcons.arrowRight, size: 16, color: AppColors.background),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryCta extends StatefulWidget {
  @override
  State<_SecondaryCta> createState() => _SecondaryCtaState();
}

class _SecondaryCtaState extends State<_SecondaryCta> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => context.go('/network'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _hovering ? AppColors.textPrimary : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.share2, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text('View Network Graph',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final bool isNarrow;
  final List<FeatureCardData> features;
  const _FeatureGrid({required this.isNarrow, required this.features});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width < 760 ? 1 : (width < 1100 ? 2 : 4);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: columns == 1 ? 2.0 : 0.95,
      ),
      itemBuilder: (context, i) {
        return FeatureCard(data: features[i])
            .animate(delay: (i * 100).ms)
            .fadeIn(duration: 450.ms)
            .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
      },
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.border),
        const SizedBox(height: 20),
        Text(
          'Prototype for Smart India Hackathon 2026 · Problem Statement 26146 · NTRO — Blockchain & Cybersecurity',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
