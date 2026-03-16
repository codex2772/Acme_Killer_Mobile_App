import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/billing/billing_item_model.dart';
import '../controllers/billing_controller.dart';

class InvoiceItemRow extends StatelessWidget {
  final int index;
  const InvoiceItemRow({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BillingController>();

    return Obx(() {
      if (index >= ctrl.items.length) return const SizedBox.shrink();
      final item = ctrl.items[index];

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item ${index + 1}',
                    style: const TextStyle(
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
                Row(children: [
                  Text(
                    '₹${item.total}',
                    style: const TextStyle(
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => ctrl.removeItem(index),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.delete_outline, color: AppColors.error, size: 14),
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 10),

            // ── Inventory picker ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: item.inventoryId.isEmpty ? null : item.inventoryId,
                  dropdownColor: AppColors.bgSecondary,
                  isExpanded: true,
                  hint: const Text('Select inventory item',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  items: ctrl.availableItems.map((inv) {
                    return DropdownMenuItem<String>(
                      value: inv.id,
                      child: Text('${inv.name} (${inv.id}) — ${inv.netWeight}g',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    final inv = ctrl.availableItems.firstWhereOrNull((i) => i.id == id);
                    if (inv != null) {
                      final goldRate = 6285.0; // In real app get from state
                      item.name = inv.name;
                      item.inventoryId = inv.id;
                      item.weight = inv.netWeight;
                      item.rate = inv.netWeight > 0 ? inv.sellingPrice / inv.netWeight : goldRate;
                      item.making = inv.makingCharge;
                      item.purity = inv.purity;
                      ctrl.recalculate();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Weight + Rate + Making ──
            Row(children: [
              Expanded(child: _numField('Weight (g)', item.weight.toString(), (v) {
                item.weight = double.tryParse(v) ?? item.weight;
                ctrl.recalculate();
              })),
              const SizedBox(width: 8),
              Expanded(child: _numField('Rate (₹/g)', item.rate.toString(), (v) {
                item.rate = double.tryParse(v) ?? item.rate;
                ctrl.recalculate();
              })),
              const SizedBox(width: 8),
              Expanded(child: _numField('Making %', item.making.toString(), (v) {
                item.making = double.tryParse(v) ?? item.making;
                ctrl.recalculate();
              })),
            ]),

            const SizedBox(height: 8),

            // ── Breakdown ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _calc('Metal', '₹${item.metalValue}'),
                _calc('Making', '₹${item.makingValue}'),
                _calc('Total', '₹${item.total}', bold: true),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _numField(String label, String initial, ValueChanged<String> onChange) {
    final ctrl = TextEditingController(text: initial);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            onChanged: onChange,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _calc(String label, String val, {bool bold = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      Text(val, style: TextStyle(
          color: bold ? AppColors.goldPrimary : AppColors.textSecondary,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          fontSize: 12)),
    ],
  );
}
