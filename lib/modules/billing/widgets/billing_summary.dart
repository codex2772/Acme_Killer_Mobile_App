import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/billing_controller.dart';

class BillingSummary extends GetView<BillingController> {
  final VoidCallback? onSave;
  final String saveLabel;

  const BillingSummary({super.key, this.onSave, this.saveLabel = 'Save Invoice'});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,-2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(child: Container(width: 36, height: 3,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 12),

          _row('Subtotal', '₹${controller.subtotal}'),
          _row('GST (${controller.gstRate.value}%)', '₹${controller.gstAmount}'),
          if (controller.discount.value > 0)
            _row('Discount', '- ₹${controller.discount.value}', color: AppColors.success),
          if (controller.oldGoldValue.value > 0)
            _row('Old Gold Adj.', '- ₹${controller.oldGoldValue.value}', color: AppColors.warning),

          const Divider(color: AppColors.border, height: 16),

          _row('Grand Total', '₹${controller.grandTotal}',
              bold: true, color: AppColors.goldPrimary, large: true),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(saveLabel,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _row(String label, String val, {bool bold = false, Color? color, bool large = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(
                color: AppColors.textSecondary, fontSize: large ? 14 : 13)),
            Text(val, style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontSize: large ? 16 : 13)),
          ],
        ),
      );
}
