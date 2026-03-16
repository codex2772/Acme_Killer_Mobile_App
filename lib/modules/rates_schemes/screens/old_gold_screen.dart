import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/rates_schemes_controller.dart';

// ─────────────────────────────────────────────────────────────
// OLD GOLD LIST SCREEN
// ─────────────────────────────────────────────────────────────
class OldGoldScreen extends GetView<RatesSchemesController> {
  const OldGoldScreen({super.key});

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
          'Old Gold Purchase',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addOldGold),
              icon: const Icon(Icons.add, size: 14, color: Colors.black),
              label: const Text(
                'New',
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
                  vertical: 0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats
          Obx(() {
            final list = controller.oldGoldPurchases;
            final totalWeight = list.fold(0.0, (s, p) => s + p.weight);
            final totalValue = list.fold(0, (s, p) => s + p.totalNum);
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  _chip('${list.length}', 'Purchases', AppColors.goldPrimary),
                  _chip(
                    '${totalWeight.toStringAsFixed(1)}g',
                    'Total Weight',
                    AppColors.info,
                  ),
                  _chip(
                    controller.fmt(totalValue),
                    'Total Value',
                    AppColors.success,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),

          // Filter pills
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _pill('all', 'All'),
                _pill('exchange', 'Exchange'),
                _pill('purchase', 'Purchase'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: Obx(() {
              final list = controller.filteredOldGold;
              if (list.isEmpty)
                return const Center(
                  child: Text(
                    'No old gold entries',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                );
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
                itemCount: list.length,
                itemBuilder: (_, i) => _OGCard(entry: list[i]),
              );
            }),
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
              fontSize: 13,
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

  Widget _pill(String val, String label) => Obx(() {
    final active = controller.ogFilter.value == val;
    return GestureDetector(
      onTap: () => controller.ogFilter.value = val,
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
}

class _OGCard extends StatelessWidget {
  final OldGoldEntry entry;
  const _OGCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isExchange = entry.type == 'Exchange';
    final typeColor = isExchange ? AppColors.success : AppColors.info;
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.oldGoldDetail, arguments: entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
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
                  child: const Icon(
                    Icons.autorenew_rounded,
                    color: AppColors.goldPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.id,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        entry.customer,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            '${entry.weight}g ${entry.purity}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '@ ₹${entry.rate}/g',
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
                      entry.formattedTotal,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _badge(entry.type, typeColor),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _meta(
                  Icons.science_outlined,
                  entry.purityTest?.method ?? 'Pending',
                  color: entry.purityTest != null
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const SizedBox(width: 12),
                _meta(
                  Icons.shield_outlined,
                  entry.kycDone ? 'KYC Done' : 'KYC Required',
                  color: entry.kycDone ? AppColors.success : AppColors.error,
                ),
                const Spacer(),
                _meta(Icons.calendar_today_outlined, _fmt(entry.date)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withOpacity(0.35)),
    ),
    child: Text(
      t,
      style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );

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
// ADD OLD GOLD SCREEN
// ─────────────────────────────────────────────────────────────
class AddOldGoldScreen extends StatefulWidget {
  const AddOldGoldScreen({super.key});
  @override
  State<AddOldGoldScreen> createState() => _AddOldGoldScreenState();
}

class _AddOldGoldScreenState extends State<AddOldGoldScreen> {
  final _ctrl = Get.find<RatesSchemesController>();

  final _custCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _actualPurity = TextEditingController();
  final _purityPct = TextEditingController();
  final _idNumber = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _type = 'Exchange';
  String _purity = '22K';
  String _testMethod = 'XRF';
  String _idType = 'Aadhaar';

  int get _total {
    final w = double.tryParse(_weightCtrl.text) ?? 0;
    final r = int.tryParse(_rateCtrl.text) ?? _ctrl.goldRate22k;
    return (w * r).round();
  }

  @override
  void initState() {
    super.initState();
    _rateCtrl.text = '${_ctrl.goldRate22k}';
  }

  @override
  void dispose() {
    for (final c in [
      _custCtrl,
      _weightCtrl,
      _rateCtrl,
      _actualPurity,
      _purityPct,
      _idNumber,
      _notesCtrl,
    ])
      c.dispose();
    super.dispose();
  }

  void _submit() {
    if (_custCtrl.text.trim().isEmpty || _weightCtrl.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Customer and weight are required',
        backgroundColor: AppColors.error.withOpacity(0.2),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    final newId =
        'OG${(_ctrl.oldGoldPurchases.length + 1).toString().padLeft(3, '0')}';
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final rate = int.tryParse(_rateCtrl.text) ?? _ctrl.goldRate22k;
    _ctrl.addOldGold(
      OldGoldEntry(
        id: newId,
        customer: _custCtrl.text.trim(),
        customerId: null,
        weight: weight,
        purity: _purity,
        rate: rate,
        totalNum: _total,
        date: DateTime.now().toIso8601String().substring(0, 10),
        type: _type,
        store: 'Rajmahal Jewellers - Main',
        purityTest: _testMethod.isNotEmpty
            ? PurityTest(
                method: _testMethod,
                actualPurity: _actualPurity.text.isEmpty
                    ? _purity
                    : _actualPurity.text,
                purityPercent: _purityPct.text.isEmpty ? '—' : _purityPct.text,
                testedBy: 'Staff',
              )
            : null,
        kycDone: _total > 50000,
        notes: _notesCtrl.text.trim(),
      ),
    );
    Get.back();
    Get.snackbar(
      'Entry Saved',
      '${_weightCtrl.text}g $_purity — ${_ctrl.fmt(_total)}',
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
          'New Old Gold Entry',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            'Customer & Type',
            Icons.person_outline,
            Column(
              children: [
                _tf(_custCtrl, 'Customer Name *', hint: 'e.g., Priya Sharma'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _typeBtn('Exchange')),
                    const SizedBox(width: 10),
                    Expanded(child: _typeBtn('Purchase')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _card(
            'Gold Details',
            Icons.scale_outlined,
            Column(
              children: [
                _row3(
                  _tf(
                    _weightCtrl,
                    'Weight (g) *',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  _dd(
                    'Purity',
                    ['22K', '18K', '24K', '14K'],
                    _purity,
                    (v) => setState(() {
                      _purity = v!;
                      if (_rateCtrl.text.isEmpty)
                        _rateCtrl.text = '${_ctrl.goldRate22k}';
                    }),
                  ),
                  _tf(
                    _rateCtrl,
                    'Rate (₹/g)',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 10),
                // Live total
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.goldPrimary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated Value',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _ctrl.fmt(_total),
                        style: const TextStyle(
                          color: AppColors.goldPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _card(
            'Purity Testing',
            Icons.science_outlined,
            Column(
              children: [
                _row3(
                  _dd(
                    'Test Method',
                    ['XRF', 'Touchstone', 'Acid Test'],
                    _testMethod,
                    (v) => setState(() => _testMethod = v!),
                  ),
                  _tf(_actualPurity, 'Actual Purity', hint: 'e.g., 21.8K'),
                  _tf(_purityPct, 'Purity %', hint: 'e.g., 90.8%'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (_total > 50000) ...[
            _card(
              'KYC (Required > ₹50,000)',
              Icons.shield_outlined,
              Column(
                children: [
                  _row2(
                    _dd(
                      'ID Type',
                      ['Aadhaar', 'PAN', 'Voter ID'],
                      _idType,
                      (v) => setState(() => _idType = v!),
                    ),
                    _tf(_idNumber, 'ID Number'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          _card(
            'Notes',
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
                  hintText: 'Additional notes...',
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
                    backgroundColor: AppColors.goldPrimary,
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

  Widget _typeBtn(String val) => GestureDetector(
    onTap: () => setState(() => _type = val),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _type == val
            ? AppColors.goldPrimary.withOpacity(0.15)
            : AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _type == val ? AppColors.goldPrimary : AppColors.border,
          width: _type == val ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: Text(
          val,
          style: TextStyle(
            color: _type == val
                ? AppColors.goldPrimary
                : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: _type == val ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    ),
  );

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

  Widget _tf(
    TextEditingController ctrl,
    String label, {
    String? hint,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) => Column(
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
          onChanged: onChanged,
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
      const SizedBox(height: 10),
    ],
  );

  Widget _dd(
    String label,
    List<String> items,
    String val,
    ValueChanged<String?> onChange,
  ) => Column(
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
            value: val,
            isExpanded: true,
            dropdownColor: AppColors.bgSecondary,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
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
        ),
      ),
      const SizedBox(height: 10),
    ],
  );

  Widget _row2(Widget a, Widget b) => Row(
    children: [
      Expanded(
        child: Padding(padding: const EdgeInsets.only(right: 6), child: a),
      ),
      Expanded(
        child: Padding(padding: const EdgeInsets.only(left: 6), child: b),
      ),
    ],
  );
  Widget _row3(Widget a, Widget b, Widget c) => Row(
    children: [
      Expanded(
        child: Padding(padding: const EdgeInsets.only(right: 4), child: a),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: b,
        ),
      ),
      Expanded(
        child: Padding(padding: const EdgeInsets.only(left: 4), child: c),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────
// OLD GOLD DETAIL SCREEN
// ─────────────────────────────────────────────────────────────
class OldGoldDetailScreen extends StatelessWidget {
  const OldGoldDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OldGoldEntry og = Get.arguments as OldGoldEntry;
    final typeColor = og.type == 'Exchange'
        ? AppColors.success
        : AppColors.info;

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
          og.id,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.print_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () => Get.snackbar(
              'Print',
              'Receipt sent to printer',
              backgroundColor: AppColors.bgCard,
              colorText: AppColors.textPrimary,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.autorenew_rounded,
                    color: AppColors.goldPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        og.customer,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _badge(og.type, typeColor),
                          const SizedBox(width: 8),
                          _badge(
                            og.kycDone ? 'KYC Done' : 'KYC Required',
                            og.kycDone ? AppColors.success : AppColors.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  og.formattedTotal,
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Gold details
          _detailCard('Gold Details', Icons.scale_outlined, [
            _row('Weight', '${og.weight}g'),
            _row('Purity', og.purity),
            _row('Rate', '₹${og.rate}/g'),
            _row('Total Value', og.formattedTotal),
            _row('Date', _fmt(og.date)),
            if (og.notes.isNotEmpty) _row('Notes', og.notes),
          ]),
          const SizedBox(height: 12),

          // Purity test
          _detailCard(
            'Purity Test Result',
            Icons.science_outlined,
            og.purityTest != null
                ? [
                    _row('Method', og.purityTest!.method),
                    _row('Actual Purity', og.purityTest!.actualPurity),
                    _row('Purity %', og.purityTest!.purityPercent),
                    _row('Tested By', og.purityTest!.testedBy),
                  ]
                : [
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'No purity test recorded',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ],
          ),

          // Melting record
          if (og.meltingRecord != null) ...[
            const SizedBox(height: 12),
            _detailCard('Melting Record', Icons.whatshot_outlined, [
              _row('Melted Weight', '${og.meltingRecord!.meltedWeight}g'),
              _row('Melt Date', _fmt(og.meltingRecord!.meltDate)),
              _row('Melted By', og.meltingRecord!.meltedBy),
              _row(
                'Weight Loss',
                '${(og.weight - double.parse(og.meltingRecord!.meltedWeight)).toStringAsFixed(2)}g',
              ),
            ]),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _detailCard(String title, IconData icon, List<Widget> rows) =>
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
            ...rows,
          ],
        ),
      );

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  static Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withOpacity(0.35)),
    ),
    child: Text(
      t,
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
