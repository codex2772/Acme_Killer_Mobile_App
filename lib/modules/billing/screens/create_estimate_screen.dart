import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../modules/customers/controllers/customer_controller.dart';
import '../controllers/billing_controller.dart';
import '../widgets/billing_summary.dart';
import '../widgets/invoice_item_row.dart';

class CreateEstimateScreen extends GetView<BillingController> {
  const CreateEstimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController custCtrl = Get.find<CustomerController>();
    final validUntilCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    controller.clearBuilder();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text('New Estimate',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _card('Customer & Validity', Icons.person_outline, Column(
                    children: [
                      Obx(() => DropdownButtonFormField<String>(
                        value: controller.customer.value.isEmpty ? null : controller.customer.value,
                        dropdownColor: AppColors.bgSecondary,
                        decoration: _deco('Select Customer *'),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        items: custCtrl.customers.map((c) => DropdownMenuItem(
                          value: c.name,
                          child: Text('${c.name} — ${c.phone}',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                        )).toList(),
                        onChanged: (v) { if (v != null) controller.customer.value = v; },
                      )),
                      const SizedBox(height: 12),
                      _dateField('Valid Until', validUntilCtrl),
                    ],
                  )),
                  const SizedBox(height: 12),

                  _card('Items', Icons.inventory_2_outlined, Column(
                    children: [
                      Obx(() => Column(
                        children: [
                          if (controller.items.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border)),
                              child: const Center(child: Text('Tap to add items',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)))),
                          ...List.generate(controller.items.length, (i) => InvoiceItemRow(index: i)),
                        ],
                      )),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.addItem,
                          icon: const Icon(Icons.add, size: 16, color: AppColors.goldPrimary),
                          label: const Text('Add Item',
                              style: TextStyle(color: AppColors.goldPrimary, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.goldPrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 12),

                  _card('Notes & Terms', Icons.notes_outlined, TextField(
                    controller: notesCtrl, maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Any special notes or terms...',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none),
                  )),
                ],
              ),
            ),
          ),
          BillingSummary(
            saveLabel: 'Save Estimate',
            onSave: () {
              if (controller.customer.value.isEmpty) {
                Get.snackbar('Error', 'Select a customer',
                    backgroundColor: AppColors.error.withOpacity(0.2), colorText: AppColors.error,
                    snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
                return;
              }
              final est = controller.saveEstimate(
                validUntil: validUntilCtrl.text.isEmpty ? null : validUntilCtrl.text,
                notes: notesCtrl.text,
              );
              Get.back();
              Get.snackbar('Estimate Saved', 'Estimate #${est.id} created!',
                  backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                  snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
            },
          ),
        ],
      ),
    );
  }

  Widget _card(String title, IconData icon, Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: AppColors.goldPrimary, size: 15),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(color: AppColors.textPrimary,
            fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
      const SizedBox(height: 12),
      child,
    ]),
  );

  Widget _dateField(String label, TextEditingController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12,
          fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      GestureDetector(
        onTap: () async {
          final d = await showDatePicker(
            context: Get.context!,
            initialDate: DateTime.now().add(const Duration(days: 14)),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
            builder: (c, w) => Theme(data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(primary: AppColors.goldPrimary)), child: w!),
          );
          if (d != null) ctrl.text = d.toIso8601String().substring(0,10);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 14),
            const SizedBox(width: 8),
            Text(ctrl.text.isEmpty ? 'Select validity date' : ctrl.text,
                style: TextStyle(color: ctrl.text.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                    fontSize: 13)),
          ]),
        ),
      ),
    ]);
  }

  InputDecoration _deco(String label) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    filled: true, fillColor: AppColors.inputFill,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.goldPrimary)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}
