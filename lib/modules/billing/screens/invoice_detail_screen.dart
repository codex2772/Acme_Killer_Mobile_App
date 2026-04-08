import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../models/billing/billing_item_model.dart'
    show BillingItem, MakingType;
import '../../../models/billing/invoice_model.dart';
import '../controllers/billing_controller.dart';
import '../widgets/billing_summary.dart' show numberToWords;

// ════════════════════════════════════════════════════════════════════
// InvoiceDetailScreen
//
// Fixes:
//  1. Fetches full invoice with items from API on open
//  2. PDF download mirrors Electron printInvoice() layout exactly
//  3. Items table shows in both detail view and PDF
// ════════════════════════════════════════════════════════════════════
class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({super.key});
  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late Invoice inv;
  late final BillingController _ctrl;
  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    inv = Get.arguments as Invoice;
    _ctrl = Get.find<BillingController>();
    // Fetch full detail with items populated
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    if (inv.backendId == null) return;
    final originalStore = inv.store; // preserve store set during list fetch
    setState(() => _loadingDetail = true);
    final full = await _ctrl.fetchInvoiceDetail(inv);
    if (mounted && full != null) {
      setState(() {
        inv = full;
        // If API didn't return store name, restore from list (mirrors Electron fallback)
        if ((inv.store == null || inv.store!.isEmpty) &&
            originalStore != null &&
            originalStore.isNotEmpty) {
          inv = inv.copyWith(store: originalStore);
        }
        _loadingDetail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(inv.status);
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
        title: Text(
          inv.typeLabel,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Download PDF',
            onPressed: () => _downloadPdf(inv),
          ),
          IconButton(
            icon: const Icon(
              Icons.print_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Print / Preview',
            onPressed: () => _showPrintPreview(context, inv),
          ),
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () => Get.snackbar(
              'Share',
              'Invoice details copied!',
              backgroundColor: AppColors.bgCard,
              colorText: AppColors.textPrimary,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(inv, statusColor),
            const SizedBox(height: 14),
            _sectionCard('Items', Icons.inventory_2_outlined, _itemsTable(inv)),
            const SizedBox(height: 14),
            _summaryCard(inv),
            const SizedBox(height: 14),
            if (inv.notes.isNotEmpty) ...[
              _sectionCard(
                'Notes',
                Icons.notes_outlined,
                Text(
                  inv.notes,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (inv.payments.isNotEmpty) ...[
              _sectionCard(
                'Payment History',
                Icons.payment_outlined,
                Column(
                  children: inv.payments
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: AppColors.success,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    p.mode,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${p.amount}',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
            ],
            _actionButtons(inv, _ctrl),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════
  Widget _headerCard(Invoice inv, Color statusColor) => Container(
    padding: const EdgeInsets.all(18),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inv.typeLabel,
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  inv.id,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            _statusBadge(inv.status, statusColor, large: true),
          ],
        ),
        const Divider(color: AppColors.border, height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _metaItem('Customer', inv.customer),
            _metaItem('Date', inv.formattedDate),
            _metaItem('Payment', inv.paymentMode),
            _metaItem(
              'Store',
              (inv.store ?? '').replaceAll('Rajmahal Jewellers - ', ''),
            ),
            if (inv.dueDate != null)
              _metaItem('Due Date', _fmtDate(inv.dueDate!)),
            if ((inv.digitalSignature ?? '').isNotEmpty)
              _metaItem('Signed By', inv.digitalSignature!),
          ],
        ),
      ],
    ),
  );

  Widget _metaItem(String label, String val) => SizedBox(
    width: 140,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );

  // ════════════════════════════════════════════════════════════════
  // ITEMS TABLE
  // ════════════════════════════════════════════════════════════════
  Widget _itemsTable(Invoice inv) {
    if (_loadingDetail) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            color: AppColors.goldPrimary,
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (inv.items.isEmpty) {
      return const Text(
        'No item details available',
        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
      );
    }
    return Column(
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '#',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ),
              Expanded(
                child: Text(
                  'Item',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ),
              Text(
                'Purity',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              SizedBox(width: 8),
              Text(
                'Amount',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        ...inv.items.asMap().entries.map(
          (e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.value.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (e.value.weight > 0)
                        Text(
                          '${e.value.weight}g @ ₹${e.value.rate.toStringAsFixed(0)}/g',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  e.value.purity.isEmpty ? '—' : e.value.purity,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  e.value.total > 0 ? '₹${e.value.total}' : '-',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
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

  // ════════════════════════════════════════════════════════════════
  // SUMMARY
  // ════════════════════════════════════════════════════════════════
  Widget _summaryCard(Invoice inv) {
    final cgst = inv.gst ~/ 2;
    final sgst = inv.gst - cgst;
    final gstRate = inv.gst > 0 && inv.subtotal > 0
        ? (inv.gst / inv.subtotal * 100).round()
        : 3;
    final halfRate = gstRate / 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _sumRow('Subtotal', '₹${inv.subtotal}'),
          _sumRow('CGST (${halfRate.toStringAsFixed(1)}%)', '₹$cgst'),
          _sumRow('SGST (${halfRate.toStringAsFixed(1)}%)', '₹$sgst'),
          if (inv.discount > 0) _sumRow('Discount', '- ₹${inv.discount}'),
          if (inv.oldGoldAdjustment > 0)
            _sumRow('Old Gold Adj.', '- ₹${inv.oldGoldAdjustment}'),
          if (inv.roundOff != 0)
            _sumRow(
              'Round Off',
              '${inv.roundOff > 0 ? '+' : ''}₹${inv.roundOff}',
            ),
          const Divider(color: AppColors.border, height: 16),
          _sumRow(
            'Total',
            '₹${inv.total}',
            bold: true,
            color: AppColors.goldPrimary,
            large: true,
          ),
          if (inv.total > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                numberToWords(inv.total),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (inv.status == 'Partial') ...[
            const SizedBox(height: 8),
            _sumRow('Paid', '₹${inv.paidAmount}', color: AppColors.success),
            _sumRow('Remaining', '₹${inv.remaining}', color: AppColors.warning),
          ],
        ],
      ),
    );
  }

  Widget _sumRow(
    String l,
    String v, {
    bool bold = false,
    Color? color,
    bool large = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: large ? 14 : 13,
          ),
        ),
        Text(
          v,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            fontSize: large ? 16 : 13,
          ),
        ),
      ],
    ),
  );

  // ════════════════════════════════════════════════════════════════
  // ACTION BUTTONS
  // ════════════════════════════════════════════════════════════════
  Widget _actionButtons(Invoice inv, BillingController ctrl) {
    final auth = Get.find<AuthController>();
    final isLive = !auth.isDemo.value;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if ((inv.status == 'Pending' || inv.status == 'Partial') &&
            inv.type == BillingType.invoice)
          ElevatedButton.icon(
            onPressed: () => _showRecordPayment(inv, ctrl, isLive),
            icon: const Icon(
              Icons.currency_rupee,
              size: 15,
              color: Colors.black,
            ),
            label: const Text(
              'Record Payment',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        if (inv.type == BillingType.estimate && inv.status != 'Converted')
          ElevatedButton.icon(
            onPressed: () async {
              if (isLive && inv.backendId != null) {
                final ok = await ctrl.convertEstimateViaApi(inv.backendId);
                if (ok) {
                  Get.back();
                  _ok('Estimate converted to invoice!');
                  return;
                }
              }
              ctrl.convertEstimate(inv.id);
              Get.back();
              _ok('Estimate converted to invoice!');
            },
            icon: const Icon(
              Icons.swap_horiz_rounded,
              size: 15,
              color: Colors.black,
            ),
            label: const Text(
              'Convert to Invoice',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        if (inv.type == BillingType.invoice &&
            inv.status != 'Cancelled' &&
            inv.status != 'Paid')
          OutlinedButton.icon(
            onPressed: () => _showCancelDialog(inv, ctrl, isLive),
            icon: const Icon(
              Icons.cancel_outlined,
              size: 15,
              color: AppColors.error,
            ),
            label: const Text(
              'Cancel Invoice',
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // PDF GENERATION — mirrors Electron printInvoice() exactly
  // ════════════════════════════════════════════════════════════════
  Future<pw.Document> _buildPdf(Invoice inv) async {
    // ── Load Noto Sans from Google Fonts — supports ₹ (U+20B9) and — (U+2014) ──
    // This is the fix for: "Helvetica has no Unicode support" and
    // "Unable to find a font to draw ₹" errors
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final fontItalic = await PdfGoogleFonts.notoSansItalic();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
        italic: fontItalic,
      ),
    );

    final gold = PdfColor.fromHex('#D4AF37');
    final dark = PdfColor.fromHex('#1A1A2E');
    final grey = PdfColors.grey600;

    final cgst = inv.gst ~/ 2;
    final sgst = inv.gst - cgst;
    final gstRate = inv.gst > 0 && inv.subtotal > 0
        ? (inv.gst / inv.subtotal * 100).round()
        : 3;
    final half = gstRate / 2;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          // ── HEADER ──
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: dark,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Business info
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'JewelERP',
                      style: pw.TextStyle(
                        color: gold,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Fine Jewellery Since 1985',
                      style: pw.TextStyle(
                        color: PdfColors.grey400,
                        fontSize: 9,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'GSTIN: 27AABCU9603R1ZM',
                      style: pw.TextStyle(
                        color: PdfColors.grey400,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
                // Invoice type + number
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      inv.typeLabel.toUpperCase(),
                      style: pw.TextStyle(
                        color: gold,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    pw.Text(
                      inv.id,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Date: ${inv.formattedDate}',
                      style: pw.TextStyle(
                        color: PdfColors.grey300,
                        fontSize: 9,
                      ),
                    ),
                    if (inv.dueDate != null)
                      pw.Text(
                        'Due: ${_fmtDate(inv.dueDate!)}',
                        style: pw.TextStyle(
                          color: PdfColors.grey300,
                          fontSize: 9,
                        ),
                      ),
                    pw.Text(
                      'Store: ${(inv.store ?? "").replaceAll("Rajmahal Jewellers - ", "")}',
                      style: pw.TextStyle(
                        color: PdfColors.grey300,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ── PARTIES ──
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILL TO',
                        style: pw.TextStyle(
                          color: grey,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        inv.customer,
                        style: pw.TextStyle(
                          color: dark,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE DETAILS',
                        style: pw.TextStyle(
                          color: grey,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Status: ${inv.status}',
                        style: pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Payment: ${inv.paymentMode}',
                        style: pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Items: ${inv.items.length}',
                        style: pw.TextStyle(fontSize: 9),
                      ),
                      if ((inv.digitalSignature ?? '').isNotEmpty)
                        pw.Text(
                          'Auth by: ${inv.digitalSignature}',
                          style: pw.TextStyle(fontSize: 9),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // ── ITEMS TABLE (mirrors Electron columns: # | Description | Purity | HSN | Weight | Rate | Amount) ──
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FixedColumnWidth(24),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FixedColumnWidth(48),
              3: const pw.FixedColumnWidth(48),
              4: const pw.FixedColumnWidth(56),
              5: const pw.FixedColumnWidth(64),
              6: const pw.FixedColumnWidth(72),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F5F5F5'),
                ),
                children:
                    [
                          '#',
                          'Description',
                          'Purity',
                          'HSN',
                          'Weight',
                          'Rate',
                          'Amount',
                        ]
                        .map(
                          (h) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 6,
                            ),
                            child: pw.Text(
                              h,
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: grey,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              // Item rows
              ...inv.items.asMap().entries.map((e) {
                final item = e.value;
                return pw.TableRow(
                  children: [
                    _pdfCell('${e.key + 1}'),
                    _pdfCell(item.name),
                    _pdfCell(item.purity.isEmpty ? '—' : item.purity),
                    _pdfCell('7113'),
                    _pdfCell(
                      item.weight > 0
                          ? '${item.weight.toStringAsFixed(3)}g'
                          : '-',
                    ),
                    _pdfCell(
                      item.rate > 0 ? '₹${item.rate.toStringAsFixed(0)}' : '-',
                    ),
                    _pdfCell(
                      item.total > 0 ? '₹${item.total}' : '-',
                      align: pw.TextAlign.right,
                    ),
                  ],
                );
              }),
              // Empty state if no items
              if (inv.items.isEmpty)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(20),
                      child: pw.Text(
                        'No items',
                        style: pw.TextStyle(color: grey, fontSize: 9),
                      ),
                    ),
                    ...List.generate(6, (_) => pw.SizedBox()),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 16),

          // ── BOTTOM: Payment + Summary ──
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Payment details (left)
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PAYMENT DETAILS',
                        style: pw.TextStyle(
                          color: grey,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      if (inv.payments.isNotEmpty)
                        ...inv.payments.map(
                          (p) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 2),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  p.mode,
                                  style: pw.TextStyle(fontSize: 9),
                                ),
                                pw.Text(
                                  '₹${p.amount}',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              inv.paymentMode,
                              style: pw.TextStyle(fontSize: 9),
                            ),
                            pw.Text(
                              '₹${inv.total}',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      if (inv.notes.isNotEmpty) ...[
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Notes: ${inv.notes}',
                          style: pw.TextStyle(color: grey, fontSize: 8),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              // Summary (right) — mirrors Electron print-inv-summary
              pw.SizedBox(
                width: 180,
                child: pw.Column(
                  children: [
                    _pdfSumRow('Subtotal', '₹${_fmt(inv.subtotal)}'),
                    _pdfSumRow(
                      'CGST (${half.toStringAsFixed(1)}%)',
                      '₹${_fmt(cgst)}',
                    ),
                    _pdfSumRow(
                      'SGST (${half.toStringAsFixed(1)}%)',
                      '₹${_fmt(sgst)}',
                    ),
                    if (inv.discount > 0)
                      _pdfSumRow('Discount', '- ₹${_fmt(inv.discount)}'),
                    if (inv.oldGoldAdjustment > 0)
                      _pdfSumRow(
                        'Old Gold Adj.',
                        '- ₹${_fmt(inv.oldGoldAdjustment)}',
                      ),
                    if (inv.roundOff != 0)
                      _pdfSumRow(
                        'Round Off',
                        '${inv.roundOff > 0 ? "+" : ""}₹${_fmt(inv.roundOff)}',
                      ),
                    pw.Divider(color: PdfColors.grey400),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Grand Total',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                            color: dark,
                          ),
                        ),
                        pw.Text(
                          '₹${_fmt(inv.total)}',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 13,
                            color: gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // ── AMOUNT IN WORDS ──
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F9F9F5'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'Amount in Words: ${numberToWords(inv.total)}',
              style: pw.TextStyle(
                color: grey,
                fontSize: 8,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
          pw.SizedBox(height: 16),

          // ── TERMS (mirrors Electron) ──
          pw.Text(
            'Terms & Conditions',
            style: pw.TextStyle(
              color: grey,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          ...[
            'Goods once sold cannot be returned. Exchange only within 7 days with original bill.',
            'Making charges and stone charges are non-refundable.',
            'Gold rate applicable at the time of exchange will be current day\'s rate.',
            'Hallmark certification as per BIS standards.',
            'This is a computer-generated invoice. E&OE.',
          ].asMap().entries.map(
            (e) => pw.Text(
              '${e.key + 1}. ${e.value}',
              style: pw.TextStyle(color: grey, fontSize: 7),
            ),
          ),

          pw.SizedBox(height: 24),

          // ── FOOTER + SIGNATURES ──
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Container(
                    width: 120,
                    height: 0.5,
                    color: PdfColors.grey400,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Customer Signature',
                    style: pw.TextStyle(color: grey, fontSize: 8),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'Thank you for your purchase!',
                    style: pw.TextStyle(color: grey, fontSize: 8),
                  ),
                  pw.Text(
                    'JewelERP',
                    style: pw.TextStyle(
                      color: gold,
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Container(
                    width: 120,
                    height: 0.5,
                    color: PdfColors.grey400,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Authorized Signatory',
                    style: pw.TextStyle(color: grey, fontSize: 8),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    return doc;
  }

  pw.Widget _pdfCell(String text, {pw.TextAlign align = pw.TextAlign.left}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
          textAlign: align,
        ),
      );

  pw.Widget _pdfSumRow(String l, String v) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(l, style: pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
        pw.Text(v, style: pw.TextStyle(fontSize: 9)),
      ],
    ),
  );

  String _fmt(int v) => v.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  // Download PDF directly to device
  Future<void> _downloadPdf(Invoice inv) async {
    final doc = await _buildPdf(inv);
    final bytes = await doc.save();
    // layoutPdf opens system print/save dialog — works on all Android versions
    // sharePdf requires additional Android manifest setup
    await Printing.layoutPdf(
      name: '${inv.id}.pdf',
      onLayout: (_) async => bytes,
    );
  }

  // Print preview bottom sheet with option to print/download
  void _showPrintPreview(BuildContext context, Invoice inv) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Preview — ${inv.typeLabel} ${inv.id}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final doc = await _buildPdf(inv);
                          await Printing.layoutPdf(
                            onLayout: (_) async => doc.save(),
                          );
                        },
                        icon: const Icon(
                          Icons.print_outlined,
                          size: 16,
                          color: Color(0xFFD4AF37),
                        ),
                        label: const Text(
                          'Print',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final doc = await _buildPdf(inv);
                          final bytes = await doc.save();
                          await Printing.layoutPdf(
                            name: '${inv.id}.pdf',
                            onLayout: (_) async => bytes,
                          );
                        },
                        icon: const Icon(
                          Icons.download_outlined,
                          size: 16,
                          color: Color(0xFFD4AF37),
                        ),
                        label: const Text(
                          'Download',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // PDF preview widget
            Expanded(
              child: PdfPreview(
                build: (format) async => (await _buildPdf(inv)).save(),
                allowPrinting: true,
                allowSharing: true,
                canChangeOrientation: false,
                canChangePageFormat: false,
                initialPageFormat: PdfPageFormat.a4,
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // RECORD PAYMENT
  // ════════════════════════════════════════════════════════════════
  void _showRecordPayment(Invoice inv, BillingController ctrl, bool isLive) {
    final amtCtrl = TextEditingController(text: '${inv.remaining}');
    final modeVal = 'Cash'.obs;
    final modes = ['Cash', 'UPI', 'Card', 'RTGS/NEFT', 'Cheque'];
    final isLoading = false.obs;

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
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Record Payment',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ₹${inv.total}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Remaining: ₹${inv.remaining}',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _bsField(
                    'Amount (₹)',
                    amtCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: modeVal.value,
                      dropdownColor: AppColors.bgSecondary,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: _bsDeco('Payment Mode'),
                      items: modes
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
                        if (v != null) modeVal.value = v;
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton(
                  onPressed: isLoading.value
                      ? null
                      : () async {
                          final amt = int.tryParse(amtCtrl.text) ?? 0;
                          if (amt <= 0) return;
                          isLoading.value = true;
                          if (isLive && inv.backendId != null) {
                            final ok = await ctrl.recordPaymentViaApi(
                              inv.backendId,
                              amt,
                              modeVal.value,
                            );
                            if (ok) {
                              Get.back();
                              _ok('₹$amt recorded via ${modeVal.value}');
                              isLoading.value = false;
                              return;
                            }
                          }
                          ctrl.recordPayment(inv.id, amt, modeVal.value);
                          isLoading.value = false;
                          Get.back();
                          _ok('₹$amt recorded via ${modeVal.value}');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    disabledBackgroundColor: AppColors.goldPrimary.withOpacity(
                      0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Record Payment',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(Invoice inv, BillingController ctrl, bool isLive) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          'Cancel Invoice',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Cancel invoice ${inv.id}? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'No',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isLive && inv.backendId != null)
                await ctrl.cancelInvoiceViaApi(inv.backendId);
              else
                ctrl.cancelInvoice(inv.id);
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Cancel Invoice',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget helpers ──
  Widget _sectionCard(String title, IconData icon, Widget child) => Container(
    padding: const EdgeInsets.all(16),
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

  Widget _statusBadge(String s, Color color, {bool large = false}) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: large ? 14 : 8,
      vertical: large ? 6 : 3,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.35)),
    ),
    child: Text(
      s,
      style: TextStyle(
        color: color,
        fontSize: large ? 12 : 10,
        fontWeight: FontWeight.w600,
      ),
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
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return d;
    }
  }

  Widget _bsField(
    String label,
    TextEditingController ctrl, {
    TextInputType? keyboardType,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          ),
        ),
      ),
    ],
  );

  InputDecoration _bsDeco(String label) => InputDecoration(
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
  );

  void _ok(String msg) => Get.snackbar(
    'Success',
    msg,
    backgroundColor: AppColors.bgCard,
    colorText: AppColors.textPrimary,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
  );
}
