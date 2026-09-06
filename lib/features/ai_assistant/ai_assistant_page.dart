import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/glass_card.dart';
import 'ai_response_engine.dart';
import 'widgets/chat_message_bubble.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage(this.text, this.isUser);
}

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      "Hello — I'm the CHAINWATCH AI assistant. Ask me about a specific wallet, "
      "a detection pattern, or pick a suggestion below to get started.",
      false,
    ),
  ];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _thinking = false;

  void _send([String? text]) {
    final message = (text ?? _controller.text).trim();
    if (message.isEmpty || _thinking) return;

    setState(() {
      _messages.add(_ChatMessage(message, true));
      _controller.clear();
      _thinking = true;
    });
    _scrollToBottom();

    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(AiResponseEngine.respond(message), false));
        _thinking = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(isNarrow ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.bot, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text('AI Assistant', style: AppTextStyles.displayMedium.copyWith(fontSize: isNarrow ? 24 : 30)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Ask about wallets, risk patterns, or where to focus your investigation next',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            Expanded(
              child: GlassCard(
                hoverGlow: false,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: _messages.length + (_thinking ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == _messages.length) {
                            return const _ThinkingIndicator();
                          }
                          final m = _messages[i];
                          return ChatMessageBubble(text: m.text, isUser: m.isUser);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AiResponseEngine.suggestedQuestions.map((q) {
                          return ActionChip(
                            label: Text(q, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
                            backgroundColor: AppColors.surfaceElevated,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onPressed: () => _send(q),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: AppTextStyles.bodyLarge,
                              onSubmitted: (_) => _send(),
                              decoration: const InputDecoration(
                                hintText: 'Ask about a wallet, pattern, or threat...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filled(
                            onPressed: _thinking ? null : () => _send(),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.all(14),
                            ),
                            icon: const Icon(LucideIcons.send, size: 18, color: AppColors.background),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: const Icon(LucideIcons.bot, size: 15, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(duration: 400.ms, delay: (i * 150).ms)
                      .then()
                      .fadeOut(duration: 400.ms),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
