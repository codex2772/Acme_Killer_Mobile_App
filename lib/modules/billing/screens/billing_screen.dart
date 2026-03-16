import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/billing_controller.dart';
import '../../../models/billing/invoice_model.dart';

class BillingScreen extends GetView<BillingController> {
  BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
            'Billing & Invoices',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.goldPrimary,
            indicatorWeight: 2,
            labelColor: AppColors.goldPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Invoices'),
              Tab(text: 'Estimates'),
              Tab(text: 'Credit Notes'),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            _InvoicesTab(controller: controller),
            _EstimatesTab(controller: controller),
            _CreditNotesTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INVOICES TAB
// ─────────────────────────────────────────────────────────────
class _InvoicesTab extends StatelessWidget {
  final BillingController controller;
  const _InvoicesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats row
        Obx(() => _statsRow(controller)),
        const SizedBox(height: 2),

        // Search + filter + new button
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
                      hintText: 'Search invoices...',
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
                    onChanged: (v) => controller.searchQuery.value = v,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.createInvoice),
                icon: const Icon(Icons.add, color: Colors.black, size: 16),
                label: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
              _pill(controller, 'all', 'All'),
              _pill(controller, 'paid', 'Paid'),
              _pill(controller, 'pending', 'Pending'),
              _pill(controller, 'partial', 'Partial'),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // List
        Expanded(
          child: Obx(() {
            final list = controller.filteredInvoices;
            if (list.isEmpty) return _empty('No invoices found');
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
              itemCount: list.length,
              itemBuilder: (_, i) => _BillingCard(
                bill: list[i],
                onTap: () =>
                    Get.toNamed(AppRoutes.invoiceDetail, arguments: list[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _statsRow(BillingController c) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
    child: Row(
      children: [
        _statChip('${c.invoices.length}', 'Invoices', AppColors.goldPrimary),
        _statChip('${c.paidCount}', 'Paid', AppColors.success),
        _statChip('${c.pendingCount}', 'Pending', AppColors.warning),
        _statChipWide(
          c.formatCurrency(c.totalRevenue),
          'Revenue',
          AppColors.info,
        ),
      ],
    ),
  );

  Widget _statChip(String v, String l, Color c) => Expanded(
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
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            l,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    ),
  );

  Widget _statChipWide(String v, String l, Color c) => Expanded(
    child: Container(
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
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    ),
  );

  Widget _pill(BillingController c, String val, String label) => Obx(() {
    final active = c.statusFilter.value == val;
    return GestureDetector(
      onTap: () => c.statusFilter.value = val,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.goldPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldPrimary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : AppColors.goldPrimary,
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  });

  Widget _empty(String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.receipt_long_outlined,
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
// ESTIMATES TAB
// ─────────────────────────────────────────────────────────────
class _EstimatesTab extends StatelessWidget {
  final BillingController controller;
  const _EstimatesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Quotations for potential orders',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.createEstimate),
                icon: const Icon(Icons.add, color: Colors.black, size: 16),
                label: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
            final list = controller.estimates;
            if (list.isEmpty)
              return const Center(
                child: Text(
                  'No estimates yet',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
              itemCount: list.length,
              itemBuilder: (_, i) => _BillingCard(
                bill: list[i],
                onTap: () =>
                    Get.toNamed(AppRoutes.invoiceDetail, arguments: list[i]),
                trailing: _convertBtn(list[i], controller),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _convertBtn(Invoice est, BillingController ctrl) {
    if (est.status == 'Converted') return const SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        ctrl.convertEstimate(est.id);
        Get.snackbar(
          'Converted',
          'Estimate ${est.id} converted to invoice!',
          backgroundColor: AppColors.bgCard,
          colorText: AppColors.textPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.goldPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4)),
        ),
        child: const Text(
          'Convert',
          style: TextStyle(
            color: AppColors.goldPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CREDIT NOTES TAB
// ─────────────────────────────────────────────────────────────
class _CreditNotesTab extends StatelessWidget {
  final BillingController controller;
  const _CreditNotesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Return / refund credit notes',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.createCreditNote),
                icon: const Icon(Icons.add, color: Colors.black, size: 16),
                label: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
            final list = controller.creditNotes;
            if (list.isEmpty)
              return const Center(
                child: Text(
                  'No credit notes yet',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
              itemCount: list.length,
              itemBuilder: (_, i) => _BillingCard(
                bill: list[i],
                amountColor: AppColors.error,
                onTap: () =>
                    Get.toNamed(AppRoutes.invoiceDetail, arguments: list[i]),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED BILLING CARD
// ─────────────────────────────────────────────────────────────
class _BillingCard extends StatelessWidget {
  final Invoice bill;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? amountColor;

  const _BillingCard({
    required this.bill,
    this.onTap,
    this.trailing,
    this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(bill.status);
    final typeColor = bill.type == BillingType.creditNote
        ? AppColors.error
        : bill.type == BillingType.estimate
        ? AppColors.warning
        : AppColors.info;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
                // Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.goldPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            bill.id,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              bill.typeLabel,
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bill.customer,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
                      bill.formattedTotal,
                      style: TextStyle(
                        color: amountColor ?? AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _statusBadge(bill.status, statusColor),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _meta(Icons.payment_outlined, bill.paymentMode),
                const SizedBox(width: 14),
                _meta(Icons.calendar_today_outlined, bill.formattedDate),
                if (bill.dueDate != null) ...[
                  const SizedBox(width: 14),
                  _meta(
                    Icons.schedule_outlined,
                    'Due ${_fmtDate(bill.dueDate!)}',
                    color: AppColors.warning,
                  ),
                ],
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),

            // Partial payment progress bar
            if (bill.status == 'Partial') ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paid: ${BillingController().formatCurrency(bill.paidAmount)}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Remaining: ${BillingController().formatCurrency(bill.remaining)}',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: bill.total > 0 ? bill.paidAmount / bill.total : 0,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.warning),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text, {Color? color}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: color ?? AppColors.textMuted),
      const SizedBox(width: 4),
      Text(
        text,
        style: TextStyle(color: color ?? AppColors.textMuted, fontSize: 11),
      ),
    ],
  );

  Widget _statusBadge(String s, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.35)),
    ),
    child: Text(
      s,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );

  Color _statusColor(String s) {
    switch (s) {
      case 'Paid':
        return AppColors.success;
      case 'Pending':
        return AppColors.warning;
      case 'Partial':
        return AppColors.info;
      case 'Cancelled':
        return AppColors.error;
      case 'Converted':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _fmtDate(String d) {
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
