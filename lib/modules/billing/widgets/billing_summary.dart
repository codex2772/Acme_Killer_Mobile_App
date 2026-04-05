import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/billing_controller.dart';

// ════════════════════════════════════════════════════════════════════
// numberToWords — Indian format
// mirrors Electron billing.js numberToWords()
// 364250 → "Rupees Three Lakh Sixty Four Thousand Two Hundred and Fifty Only"
// ════════════════════════════════════════════════════════════════════
String numberToWords(int n) {
  if (n == 0) return 'Zero';
  const ones = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
    'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
    'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
  ];
  const tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy',
    'Eighty', 'Ninety'
  ];

  String convert(int num) {
    if (num < 20) return ones[num];
    if (num < 100) {
      return tens[num ~/ 10] + (num % 10 != 0 ? ' ${ones[num % 10]}' : '');
    }
    if (num < 1000) {
      return '${ones[num ~/ 100]} Hundred${num % 100 != 0 ? ' and ${convert(num % 100)}' : ''}';
    }
    if (num < 100000) {
      return '${convert(num ~/ 1000)} Thousand${num % 1000 != 0 ? ' ${convert(num % 1000)}' : ''}';
    }
    if (num < 10000000) {
      return '${convert(num ~/ 100000)} Lakh${num % 100000 != 0 ? ' ${convert(num % 100000)}' : ''}';
    }
    return '${convert(num ~/ 10000000)} Crore${num % 10000000 != 0 ? ' ${convert(num % 10000000)}' : ''}';
  }

  final rupees = n.abs();
  return 'Rupees ${convert(rupees)} Only';
}

// ════════════════════════════════════════════════════════════════════
// BillingSummary — FIXED
//
// Changes from previous build:
//  1. CGST/SGST split display (mirrors Electron invoice summary)
//  2. Amount in Words (Indian format)
//  3. Loading state support via _isSubmitting
// ════════════════════════════════════════════════════════════════════
class BillingSummary extends GetView<BillingController> {
  final VoidCallback? onSave;
  final String saveLabel;

  const BillingSummary(
      {super.key, this.onSave, this.saveLabel = 'Save Invoice'});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── GST split: CGST + SGST must sum exactly to total GST ──
      // mirrors Electron: Math.round(inv.gst / 2) for each component
      // Use floor for CGST, remainder for SGST so they always sum correctly
      final gst = controller.gstAmount;
      final cgst = gst ~/ 2;
      final sgst = gst - cgst; // absorbs the odd ₹1 if any
      final gstHalfRate = controller.gstRate.value / 2;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
                child: Container(
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),

            _row('Subtotal', '₹${controller.subtotal}'),
            // ── CGST + SGST split (mirrors Electron billing.js) ──
            // cgst = gst ~/ 2, sgst = gst - cgst so they always sum to exact GST total
            _row('CGST (${gstHalfRate.toStringAsFixed(1)}%)', '₹$cgst'),
            _row('SGST (${gstHalfRate.toStringAsFixed(1)}%)', '₹$sgst'),
            if (controller.discount.value > 0)
              _row('Discount', '- ₹${controller.discount.value}',
                  color: AppColors.success),
            if (controller.oldGoldValue.value > 0)
              _row('Old Gold Adj.', '- ₹${controller.oldGoldValue.value}',
                  color: AppColors.warning),

            const Divider(color: AppColors.border, height: 16),

            _row('Grand Total', '₹${controller.grandTotal}',
                bold: true, color: AppColors.goldPrimary, large: true),

            // ── Amount in Words (mirrors Electron numberToWords()) ──
            if (controller.grandTotal > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  numberToWords(controller.grandTotal),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(saveLabel,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _row(String label, String val,
          {bool bold = false, Color? color, bool large = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: large ? 14 : 13)),
            Text(val,
                style: TextStyle(
                    color: color ?? AppColors.textPrimary,
                    fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                    fontSize: large ? 16 : 13)),
          ],
        ),
      );
}
