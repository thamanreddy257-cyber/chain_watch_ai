import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A premium elevated card with a subtle border that glows cyan on hover.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hoverGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.hoverGlow = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovering && widget.hoverGlow
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.border,
              width: 1,
            ),
            boxShadow: _hovering && widget.hoverGlow
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
