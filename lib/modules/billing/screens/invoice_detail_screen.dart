import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../models/billing/invoice_model.dart';
import '../controllers/billing_controller.dart';
import '../widgets/billing_summary.dart'; // for numberToWords

// ════════════════════════════════════════════════════════════════════
// InvoiceDetailScreen — FIXED
//
// Changes vs previous build:
//  1. Print preview bottom sheet (mirrors Electron printInvoice())
//  2. CGST/SGST split in summary
//  3. Amount in words (Indian format) — reuses numberToWords()
//  4. Record payment → calls recordPaymentViaApi() first
//  5. Convert estimate → calls convertEstimateViaApi() first
//  6. Cancel invoice → calls cancelInvoiceViaApi() first
//  7. Split payment history display
// ════════════════════════════════════════════════════════════════════
class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Invoice inv = Get.arguments as Invoice;
    final ctrl = Get.find<BillingController>();
    final statusColor = _statusColor(inv.status);

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
          // ── Print preview (mirrors Electron printInvoice()) ──
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppColors.textSecondary),
            onPressed: () => _showPrintPreview(context, inv),
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
            _headerCard(inv, statusColor),
            const SizedBox(height: 14),
            _sectionCard('Items', Icons.inventory_2_outlined, _itemsTable(inv)),
            const SizedBox(height: 14),
            _summaryCard(inv),
            const SizedBox(height: 14),
            if (inv.notes.isNotEmpty) ...[
              _sectionCard('Notes', Icons.notes_outlined, Text(inv.notes,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5))),
              const SizedBox(height: 14),
            ],
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
            _actionButtons(inv, ctrl),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // HEADER CARD
  // ════════════════════════════════════════════════════════════════
  Widget _headerCard(Invoice inv, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(inv.typeLabel, style: const TextStyle(
                color: AppColors.goldPrimary, fontSize: 12,
                fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(inv.id, style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          _statusBadge(inv.status, statusColor, large: true),
        ]),
        const Divider(color: AppColors.border, height: 20),
        _metaGrid(inv),
      ]),
    );
  }

  Widget _metaGrid(Invoice inv) {
    return Wrap(spacing: 16, runSpacing: 12, children: [
      _metaItem('Customer', inv.customer),
      _metaItem('Date', inv.formattedDate),
      _metaItem('Payment', inv.paymentMode),
      _metaItem('Store', (inv.store ?? '').replaceAll('Rajmahal Jewellers - ', '')),
      if (inv.dueDate != null) _metaItem('Due Date', _fmtDate(inv.dueDate!)),
      if ((inv.digitalSignature ?? '').isNotEmpty) _metaItem('Signed By', inv.digitalSignature!),
    ]);
  }

  Widget _metaItem(String label, String val) => SizedBox(width: 140,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      const SizedBox(height: 2),
      Text(val, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13,
          fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );

  // ════════════════════════════════════════════════════════════════
  // ITEMS TABLE
  // ════════════════════════════════════════════════════════════════
  Widget _itemsTable(Invoice inv) {
    if (inv.items.isEmpty) {
      return const Text('No item details', style: TextStyle(color: AppColors.textMuted));
    }
    return Column(children: [
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
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.value.name, style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            if (e.value.weight > 0)
              Text('${e.value.weight}g @ ₹${e.value.rate.toStringAsFixed(0)}/g  ·  ${e.value.purity}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
          Text(e.value.total > 0 ? '₹${e.value.total}' : '—',
              style: const TextStyle(color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500, fontSize: 13)),
        ]),
      )),
    ]);
  }

  // ════════════════════════════════════════════════════════════════
  // SUMMARY CARD — with CGST/SGST + Amount in Words
  // ════════════════════════════════════════════════════════════════
  Widget _summaryCard(Invoice inv) {
    // ── GST split: floor/remainder so CGST+SGST always = total GST ──
    final cgst = inv.gst ~/ 2;
    final sgst = inv.gst - cgst;
    final gstRate = inv.gst > 0 && inv.subtotal > 0
        ? (inv.gst / inv.subtotal * 100).round()
        : 3;
    final halfRate = gstRate / 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
      child: Column(children: [
        _sumRow('Subtotal', '₹${inv.subtotal}'),
        _sumRow('CGST (${halfRate.toStringAsFixed(1)}%)', '₹$cgst'),
        _sumRow('SGST (${halfRate.toStringAsFixed(1)}%)', '₹$sgst'),
        if (inv.discount > 0) _sumRow('Discount', '- ₹${inv.discount}'),
        if (inv.oldGoldAdjustment > 0) _sumRow('Old Gold Adj.', '- ₹${inv.oldGoldAdjustment}'),
        if (inv.roundOff != 0) _sumRow('Round Off', '${inv.roundOff > 0 ? '+' : ''}₹${inv.roundOff}'),
        const Divider(color: AppColors.border, height: 16),
        _sumRow('Total', '₹${inv.total}', bold: true, color: AppColors.goldPrimary, large: true),

        // ── Amount in Words ──
        if (inv.total > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(numberToWords(inv.total),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center),
          ),

        if (inv.status == 'Partial') ...[
          const SizedBox(height: 8),
          _sumRow('Paid', '₹${inv.paidAmount}', color: AppColors.success),
          _sumRow('Remaining', '₹${inv.remaining}', color: AppColors.warning),
        ],
      ]),
    );
  }

  Widget _sumRow(String l, String v, {bool bold = false, Color? color, bool large = false}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l, style: TextStyle(color: AppColors.textSecondary, fontSize: large ? 14 : 13)),
          Text(v, style: TextStyle(color: color ?? AppColors.textPrimary,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500, fontSize: large ? 16 : 13)),
        ]));

  // ════════════════════════════════════════════════════════════════
  // ACTION BUTTONS — all API-bound
  // ════════════════════════════════════════════════════════════════
  Widget _actionButtons(Invoice inv, BillingController ctrl) {
    final auth = Get.find<AuthController>();
    final isLive = !auth.isDemo.value;

    return Wrap(spacing: 10, runSpacing: 10, children: [
      // Record payment
      if ((inv.status == 'Pending' || inv.status == 'Partial') && inv.type == BillingType.invoice)
        ElevatedButton.icon(
          onPressed: () => _showRecordPayment(inv, ctrl, isLive),
          icon: const Icon(Icons.currency_rupee, size: 15, color: Colors.black),
          label: const Text('Record Payment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
        ),

      // Convert estimate
      if (inv.type == BillingType.estimate && inv.status != 'Converted')
        ElevatedButton.icon(
          onPressed: () async {
            if (isLive && inv.backendId != null) {
              final ok = await ctrl.convertEstimateViaApi(inv.backendId);
              if (ok) { Get.back(); _ok('Estimate converted to invoice!'); return; }
            }
            ctrl.convertEstimate(inv.id);
            Get.back(); _ok('Estimate converted to invoice!');
          },
          icon: const Icon(Icons.swap_horiz_rounded, size: 15, color: Colors.black),
          label: const Text('Convert to Invoice', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
        ),

      // Cancel invoice
      if (inv.type == BillingType.invoice && inv.status != 'Cancelled' && inv.status != 'Paid')
        OutlinedButton.icon(
          onPressed: () => _showCancelDialog(inv, ctrl, isLive),
          icon: const Icon(Icons.cancel_outlined, size: 15, color: AppColors.error),
          label: const Text('Cancel Invoice', style: TextStyle(color: AppColors.error)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
    ]);
  }

  // ════════════════════════════════════════════════════════════════
  // RECORD PAYMENT — API first, local fallback
  // ════════════════════════════════════════════════════════════════
  void _showRecordPayment(Invoice inv, BillingController ctrl, bool isLive) {
    final amtCtrl = TextEditingController(text: '${inv.remaining}');
    final modeVal = 'Cash'.obs;
    final modes = ['Cash','UPI','Card','RTGS/NEFT','Cheque'];
    final isLoading = false.obs;

    Get.bottomSheet(Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          Expanded(child: Obx(() => DropdownButtonFormField<String>(
            value: modeVal.value, dropdownColor: AppColors.bgSecondary,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: _bsDeco('Payment Mode'),
            items: modes.map((m) => DropdownMenuItem(value: m,
                child: Text(m, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
            onChanged: (v) { if (v != null) modeVal.value = v; },
          ))),
        ]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 50,
          child: Obx(() => ElevatedButton(
            onPressed: isLoading.value ? null : () async {
              final amt = int.tryParse(amtCtrl.text) ?? 0;
              if (amt <= 0) return;
              isLoading.value = true;

              // ── API first ──
              if (isLive && inv.backendId != null) {
                final ok = await ctrl.recordPaymentViaApi(inv.backendId, amt, modeVal.value);
                if (ok) {
                  Get.back(); _ok('₹$amt recorded via ${modeVal.value}');
                  isLoading.value = false; return;
                }
              }

              // ── Local fallback ──
              ctrl.recordPayment(inv.id, amt, modeVal.value);
              isLoading.value = false;
              Get.back(); _ok('₹$amt recorded via ${modeVal.value}');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary,
                disabledBackgroundColor: AppColors.goldPrimary.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: isLoading.value
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Text('Record Payment',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )),
        ),
      ]),
    ));
  }

  // ════════════════════════════════════════════════════════════════
  // CANCEL DIALOG — API first
  // ════════════════════════════════════════════════════════════════
  void _showCancelDialog(Invoice inv, BillingController ctrl, bool isLive) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      title: const Text('Cancel Invoice', style: TextStyle(color: AppColors.textPrimary)),
      content: Text('Cancel invoice ${inv.id}? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Get.back(),
            child: const Text('No', style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () async {
            if (isLive && inv.backendId != null) {
              await ctrl.cancelInvoiceViaApi(inv.backendId);
            } else {
              ctrl.cancelInvoice(inv.id);
            }
            Get.back(); Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Cancel Invoice', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  // ════════════════════════════════════════════════════════════════
  // PRINT PREVIEW — mirrors Electron printInvoice()
  // Full invoice layout as a bottom sheet
  // ════════════════════════════════════════════════════════════════
  void _showPrintPreview(BuildContext context, Invoice inv) {
    // ── GST split: floor/remainder so they always sum to exact total ──
    final cgst = inv.gst ~/ 2;
    final sgst = inv.gst - cgst;
    final gstRate = inv.gst > 0 && inv.subtotal > 0
        ? (inv.gst / inv.subtotal * 100).round() : 3;
    final halfRate = gstRate / 2;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          // ── Top bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Print Preview — ${inv.typeLabel} ${inv.id}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Row(children: [
                TextButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.snackbar('Print', 'Sending to printer...',
                        backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
                  },
                  icon: const Icon(Icons.print_outlined, size: 16, color: AppColors.goldPrimary),
                  label: const Text('Print', style: TextStyle(color: AppColors.goldPrimary, fontSize: 12)),
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Get.back()),
              ]),
            ]),
          ),

          // ── Invoice content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Business header
                Center(child: Column(children: [
                  const Text('JewelERP', style: TextStyle(
                      color: Color(0xFF1A1A2E), fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('Fine Jewellery Since 1985',
                      style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 6),
                  Text('GSTIN: 27AABCU9603R1ZM',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                ])),
                const SizedBox(height: 16),

                // Invoice type + number
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(inv.typeLabel.toUpperCase(),
                        style: TextStyle(color: const Color(0xFFD4AF37), fontSize: 14,
                            fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(inv.id, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 18,
                        fontWeight: FontWeight.bold)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('Date: ${inv.formattedDate}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
                    if (inv.dueDate != null)
                      Text('Due: ${_fmtDate(inv.dueDate!)}',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
                    Text('Store: ${(inv.store ?? "").replaceAll("Rajmahal Jewellers - ", "")}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
                  ]),
                ]),

                const Divider(height: 24, color: Color(0xFFE0E0E0)),

                // Bill To
                Text('BILL TO', style: TextStyle(color: Colors.grey.shade500, fontSize: 10,
                    fontWeight: FontWeight.w600, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(inv.customer, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14,
                    fontWeight: FontWeight.w600)),

                const SizedBox(height: 16),

                // Items table
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(4)),
                  child: Column(children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      color: const Color(0xFFF5F5F5),
                      child: Row(children: [
                        const SizedBox(width: 24, child: Text('#', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF666666)))),
                        const Expanded(child: Text('Description', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF666666)))),
                        const SizedBox(width: 50, child: Text('Wt(g)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF666666)))),
                        const SizedBox(width: 60, child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF666666)))),
                        const SizedBox(width: 70, child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF666666)))),
                      ]),
                    ),
                    ...inv.items.asMap().entries.map((e) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: const Color(0xFFE0E0E0).withOpacity(0.5)))),
                      child: Row(children: [
                        SizedBox(width: 24, child: Text('${e.key + 1}', style: const TextStyle(fontSize: 11, color: Color(0xFF333333)))),
                        Expanded(child: Text(e.value.name, style: const TextStyle(fontSize: 11, color: Color(0xFF333333)))),
                        SizedBox(width: 50, child: Text(e.value.weight > 0 ? '${e.value.weight}' : '—', style: const TextStyle(fontSize: 11, color: Color(0xFF333333)))),
                        SizedBox(width: 60, child: Text(e.value.rate > 0 ? '₹${e.value.rate.toStringAsFixed(0)}' : '—', textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Color(0xFF333333)))),
                        SizedBox(width: 70, child: Text(e.value.total > 0 ? '₹${e.value.total}' : '—', textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Color(0xFF333333), fontWeight: FontWeight.w500))),
                      ]),
                    )),
                  ]),
                ),

                const SizedBox(height: 16),

                // Summary (right-aligned)
                Row(children: [
                  const Spacer(),
                  SizedBox(width: 200, child: Column(children: [
                    _printSumRow('Subtotal', '₹${inv.subtotal}'),
                    _printSumRow('CGST (${halfRate.toStringAsFixed(1)}%)', '₹$cgst'),
                    _printSumRow('SGST (${halfRate.toStringAsFixed(1)}%)', '₹$sgst'),
                    if (inv.discount > 0) _printSumRow('Discount', '- ₹${inv.discount}'),
                    if (inv.oldGoldAdjustment > 0) _printSumRow('Old Gold', '- ₹${inv.oldGoldAdjustment}'),
                    const Divider(color: Color(0xFFE0E0E0)),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Grand Total', style: TextStyle(color: Color(0xFF1A1A2E),
                            fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('₹${inv.total}', style: const TextStyle(color: Color(0xFFD4AF37),
                            fontSize: 15, fontWeight: FontWeight.bold)),
                      ])),
                  ])),
                ]),

                const SizedBox(height: 12),

                // Amount in words
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF9F9F5),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text('Amount in Words: ${numberToWords(inv.total)}',
                      style: const TextStyle(color: Color(0xFF555555), fontSize: 10,
                          fontStyle: FontStyle.italic)),
                ),

                const SizedBox(height: 16),

                // Terms
                Text('Terms & Conditions', style: TextStyle(color: Colors.grey.shade600,
                    fontSize: 10, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ...[
                  'Goods once sold cannot be returned. Exchange only within 7 days with original bill.',
                  'Making charges and stone charges are non-refundable.',
                  'Gold rate applicable at the time of exchange will be current day\'s rate.',
                  'Hallmark certification as per BIS standards.',
                  'This is a computer-generated invoice. E&OE.',
                ].asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('${e.key + 1}. ${e.value}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 9, height: 1.5)),
                )),

                const SizedBox(height: 24),

                // Signatures
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _sigBlock('Customer Signature'),
                  _sigBlock('Authorized Signatory'),
                ]),

                const SizedBox(height: 20),

                // Footer
                Center(child: Column(children: [
                  Text('Thank you for your purchase!',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                  const Text('JewelERP', style: TextStyle(color: Color(0xFFD4AF37),
                      fontSize: 11, fontWeight: FontWeight.w600)),
                ])),
              ]),
            ),
          ),
        ]),
      ),
      isScrollControlled: true,
    );
  }

  Widget _printSumRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      Text(v, style: const TextStyle(color: Color(0xFF333333), fontSize: 11)),
    ]));

  Widget _sigBlock(String label) => Column(children: [
    Container(width: 120, height: 1, color: const Color(0xFFCCCCCC)),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 9)),
  ]);

  void _ok(String msg) => Get.snackbar('Success', msg,
      backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));

  // ── Helpers ──
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
      const SizedBox(height: 12), child,
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
      case 'Paid': return AppColors.success;
      case 'Pending': return AppColors.warning;
      case 'Partial': return AppColors.info;
      case 'Cancelled': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month-1]} ${dt.year}';
    } catch (_) { return d; }
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
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
  );
}
