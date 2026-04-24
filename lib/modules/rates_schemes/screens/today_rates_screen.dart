import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
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
          // ── Rate Board (Fullscreen) — mirrors Electron "Fullscreen Board" button ──
          IconButton(
            icon: const Icon(
              Icons.open_in_full_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Fullscreen Rate Board',
            onPressed: () => Get.toNamed(AppRoutes.rateBoard),
          ),

          // ── Fetch Live Rates — mirrors Electron "Fetch Live Rates" button ──
          Obx(
            () => IconButton(
              icon: controller.isFetchingLive.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.goldPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.goldPrimary,
                    ),
              tooltip: 'Fetch Live Rates',
              onPressed: controller.isFetchingLive.value
                  ? null
                  : () => _showFetchLiveRates(context),
            ),
          ),

          // ── Rate Card PDF ──
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Rate Card PDF',
            onPressed: () => _snack('Rate card PDF downloaded!'),
          ),

          // ── Update Rates manually ──
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

  // ════════════════════════════════════════════════════════════════
  // _showFetchLiveRates — mirrors Electron "Fetch Live Rates" dialog
  //
  // 1. Calls RatesSchemesController.fetchLiveRates()
  //    (which calls RatesService.fetchLive() → Swissquote → metals.live)
  // 2. Shows comparison table: International spot vs Current store rates
  // 3. User can adjust values then click "Apply & Save Rates"
  //    which calls controller.updateRates() + controller.saveRates()
  // ════════════════════════════════════════════════════════════════
  Future<void> _showFetchLiveRates(BuildContext context) async {
    // Show fetching snackbar
    _snack('Fetching live international rates…');

    final success = await controller.fetchLiveRates();
    if (!success) {
      _snack('Failed to fetch live rates. Check your connection.');
      return;
    }

    final live = controller.liveRatesData;
    if (live == null || !mounted) return;

    // Pull live values
    final int live24k = (live['gold24k'] as num? ?? 0).toInt();
    final int live22k = (live['gold22k'] as num? ?? 0).toInt();
    final int live18k = (live['gold18k'] as num? ?? 0).toInt();
    final int live14k = (live['gold14k'] as num? ?? 0).toInt();
    final double liveSilver = (live['silver'] as num? ?? 0).toDouble();
    final int livePlat = (live['platinum'] as num? ?? 0).toInt();
    final int liveRose = (live['roseGold18k'] as num? ?? 0).toInt();
    final int liveWhite = (live['whiteGold18k'] as num? ?? 0).toInt();
    final double usdInr = (live['usdToInr'] as num? ?? 83.5).toDouble();
    final double goldUsdOz = (live['goldUsdOz'] as num? ?? 0).toDouble();
    final double silUsdOz = (live['silverUsdOz'] as num? ?? 0).toDouble();
    final double platUsdOz = (live['platinumUsdOz'] as num? ?? 0).toDouble();
    final String fetchedAt = live['fetchedAt']?.toString() ?? '';
    final String source = live['source']?.toString() ?? 'Live API';

    // Current store rates (for diff comparison)
    final cur24k = controller.metals[0].rate.value;
    final cur22k = controller.metals[1].rate.value;
    final cur18k = controller.metals[2].rate.value;
    final curSilver = controller.metals[4].rate.value;
    final curPlat = controller.metals[5].rate.value;

    // Editable controllers — pre-filled with live values
    final e24k = TextEditingController(text: '$live24k');
    final e22k = TextEditingController(text: '$live22k');
    final e18k = TextEditingController(text: '$live18k');
    final e14k = TextEditingController(text: '$live14k');
    final eSil = TextEditingController(text: liveSilver.toStringAsFixed(2));
    final ePlt = TextEditingController(text: '$livePlat');
    final eRose = TextEditingController(text: '$liveRose');
    final eWht = TextEditingController(text: '$liveWhite');

    // Parse fetched time for display
    String timeLabel = '';
    try {
      final dt = DateTime.parse(fetchedAt).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ap = dt.hour >= 12 ? 'PM' : 'AM';
      timeLabel = '$h:$m $ap';
    } catch (_) {}

    await Get.dialog(
      Dialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 680,
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Dialog header ────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.goldPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Live International Spot Rates',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Success banner ──────────────────────────
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    timeLabel.isNotEmpty
                                        ? 'Rates fetched at $timeLabel'
                                        : 'Live rates fetched successfully',
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Source: $source  •  USD/INR: ${usdInr.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Disclaimer banner ─────────────────────────
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                              size: 14,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'International spot rates. Indian retail rates are typically 3–8% higher due to import duty + GST. Adjust before saving.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Comparison table ─────────────────────────
                      _LiveRatesTable(
                        rows: [
                          _LiveRateRow(
                            metal: 'Gold 24K',
                            usdOz: goldUsdOz > 0
                                ? '\$${goldUsdOz.toStringAsFixed(2)}'
                                : '—',
                            spotInr: live24k,
                            currentInr: cur24k,
                            color: const Color(0xFFF0D060),
                          ),
                          _LiveRateRow(
                            metal: 'Gold 22K',
                            usdOz: '—',
                            spotInr: live22k,
                            currentInr: cur22k,
                            color: AppColors.goldPrimary,
                          ),
                          _LiveRateRow(
                            metal: 'Gold 18K',
                            usdOz: '—',
                            spotInr: live18k,
                            currentInr: cur18k,
                            color: AppColors.goldDark,
                          ),
                          _LiveRateRow(
                            metal: 'Silver',
                            usdOz: silUsdOz > 0
                                ? '\$${silUsdOz.toStringAsFixed(2)}'
                                : '—',
                            spotInr: liveSilver.toInt(),
                            currentInr: curSilver,
                            color: const Color(0xFF94A3B8),
                          ),
                          _LiveRateRow(
                            metal: 'Platinum',
                            usdOz: platUsdOz > 0
                                ? '\$${platUsdOz.toStringAsFixed(2)}'
                                : '—',
                            spotInr: livePlat,
                            currentInr: curPlat,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Adjust & Apply section ────────────────────
                      const Text(
                        'Adjust & Apply',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Row 1: 24K, 22K, 18K
                      Row(
                        children: [
                          Expanded(child: _liveField(e24k, 'Gold 24K (₹/g)')),
                          const SizedBox(width: 10),
                          Expanded(child: _liveField(e22k, 'Gold 22K (₹/g)')),
                          const SizedBox(width: 10),
                          Expanded(child: _liveField(e18k, 'Gold 18K (₹/g)')),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Row 2: 14K, Silver, Platinum
                      Row(
                        children: [
                          Expanded(child: _liveField(e14k, 'Gold 14K (₹/g)')),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _liveField(
                              eSil,
                              'Silver (₹/g)',
                              decimal: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _liveField(ePlt, 'Platinum (₹/g)')),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Row 3: Rose Gold, White Gold
                      Row(
                        children: [
                          Expanded(
                            child: _liveField(eRose, 'Rose Gold 18K (₹/g)'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _liveField(eWht, 'White Gold 18K (₹/g)'),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Dialog actions ───────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Apply values from editable fields
                        controller.updateRates(
                          g24k: int.tryParse(e24k.text),
                          g22k: int.tryParse(e22k.text),
                          g18k: int.tryParse(e18k.text),
                          g14k: int.tryParse(e14k.text),
                          silver: (double.tryParse(eSil.text) ?? liveSilver)
                              .toInt(),
                          platinum: int.tryParse(ePlt.text),
                          // Rhodium has no live source — keep current value
                          rhodium: controller.metals[6].rate.value,
                          roseGold18k: int.tryParse(eRose.text),
                          whiteGold18k: int.tryParse(eWht.text),
                        );
                        Get.back();
                        // Save to backend
                        final saved = await controller.saveRates();
                        _snack(
                          saved
                              ? 'Live rates applied & saved to database! Gold 22K: ₹${e22k.text}/g'
                              : 'Live rates applied locally. Gold 22K: ₹${e22k.text}/g',
                        );
                      },
                      icon: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.black,
                      ),
                      label: const Text(
                        'Apply & Save Rates',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
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
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Dispose controllers when dialog closes
    e24k.dispose();
    e22k.dispose();
    e18k.dispose();
    e14k.dispose();
    eSil.dispose();
    ePlt.dispose();
    eRose.dispose();
    eWht.dispose();
  }

  Widget _liveField(
    TextEditingController ctrl,
    String label, {
    bool decimal = false,
  }) => TextField(
    controller: ctrl,
    keyboardType: decimal
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.number,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
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
  );

  // ── Update Rates manually — mirrors Electron "Update Rates" modal ──
  void _showUpdateRates(BuildContext context) {
    final g24 = TextEditingController(
      text: '${controller.metals[0].rate.value}',
    );
    final g22 = TextEditingController(
      text: '${controller.metals[1].rate.value}',
    );
    final g18 = TextEditingController(
      text: '${controller.metals[2].rate.value}',
    );
    final g14 = TextEditingController(
      text: '${controller.metals[3].rate.value}',
    );
    final sil = TextEditingController(
      text: '${controller.metals[4].rate.value}',
    );
    final pla = TextEditingController(
      text: '${controller.metals[5].rate.value}',
    );
    final rho = TextEditingController(
      text: '${controller.metals[6].rate.value}',
    );
    final rose = TextEditingController(
      text: '${controller.metals[7].rate.value}',
    );
    final wht = TextEditingController(
      text: '${controller.metals[8].rate.value}',
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
              // Row 1: Gold 22K + 24K
              _row2Ctrl(g22, 'Gold 22K (₹/g)', g24, 'Gold 24K (₹/g)'),
              // Row 2: Gold 18K + 14K
              _row2Ctrl(g18, 'Gold 18K (₹/g)', g14, 'Gold 14K (₹/g)'),
              // Row 3: Silver + Platinum
              _row2Ctrl(sil, 'Silver (₹/g)', pla, 'Platinum (₹/g)'),
              // Row 4: Rhodium + Rose Gold
              _row2Ctrl(rho, 'Rhodium (₹/g)', rose, 'Rose Gold 18K (₹/g)'),
              // White Gold standalone
              _dlgField(
                wht,
                'White Gold 18K (₹/g)',
                keyboardType: TextInputType.number,
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
            onPressed: () async {
              // Apply to RxInt → Obx rebuilds UI immediately
              controller.updateRates(
                g24k: int.tryParse(g24.text),
                g22k: int.tryParse(g22.text),
                g18k: int.tryParse(g18.text),
                g14k: int.tryParse(g14.text),
                silver: int.tryParse(sil.text),
                platinum: int.tryParse(pla.text),
                rhodium: int.tryParse(rho.text),
                roseGold18k: int.tryParse(rose.text),
                whiteGold18k: int.tryParse(wht.text),
              );
              Get.back();
              // Save ALL 9 fields to backend
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

// ════════════════════════════════════════════════════════════════════
// Live Rates Comparison Table helpers
// mirrors Electron: the table inside the "Live International Spot Rates" modal
// ════════════════════════════════════════════════════════════════════
class _LiveRateRow {
  final String metal;
  final String usdOz;
  final int spotInr;
  final int currentInr;
  final Color color;

  const _LiveRateRow({
    required this.metal,
    required this.usdOz,
    required this.spotInr,
    required this.currentInr,
    required this.color,
  });

  int get diff => spotInr - currentInr;
  bool get isUp => diff >= 0;
  String get diffStr => '${isUp ? '+' : ''}₹${_fmt(diff.abs())}';

  static String _fmt(int v) {
    if (v >= 10000) {
      final s = v.toString();
      final last3 = s.substring(s.length - 3);
      final rest = s
          .substring(0, s.length - 3)
          .replaceAllMapped(
            RegExp(r'(\d{1,2})(?=(\d{2})+$)'),
            (m) => '${m[1]},',
          );
      return '$rest,$last3';
    }
    if (v >= 1000) {
      final s = v.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return v.toString();
  }
}

class _LiveRatesTable extends StatelessWidget {
  final List<_LiveRateRow> rows;
  const _LiveRatesTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Metal',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Intl (USD/oz)',
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
                    'Spot (₹/g)',
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
                    'Current',
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
                    'Diff',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          ...rows.map(
            (r) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      r.metal,
                      style: TextStyle(
                        color: r.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      r.usdOz,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${_LiveRateRow._fmt(r.spotInr)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${_LiveRateRow._fmt(r.currentInr)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      r.diffStr,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: r.isUp ? AppColors.success : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
}
