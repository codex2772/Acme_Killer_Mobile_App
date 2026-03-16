import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/billing/invoice_model.dart';
import '../controllers/billing_controller.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Invoice inv = Get.arguments as Invoice;
    final ctrl = Get.find<BillingController>();

    final statusColor = _statusColor(inv.status);
    final typeColor = inv.type == BillingType.creditNote
        ? AppColors.error
        : inv.type == BillingType.estimate
            ? AppColors.warning
            : AppColors.info;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(inv.typeLabel,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppColors.textSecondary),
            onPressed: () => Get.snackbar('Print', 'Invoice sent to printer',
                backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12)),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () => Get.snackbar('Share', 'Invoice details copied!',
                backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12)),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(inv.typeLabel, style: const TextStyle(
                            color: AppColors.goldPrimary, fontSize: 12,
                            fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(inv.id, style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 20,
                            fontWeight: FontWeight.bold)),
                      ]),
                      _statusBadge(inv.status, statusColor, large: true),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 20),
                  _metaGrid(inv),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Items ──
            _sectionCard('Items', Icons.inventory_2_outlined, _itemsTable(inv)),

            const SizedBox(height: 14),

            // ── Summary ──
            _summaryCard(inv),

            const SizedBox(height: 14),

            // ── Notes ──
            if (inv.notes.isNotEmpty) ...[
              _sectionCard('Notes', Icons.notes_outlined, Text(inv.notes,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5))),
              const SizedBox(height: 14),
            ],

            // ── Payment history ──
            if (inv.payments.isNotEmpty) ...[
              _sectionCard('Payment History', Icons.payment_outlined, Column(
                children: inv.payments.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.success, size: 14),
                        const SizedBox(width: 8),
                        Text(p.mode, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                      ]),
                      Text('₹${p.amount}', style: const TextStyle(color: AppColors.success,
                          fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                )).toList(),
              )),
              const SizedBox(height: 14),
            ],

            // ── Action buttons ──
            _actionButtons(inv, ctrl),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _metaGrid(Invoice inv) {
    return Wrap(
      spacing: 16, runSpacing: 12,
      children: [
        _metaItem('Customer',    inv.customer),
        _metaItem('Date',        inv.formattedDate),
        _metaItem('Payment',     inv.paymentMode),
        _metaItem('Store',       (inv.store ?? '').replaceAll('Rajmahal Jewellers - ', '')),
        if (inv.dueDate != null) _metaItem('Due Date', _fmtDate(inv.dueDate!)),
        if ((inv.digitalSignature ?? '').isNotEmpty) _metaItem('Signed By', inv.digitalSignature!),
      ],
    );
  }

  Widget _metaItem(String label, String val) => SizedBox(
    width: 140,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      const SizedBox(height: 2),
      Text(val, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13,
          fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );

  Widget _itemsTable(Invoice inv) {
    if (inv.items.isEmpty) {
      return const Text('No item details', style: TextStyle(color: AppColors.textMuted));
    }
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            SizedBox(width: 24, child: Text('#', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
            Expanded(child: Text('Item', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
            Text('Amount', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ]),
        ),
        ...inv.items.asMap().entries.map((e) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
          child: Row(children: [
            SizedBox(width: 24, child: Text('${e.key + 1}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.value.name, style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                if (e.value.weight > 0)
                  Text('${e.value.weight}g @ ₹${e.value.rate.toStringAsFixed(0)}/g',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            )),
            Text(e.value.total > 0 ? '₹${e.value.total}' : '—',
                style: const TextStyle(color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ]),
        )),
      ],
    );
  }

  Widget _summaryCard(Invoice inv) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        _sumRow('Subtotal', '₹${inv.subtotal}'),
        _sumRow('GST (3%)', '₹${inv.gst}'),
        if (inv.discount > 0) _sumRow('Discount', '- ₹${inv.discount}'),
        if (inv.oldGoldAdjustment > 0) _sumRow('Old Gold Adj.', '- ₹${inv.oldGoldAdjustment}'),
        if (inv.roundOff != 0) _sumRow('Round Off', '${inv.roundOff > 0 ? '+' : ''}₹${inv.roundOff}'),
        const Divider(color: AppColors.border, height: 16),
        _sumRow('Total', inv.formattedTotal, bold: true, color: AppColors.goldPrimary, large: true),
        if (inv.status == 'Partial') ...[
          const SizedBox(height: 4),
          _sumRow('Paid', '₹${inv.paidAmount}', color: AppColors.success),
          _sumRow('Remaining', '₹${inv.remaining}', color: AppColors.warning),
        ],
      ]),
    );
  }

  Widget _sumRow(String l, String v, {bool bold = false, Color? color, bool large = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l, style: TextStyle(color: AppColors.textSecondary, fontSize: large ? 14 : 13)),
          Text(v, style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontSize: large ? 16 : 13)),
        ]),
      );

  Widget _actionButtons(Invoice inv, BillingController ctrl) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: [
        // Record payment (pending/partial invoices only)
        if ((inv.status == 'Pending' || inv.status == 'Partial') && inv.type == BillingType.invoice)
          ElevatedButton.icon(
            onPressed: () => _showRecordPayment(inv, ctrl),
            icon: const Icon(Icons.currency_rupee, size: 15, color: Colors.black),
            label: const Text('Record Payment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0),
          ),

        // Convert estimate to invoice
        if (inv.type == BillingType.estimate && inv.status != 'Converted')
          ElevatedButton.icon(
            onPressed: () {
              ctrl.convertEstimate(inv.id);
              Get.back();
              Get.snackbar('Converted', 'Estimate converted to invoice!',
                  backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                  snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
            },
            icon: const Icon(Icons.swap_horiz_rounded, size: 15, color: Colors.black),
            label: const Text('Convert to Invoice', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0),
          ),

        // Cancel invoice
        if (inv.type == BillingType.invoice && inv.status != 'Cancelled' && inv.status != 'Paid')
          OutlinedButton.icon(
            onPressed: () {
              Get.dialog(AlertDialog(
                backgroundColor: AppColors.bgSecondary,
                title: const Text('Cancel Invoice', style: TextStyle(color: AppColors.textPrimary)),
                content: Text('Cancel invoice ${inv.id}? This cannot be undone.',
                    style: const TextStyle(color: AppColors.textSecondary)),
                actions: [
                  TextButton(onPressed: () => Get.back(),
                      child: const Text('No', style: TextStyle(color: AppColors.textSecondary))),
                  ElevatedButton(
                    onPressed: () {
                      ctrl.cancelInvoice(inv.id);
                      Get.back(); Get.back();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    child: const Text('Cancel Invoice', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ));
            },
            icon: const Icon(Icons.cancel_outlined, size: 15, color: AppColors.error),
            label: const Text('Cancel Invoice', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
      ],
    );
  }

  void _showRecordPayment(Invoice inv, BillingController ctrl) {
    final amtCtrl = TextEditingController(text: '${inv.remaining}');
    final modeVal = 'Cash'.obs;
    final modes = ['Cash','UPI','Card','RTGS/NEFT','Cheque'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            const Text('Record Payment', style: TextStyle(color: AppColors.textPrimary,
                fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total: ₹${inv.total}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text('Remaining: ₹${inv.remaining}',
                  style: const TextStyle(color: AppColors.warning, fontSize: 12)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _bsField('Amount (₹)', amtCtrl, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: modeVal.value,
                  dropdownColor: AppColors.bgSecondary,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: _bsDeco('Payment Mode'),
                  items: modes.map((m) => DropdownMenuItem(value: m,
                      child: Text(m, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
                  onChanged: (v) { if (v != null) modeVal.value = v; },
                )),
              ),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final amt = int.tryParse(amtCtrl.text) ?? 0;
                  if (amt <= 0) return;
                  ctrl.recordPayment(inv.id, amt, modeVal.value);
                  Get.back();
                  Get.snackbar('Payment Recorded', '₹$amt recorded via ${modeVal.value}',
                      backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: const Text('Record Payment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bsField(String label, TextEditingController ctrl, {TextInputType? keyboardType}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: TextField(controller: ctrl, keyboardType: keyboardType,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11))),
        ),
      ]);

  InputDecoration _bsDeco(String label) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    filled: true, fillColor: AppColors.inputFill,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
  );

  Widget _sectionCard(String title, IconData icon, Widget child) => Container(
    padding: const EdgeInsets.all(16),
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

  Widget _statusBadge(String s, Color color, {bool large = false}) => Container(
    padding: EdgeInsets.symmetric(horizontal: large ? 14 : 8, vertical: large ? 6 : 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35))),
    child: Text(s, style: TextStyle(color: color, fontSize: large ? 12 : 10, fontWeight: FontWeight.w600)),
  );

  Color _statusColor(String s) {
    switch (s) {
      case 'Paid':      return AppColors.success;
      case 'Pending':   return AppColors.warning;
      case 'Partial':   return AppColors.info;
      case 'Cancelled': return AppColors.error;
      case 'Converted': return AppColors.textSecondary;
      default:          return AppColors.textSecondary;
    }
  }

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month-1]} ${dt.year}';
    } catch (_) { return d; }
  }
}
