import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class _PipelineStep {
  final String label;
  final IconData icon;
  const _PipelineStep(this.label, this.icon);
}

const _steps = [
  _PipelineStep('Detection', LucideIcons.radar),
  _PipelineStep('Investigation', LucideIcons.search),
  _PipelineStep('AI Analysis', LucideIcons.brainCircuit),
  _PipelineStep('Network View', LucideIcons.share2),
  _PipelineStep('Report', LucideIcons.fileText),
];

class PipelineStrip extends StatelessWidget {
  const PipelineStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 800;
    final children = <Widget>[];
    for (var i = 0; i < _steps.length; i++) {
      children.add(_StepChip(step: _steps[i], index: i));
      if (i != _steps.length - 1) {
        children.add(
          isNarrow
              ? const _ArrowRotated()
              : Icon(LucideIcons.arrowRight,
                  color: AppColors.textMuted.withValues(alpha: 0.5), size: 18),
        );
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: children,
    );
  }
}

class _ArrowRotated extends StatelessWidget {
  const _ArrowRotated();
  @override
  Widget build(BuildContext context) {
    return Icon(LucideIcons.arrowRight,
        color: AppColors.textMuted.withValues(alpha: 0.5), size: 18);
  }
}

class _StepChip extends StatelessWidget {
  final _PipelineStep step;
  final int index;
  const _StepChip({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(step.icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(step.label, style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    )
        .animate(delay: (300 + index * 120).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
