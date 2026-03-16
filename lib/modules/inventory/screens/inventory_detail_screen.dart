import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/inventory_model.dart';
import '../../../routes/app_routes.dart';

class InventoryDetailScreen extends StatelessWidget {
  const InventoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryItem item = Get.arguments as InventoryItem;
    final marginPct = item.margin.round();
    final profit    = item.profit;
    final statusColor = _statusColor(item.status);
    final ageOld  = item.stockAge > 90;
    final ageMid  = item.stockAge > 30;
    final ageColor = ageOld ? AppColors.error : ageMid ? AppColors.warning : AppColors.success;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 18),
            onPressed: () => Get.back(),
          ),
          title: Text(item.name,
              style: const TextStyle(color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600, fontSize: 16),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.editInventory, arguments: item),
              child: const Text('Edit',
                  style: TextStyle(color: AppColors.goldPrimary,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),

        body: Column(
          children: [
            // ── Header card ──
            _headerCard(item, statusColor, ageColor, marginPct, profit),

            // ── Mini stats ──
            _miniStats(item, marginPct, profit),

            // ── Tabs ──
            Container(
              color: AppColors.bgPrimary,
              child: const TabBar(
                indicatorColor: AppColors.goldPrimary,
                indicatorWeight: 2,
                labelColor: AppColors.goldPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: 'Details'),
                  Tab(text: 'Stone'),
                  Tab(text: 'Pricing'),
                  Tab(text: 'History'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(children: [
                _detailsTab(item),
                _stoneTab(item),
                _pricingTab(item, marginPct, profit),
                _historyTab(item),
              ]),
            ),
          ],
        ),

        bottomNavigationBar: _bottomBar(item),
      ),
    );
  }

  // ─── Header card ───
  Widget _headerCard(InventoryItem item, Color statusColor,
      Color ageColor, int marginPct, int profit) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.diamond_outlined,
                color: AppColors.goldPrimary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(children: [
                  _badge(item.status, statusColor),
                  const SizedBox(width: 6),
                  Text('${item.id}  •  ${item.barcode}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ]),
                const SizedBox(height: 3),
                Text('${item.category}  •  ${item.metal} ${item.purity}  •  ${item.store.replaceAll('Rajmahal Jewellers - ', '')}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mini stats row ───
  Widget _miniStats(InventoryItem item, int marginPct, int profit) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(children: [
        _miniStat('${item.netWeight}g',   'Net Weight', AppColors.goldPrimary),
        _miniStat('${item.grossWeight}g', 'Gross Wt',   AppColors.info),
        _miniStat(item.formattedPrice,    'Price',       AppColors.success),
        _miniStat('$marginPct%',          'Margin',      AppColors.warning),
      ]),
    );
  }

  Widget _miniStat(String val, String label, Color color) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(children: [
        Text(val, style: TextStyle(color: color, fontSize: 13,
            fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textMuted,
            fontSize: 10)),
      ]),
    ),
  );

  // ─── DETAILS TAB ───
  Widget _detailsTab(InventoryItem item) => ListView(
    padding: const EdgeInsets.all(14),
    children: [
      _card('Item Information', Icons.tag_outlined, [
        _row('Item ID',      item.id),
        _row('Name',         item.name),
        _row('Category',     item.category),
        _row('Metal',        item.metal),
        _row('Purity',       item.purity),
        _row('HUID',         item.huid),
        _row('Barcode',      item.barcode),
        _row('Description',  item.description.isEmpty ? '—' : item.description),
      ]),
      const SizedBox(height: 12),
      _card('Weight & Location', Icons.scale_outlined, [
        _row('Net Weight',    '${item.netWeight}g'),
        _row('Gross Weight',  '${item.grossWeight}g'),
        _row('Stone Weight',  '${item.stoneWeight}g'),
        _row('Making Charge', '${item.makingCharge}%'),
        _row('Location',      item.showcaseLocation.isEmpty ? 'Not assigned' : item.showcaseLocation),
        _row('Store',         item.store),
      ]),
      const SizedBox(height: 12),
      _card('Hallmark & Certification', Icons.verified_outlined, [
        _row('Certificate', item.hallmarkCert.isEmpty ? '—' : item.hallmarkCert),
        _row('Hallmark Date', item.hallmarkDate == null ? '—' : _fmtDate(item.hallmarkDate!)),
        _row('Date Added',  _fmtDate(item.dateAdded)),
        _row('Days in Stock', '${item.stockAge} days'),
      ]),
    ],
  );

  // ─── STONE TAB ───
  Widget _stoneTab(InventoryItem item) => item.stoneDetails == null
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.diamond_outlined,
                  color: AppColors.textMuted, size: 52),
              const SizedBox(height: 12),
              const Text('No stone details for this item',
                  style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        )
      : ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _card('Stone Details', Icons.diamond_outlined, [
              _row('Type',          item.stoneDetails!['type'] ?? '—'),
              _row('Carat',         '${item.stoneDetails!['carat'] ?? '—'} ct'),
              _row('Cut',           item.stoneDetails!['cut'] ?? '—'),
              _row('Clarity',       item.stoneDetails!['clarity'] ?? '—'),
              _row('Color',         item.stoneDetails!['color'] ?? '—'),
              _row('Certification', item.stoneDetails!['certification'] ?? '—'),
            ]),
          ],
        );

  // ─── PRICING TAB ───
  Widget _pricingTab(InventoryItem item, int marginPct, int profit) {
    final gst = (item.sellingPrice * 0.03).round();
    final makingAmt = (item.costPrice * (item.makingCharge / 100)).round();
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.currency_rupee, color: AppColors.goldPrimary, size: 16),
                SizedBox(width: 8),
                Text('Pricing Breakdown', style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600, fontSize: 14)),
              ]),
              const SizedBox(height: 14),
              _priceRow('Cost Price',         _fmt(item.costPrice)),
              _priceRow('Making Charge (${item.makingCharge.toStringAsFixed(0)}%)', _fmt(makingAmt)),
              _priceRow('GST (3%)',            _fmt(gst)),
              const Divider(color: AppColors.border, height: 20),
              _priceRow('Selling Price',       _fmt(item.sellingPrice), bold: true, color: AppColors.goldPrimary),
              _priceRow('Profit Margin',       '$marginPct% (${_fmt(profit)})', bold: true, color: AppColors.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String val, {bool bold = false, Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text(val, style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontSize: 13)),
          ],
        ),
      );

  // ─── HISTORY TAB ───
  Widget _historyTab(InventoryItem item) {
    if (item.transferHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_rounded, color: AppColors.textMuted, size: 52),
            SizedBox(height: 12),
            Text('No transfers recorded',
                style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(14),
      children: item.transferHistory.map((t) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.swap_horiz_rounded, color: AppColors.info, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${t['from']?.toString().replaceAll('Rajmahal Jewellers - ','')} → ${t['to']?.toString().replaceAll('Rajmahal Jewellers - ','')}',
                style: const TextStyle(color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500)),
            Text('${t['date']}  •  By ${t['by']}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
        ]),
      )).toList(),
    );
  }

  // ─── Bottom bar ───
  Widget _bottomBar(InventoryItem item) => Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
    decoration: const BoxDecoration(
      color: AppColors.bgSecondary,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.transferInventory, arguments: item),
          icon: const Icon(Icons.swap_horiz_rounded, size: 16),
          label: const Text('Transfer'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.editInventory, arguments: item),
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.info,
            side: const BorderSide(color: AppColors.info),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.createInvoice),
          icon: const Icon(Icons.receipt_long_outlined, size: 16, color: Colors.black),
          label: const Text('Invoice', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.goldPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
    ]),
  );

  // ─── Helpers ───
  Widget _card(String title, IconData icon, List<Widget> rows) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: AppColors.goldPrimary, size: 15),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        ...rows,
      ],
    ),
  );

  Widget _row(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Flexible(child: Text(val,
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.textPrimary,
                fontWeight: FontWeight.w500, fontSize: 12),
            maxLines: 2, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.35)),
    ),
    child: Text(label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  Color _statusColor(String s) {
    switch (s) {
      case 'In Stock':  return AppColors.success;
      case 'Low Stock': return AppColors.warning;
      case 'Sold':      return AppColors.error;
      default:          return AppColors.info;
    }
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }

  String _fmt(int v) {
    if (v >= 10000000) return '₹${(v/10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '₹${(v/100000).toStringAsFixed(1)}L';
    if (v >= 1000)     return '₹${(v/1000).toStringAsFixed(0)}K';
    return '₹$v';
  }
}
