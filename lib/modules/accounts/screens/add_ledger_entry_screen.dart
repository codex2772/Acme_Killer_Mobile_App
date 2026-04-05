import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/store_controller.dart';
import '../controllers/accounts_controller.dart';

class AddLedgerEntryScreen extends StatefulWidget {
  const AddLedgerEntryScreen({super.key});
  @override
  State<AddLedgerEntryScreen> createState() => _AddLedgerEntryScreenState();
}

class _AddLedgerEntryScreenState extends State<AddLedgerEntryScreen> {
  final _ctrl = Get.find<AccountsController>();

  final _partyCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );

  String _type = 'CR';
  String _category = '';
  String _mode = 'Cash';
  // mirrors Electron: storePickerHTML() in All Stores mode
  String? _selectedStoreName;
  int? _selectedStoreId;

  static const _modes = [
    'Cash',
    'UPI',
    'Card',
    'RTGS/NEFT',
    'Bank Transfer',
    'Cheque',
    'Online',
  ];
  static const _categories = ['', 'Sales', 'Purchase', ...kExpenseCategories];

  @override
  void initState() {
    super.initState();
    try {
      final store = Get.find<StoreController>();
      _selectedStoreName = store.selectedStoreName;
      _selectedStoreId = store.selectedStore.value?.id;
    } catch (_) {}
  }

  @override
  void dispose() {
    _partyCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final party = _partyCtrl.text.trim();
    final amount = int.tryParse(_amountCtrl.text) ?? 0;
    if (party.isEmpty || amount == 0) {
      Get.snackbar(
        'Error',
        'Party and amount are required',
        backgroundColor: AppColors.error.withOpacity(0.2),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    // mirrors Electron: require store selection in All Stores mode
    try {
      final storeCtrl = Get.find<StoreController>();
      if (storeCtrl.selectedStore.value == null &&
          storeCtrl.stores.length > 1 &&
          _selectedStoreId == null) {
        Get.snackbar(
          'Error',
          'Please select a store for this entry',
          backgroundColor: AppColors.error.withOpacity(0.2),
          colorText: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
        return;
      }
    } catch (_) {}

    _ctrl.addEntry(
      type: _type,
      date: _dateCtrl.text,
      party: party,
      amount: amount,
      mode: _mode,
      category: _category,
      note: _notesCtrl.text.trim(),
    );
    Get.back();
    Get.snackbar(
      'Entry Saved',
      '${_type == 'CR' ? '✅ Credit' : '🔴 Debit'} ₹$amount — $party',
      backgroundColor: AppColors.bgCard,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

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
          'Add Ledger Entry',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Store selector — mirrors Electron storePickerHTML() ──
          Builder(
            builder: (_) {
              try {
                final storeCtrl = Get.find<StoreController>();
                final isAllStores =
                    storeCtrl.selectedStore.value == null &&
                    storeCtrl.stores.length > 1;
                if (!isAllStores) return const SizedBox.shrink();
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.store_outlined,
                                color: AppColors.warning,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Select store for this entry',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
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
                                value: _selectedStoreId,
                                isExpanded: true,
                                dropdownColor: AppColors.bgSecondary,
                                hint: const Text(
                                  '— Select Store —',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                                items: storeCtrl.stores
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
                                  setState(() {
                                    _selectedStoreId = id;
                                    _selectedStoreName = storeCtrl.stores
                                        .firstWhereOrNull((s) => s.id == id)
                                        ?.name;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } catch (_) {
                return const SizedBox.shrink();
              }
            },
          ),

          // ── Type toggle ──
          _card(
            'Transaction Type',
            Icons.swap_horiz_rounded,
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _typeBtn('CR', 'Credit (CR)', AppColors.success),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _typeBtn('DR', 'Debit (DR)', AppColors.error),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Live indicator
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (_type == 'CR' ? AppColors.success : AppColors.error)
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          (_type == 'CR' ? AppColors.success : AppColors.error)
                              .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _type == 'CR'
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: _type == 'CR'
                            ? AppColors.success
                            : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _type == 'CR'
                            ? 'Credit — Money coming IN (sales, payments received)'
                            : 'Debit — Money going OUT (expenses, purchases)',
                        style: TextStyle(
                          color: _type == 'CR'
                              ? AppColors.success
                              : AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Entry details ──
          _card(
            'Entry Details',
            Icons.edit_note_outlined,
            Column(
              children: [
                _field(
                  _partyCtrl,
                  'Party / Description *',
                  hint: 'Customer name or expense description',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        _amountCtrl,
                        'Amount (₹) *',
                        hint: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _datePicker()),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Category & Payment ──
          _card(
            'Category & Payment',
            Icons.category_outlined,
            Column(
              children: [
                _dropdown(
                  'Category',
                  _categories,
                  _category.isEmpty ? '' : _category,
                  (v) => setState(() => _category = v ?? ''),
                  hintText: 'Select Category',
                ),
                const SizedBox(height: 10),
                _dropdown(
                  'Payment Mode',
                  _modes,
                  _mode,
                  (v) => setState(() => _mode = v ?? 'Cash'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Notes ──
          _card(
            'Notes (Optional)',
            Icons.notes_outlined,
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 2,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                decoration: const InputDecoration(
                  hintText: 'Transaction details...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check, size: 18, color: Colors.black),
                  label: const Text(
                    'Save Entry',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == 'CR'
                        ? AppColors.success
                        : AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Type button ──
  Widget _typeBtn(String type, String label, Color color) {
    final active = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : AppColors.inputFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? color : AppColors.border,
            width: active ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? color : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ── Section card ──
  Widget _card(String title, IconData icon, Widget child) => Container(
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
    TextEditingController ctrl,
    String label, {
    String? hint,
    TextInputType? keyboardType,
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
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String value,
    ValueChanged<String?> onChange, {
    String? hintText,
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.isEmpty ? null : value,
              isExpanded: true,
              dropdownColor: AppColors.bgSecondary,
              iconEnabledColor: AppColors.textSecondary,
              hint: hintText != null
                  ? Text(
                      hintText,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    )
                  : null,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              items: items
                  .map(
                    (i) => DropdownMenuItem(
                      value: i.isEmpty ? null : i,
                      child: Text(
                        i.isEmpty ? '— None —' : i,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _datePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
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
              initialDate: DateTime.tryParse(_dateCtrl.text) ?? DateTime.now(),
              firstDate: DateTime(2020),
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
            if (d != null)
              setState(
                () => _dateCtrl.text = d.toIso8601String().substring(0, 10),
              );
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
                  _dateCtrl.text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
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
}
