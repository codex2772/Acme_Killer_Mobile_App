import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/billing/billing_item_model.dart'
    show BillingItem, MakingType;
import '../../../models/inventory_model.dart';
import '../controllers/billing_controller.dart';
import '../../rates_schemes/controllers/rates_schemes_controller.dart';

// ════════════════════════════════════════════════════════════════════
// InvoiceItemRow — StatefulWidget
//
// Key fixes:
//  1. Rate = live goldRate[purity] from RatesSchemesController
//     mirrors Electron: state.goldRate[item.purity] || sellingPrice/weight
//  2. Making: inventory stores flat ₹, BillingItem needs %.
//     Convert: makingPct = (flatMaking / metalValue) * 100
//  3. TextEditingControllers created ONCE — no rebuild flicker
// ════════════════════════════════════════════════════════════════════
class InvoiceItemRow extends StatefulWidget {
  final int index;
  const InvoiceItemRow({super.key, required this.index});
  @override
  State<InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends State<InvoiceItemRow> {
  late final BillingController ctrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _makingCtrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<BillingController>();
    final item = ctrl.items[widget.index];
    _weightCtrl = TextEditingController(text: _fmt(item.weight));
    _rateCtrl = TextEditingController(text: _fmt(item.rate));
    _makingCtrl = TextEditingController(text: _fmt(item.making));
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _rateCtrl.dispose();
    _makingCtrl.dispose();
    super.dispose();
  }

  String _fmt(double v) =>
      v == 0 ? '' : v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');

  void _updateControllers(BillingItem item) {
    _weightCtrl.text = _fmt(item.weight);
    _rateCtrl.text = _fmt(item.rate);
    _makingCtrl.text = _fmt(item.making);
  }

  // mirrors Electron: state.goldRate[item.purity] || sellingPrice / weight
  double _getLiveRate(InventoryItem inv) {
    try {
      final rates = Get.find<RatesSchemesController>();
      int liveRate = 0;
      if (inv.metal == 'Gold' ||
          inv.metal == 'Rose Gold' ||
          inv.metal == 'White Gold') {
        switch (inv.purity) {
          case '24K':
            liveRate = rates.metals[0].rate.value;
            break;
          case '22K':
            liveRate = rates.metals[1].rate.value;
            break;
          case '18K':
            liveRate = rates.metals[2].rate.value;
            break;
          case '14K':
            liveRate = rates.metals[3].rate.value;
            break;
          default:
            liveRate = rates.metals[1].rate.value;
        }
      } else if (inv.metal == 'Silver') {
        liveRate = rates.metals[4].rate.value;
      } else if (inv.metal == 'Platinum') {
        liveRate = rates.metals[5].rate.value;
      }
      if (liveRate > 0) return liveRate.toDouble();
    } catch (_) {}
    // Fallback: derive from sellingPrice / netWeight
    return inv.netWeight > 0 ? inv.sellingPrice / inv.netWeight : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.index >= ctrl.items.length) return const SizedBox.shrink();
      final item = ctrl.items[widget.index];

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item ${widget.index + 1}',
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    Obx(
                      () => Text(
                        '₹${ctrl.items[widget.index].total}',
                        style: const TextStyle(
                          color: AppColors.goldPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => ctrl.removeItem(widget.index),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Inventory picker ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: ctrl.items[widget.index].inventoryId.isEmpty
                        ? null
                        : ctrl.items[widget.index].inventoryId,
                    dropdownColor: AppColors.bgSecondary,
                    isExpanded: true,
                    hint: const Text(
                      'Select inventory item',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    items: ctrl.availableItems
                        .map(
                          (inv) => DropdownMenuItem<String>(
                            value: inv.id,
                            child: Text(
                              '${inv.name} — ${inv.purity} ${inv.netWeight}g',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      if (id == null) return;
                      final inv = ctrl.availableItems.firstWhereOrNull(
                        (i) => i.id == id,
                      );
                      if (inv == null) return;

                      final currentItem = ctrl.items[widget.index];

                      // ── Rate: live goldRate first, fallback sellingPrice/weight ──
                      final rate = _getLiveRate(inv);
                      final weight = double.parse(
                        inv.netWeight.toStringAsFixed(3),
                      );

                      // ── Making: inventory stores flat ₹ — use FLAT type directly ──
                      // mirrors Electron: makingInput.dataset.makingType = 'FLAT'
                      currentItem.name = inv.name;
                      currentItem.inventoryId = inv.id;
                      currentItem.backendId = inv.backendId;
                      currentItem.weight = weight;
                      currentItem.rate = rate;
                      currentItem.making = inv.makingCharge; // flat ₹
                      currentItem.makingType = MakingType.flat;
                      currentItem.purity = inv.purity;

                      _updateControllers(currentItem);
                      ctrl.recalculate();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Weight + Rate + Making ──
            Row(
              children: [
                Expanded(
                  child: _numField('Weight (g)', _weightCtrl, (v) {
                    ctrl.items[widget.index].weight =
                        double.tryParse(v) ?? ctrl.items[widget.index].weight;
                    ctrl.recalculate();
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _numField('Rate (₹/g)', _rateCtrl, (v) {
                    ctrl.items[widget.index].rate =
                        double.tryParse(v) ?? ctrl.items[widget.index].rate;
                    ctrl.recalculate();
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    final type = ctrl.items[widget.index].makingType;
                    final label = type == MakingType.flat
                        ? 'Making (₹)'
                        : 'Making %';
                    return _numField(label, _makingCtrl, (v) {
                      ctrl.items[widget.index].making =
                          double.tryParse(v) ?? ctrl.items[widget.index].making;
                      ctrl.recalculate();
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Breakdown ──
            Obx(() {
              final it = ctrl.items[widget.index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _calc('Metal', '₹${it.metalValue}'),
                  _calc('Making', '₹${it.makingValue}'),
                  _calc('Total', '₹${it.total}', bold: true),
                ],
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _numField(
    String label,
    TextEditingController ctrl,
    ValueChanged<String> onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            onChanged: onChange,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _calc(String label, String val, {bool bold = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
      ),
      Text(
        val,
        style: TextStyle(
          color: bold ? AppColors.goldPrimary : AppColors.textSecondary,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
      ),
    ],
  );
}
