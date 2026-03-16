import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/reports_controller.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReportsController>();
    final reportId = Get.arguments as String? ?? ctrl.selectedReportId.value;
    final report = ReportsController.reportTypes
        .firstWhere((r) => r.id == reportId,
            orElse: () => ReportsController.reportTypes.first);
    final color = Color(report.colorValue);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(report.title,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined,
                color: AppColors.textSecondary),
            onPressed: () => _snack('PDF export downloaded!'),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_outlined,
                color: AppColors.textSecondary),
            onPressed: () => _snack('CSV exported!'),
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined,
                color: AppColors.textSecondary),
            onPressed: () => _snack('Sent to printer'),
          ),
        ],
      ),
      body: _buildBody(reportId, color, ctrl),
    );
  }

  Widget _buildBody(String type, Color color, ReportsController ctrl) {
    switch (type) {
      case 'salesTrend':    return _SalesTrendReport(color: color, ctrl: ctrl);
      case 'topSelling':    return _TopSellingReport(color: color, ctrl: ctrl);
      case 'deadStock':     return _DeadStockReport(color: color, ctrl: ctrl);
      case 'customerAcq':   return _CustomerAcqReport(color: color, ctrl: ctrl);
      case 'storeComp':     return _StoreCompReport(color: color, ctrl: ctrl);
      case 'makingCharge':  return _MakingChargeReport(color: color, ctrl: ctrl);
      case 'schemeCollection': return _SchemeCollectionReport(color: color, ctrl: ctrl);
      case 'outstandingDues':  return _OutstandingDuesReport(color: color, ctrl: ctrl);
      case 'dayBook':       return _DayBookReport(color: color, ctrl: ctrl);
      case 'gstReport':     return _GSTReport(color: color, ctrl: ctrl);
      default:              return _PlaceholderReport(report: ReportsController.reportTypes.first);
    }
  }

  void _snack(String msg) => Get.snackbar(
    'Export', msg,
    backgroundColor: AppColors.bgCard,
    colorText: AppColors.textPrimary,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
  );
}

// ─── SALES TREND ───────────────────────────────────────────
class _SalesTrendReport extends StatelessWidget {
  final Color color; final ReportsController ctrl;
  const _SalesTrendReport({required this.color, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _BarChart(
        bars: ReportsController.weeklyBars,
        labels: ReportsController.weekDays,
        color: color,
        title: 'Weekly Sales (₹ in Lakhs)',
      ),
      const SizedBox(height: 14),
      _StatsRow(stats: [
        _Stat('₹24.5L', 'This Week',    AppColors.goldPrimary),
        _Stat('₹98.2L', 'This Month',   AppColors.success),
        _Stat('+18%',   'vs Last Month',AppColors.info),
        _Stat('28',     'Invoices',     const Color(0xFFC084FC)),
      ]),
      const SizedBox(height: 14),
      _sectionTitle('Monthly Breakdown'),
      _DataTable(
        headers: ['Month','Invoices','Revenue','Growth'],
        rows: [
          ['March 2026','28','₹98.2L','+18%'],
          ['February 2026','24','₹83.3L','+12%'],
          ['January 2026','21','₹74.5L','+8%'],
          ['December 2025','19','₹68.9L','+22%'],
          ['November 2025','16','₹56.5L','+5%'],
        ],
      ),
    ]);
  }
}

// ─── TOP SELLING ───────────────────────────────────────────
class _TopSellingReport extends StatelessWidget {
  final Color color; final ReportsController ctrl;
  const _TopSellingReport({required this.color, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _StatsRow(stats: [
        _Stat('5',       'Categories',  AppColors.goldPrimary),
        _Stat('200',     'Units Sold',  AppColors.success),
        _Stat('₹1.06Cr', 'Revenue',     AppColors.info),
        _Stat('₹53K',    'Avg. Ticket', const Color(0xFFC084FC)),
      ]),
      const SizedBox(height: 14),
      _sectionTitle('Top Items by Revenue'),
      ...ReportsController.topSellingItems.asMap().entries.map((e) {
        final item = e.value;
        final rank = item['rank'] as int;
        final maxRev = 3190000;
        final progress = (item['revenue'] as int) / maxRev;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: _cardDeco(),
          child: Column(children: [
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: rank == 1 ? AppColors.goldPrimary.withOpacity(0.2) : AppColors.bgSecondary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('#$rank', style: TextStyle(
                  color: rank == 1 ? AppColors.goldPrimary : AppColors.textMuted,
                  fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['name'] as String, style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(item['category'] as String, style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(ctrl.fmt(item['revenue'] as int),
                    style: const TextStyle(color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${item['units']} units', style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11)),
              ]),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
          ]),
        );
      }),
    ]);
  }
}

// ─── DEAD STOCK ────────────────────────────────────────────
class _DeadStockReport extends StatelessWidget {
  final Color color; final ReportsController ctrl;
  const _DeadStockReport({required this.color, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final deadItems = ReportsController.deadStockItems.where((i) => (i['days'] as int) > 60).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Text('${deadItems.length} items have been in stock for over 60 days',
              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
      _StatsRow(stats: [
        _Stat('${deadItems.length}', 'Dead Stock Items', AppColors.error),
        _Stat(ctrl.fmt(deadItems.fold(0, (s, i) => s + (i['value'] as int))), 'Total Value', AppColors.warning),
        _Stat('${ReportsController.deadStockItems.length - deadItems.length}', 'Healthy Items', AppColors.success),
      ]),
      const SizedBox(height: 14),
      _sectionTitle('Items Over 60 Days'),
      ...deadItems.map((item) {
        final days = item['days'] as int;
        final ageColor = days > 90 ? AppColors.error : AppColors.warning;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: _cardDeco(),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ageColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${days}d', style: TextStyle(
                  color: ageColor, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item['name'] as String, style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${item['category']}  •  ${(item['location'] as String).isEmpty ? 'No location' : item['location']}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ])),
            Text(ctrl.fmt(item['value'] as int),
                style: const TextStyle(color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        );
      }),
    ]);
  }
}

// ─── CUSTOMER ACQUISITION ──────────────────────────────────
class _CustomerAcqReport extends StatelessWidget {
  final Color color; final ReportsController ctrl;
  const _CustomerAcqReport({required this.color, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final maxCount = ReportsController.custMonthly.map((m) => m['count'] as int).reduce((a, b) => a > b ? a : b);
    return ListView(padding: const EdgeInsets.all(16), children: [
      _BarChart(
        bars: ReportsController.custMonthly.map((m) => ((m['count'] as int) * 100 ~/ maxCount)).toList(),
        labels: ReportsController.custMonthly.map((m) => m['month'] as String).toList(),
        color: color,
        title: 'New Customers per Month',
      ),
      const SizedBox(height: 14),
      _StatsRow(stats: [
        _Stat('5', 'Total Customers',  AppColors.info),
        _Stat('2', 'VIP',              AppColors.goldPrimary),
        _Stat('2', 'Premium',          AppColors.info),
        _Stat('1', 'Regular',          AppColors.textSecondary),
      ]),
      const SizedBox(height: 14),
      _sectionTitle('Monthly Customer Registrations'),
      _DataTable(
        headers: ['Month','New Customers','Cumulative'],
        rows: () {
          int cum = 0;
          return ReportsController.custMonthly.map((m) {
            cum += m['count'] as int;
            return [m['month'] as String, '${m['count']}', '$cum'];
          }).toList();
        }(),
      ),
    ]);
  }
}

// ─── STORE COMPARISON ──────────────────────────────────────
class _StoreCompReport extends StatelessWidget {
  final Color color; final ReportsController ctrl;
  const _StoreCompReport({required this.color, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    const stores = ReportsController.storeData;
    final colors = [AppColors.goldPrimary, AppColors.info, AppColors.success];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: stores.asMap().entries.map((e) {
        final s = e.value;
        final c = colors[e.key % colors.length];
        return Expanded(child: Container(
          margin: EdgeInsets.only(right: e.key < stores.length - 1 ? 8 : 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.withOpacity(0.3)),
          ),
          child: Column(children: [
            Text(ctrl.fmt(s['revenue'] as int),
                style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(s['name'] as String,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ]),
        ));
      }).toList()),
      const SizedBox(height: 14),
      _sectionTitle('Store Performance Breakdown'),
      _DataTable(
        headers: ['Store','Invoices','Revenue','Customers','Avg. Ticket'],
        rows: stores.map((s) => [
          s['name'] as String,
          '${s['invoices']}',
          ctrl.fmt(s['revenue'] as int),
          '${s['customers']}',
          ctrl.fmt(s['avg'] as int),
        ]).toList(),
      ),
    ]);
  }
}

// ─── MAKING CHARGE ─────────────────────────────────────────
class _MakingChargeReport extends StatelessWidget {
  final Color color; final ReportsController ctrl;
  const _MakingChargeReport({required this.color, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final totalMC = ReportsController.makingChargeInvoices.fold(0, (s, i) => s + (i['mc'] as int));
    return ListView(padding: const EdgeInsets.all(16), children: [
      _StatsRow(stats: [
        _Stat(ctrl.fmt(totalMC),                           'Total MC Revenue', AppColors.goldPrimary),
        _Stat('${ReportsController.makingChargeInvoices.length}', 'Invoices with MC', AppColors.success),
        _Stat('12%',                                       'Default MC Rate',  AppColors.info),
      ]),
      const SizedBox(height: 14),
      _sectionTitle('Making Charge Breakdown by Invoice'),
      _DataTable(
        headers: ['Invoice','Customer','Subtotal','Making Charge','Date'],
        rows: ReportsController.makingChargeInvoices.map((i) => [
          i['id'] as String,
          i['customer'] as String,
          ctrl.fmt(i['subtotal'] as int),
          ctrl.fmt(i['mc'] as int),
          i['date'] as String,
        ]).toList(),
      ),
    ]);
  }
}

// ─── SCHEME COLLECTION ─────────────────────────────────────
class _SchemeCollectionReport extends StatelessWidget {
  final Color color; final ReportsController ctrl;
  const _SchemeCollectionReport({required this.color, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final totalMembers   = ReportsController.schemeData.fold(0, (s, d) => s + (d['members'] as int));
    final totalCollected = ReportsController.schemeData.fold(0, (s, d) => s + (d['collected'] as int));
    return ListView(padding: const EdgeInsets.all(16), children: [
      _StatsRow(stats: [
        _Stat('${ReportsController.schemeData.length}', 'Active Schemes', color),
        _Stat('$totalMembers',          'Total Members',    AppColors.goldPrimary),
        _Stat(ctrl.fmt(totalCollected), 'Total Collected',  AppColors.success),
      ]),
      const SizedBox(height: 14),
      _sectionTitle('Scheme-wise Collection'),
      ...ReportsController.schemeData.map((s) {
        final due = s['due'] as int;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: _cardDeco(),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['name'] as String, style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('${s['monthly']}/month  •  ${s['members']} members',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(ctrl.fmt(s['collected'] as int), style: const TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(due > 0 ? '$due due this month' : 'All paid',
                      style: TextStyle(
                          color: due > 0 ? AppColors.error : AppColors.success,
                          fontSize: 11)),
                ]),
              ],
            ),
          ]),
        );
      }),
    ]);
  }
}

// ─── OUTSTANDING DUES ──────────────────────────────────────
class _OutstandingDuesReport extends StatelessWidget {
  final Color color; final ReportsController ctrl;
  const _OutstandingDuesReport({required this.color, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final dues = ReportsController.outstandingDues;
    final total = dues.fold(0, (s, d) => s + (d['totalNum'] as int));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Outstanding', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(ctrl.fmt(total), style: const TextStyle(color: AppColors.warning,
              fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
      ),
      _sectionTitle('Outstanding Invoices'),
      ...dues.map((r) {
        final status = r['status'] as String;
        final statusColor = status == 'Partial' ? AppColors.info : AppColors.warning;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: _cardDeco(),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.receipt_outlined, size: 16, color: AppColors.warning),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['customer'] as String, style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
              Row(children: [
                Text(r['id'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                if (r['dueDate'] != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.schedule_outlined, size: 11, color: AppColors.warning),
                  const SizedBox(width: 3),
                  Text('Due ${r['dueDate']}', style: const TextStyle(color: AppColors.warning, fontSize: 11)),
                ],
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(r['total'] as String, style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.35))),
                child: Text(status, style: TextStyle(
                    color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
        );
      }),
    ]);
  }
}

// ─── DAY BOOK ──────────────────────────────────────────────
class _DayBookReport extends StatefulWidget {
  final Color color; final ReportsController ctrl;
  const _DayBookReport({required this.color, required this.ctrl});
  @override State<_DayBookReport> createState() => _DayBookReportState();
}
class _DayBookReportState extends State<_DayBookReport> {
  String selectedDate = '2026-03-12';

  @override
  Widget build(BuildContext context) {
    int totalCR = 0, totalDR = 0;
    for (final e in ReportsController.dayBookEntries) {
      final amtStr = (e['amount'] as String).replaceAll(RegExp(r'[₹,]'), '');
      final amt = int.tryParse(amtStr) ?? 0;
      if (e['type'] == 'CR') totalCR += amt;
      else totalDR += amt;
    }

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Date picker
      GestureDetector(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
            firstDate: DateTime(2024), lastDate: DateTime(2030),
            builder: (c, w) => Theme(
              data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(primary: AppColors.goldPrimary)),
              child: w!,
            ),
          );
          if (d != null) setState(() => selectedDate = d.toIso8601String().substring(0,10));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.goldPrimary, size: 16),
            const SizedBox(width: 10),
            Text(selectedDate, style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.edit_outlined, color: AppColors.textMuted, size: 14),
          ]),
        ),
      ),
      _StatsRow(stats: [
        _Stat(widget.ctrl.fmt(totalCR), 'Total Credit',  AppColors.success),
        _Stat(widget.ctrl.fmt(totalDR), 'Total Debit',   AppColors.error),
        _Stat(widget.ctrl.fmt(totalCR - totalDR), 'Net Cash', AppColors.goldPrimary),
        _Stat('${ReportsController.dayBookEntries.length}', 'Transactions', AppColors.info),
      ]),
      const SizedBox(height: 14),
      _sectionTitle('All Transactions — $selectedDate'),
      ...ReportsController.dayBookEntries.map((e) {
        final isCR = e['type'] == 'CR';
        final typeColor = isCR ? AppColors.success : AppColors.error;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: typeColor, width: 3))),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Text(e['type'] as String, style: TextStyle(
                  color: typeColor, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e['party'] as String, style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
              Row(children: [
                Text(e['time'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(width: 8),
                Text(e['mode'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ]),
              if ((e['desc'] as String).isNotEmpty)
                Text(e['desc'] as String, style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Text(e['amount'] as String, style: TextStyle(
                color: typeColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        );
      }),
    ]);
  }
}

// ─── GST REPORT ────────────────────────────────────────────
class _GSTReport extends StatelessWidget {
  final Color color; final ReportsController ctrl;
  const _GSTReport({required this.color, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final invoices = ReportsController.gstInvoices;
    final totalTaxable = invoices.fold(0, (s, i) => s + (i['taxable'] as int));
    final totalGST     = invoices.fold(0, (s, i) => s + (i['gst'] as int));
    final cgst = totalGST ~/ 2;

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Info banner
      Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.info.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.description_outlined, color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('GST Summary for Filing', style: TextStyle(
                color: AppColors.info, fontWeight: FontWeight.bold, fontSize: 13)),
            Text('Period: March 2026  |  Rate: 3%', style: TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
          ]),
        ]),
      ),
      _StatsRow(stats: [
        _Stat(ctrl.fmt(totalTaxable), 'Taxable Value', AppColors.goldPrimary),
        _Stat(ctrl.fmt(cgst),         'CGST (1.5%)',   AppColors.success),
        _Stat(ctrl.fmt(cgst),         'SGST (1.5%)',   AppColors.info),
        _Stat(ctrl.fmt(totalGST),     'Total GST',     AppColors.error),
      ]),
      const SizedBox(height: 14),
      _sectionTitle('Invoice-wise GST Breakup'),
      _DataTable(
        headers: ['Invoice','Customer','Taxable','CGST','SGST','Total Tax','Invoice Value'],
        rows: invoices.map((i) {
          final cgstAmt = (i['gst'] as int) ~/ 2;
          return [
            i['id'] as String,
            i['customer'] as String,
            ctrl.fmt(i['taxable'] as int),
            ctrl.fmt(cgstAmt),
            ctrl.fmt(cgstAmt),
            ctrl.fmt(i['gst'] as int),
            ctrl.fmt(i['total'] as int),
          ];
        }).toList(),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDeco(),
        child: Column(children: [
          const Text('GSTR-3B Summary', style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          const Divider(color: AppColors.border, height: 16),
          _gstRow('Outward Taxable Supplies', ctrl.fmt(totalTaxable)),
          _gstRow('Total Tax Payable',        ctrl.fmt(totalGST)),
          _gstRow('CGST',                     ctrl.fmt(cgst)),
          _gstRow('SGST',                     ctrl.fmt(cgst)),
          _gstRow('ITC Available',            '₹0 (Jewellery — exempt)'),
          const Divider(color: AppColors.border, height: 12),
          _gstRow('Net Tax Payable', ctrl.fmt(totalGST), bold: true, color: AppColors.error),
        ]),
      ),
    ]);
  }

  Widget _gstRow(String l, String v, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      Text(v, style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500, fontSize: 12)),
    ]),
  );
}

// ─── PLACEHOLDER ───────────────────────────────────────────
class _PlaceholderReport extends StatelessWidget {
  final ReportType report;
  const _PlaceholderReport({required this.report});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.bar_chart_outlined, color: AppColors.textMuted, size: 52),
      const SizedBox(height: 12),
      Text(report.title, style: const TextStyle(
          color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      const Text('Report data is being generated...',
          style: TextStyle(color: AppColors.textMuted)),
    ]),
  );
}

// ─── SHARED WIDGETS ────────────────────────────────────────

class _Stat {
  final String value, label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
}

class _StatsRow extends StatelessWidget {
  final List<_Stat> stats;
  const _StatsRow({required this.stats});
  @override
  Widget build(BuildContext context) => Row(
    children: stats.asMap().entries.map((e) {
      final s = e.value;
      final last = e.key == stats.length - 1;
      return Expanded(child: Container(
        margin: EdgeInsets.only(right: last ? 0 : 8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: s.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: s.color.withOpacity(0.25)),
        ),
        child: Column(children: [
          Text(s.value, style: TextStyle(color: s.color, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(s.label, style: const TextStyle(color: AppColors.textMuted, fontSize: 9), textAlign: TextAlign.center),
        ]),
      ));
    }).toList(),
  );
}

class _BarChart extends StatelessWidget {
  final List<int> bars;
  final List<String> labels;
  final Color color;
  final String title;
  const _BarChart({required this.bars, required this.labels, required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(children: [
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: bars.asMap().entries.map((e) {
              final pct = e.value / 100;
              final label = e.key < labels.length ? labels[e.key] : '';
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Flexible(
                        flex: (pct * 100).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [color.withOpacity(0.6), color],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ])),
                    const SizedBox(height: 5),
                    Text(label, style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 9)),
                  ],
                ),
              ));
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 11)),
      ]),
    );
  }
}

class _DataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  const _DataTable({required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDeco(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 28),
          child: Table(
            border: TableBorder(
              horizontalInside: const BorderSide(color: AppColors.border, width: 0.5),
              bottom: const BorderSide(color: AppColors.border, width: 0.5),
            ),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              // Header
              TableRow(
                decoration: const BoxDecoration(color: AppColors.bgSecondary),
                children: headers.map((h) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(h, style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                )).toList(),
              ),
              // Rows
              ...rows.map((row) => TableRow(
                children: row.map((cell) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(cell, style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 12)),
                )).toList(),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _sectionTitle(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Text(t, style: const TextStyle(
      color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
);

BoxDecoration _cardDeco() => BoxDecoration(
  color: AppColors.bgCard,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: AppColors.border),
);
