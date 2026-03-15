import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';

class CreateCreditNoteScreen extends StatelessWidget {
  const CreateCreditNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final invoiceController = TextEditingController();
    final itemController = TextEditingController();
    final amountController = TextEditingController();

    String reason = "Design Issue";
    String refundMode = "Cash Refund";

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: const Text(
          "Create Credit Note",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// INVOICE

            input(invoiceController, "Against Invoice"),

            /// ITEM

            input(itemController, "Item Description"),

            /// REFUND AMOUNT

            input(amountController, "Refund Amount"),

            const SizedBox(height: 10),

            /// REASON

            DropdownButtonFormField<String>(
              value: reason,
              dropdownColor: AppColors.bgCard,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                labelText: "Return Reason",
                labelStyle: const TextStyle(color: Colors.white70),

                filled: true,
                fillColor: AppColors.inputFill,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              items: const [
                DropdownMenuItem(
                    value: "Design Issue", child: Text("Design Issue")),
                DropdownMenuItem(
                    value: "Size Mismatch", child: Text("Size Mismatch")),
                DropdownMenuItem(
                    value: "Quality Issue", child: Text("Quality Issue")),
                DropdownMenuItem(
                    value: "Customer Changed Mind",
                    child: Text("Customer Changed Mind")),
              ],

              onChanged: (v) {
                reason = v!;
              },
            ),

            const SizedBox(height: 10),

            /// REFUND MODE

            DropdownButtonFormField<String>(
              value: refundMode,
              dropdownColor: AppColors.bgCard,
              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                labelText: "Refund Mode",
                labelStyle: const TextStyle(color: Colors.white70),

                filled: true,
                fillColor: AppColors.inputFill,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              items: const [
                DropdownMenuItem(
                    value: "Cash Refund", child: Text("Cash Refund")),
                DropdownMenuItem(
                    value: "Bank Transfer", child: Text("Bank Transfer")),
                DropdownMenuItem(
                    value: "Store Credit", child: Text("Store Credit")),
              ],

              onChanged: (v) {
                refundMode = v!;
              },
            ),

            const SizedBox(height: 20),

            /// SAVE BUTTON

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                icon: const Icon(Icons.receipt_long, color: Colors.black),

                label: const Text(
                  "Process Credit Note",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INPUT FIELD

  Widget input(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: TextField(
        controller: controller,

        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),

          filled: true,
          fillColor: AppColors.inputFill,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
