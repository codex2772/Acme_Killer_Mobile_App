import 'package:flutter/material.dart';
import 'package:acme_killer_mobile_app/core/constants/app_colors.dart';

class ModuleCard extends StatelessWidget {
  final String title;
  final String count;

  const ModuleCard({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.widgets, color: AppColors.goldPrimary),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            count,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),

          const Spacer(),

          const Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.goldPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
