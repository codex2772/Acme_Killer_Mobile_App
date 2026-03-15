import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/billing_controller.dart';
import '../widgets/invoice_item_row.dart';
import '../widgets/billing_summary.dart';

class CreateEstimateScreen extends GetView<BillingController> {
  const CreateEstimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: const Text(
          "Create Estimate",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.goldPrimary,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Add Item", style: TextStyle(color: Colors.black)),
        onPressed: controller.addItem,
      ),

      body: Column(
        children: [
          /// CUSTOMER
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: customerController,

              style: const TextStyle(color: Colors.white),

              onChanged: (v) {
                controller.customer.value = v;
              },

              decoration: InputDecoration(
                labelText: "Customer",
                labelStyle: const TextStyle(color: Colors.white70),

                filled: true,
                fillColor: AppColors.inputFill,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          /// ITEMS
          Expanded(
            child: Obx(() {
              if (controller.items.isEmpty) {
                return const Center(
                  child: Text(
                    "No items added",
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: controller.items.length,

                itemBuilder: (_, i) {
                  return InvoiceItemRow(index: i);
                },
              );
            }),
          ),

          /// SUMMARY
          const BillingSummary(),
        ],
      ),
    );
  }
}
