import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../modules/customers/controllers/customer_controller.dart';
import '../controllers/billing_controller.dart';
import '../widgets/billing_summary.dart';
import '../widgets/invoice_item_row.dart';

// ════════════════════════════════════════════════════════════════════
// CreateEstimateScreen — FIXED
//
// Changes:
//  1. Store picker in All Stores mode (matches invoice screen)
//  2. API call via createEstimateViaApi() — no longer local-only
//  3. Store picker validation before save
// ════════════════════════════════════════════════════════════════════
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
                  // ── Store picker (All Stores mode) ──
                  _storePicker(),

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
                        onChanged: (v) {
                          if (v == null) return;
                          final cust = custCtrl.customers.firstWhereOrNull((c) => c.name == v);
                          controller.customer.value = v;
                          controller.customerId.value = cust?.backendId?.toString() ?? cust?.id ?? '';
                        },
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
            onSave: () => _save(validUntilCtrl.text, notesCtrl.text),
          ),
        ],
      ),
    );
  }

  // ── Store picker ──
  Widget _storePicker() {
    return Obx(() {
      if (!controller.isAllStoresMode) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warning.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.store_outlined, color: AppColors.warning, size: 16),
              const SizedBox(width: 8),
              const Expanded(child: Text('Select store for this estimate',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13))),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.inputFill, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.billingStore.value?.id,
                  dropdownColor: AppColors.bgSecondary, isExpanded: true,
                  hint: const Text('— Choose Store —',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  items: controller.availableStores.map((s) => DropdownMenuItem<int>(
                    value: s.id, child: Text(s.name,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  )).toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    final store = controller.availableStores.firstWhereOrNull((s) => s.id == id);
                    controller.selectBillingStore(store);
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Save with API ──
  Future<void> _save(String validUntil, String notes) async {
    final storeErr = controller.validateStoreSelection();
    if (storeErr != null) {
      _err(storeErr); return;
    }
    if (controller.customer.value.isEmpty) {
      _err('Select a customer'); return;
    }
    if (controller.items.isEmpty) {
      _err('Add at least one item'); return;
    }

    final auth = Get.find<AuthController>();
    if (!auth.isDemo.value) {
      final lineItems = controller.items.map((item) => {
        'name': item.name,
        'weight': item.weight,
        'rate': item.rate,
        'makingCharge': item.making,
        'amount': item.total,
      }).toList();

      final ok = await controller.createEstimateViaApi({
        'customerId': controller.customerId.value,
        'customerName': controller.customer.value,
        'total': controller.grandTotal,
        'gstAmount': controller.gstAmount,
        'discount': controller.discount.value,
        'validUntil': validUntil.isEmpty ? null : validUntil,
        'notes': notes,
        'items': lineItems,
      });

      if (ok) {
        await controller.restoreStoreContext();
        Get.back();
        Get.snackbar('Estimate Created', 'Estimate saved to server!',
            backgroundColor: AppColors.bgCard, colorText: AppColors.success,
            snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
        return;
      }
    }

    // Local fallback
    final est = controller.saveEstimate(
      validUntil: validUntil.isEmpty ? null : validUntil, notes: notes);
    await controller.restoreStoreContext();
    Get.back();
    Get.snackbar('Estimate Saved', 'Estimate #${est.id} created!',
        backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
  }

  void _err(String msg) => Get.snackbar('Error', msg,
      backgroundColor: AppColors.error.withOpacity(0.2), colorText: AppColors.error,
      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));

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
      const SizedBox(height: 12), child,
    ]),
  );

  Widget _dateField(String label, TextEditingController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      GestureDetector(
        onTap: () async {
          final d = await showDatePicker(context: Get.context!,
            initialDate: DateTime.now().add(const Duration(days: 14)),
            firstDate: DateTime.now(), lastDate: DateTime(2030),
            builder: (c, w) => Theme(data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(primary: AppColors.goldPrimary)), child: w!));
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
                style: TextStyle(color: ctrl.text.isEmpty ? AppColors.textMuted : AppColors.textPrimary, fontSize: 13)),
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
