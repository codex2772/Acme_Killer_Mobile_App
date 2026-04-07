import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rates_schemes_controller.dart';

class TodayRatesScreen extends StatefulWidget {
  const TodayRatesScreen({super.key});
  @override
  State<TodayRatesScreen> createState() => _TodayRatesScreenState();
}

class _TodayRatesScreenState extends State<TodayRatesScreen> {
  late final RatesSchemesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<RatesSchemesController>();
    // Always fetch fresh rates on screen open — never show stale data
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.refreshRates(),
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
          "Today's Rates",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Rate Card PDF',
            onPressed: () => _snack('Rate card PDF downloaded!'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isFetchingLive.value
                    ? null
                    : () => _showUpdateRates(context),
                icon: controller.isFetchingLive.value
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        size: 14,
                        color: Colors.black,
                      ),
                label: const Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // ── Obx here so the entire body rebuilds when isLoadingRates or
        //    any metal.rate.value changes (since rate is RxInt) ──
        if (controller.isLoadingRates.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.goldPrimary),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            // Last updated
            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  color: AppColors.textMuted,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  'Gold 22K: ₹${controller.metals[1].rate.value}/g  •  Updated: ${DateTime.now().toIso8601String().substring(0, 10)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Rates grid — Obx inside each card handles per-card rebuilds ──
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: controller.metals.length,
              itemBuilder: (_, i) => _RateCard(metal: controller.metals[i]),
            ),

            const SizedBox(height: 20),

            _sectionTitle(Icons.trending_up_rounded, '30-Day Rate History'),
            _BarChart(entries: controller.rateHistory),
            const SizedBox(height: 16),

            _sectionTitle(Icons.table_chart_outlined, 'Rate History Table'),
            _RateHistoryTable(entries: controller.rateHistory),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitleWidget(
                  Icons.notifications_outlined,
                  'Rate Alerts',
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddAlert(context),
                  icon: const Icon(Icons.add, size: 14, color: Colors.black),
                  label: const Text(
                    'Add Alert',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(
              () => Column(
                children: controller.rateAlerts
                    .map((a) => _AlertRow(alert: a, ctrl: controller))
                    .toList(),
              ),
            ),
            const SizedBox(height: 30),
          ],
        );
      }),
    );
  }

  void _showUpdateRates(BuildContext context) {
    final g22 = TextEditingController(
      text: '${controller.metals[1].rate.value}',
    );
    final g24 = TextEditingController(
      text: '${controller.metals[0].rate.value}',
    );
    final g18 = TextEditingController(
      text: '${controller.metals[2].rate.value}',
    );
    final sil = TextEditingController(
      text: '${controller.metals[4].rate.value}',
    );
    final pla = TextEditingController(
      text: '${controller.metals[5].rate.value}',
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          "Update Today's Rates",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row2Ctrl(g22, 'Gold 22K (₹/g)', g24, 'Gold 24K (₹/g)'),
              _dlgField(g18, 'Gold 18K (₹/g)'),
              _row2Ctrl(sil, 'Silver (₹/g)', pla, 'Platinum (₹/g)'),
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
            onPressed: () async {
              // updateRates() sets RxInt values → Obx rebuilds UI immediately
              controller.updateRates(
                g22k: int.tryParse(g22.text),
                g24k: int.tryParse(g24.text),
                g18k: int.tryParse(g18.text),
                silver: int.tryParse(sil.text),
                platinum: int.tryParse(pla.text),
              );
              Get.back();
              // Save to API in background
              final saved = await controller.saveRates();
              _snack(
                saved
                    ? 'Rates saved to server — Gold 22K: ₹${g22.text}/g'
                    : 'Rates updated locally — Gold 22K: ₹${g22.text}/g',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
            ),
            child: const Text(
              'Save Rates',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAlert(BuildContext context) {
    String metal = 'Gold 22K', cond = 'below';
    final threshCtrl = TextEditingController();
    final custCtrl = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          backgroundColor: AppColors.bgSecondary,
          title: const Text(
            'Add Rate Alert',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dlgDrop(
                'Metal',
                ['Gold 22K', 'Gold 24K', 'Silver', 'Platinum'],
                metal,
                (v) => setState(() => metal = v!),
              ),
              _dlgDrop(
                'When rate goes',
                ['below', 'above'],
                cond,
                (v) => setState(() => cond = v!),
              ),
              _dlgField(
                threshCtrl,
                'Threshold (₹/g)',
                keyboardType: TextInputType.number,
              ),
              _dlgField(custCtrl, 'Notify Customer (optional)'),
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
              onPressed: () async {
                final t = int.tryParse(threshCtrl.text) ?? 0;
                if (t == 0) return;
                final newId =
                    'RA${(controller.rateAlerts.length + 1).toString().padLeft(3, '0')}';
                final alert = RateAlert(
                  id: newId,
                  metal: metal,
                  condition: cond,
                  threshold: t,
                  customer: custCtrl.text.trim().isEmpty
                      ? 'All'
                      : custCtrl.text.trim(),
                  active: true,
                );
                controller.addRateAlert(alert);
                Get.back();
                _snack('Rate alert added!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
              ),
              child: const Text(
                'Save Alert',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, color: AppColors.goldPrimary, size: 15),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitleWidget(IconData icon, String title) => Row(
    children: [
      Icon(icon, color: AppColors.goldPrimary, size: 15),
      const SizedBox(width: 7),
      Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ],
  );

  Widget _row2Ctrl(
    TextEditingController a,
    String la,
    TextEditingController b,
    String lb,
  ) => Row(
    children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: _dlgField(a, la, keyboardType: TextInputType.number),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 6),
          child: _dlgField(b, lb, keyboardType: TextInputType.number),
        ),
      ),
    ],
  );

  Widget _dlgField(
    TextEditingController ctrl,
    String label, {
    TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: ctrl,
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
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: DropdownButtonFormField<String>(
      value: val,
      dropdownColor: AppColors.bgSecondary,
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
    ),
  );

  void _snack(String msg) => Get.snackbar(
    '',
    msg,
    backgroundColor: AppColors.bgCard,
    colorText: AppColors.textPrimary,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
  );
}

// ════════════════════════════════════════════════════════════════════
// _RateCard — Obx wraps BOTH rate value and tola so they rebuild
// when metal.rate.value changes (it's RxInt)
// ════════════════════════════════════════════════════════════════════
class _RateCard extends StatelessWidget {
  final MetalRate metal;
  const _RateCard({super.key, required this.metal});

  @override
  Widget build(BuildContext context) {
    final color = Color(metal.colorValue);
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
              Flexible(
                child: Text(
                  metal.metal,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: metal.trendUp.value
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      metal.trendUp.value
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: metal.trendUp.value
                          ? AppColors.success
                          : AppColors.error,
                      size: 9,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      metal.change.value.isEmpty ? "—" : metal.change.value,
                      style: TextStyle(
                        color: metal.trendUp.value
                            ? AppColors.success
                            : AppColors.error,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Obx so rate + tola rebuild when RxInt changes ──
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${metal.rate.value}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  '/gram',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
                const SizedBox(height: 3),
                Text(
                  '₹${metal.tolaRate}/tola',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<RateHistoryEntry> entries;
  const _BarChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final reversed = entries.reversed.toList();
    const minRate = 6100, maxRate = 6350;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: reversed.map((r) {
                final pct = ((r.gold22k - minRate) / (maxRate - minRate)).clamp(
                  0.1,
                  1.0,
                );
                final day = r.date.split('-').last;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          flex: (pct * 80).round() + 10,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color(0xFFB8941E),
                                  AppColors.goldPrimary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gold 22K — ₹/gram over last 7 days',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RateHistoryTable extends StatelessWidget {
  final List<RateHistoryEntry> entries;
  const _RateHistoryTable({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [_header(), ...entries.map((r) => _row(r))]),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: const BoxDecoration(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    child: const Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Date',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '22K',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '24K',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'Silver',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Platinum',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _row(RateHistoryEntry r) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            _fmt(r.date),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '₹${r.gold22k}',
            style: const TextStyle(
              color: AppColors.goldPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '₹${r.gold24k}',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '₹${r.silver.toStringAsFixed(0)}',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '₹${r.platinum}',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
          ),
        ),
      ],
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

class _AlertRow extends StatelessWidget {
  final RateAlert alert;
  final RatesSchemesController ctrl;
  const _AlertRow({super.key, required this.alert, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.warning,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${alert.metal} ${alert.condition == 'below' ? '↓ Below' : '↑ Above'} ₹${alert.threshold}/g',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Notify: ${alert.customer}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: alert.active
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  alert.active ? 'Active' : 'Paused',
                  style: TextStyle(
                    color: alert.active
                        ? AppColors.success
                        : AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => ctrl.toggleAlert(alert.id),
                child: Icon(
                  alert.active
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => ctrl.deleteAlert(alert.id),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
