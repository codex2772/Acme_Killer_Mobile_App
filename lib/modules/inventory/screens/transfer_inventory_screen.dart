import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/store_controller.dart';
import '../../../models/inventory_model.dart';
import '../controllers/inventory_controller.dart';

class TransferInventoryScreen extends StatefulWidget {
  const TransferInventoryScreen({super.key});
  @override
  State<TransferInventoryScreen> createState() => _TransferInventoryScreenState();
}

class _TransferInventoryScreenState extends State<TransferInventoryScreen> {
  late InventoryItem _item;
  String? _targetStore;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _item = Get.arguments as InventoryItem;
  }

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  void _transfer() {
    if (_targetStore == null || _targetStore == _item.store) {
      Get.snackbar('Select Store', 'Please select a different store',
          backgroundColor: AppColors.bgCard, colorText: AppColors.warning,
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
      return;
    }
    Get.find<InventoryController>().transferItem(_item.id, _targetStore!);
    Get.back();
    Get.snackbar('Transferred',
        '"${_item.name}" transferred to ${_targetStore!.replaceAll('Rajmahal Jewellers - ', '')}',
        backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
  }

  @override
  Widget build(BuildContext context) {
    final storeCtrl = Get.find<StoreController>();
    final stores = storeCtrl.stores.where((s) => s.name != _item.store).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text('Transfer Item',
            style: TextStyle(color: AppColors.textPrimary,
                fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Item card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.diamond_outlined,
                    color: AppColors.goldPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_item.name, style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  Text('${_item.metal} ${_item.purity}  •  ${_item.netWeight}g',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              )),
              Text(_item.formattedPrice,
                  style: const TextStyle(color: AppColors.goldPrimary,
                      fontWeight: FontWeight.bold)),
            ]),
          ),

          const SizedBox(height: 20),

          // ── From ──
          const Text('From Store',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              const Icon(Icons.store_outlined,
                  color: AppColors.textMuted, size: 16),
              const SizedBox(width: 10),
              Text(_item.store.replaceAll('Rajmahal Jewellers - ', ''),
                  style: const TextStyle(color: AppColors.textPrimary)),
            ]),
          ),

          const SizedBox(height: 8),
          const Center(child: Icon(Icons.swap_vert_rounded,
              color: AppColors.goldPrimary, size: 28)),
          const SizedBox(height: 8),

          // ── To ──
          const Text('To Store *',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _targetStore == null ? AppColors.border : AppColors.goldPrimary),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _targetStore,
                dropdownColor: AppColors.bgSecondary,
                hint: const Text('Select destination store',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                isExpanded: true,
                iconEnabledColor: AppColors.goldPrimary,
                items: stores.map((s) => DropdownMenuItem(
                  value: s.name,
                  child: Text(s.shortName,
                      style: const TextStyle(color: AppColors.textPrimary)),
                )).toList(),
                onChanged: (v) => setState(() => _targetStore = v),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Note ──
          const Text('Transfer Note (Optional)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _noteCtrl,
              maxLines: 2,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Reason for transfer...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _targetStore == null ? null : _transfer,
              icon: const Icon(Icons.swap_horiz_rounded, color: Colors.black),
              label: const Text('Transfer Item',
                  style: TextStyle(color: Colors.black,
                      fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                disabledBackgroundColor: AppColors.goldPrimary.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
