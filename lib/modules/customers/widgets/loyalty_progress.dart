import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';

class LoyaltyProgress extends StatelessWidget {

  final Customer customer;

  const LoyaltyProgress({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {

    double percent = customer.loyaltyPoints / 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          "${customer.loyaltyTier} Tier",
          style: const TextStyle(
            color: AppColors.goldPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        LinearProgressIndicator(
          value: percent.clamp(0, 1),
          color: AppColors.goldPrimary,
          backgroundColor: AppColors.bgCard,
        )
      ],
    );
  }
}
