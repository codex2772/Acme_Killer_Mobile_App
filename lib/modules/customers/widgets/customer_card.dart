import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const CustomerCard({super.key, required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            /// HEADER
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.goldPrimary,
                  child: Text(
                    customer.name[0],
                    style: const TextStyle(color: Colors.black),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        customer.safePhone,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                /// VIP BADGE
                if (customer.type == "vip")
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "VIP",
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            /// STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                stat("Spent", "₹${customer.totalPurchases}"),

                stat("Visits", customer.visits.toString()),

                stat("Orders", customer.orders.toString()),
              ],
            ),

            const SizedBox(height: 10),

            /// LOYALTY TIER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  customer.loyaltyTier,
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  customer.outstanding,
                  style: const TextStyle(color: Colors.red),
                ),

                Text(
                  "${customer.loyaltyPoints} pts",
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
