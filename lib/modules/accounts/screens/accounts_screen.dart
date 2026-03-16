import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/accounts_controller.dart';

class AccountsScreen extends GetView<AccountsController> {
  AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
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
            'Accounts & Ledger',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.goldPrimary,
            indicatorWeight: 2,
            labelColor: AppColors.goldPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Ledger'),
              Tab(text: 'Expenses'),
              Tab(text: 'Receivables'),
              Tab(text: 'Suppliers'),
              Tab(text: 'Cash Register'),
            ],
          ),
        ),
        body: Column(
          children: [
            // ── Stats row ──
            Obx(() => _statsRow()),
            const SizedBox(height: 2),
            Expanded(
              child: TabBarView(
                children: [
                  _LedgerTab(controller: controller),
                  _ExpensesTab(controller: controller),
                  _ReceivablesTab(controller: controller),
                  _SuppliersTab(controller: controller),
                  _CashRegisterTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          _chip(
            controller.fmt(controller.totalCredit),
            'Credit',
            AppColors.success,
          ),
          _chip(
            controller.fmt(controller.totalDebit),
            'Debit',
            AppColors.error,
          ),
          _chip(
            controller.fmt(controller.totalReceivable),
            'Receivable',
            AppColors.info,
          ),
          _chip(
            controller.fmt(controller.totalPayable),
            'Payable',
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _chip(String v, String l, Color c) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            v,
            style: TextStyle(
              color: c,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            l,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// LEDGER TAB
// ─────────────────────────────────────────────────────────────
class _LedgerTab extends StatelessWidget {
  final AccountsController controller;
  const _LedgerTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                    ),
                    onChanged: (v) => controller.ledgerSearch.value = v,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.addLedgerEntry),
                icon: const Icon(Icons.add, size: 15, color: Colors.black),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Filter pills
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              _pill(controller, 'ledger', 'all', 'All'),
              _pill(controller, 'ledger', 'cr', 'Credit'),
              _pill(controller, 'ledger', 'dr', 'Debit'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Tally export button
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => Get.snackbar(
                  'Export',
                  'Tally export downloaded!',
                  backgroundColor: AppColors.bgCard,
                  colorText: AppColors.textPrimary,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(12),
                ),
                icon: const Icon(
                  Icons.download_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                label: const Text(
                  'Tally Export',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final list = controller.filteredLedger;
            if (list.isEmpty) return _empty('No transactions found');
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
              itemCount: list.length,
              itemBuilder: (_, i) => _LedgerRow(entry: list[i]),
            );
          }),
        ),
      ],
    );
  }

  Widget _pill(AccountsController c, String tab, String val, String label) {
    return Obx(() {
      final active = c.ledgerFilter.value == val;
      final color = val == 'cr'
          ? AppColors.success
          : val == 'dr'
          ? AppColors.error
          : AppColors.goldPrimary;
      return GestureDetector(
        onTap: () => c.ledgerFilter.value = val,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : color,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Widget _empty(String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.account_balance_wallet_outlined,
          color: AppColors.textMuted,
          size: 52,
        ),
        const SizedBox(height: 12),
        Text(msg, style: const TextStyle(color: AppColors.textMuted)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// LEDGER ROW CARD
// ─────────────────────────────────────────────────────────────
class _LedgerRow extends StatelessWidget {
  final LedgerEntry entry;
  const _LedgerRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isCR = entry.type == 'CR';
    final typeColor = isCR ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: typeColor, width: 3)),
      ),
      child: Row(
        children: [
          // Type badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              entry.type,
              style: TextStyle(
                color: typeColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.party,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (entry.category.isNotEmpty) ...[
                      _badge(entry.category),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      entry.mode,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _fmt(entry.date),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (entry.note.isNotEmpty)
                  Text(
                    entry.note,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.formattedAmount,
                style: TextStyle(
                  color: typeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                entry.id,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(
      t,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
    ),
  );

  String _fmt(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${m[dt.month - 1]}';
    } catch (_) {
      return d;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// EXPENSES TAB
// ─────────────────────────────────────────────────────────────
class _ExpensesTab extends StatelessWidget {
  final AccountsController controller;
  const _ExpensesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Track & manage expenses',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.addLedgerEntry),
                icon: const Icon(Icons.add, size: 15, color: Colors.black),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        // Category pills
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              _expPill(controller, 'all', 'All'),
              ...kExpenseCategories
                  .take(6)
                  .map((c) => _expPill(controller, c, c)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Obx(() {
            final list = controller.filteredExpenses;
            final total = list.fold(0, (s, e) => s + e.amount);
            if (list.isEmpty)
              return const Center(
                child: Text(
                  'No expenses',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            return Column(
              children: [
                // Total bar
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Expenses',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        controller.fmt(total),
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
                    itemCount: list.length,
                    itemBuilder: (_, i) =>
                        _ExpenseRow(expense: list[i], controller: controller),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _expPill(AccountsController c, String val, String label) => Obx(() {
    final active = c.expenseFilter.value == val;
    return GestureDetector(
      onTap: () => c.expenseFilter.value = val,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.warning : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warning),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : AppColors.warning,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  });
}

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  final AccountsController controller;
  const _ExpenseRow({required this.expense, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.trending_down_rounded,
              color: AppColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _badge(expense.category),
                    const SizedBox(width: 8),
                    Text(
                      expense.mode,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _fmt(expense.date),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                expense.formattedAmount,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBtn(
                    Icons.edit_outlined,
                    AppColors.info,
                    () => _editDialog(context),
                  ),
                  const SizedBox(width: 4),
                  _iconBtn(
                    Icons.delete_outline,
                    AppColors.error,
                    () => _deleteConfirm(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editDialog(BuildContext context) {
    final catCtrl = TextEditingController(text: expense.category);
    final descCtrl = TextEditingController(text: expense.description);
    final amtCtrl = TextEditingController(text: expense.amount.toString());
    String mode = expense.mode;

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          'Edit Expense',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: StatefulBuilder(
          builder: (_, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dlgField(catCtrl, 'Category'),
              _dlgField(descCtrl, 'Description'),
              _dlgField(
                amtCtrl,
                'Amount (₹)',
                keyboardType: TextInputType.number,
              ),
              _dlgDrop(
                'Mode',
                ['Cash', 'UPI', 'Card', 'Bank Transfer', 'Cheque', 'Online'],
                mode,
                (v) => setState(() => mode = v!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateExpense(
                expense.id,
                category: catCtrl.text,
                description: descCtrl.text,
                amount: int.tryParse(amtCtrl.text) ?? expense.amount,
                mode: mode,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _deleteConfirm(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          'Delete Expense',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Delete "${expense.description}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteExpense(expense.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dlgField(
    TextEditingController c,
    String label, {
    TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: c,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    ),
  );

  Widget _dlgDrop(
    String label,
    List<String> items,
    String val,
    ValueChanged<String?> onChange,
  ) => DropdownButtonFormField<String>(
    value: val,
    dropdownColor: AppColors.bgSecondary,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    ),
    items: items
        .map(
          (i) => DropdownMenuItem(
            value: i,
            child: Text(
              i,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        )
        .toList(),
    onChanged: onChange,
  );

  Widget _badge(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      t,
      style: const TextStyle(
        color: AppColors.warning,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
      );

  String _fmt(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${m[dt.month - 1]}';
    } catch (_) {
      return d;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// RECEIVABLES TAB
// ─────────────────────────────────────────────────────────────
class _ReceivablesTab extends StatelessWidget {
  final AccountsController controller;
  const _ReceivablesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Pull from BillingController
    List<Map<String, dynamic>> receivables = [];
    try {
      final billing = Get.find<dynamic>(); // fallback
    } catch (_) {}

    // Demo receivables (matching billing demo data)
    receivables = [
      {
        'id': 'BIL003',
        'customer': 'Anita Desai',
        'total': '₹5.98L',
        'totalNum': 598500,
        'dueDate': '2026-04-07',
        'status': 'Partial',
      },
      {
        'id': 'BIL004',
        'customer': 'Vikram Singh',
        'total': '₹52,000',
        'totalNum': 52000,
        'dueDate': '2026-03-20',
        'status': 'Pending',
      },
      {
        'id': 'BIL005',
        'customer': 'Meera Patel',
        'total': '₹1.98L',
        'totalNum': 198000,
        'dueDate': null,
        'status': 'Pending',
      },
    ];

    final totalRec = receivables.fold<int>(
      0,
      (s, r) => s + (r['totalNum'] as int),
    );

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Receivable',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Text(
                controller.fmt(totalRec),
                style: const TextStyle(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if (receivables.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 40,
                ),
                SizedBox(height: 8),
                Text(
                  'No outstanding receivables!',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          ...receivables.map((r) => _RecRow(r: r, ctrl: controller)),
      ],
    );
  }
}

class _RecRow extends StatelessWidget {
  final Map<String, dynamic> r;
  final AccountsController ctrl;
  const _RecRow({required this.r, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final status = r['status'] as String;
    final statusColor = status == 'Partial'
        ? AppColors.info
        : AppColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.account_balance_outlined,
              color: AppColors.info,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['customer'] as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      r['id'] as String,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    if (r['dueDate'] != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.schedule_outlined,
                        size: 11,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Due ${r['dueDate']}',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                r['total'] as String,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => Get.snackbar(
                      'Reminder',
                      'Payment reminder sent!',
                      backgroundColor: AppColors.bgCard,
                      colorText: AppColors.textPrimary,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        size: 13,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SUPPLIERS TAB
// ─────────────────────────────────────────────────────────────
class _SuppliersTab extends StatelessWidget {
  final AccountsController controller;
  const _SuppliersTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manage gold, diamond & silver suppliers',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddSupplier(context),
                icon: const Icon(Icons.add, size: 15, color: Colors.black),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final list = controller.allSuppliers;
            if (list.isEmpty)
              return const Center(
                child: Text(
                  'No suppliers added',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
              itemCount: list.length,
              itemBuilder: (_, i) =>
                  _SupplierCard(supplier: list[i], controller: controller),
            );
          }),
        ),
      ],
    );
  }

  void _showAddSupplier(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final gstCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final metals = <String>['Gold'].obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          'Add Supplier',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dlgField(nameCtrl, 'Supplier Name *'),
              _dlgField(
                phoneCtrl,
                'Phone *',
                keyboardType: TextInputType.phone,
              ),
              _dlgField(
                emailCtrl,
                'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              _dlgField(gstCtrl, 'GSTIN'),
              _dlgField(cityCtrl, 'City'),
              _dlgField(addrCtrl, 'Address'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Metals Supplied',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: ['Gold', 'Silver', 'Diamond', 'Platinum', 'Stones']
                      .map((m) {
                        final sel = metals.contains(m);
                        return FilterChip(
                          label: Text(
                            m,
                            style: TextStyle(
                              color: sel
                                  ? Colors.black
                                  : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          selected: sel,
                          onSelected: (v) =>
                              v ? metals.add(m) : metals.remove(m),
                          selectedColor: AppColors.goldPrimary,
                          backgroundColor: AppColors.bgCard,
                          checkmarkColor: Colors.black,
                          side: const BorderSide(color: AppColors.border),
                        );
                      })
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final newId =
                  'SUP${(controller.suppliers.length + 1).toString().padLeft(3, '0')}';
              controller.addSupplier(
                Supplier(
                  id: newId,
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                  address: addrCtrl.text.trim(),
                  gst: gstCtrl.text.trim(),
                  metals: List.from(metals),
                  status: 'Active',
                  store: 'Rajmahal Jewellers - Main',
                  totalBusinessNum: 0,
                  balanceNum: 0,
                ),
              );
              Get.back();
              Get.snackbar(
                'Supplier Added',
                '"${nameCtrl.text.trim()}" added!',
                backgroundColor: AppColors.bgCard,
                colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
            ),
            child: const Text(
              'Add Supplier',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dlgField(
    TextEditingController c,
    String label, {
    TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: c,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    ),
  );
}

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final AccountsController controller;
  const _SupplierCard({required this.supplier, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isActive = supplier.status == 'Active';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  supplier.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _badge(
                          isActive ? 'Active' : 'Inactive',
                          isActive ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        ...supplier.metals.map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _badge(m, AppColors.goldPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    supplier.totalBusinessFormatted,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    supplier.balanceFormatted,
                    style: TextStyle(
                      color: supplier.balanceNum < 0
                          ? AppColors.error
                          : AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _meta(Icons.phone_outlined, supplier.phone),
              const SizedBox(width: 14),
              _meta(Icons.location_on_outlined, supplier.city),
              const SizedBox(width: 14),
              _meta(Icons.receipt_outlined, supplier.gst),
              const Spacer(),
              // Edit
              GestureDetector(
                onTap: () => _showEdit(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppColors.info,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Delete
              GestureDetector(
                onTap: () => Get.dialog(
                  AlertDialog(
                    backgroundColor: AppColors.bgSecondary,
                    title: const Text(
                      'Delete Supplier',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    content: Text(
                      'Delete "${supplier.name}"?',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.deleteSupplier(supplier.id);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 14,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEdit(BuildContext context) {
    final nameCtrl = TextEditingController(text: supplier.name);
    final phoneCtrl = TextEditingController(text: supplier.phone);
    final emailCtrl = TextEditingController(text: supplier.email);
    final gstCtrl = TextEditingController(text: supplier.gst);
    final cityCtrl = TextEditingController(text: supplier.city);
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          'Edit Supplier',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dlgField(nameCtrl, 'Name *'),
            _dlgField(phoneCtrl, 'Phone'),
            _dlgField(emailCtrl, 'Email'),
            _dlgField(gstCtrl, 'GSTIN'),
            _dlgField(cityCtrl, 'City'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateSupplier(
                supplier.id,
                name: nameCtrl.text,
                phone: phoneCtrl.text,
                email: emailCtrl.text,
                gst: gstCtrl.text,
                city: cityCtrl.text,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _badge(String t, Color c) => Container(
    margin: const EdgeInsets.only(right: 4),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: c.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      t,
      style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w500),
    ),
  );

  Widget _meta(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );

  Widget _dlgField(TextEditingController c, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: c,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// CASH REGISTER TAB
// ─────────────────────────────────────────────────────────────
class _CashRegisterTab extends StatelessWidget {
  final AccountsController controller;
  const _CashRegisterTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final open = controller.openRegister;
      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Open register banner
          if (open != null) ...[
            _openBanner(open, context),
            const SizedBox(height: 14),
          ],

          // Header + button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Cash Register',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => open != null
                    ? _closeDialog(context, open)
                    : _openDialog(context),
                icon: Icon(
                  open != null ? Icons.lock_outline : Icons.add,
                  size: 15,
                  color: Colors.black,
                ),
                label: Text(
                  open != null ? 'Close Register' : 'Open Register',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Register history
          ...controller.cashRegister.map(
            (cr) => _CashRegRow(cr: cr, ctrl: controller),
          ),
        ],
      );
    });
  }

  Widget _openBanner(CashRegisterEntry open, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: AppColors.success, size: 8),
              const SizedBox(width: 6),
              const Text(
                'Register Open — Today',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _cashStat(
                'Opening',
                open.fmt(open.openingBalance),
                AppColors.info,
              ),
              _cashStat('Cash In', open.fmt(open.cashIn), AppColors.success),
              _cashStat('Cash Out', open.fmt(open.cashOut), AppColors.error),
              _cashStat(
                'Expected',
                open.fmt(open.expectedClosing),
                AppColors.goldPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cashStat(String l, String v, Color c) => Expanded(
    child: Column(
      children: [
        Text(
          v,
          style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          l,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    ),
  );

  void _openDialog(BuildContext context) {
    final ctrl = TextEditingController(text: '50000');
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          'Open Cash Register',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opening Balance (₹)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.openCashRegister(int.tryParse(ctrl.text) ?? 0);
              Get.back();
              Get.snackbar(
                'Register Opened',
                'Cash register opened!',
                backgroundColor: AppColors.bgCard,
                colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
            ),
            child: const Text(
              'Open Register',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _closeDialog(BuildContext context, CashRegisterEntry open) {
    final ctrl = TextEditingController(text: '${open.expectedClosing}');
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          'Close Cash Register',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sumRow('Opening', open.fmt(open.openingBalance)),
            _sumRow('Cash In', open.fmt(open.cashIn), color: AppColors.success),
            _sumRow('Cash Out', open.fmt(open.cashOut), color: AppColors.error),
            _sumRow('Expected', open.fmt(open.expectedClosing), bold: true),
            const SizedBox(height: 10),
            const Text(
              'Actual Cash Count (₹)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final actual = int.tryParse(ctrl.text) ?? open.expectedClosing;
              controller.closeCashRegister(open.id, actual);
              Get.back();
              final diff = actual - open.expectedClosing;
              Get.snackbar(
                'Register Closed',
                diff == 0
                    ? 'Cash balanced!'
                    : '${diff > 0 ? "Excess" : "Shortage"}: ${open.fmt(diff.abs())}',
                backgroundColor: AppColors.bgCard,
                colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
            ),
            child: const Text(
              'Close Register',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sumRow(String l, String v, {Color? color, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            Text(
              v,
              style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
}

class _CashRegRow extends StatelessWidget {
  final CashRegisterEntry cr;
  final AccountsController ctrl;
  const _CashRegRow({required this.cr, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isClosed = cr.status == 'Closed';
    final statusColor = isClosed ? AppColors.success : AppColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                cr.id,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _fmt(cr.date),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              _statusBadge(cr.status, statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _stat('Opening', cr.fmt(cr.openingBalance), AppColors.info),
              _stat('Cash In', cr.fmt(cr.cashIn), AppColors.success),
              _stat('Cash Out', cr.fmt(cr.cashOut), AppColors.error),
              _stat(
                'Closing',
                isClosed ? cr.fmt(cr.closingBalance) : '—',
                AppColors.goldPrimary,
              ),
            ],
          ),
          if (!isClosed) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ctrl.closeCashRegister(cr.id, cr.expectedClosing);
                  Get.snackbar(
                    'Closed',
                    'Register ${cr.id} closed!',
                    backgroundColor: AppColors.bgCard,
                    colorText: AppColors.textPrimary,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(12),
                  );
                },
                icon: const Icon(
                  Icons.lock_outline,
                  size: 14,
                  color: AppColors.goldPrimary,
                ),
                label: const Text(
                  'Close Register',
                  style: TextStyle(color: AppColors.goldPrimary, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.goldPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
          if (isClosed && cr.closedBy.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Closed by ${cr.closedBy}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String l, String v, Color c) => Expanded(
    child: Column(
      children: [
        Text(
          v,
          style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          l,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    ),
  );

  Widget _statusBadge(String s, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withOpacity(0.35)),
    ),
    child: Text(
      s,
      style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );

  String _fmt(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return d;
    }
  }
}
