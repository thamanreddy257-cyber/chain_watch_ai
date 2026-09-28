import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';

class FeatureCardData {
  final IconData icon;
  final String title;
  final String description;
  const FeatureCardData(
      {required this.icon, required this.title, required this.description});
}

class FeatureCard extends StatelessWidget {
  final FeatureCardData data;

  const FeatureCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 14),
          Text(data.title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 6),
          Text(data.description, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
