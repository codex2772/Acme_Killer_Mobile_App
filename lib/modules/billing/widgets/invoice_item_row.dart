import 'package:acme_killer_mobile_app/models/inventory_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/billing_controller.dart';

class InvoiceItemRow extends StatelessWidget {
  final int index;

  const InvoiceItemRow({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BillingController>();

    return Obx(() {
      final item = controller.items[index];

      return Card(
        color: AppColors.bgCard,
        margin: const EdgeInsets.only(bottom: 10),

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [
              DropdownButtonFormField<InventoryItem>(
                dropdownColor: AppColors.bgCard,

                decoration: const InputDecoration(
                  labelText: "Select Item",
                  labelStyle: TextStyle(color: Colors.white70),
                ),

                items: controller.availableItems.map((inv) {
                  return DropdownMenuItem<InventoryItem>(
                    value: inv,
                    child: Text(
                      "${inv.name} (${inv.id})",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),

                onChanged: (inv) {
                  if (inv == null) return;

                  item.name = inv.name;
                  item.weight = inv.netWeight;
                  item.rate = inv.sellingPrice / inv.netWeight;
                  item.making = inv.makingCharge;

                  controller.calculate();
                },
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: numberField("Weight", (v) {
                      item.weight = double.tryParse(v) ?? 0;
                      controller.calculate();
                    }),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: numberField("Rate", (v) {
                      item.rate = double.tryParse(v) ?? 0;
                      controller.calculate();
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: numberField("Making %", (v) {
                      item.making = double.tryParse(v) ?? 0;
                      controller.calculate();
                    }),
                  ),

                  const SizedBox(width: 10),

                  /// TOTAL
                  Text(
                    "₹${item.total}",
                    style: const TextStyle(
                      color: AppColors.goldPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      controller.removeItem(index);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget numberField(String label, Function(String) onChanged) {
    return TextField(
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),

      onChanged: onChanged,

      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),

        filled: true,
        fillColor: AppColors.inputFill,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
