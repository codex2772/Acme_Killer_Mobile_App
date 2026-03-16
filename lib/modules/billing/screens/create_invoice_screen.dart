import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../modules/customers/controllers/customer_controller.dart';
import '../controllers/billing_controller.dart';
import '../widgets/billing_summary.dart';
import '../widgets/invoice_item_row.dart';

class CreateInvoiceScreen extends GetView<BillingController> {
  CreateInvoiceScreen({super.key});

  final CustomerController _custCtrl = Get.find<CustomerController>();
  final _dueDateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _sigCtrl = TextEditingController();
  final RxString _invoiceType = 'tax'.obs;

  @override
  Widget build(BuildContext context) {
    controller.clearBuilder();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'New Invoice',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Customer ──
                  _sectionCard(
                    'Customer',
                    Icons.person_outline,
                    _customerSection(),
                  ),
                  const SizedBox(height: 12),

                  // ── Invoice info ──
                  _sectionCard(
                    'Invoice Details',
                    Icons.info_outline,
                    _invoiceInfoSection(),
                  ),
                  const SizedBox(height: 12),

                  // ── Items ──
                  _itemsSection(),
                  const SizedBox(height: 12),

                  // ── Payment ──
                  _sectionCard(
                    'Payment',
                    Icons.payment_outlined,
                    _paymentSection(),
                  ),
                  const SizedBox(height: 12),

                  // ── Old gold ──
                  _sectionCard(
                    'Old Gold Adjustment (Optional)',
                    Icons.repeat_rounded,
                    _oldGoldSection(),
                  ),
                  const SizedBox(height: 12),

                  // ── Notes ──
                  _sectionCard('Notes', Icons.notes_outlined, _notesSection()),
                ],
              ),
            ),
          ),
          BillingSummary(saveLabel: 'Save Invoice', onSave: _saveInvoice),
        ],
      ),
    );
  }

  void _saveInvoice() {
    if (controller.customer.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a customer',
        backgroundColor: AppColors.error.withOpacity(0.2),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    if (controller.items.isEmpty) {
      Get.snackbar(
        'Error',
        'Add at least one item',
        backgroundColor: AppColors.error.withOpacity(0.2),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    final inv = controller.saveInvoice(
      dueDateStr: _dueDateCtrl.text.isEmpty ? null : _dueDateCtrl.text,
      sig: _sigCtrl.text.isEmpty ? null : _sigCtrl.text,
      notes: _notesCtrl.text,
    );
    Get.back();
    Get.snackbar(
      'Invoice Created',
      'Invoice #${inv.id} saved!',
      backgroundColor: AppColors.bgCard,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  Widget _customerSection() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.customer.value.isEmpty
            ? null
            : controller.customer.value,
        dropdownColor: AppColors.bgSecondary,
        decoration: InputDecoration(
          hintText: 'Select Customer',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          filled: true,
          fillColor: AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.goldPrimary),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        items: _custCtrl.customers
            .map(
              (c) => DropdownMenuItem(
                value: c.name,
                child: Text(
                  '${c.name} — ${c.phone}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          final cust = _custCtrl.customers.firstWhereOrNull((c) => c.name == v);
          controller.customer.value = v;
          controller.customerId.value = cust?.id ?? '';
        },
      ),
    );
  }

  Widget _invoiceInfoSection() {
    return Column(
      children: [
        // Invoice type toggle
        Row(
          children: [
            _typeBtn('tax', 'Tax Invoice'),
            const SizedBox(width: 10),
            _typeBtn('supply', 'Bill of Supply'),
          ],
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _field(
                'Invoice Date',
                TextEditingController(
                  text: DateTime.now().toIso8601String().substring(0, 10),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _datePicker('Due Date', _dueDateCtrl)),
          ],
        ),
      ],
    );
  }

  Widget _typeBtn(String val, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _invoiceType.value = val,
        child: Obx(() {
          final active = _invoiceType.value == val;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.goldPrimary.withOpacity(0.15)
                  : AppColors.inputFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? AppColors.goldPrimary : AppColors.border,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active ? AppColors.goldPrimary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _itemsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.goldPrimary,
                    size: 15,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Items',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: controller.addItem,
                icon: const Icon(
                  Icons.add,
                  size: 14,
                  color: AppColors.goldPrimary,
                ),
                label: const Text(
                  'Add Item',
                  style: TextStyle(color: AppColors.goldPrimary, fontSize: 12),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => controller.items.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'Tap "Add Item" to add jewelry items',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
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

  Widget _paymentSection() {
    return Column(
      children: [
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.paymentMode.value,
            dropdownColor: AppColors.bgSecondary,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: _inputDeco('Payment Mode'),
            items:
                ['Cash', 'UPI', 'Card', 'RTGS/NEFT', 'Cheque', 'Split Payment']
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          m,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (v) {
              if (v != null) controller.paymentMode.value = v;
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _numFieldCtrl('Discount (₹)', controller.setDiscount),
            ),
            const SizedBox(width: 10),
            Expanded(child: _field('Digital Signature', _sigCtrl)),
          ],
        ),
      ],
    );
  }

  Widget _oldGoldSection() {
    final weightCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: _field(
            'Weight (g)',
            weightCtrl,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _numFieldCtrl('Value (₹)', (v) => controller.setOldGold(v)),
        ),
      ],
    );
  }

  Widget _notesSection() => _field('Notes (optional)', _notesCtrl, maxLines: 2);

  // ─── Helpers ───
  Widget _sectionCard(String title, IconData icon, Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.goldPrimary, size: 15),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            controller: ctrl,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _numFieldCtrl(String label, ValueChanged<String> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            onChanged: onChange,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _datePicker(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now().add(const Duration(days: 7)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              builder: (c, w) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.goldPrimary,
                  ),
                ),
                child: w!,
              ),
            );
            if (d != null) ctrl.text = d.toIso8601String().substring(0, 10);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textMuted,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  ctrl.text.isEmpty ? 'Select date' : ctrl.text,
                  style: TextStyle(
                    color: ctrl.text.isEmpty
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    filled: true,
    fillColor: AppColors.inputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.goldPrimary),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}
