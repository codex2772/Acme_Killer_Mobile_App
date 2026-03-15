import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/billing_controller.dart';

class BillingSummary extends GetView<BillingController> {
  const BillingSummary({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() => Container(

      padding: const EdgeInsets.all(16),

      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      child: Column(
        children: [

          row("Subtotal", controller.subtotal.value),

          row("GST (3%)", controller.gst.value),

          row("Discount", controller.discount.value),

          const Divider(),

          row("Total", controller.total, bold: true),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
              ),

              onPressed: () {

                controller.saveInvoice();

                Get.back();

              },

              child: const Text(
                "Save Invoice",
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
    ));
  }

  Widget row(String title, int value, {bool bold = false}) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [

        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary),
        ),

        Text(
          "₹$value",
          style: TextStyle(
            color: bold ? AppColors.goldPrimary : AppColors.textPrimary,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        )
      ],
    );
  }
}
