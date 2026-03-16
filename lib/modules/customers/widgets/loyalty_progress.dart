import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';

class LoyaltyProgress extends StatelessWidget {
  final Customer customer;
  const LoyaltyProgress({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final tierColor = _tierColor(customer.loyaltyTier);
    final nextTier = customer.nextTier;
    final progress = customer.loyaltyProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.star_rounded, color: tierColor, size: 16),
                const SizedBox(width: 6),
                Text(customer.loyaltyTier,
                    style: TextStyle(color: tierColor, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(' Tier', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ]),
              Text('${customer.loyaltyPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} pts',
                  style: TextStyle(color: tierColor, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),

          if (nextTier.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(_tierColor(nextTier)),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(customer.loyaltyTier,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('₹${(customer.remainingToNextTier / 1000).toStringAsFixed(0)}K more to $nextTier',
                  style: TextStyle(color: _tierColor(nextTier), fontSize: 11)),
            ]),
          ] else ...[
            const SizedBox(height: 10),
            const Text('🎉 Highest tier reached!',
                style: TextStyle(color: AppColors.success, fontSize: 13)),
          ],

          if (customer.referralCount > 0) ...[
            const Divider(color: AppColors.border, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Referrals', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text('${customer.referralCount} customers referred',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _tierColor(String t) {
    switch (t) {
      case 'Platinum': return const Color(0xFFE2E8F0);
      case 'Gold':     return AppColors.goldPrimary;
      case 'Bronze':   return const Color(0xFFCD7F32);
      default:         return const Color(0xFF94A3B8);
    }
  }
}
