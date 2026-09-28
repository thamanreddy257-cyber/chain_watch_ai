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
    this.padding = const EdgeInsets.all(16),
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
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (_hovering && widget.hoverGlow
                        ? AppColors.primary
                        : const Color(0xFF0F172A))
                    .withValues(alpha: _hovering && widget.hoverGlow ? 0.14 : 0.04),
                blurRadius: _hovering && widget.hoverGlow ? 22 : 10,
                offset: const Offset(0, 2),
                spreadRadius: -2,
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
