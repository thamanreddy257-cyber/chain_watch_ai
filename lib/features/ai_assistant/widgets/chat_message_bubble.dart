import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessageBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 640),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUser ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          height: 1.55,
        ),
      ),
    );

    final avatar = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUser ? AppColors.surfaceElevated : AppColors.primary.withValues(alpha: 0.15),
        border: Border.all(color: isUser ? AppColors.border : AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Icon(
        isUser ? LucideIcons.user : LucideIcons.bot,
        size: 15,
        color: isUser ? AppColors.textSecondary : AppColors.primary,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isUser
            ? [Flexible(child: bubble), const SizedBox(width: 10), avatar]
            : [avatar, const SizedBox(width: 10), Flexible(child: bubble)],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0);
  }
}
