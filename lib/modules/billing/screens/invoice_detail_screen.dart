import 'package:acme_killer_mobile_app/modules/billing/controllers/billing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/billing/invoice_model.dart';
import '../../../core/constants/app_colors.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Invoice inv = Get.arguments;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(backgroundColor: AppColors.bgPrimary, title: Text(inv.id)),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              inv.customer,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text("Payment Mode: ${inv.paymentMode}"),

            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: inv.items.length,

                itemBuilder: (_, i) {
                  final item = inv.items[i];

                  return ListTile(
                    title: Text(item.name),

                    trailing: Text("₹${item.total}"),
                  );
                },
              ),
            ),

            const Divider(),

            Text("Subtotal: ₹${inv.subtotal}"),

            Text("GST: ₹${inv.gst}"),

            Text(
              "Total: ₹${inv.total}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.goldPrimary,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.find<BillingController>().recordPayment(
                  inv.id,
                  inv.total,
                  "Cash",
                );
              },
              child: const Text("Mark Paid"),
            ),
          ],
        ),
      ),
    );
  }
}
