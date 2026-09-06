import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ReportSection extends StatelessWidget {
  final String title;
  final Widget child;

  const ReportSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppTextStyles.label.copyWith(color: AppColors.primary)),
        const SizedBox(height: 10),
        child,
        const SizedBox(height: 28),
        const Divider(color: AppColors.borderSubtle),
        const SizedBox(height: 28),
      ],
    );
  }
}
