import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/customer_controller.dart';

class CustomerStats extends GetView<CustomerController> {
  const CustomerStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [
            Row(
              children: [
                statCard("Customers", controller.totalCustomers.toString()),

                statCard("VIP", controller.vipCustomers.toString()),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                statCard("Revenue", "₹${controller.lifetimeRevenue}"),

                statCard(
                  "Outstanding",
                  controller.outstandingCustomers.toString(),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget statCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
        ),

        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.goldPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
