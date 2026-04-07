import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../modules/customers/controllers/customer_controller.dart';
import '../../../services/auth_service.dart';
import '../controllers/billing_controller.dart';
import '../widgets/billing_summary.dart';
import '../widgets/invoice_item_row.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});
  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  late final BillingController controller;
  late final CustomerController _custCtrl;

  final _dueDateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final RxString _invoiceType = 'tax'.obs;
  final RxBool _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BillingController>();
    _custCtrl = Get.find<CustomerController>();
    controller.clearBuilder();
  }

  @override
  void dispose() {
    _dueDateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  // SAVE INVOICE
  // ════════════════════════════════════════════════════════════════
  Future<void> _saveInvoice() async {
    final storeErr = controller.validateStoreSelection();
    if (storeErr != null) {
      _showError(storeErr);
      return;
    }
    if (controller.customer.value.isEmpty) {
      _showError('Please select a customer');
      return;
    }
    if (controller.items.isEmpty) {
      _showError('Add at least one item');
      return;
    }

    _isSubmitting.value = true;

    final splits = controller.splitPayments;
    final totalPaid = splits.fold<int>(0, (s, p) => s + p.amount);
    final isPartial = totalPaid > 0 && totalPaid < controller.grandTotal;
    final paymentStatus = totalPaid <= 0
        ? 'UNPAID'
        : (isPartial ? 'PARTIAL' : 'PAID');

    const payModeMap = {
      'Cash': 'CASH',
      'UPI': 'UPI',
      'Card': 'CARD',
      'RTGS/NEFT': 'BANK_TRANSFER',
      'Cheque': 'BANK_TRANSFER',
    };
    final primaryMode =
        payModeMap[splits.isNotEmpty ? splits[0].mode : 'Cash'] ?? 'CASH';

    final lineItems = controller.items.map((item) {
      final backendIntId =
          item.backendId; // int? — set when inventory item selected
      return {
        'name': item.name,
        'jewelryItemId': backendIntId,
        'weight': double.parse(item.weight.toStringAsFixed(3)),
        'rate': double.parse(item.rate.toStringAsFixed(2)),
        'purity': item.purity,
        'makingCharge': double.parse(item.making.toStringAsFixed(2)),
        'makingChargeType': 'PERCENTAGE',
        'amount': item.total,
        'hsn': '7113',
        'backendId': backendIntId,
      };
    }).toList();

    final auth = Get.find<AuthController>();
    if (!auth.isDemo.value) {
      final ok = await controller.createInvoiceViaApi(
        customerId: controller.customerId.value,
        customerName: controller.customer.value,
        total: controller.grandTotal,
        gstAmount: controller.gstAmount,
        discountAmount: controller.discount.value,
        paymentMode: primaryMode,
        paymentStatus: paymentStatus,
        lineItems: lineItems,
        dueDate: _dueDateCtrl.text.isEmpty ? null : _dueDateCtrl.text,
        notes: _notesCtrl.text,
      );
      _isSubmitting.value = false;
      if (ok) {
        await controller.restoreStoreContext();
        Get.back();
        Get.snackbar(
          'Invoice Created',
          'Invoice saved to server!',
          backgroundColor: AppColors.bgCard,
          colorText: AppColors.success,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
        return;
      } else {
        Get.snackbar(
          'API Error',
          'Saved locally — will sync later',
          backgroundColor: AppColors.bgCard,
          colorText: AppColors.warning,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
      }
    }

    final inv = controller.saveInvoice(
      dueDateStr: _dueDateCtrl.text.isEmpty ? null : _dueDateCtrl.text,
      notes: _notesCtrl.text,
    );
    _isSubmitting.value = false;
    await controller.restoreStoreContext();
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

  void _showError(String msg) => Get.snackbar(
    'Error',
    msg,
    backgroundColor: AppColors.error.withOpacity(0.2),
    colorText: AppColors.error,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
  );

  @override
  Widget build(BuildContext context) {
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
                  _storePicker(),
                  _sectionCard(
                    'Customer',
                    Icons.person_outline,
                    _customerSection(),
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    'Invoice Details',
                    Icons.info_outline,
                    _invoiceInfoSection(),
                  ),
                  const SizedBox(height: 12),
                  _itemsSection(),
                  const SizedBox(height: 12),
                  _sectionCard(
                    'Payment',
                    Icons.payment_outlined,
                    _paymentSection(),
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    'Old Gold Adjustment (Optional)',
                    Icons.repeat_rounded,
                    _oldGoldSection(),
                  ),
                  const SizedBox(height: 12),
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
            Row(
              children: [
                const Icon(
                  Icons.store_outlined,
                  color: AppColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Select store for this transaction',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.billingStore.value?.id,
                  dropdownColor: AppColors.bgSecondary,
                  isExpanded: true,
                  hint: const Text(
                    '— Choose Store —',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  items: controller.availableStores
                      .map(
                        (s) => DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(
                            s.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    final store = controller.availableStores.firstWhereOrNull(
                      (s) => s.id == id,
                    );
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

  // ── Customer section ──
  Widget _customerSection() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.customer.value.isEmpty
            ? null
            : controller.customer.value,
        dropdownColor: AppColors.bgSecondary,
        decoration: _inputDeco('Select Customer'),
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
          controller.customerId.value =
              cust?.backendId?.toString() ?? cust?.id ?? '';
        },
      ),
    );
  }

  // ── Invoice info section ──
  Widget _invoiceInfoSection() {
    return Column(
      children: [
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

  // ── Items section ──
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

  // ── Payment section ──
  Widget _paymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Discount + GST
        Row(
          children: [
            Expanded(
              child: _numFieldCtrl('Discount (₹)', controller.setDiscount),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _field(
                'GST (%)',
                TextEditingController(text: '${controller.gstRate.value}'),
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    controller.gstRate.value = int.tryParse(v) ?? 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payment Modes',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: controller.addSplitPayment,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.goldPrimary.withOpacity(0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 12, color: AppColors.goldPrimary),
                    SizedBox(width: 4),
                    Text(
                      'Add Mode',
                      style: TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Split rows — each is its own StatefulWidget with a stable controller
        Obx(
          () => Column(
            children: controller.splitPayments
                .asMap()
                .entries
                .map(
                  (e) => _SplitPaymentRow(
                    key: ValueKey('split_${e.key}'),
                    index: e.key,
                  ),
                )
                .toList(),
          ),
        ),

        // Balance bar
        const SizedBox(height: 10),
        Obx(() {
          final totalPaid = controller.splitPayments.fold<int>(
            0,
            (s, p) => s + p.amount,
          );
          final balance = controller.grandTotal - totalPaid;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: balance > 0
                  ? AppColors.warning.withOpacity(0.08)
                  : AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: balance > 0
                    ? AppColors.warning.withOpacity(0.3)
                    : AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.splitPayments.length} mode(s) • Paid ₹$totalPaid',
                  style: TextStyle(
                    color: balance > 0 ? AppColors.warning : AppColors.success,
                    fontSize: 12,
                  ),
                ),
                Text(
                  balance > 0 ? 'Balance: ₹$balance' : '✓ Fully Paid',
                  style: TextStyle(
                    color: balance > 0 ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Old gold section ──
  Widget _oldGoldSection() {
    final weightCtrl = TextEditingController();
    final RxString purity = '22K'.obs;
    return Column(
      children: [
        Row(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Purity',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: purity.value,
                          dropdownColor: AppColors.bgSecondary,
                          isExpanded: true,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                          items: ['24K', '22K', '18K', '14K']
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(
                                    p,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) purity.value = v;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _numFieldCtrl('Old Gold Value (₹)', (v) => controller.setOldGold(v)),
      ],
    );
  }

  Widget _notesSection() => _field('Notes (optional)', _notesCtrl, maxLines: 2);

  // ── Helpers ──
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
    ValueChanged<String>? onChanged,
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
            onChanged: onChanged,
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

  // Due date: StatefulBuilder so text updates without parent rebuild
  Widget _datePicker(String label, TextEditingController ctrl) {
    return StatefulBuilder(
      builder: (context, setLocal) => Column(
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
                context: context,
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
              if (d != null) {
                ctrl.text = d.toIso8601String().substring(0, 10);
                setLocal(() {});
              }
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
      ),
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

// ════════════════════════════════════════════════════════════════════
// _SplitPaymentRow — StatefulWidget
// TextEditingController created ONCE in initState.
// Typing a digit no longer resets the field because Obx rebuilds
// (triggered by grandTotal / splitPayments changes) don't recreate it.
// ValueKey('split_$index') ensures Flutter reuses the State correctly.
// ════════════════════════════════════════════════════════════════════
class _SplitPaymentRow extends StatefulWidget {
  final int index;
  const _SplitPaymentRow({required super.key, required this.index});
  @override
  State<_SplitPaymentRow> createState() => _SplitPaymentRowState();
}

class _SplitPaymentRowState extends State<_SplitPaymentRow> {
  late final BillingController ctrl;
  late final TextEditingController _amtCtrl;
  static const _modes = ['Cash', 'UPI', 'Card', 'RTGS/NEFT', 'Cheque'];

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<BillingController>();
    final initial = ctrl.splitPayments[widget.index].amount;
    _amtCtrl = TextEditingController(text: initial > 0 ? '$initial' : '');
  }

  @override
  void dispose() {
    _amtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.index >= ctrl.splitPayments.length)
        return const SizedBox.shrink();
      final split = ctrl.splitPayments[widget.index];

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Mode dropdown
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: split.mode,
                    dropdownColor: AppColors.bgSecondary,
                    isExpanded: true,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                    items: _modes
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null)
                        ctrl.updateSplitPayment(widget.index, mode: v);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Amount — stable controller, no flicker on any rebuild
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _amtCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  onChanged: (v) => ctrl.updateSplitPayment(
                    widget.index,
                    amount: int.tryParse(v) ?? 0,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Remove button
            if (ctrl.splitPayments.length > 1)
              GestureDetector(
                onTap: () => ctrl.removeSplitPayment(widget.index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.error,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
