import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/wallet.dart';

class _GaugePainter extends CustomPainter {
  final double progress; // 0-1
  final Color color;

  _GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const startAngle = pi * 0.75;
    const sweepAngle = pi * 1.5;

    final trackPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 8),
        startAngle, sweepAngle, false, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 8),
        startAngle, sweepAngle * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class RiskGauge extends StatelessWidget {
  final int score;
  final RiskLevel level;

  const RiskGauge({super.key, required this.score, required this.level});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(level.label);
    return SizedBox(
      width: 160,
      height: 160,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score / 100),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _GaugePainter(progress: value, color: color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(value * 100).toInt()}',
                      style: AppTextStyles.statNumber.copyWith(fontSize: 38, color: color)),
                  Text('RISK SCORE', style: AppTextStyles.label.copyWith(fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
