import 'package:acme_killer_mobile_app/models/customer_model.dart';
import 'package:acme_killer_mobile_app/modules/customers/controllers/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/billing_controller.dart';
import '../widgets/invoice_item_row.dart';

class CreateInvoiceScreen extends GetView<BillingController> {
  CreateInvoiceScreen({super.key});

  final customerController = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: const Text(
          "Create Invoice",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          /// SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customerSection(),

                  const SizedBox(height: 16),

                  invoiceInfo(),

                  const SizedBox(height: 20),

                  itemsSection(),

                  const SizedBox(height: 20),

                  paymentSection(),

                  const SizedBox(height: 20),

                  goldAdjustment(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          /// SUMMARY PANEL
          summaryPanel(),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.goldPrimary,
        onPressed: controller.addItem,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Add Item", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  /// CUSTOMER

  Widget customerSection() {
    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Customer"),

          const SizedBox(height: 10),

          DropdownButtonFormField<Customer>(
            dropdownColor: AppColors.bgCard,
            decoration: InputDecoration(
              labelText: "Select Customer",
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            items: customerController.customers.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text("${c.name} • ${c.phone}"),
              );
            }).toList(),

            onChanged: (c) {
              if (c == null) return;
              controller.customer.value = c.name;
            },
          ),
        ],
      ),
    );
  }

  /// INVOICE INFO

  Widget invoiceInfo() {
    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Invoice Info"),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(decoration: inputDecoration("Invoice Date")),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: TextField(decoration: inputDecoration("Due Date")),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Tax Invoice"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Bill of Supply"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ITEMS

  Widget itemsSection() {
    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              sectionTitle("Items"),
              Text(
                "${controller.items.length} item(s)",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Obx(
            () => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.items.length,
              itemBuilder: (_, i) => InvoiceItemRow(index: i),
            ),
          ),
        ],
      ),
    );
  }

  /// PAYMENT

  Widget paymentSection() {
    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Payment"),

          const SizedBox(height: 10),

          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.paymentMode.value,
              dropdownColor: AppColors.bgCard,

              items: const [
                DropdownMenuItem(value: "Cash", child: Text("Cash")),
                DropdownMenuItem(value: "UPI", child: Text("UPI")),
                DropdownMenuItem(value: "Card", child: Text("Card")),
                DropdownMenuItem(value: "Bank", child: Text("Bank Transfer")),
              ],

              onChanged: (v) {
                if (v == null) return;
                controller.paymentMode.value = v;
              },

              decoration: inputDecoration("Payment Mode"),
            ),
          ),
        ],
      ),
    );
  }

  /// OLD GOLD

  Widget goldAdjustment() {
    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Old Gold Adjustment"),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    labelText: "Weight (g)",
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    labelText: "Value",
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget discountSection() {
    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Discount"),

          const SizedBox(height: 10),

          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),

            onChanged: controller.setDiscount,

            decoration: InputDecoration(
              labelText: "Discount ₹",
              labelStyle: const TextStyle(color: Colors.white),

              filled: true,
              fillColor: AppColors.inputFill,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget adjustmentsSection() {
    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Adjustments"),

          const SizedBox(height: 10),

          TextField(
            keyboardType: TextInputType.number,
            onChanged: controller.setDiscount,
            decoration: inputDecoration("Discount ₹"),
          ),

          const SizedBox(height: 10),

          TextField(
            keyboardType: TextInputType.number,
            onChanged: controller.setOldGold,
            decoration: inputDecoration("Old Gold Value"),
          ),
        ],
      ),
    );
  }

  /// SUMMARY

  Widget summaryPanel() {
    return Obx(
      () => Container(
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
            row("Old Gold Adj.", controller.oldGoldValue.value),

            const Divider(),

            row("Total", controller.total, bold: true),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,

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
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// CARD

  Widget card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),

      child: child,
    );
  }

  /// TITLE

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget row(String label, int value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),

        Text(
          "₹$value",
          style: TextStyle(
            color: bold ? AppColors.goldPrimary : AppColors.textPrimary,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
