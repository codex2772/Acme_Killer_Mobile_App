import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/inventory_card.dart';

class InventoryScreen extends StatefulWidget {
  InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late final InventoryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<InventoryController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshIfStale();
    });
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
          'Inventory',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Export
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Export',
            onPressed: _showExportSheet,
          ),
          // Add
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addInventory),
              icon: const Icon(Icons.add, color: Colors.black, size: 16),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Stats row ──
          Obx(() => _statsRow()),
          const SizedBox(height: 2),

          // ── Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search name, HUID, barcode...',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (v) => controller.searchQuery.value = v,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Filter pills ──
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _pill('all', 'All'),
                _pill('gold', 'Gold'),
                _pill('silver', 'Silver'),
                _pill('platinum', 'Platinum'),
                _pill('diamond', 'Diamond'),
                _pill('lowstock', '⚠ Low Stock', warning: true),
                // mirrors Electron: outofstock filter pill
                _pill('outofstock', '✕ Out of Stock', danger: true),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── List ──
          Expanded(
            child: Obx(() {
              final items = controller.filteredInventory;
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.goldPrimary,
                  ),
                );
              }
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.textMuted,
                        size: 52,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No items found',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.addInventory),
                        child: const Text(
                          'Add first item',
                          style: TextStyle(color: AppColors.goldPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.goldPrimary,
                backgroundColor: AppColors.bgSecondary,
                onRefresh: () => controller.refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return InventoryCard(
                      item: item,
                      onTap: () => Get.toNamed(
                        AppRoutes.inventoryDetail,
                        arguments: item,
                      ),
                      onEdit: () =>
                          Get.toNamed(AppRoutes.editInventory, arguments: item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Stats row ──
  Widget _statsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        children: [
          _statChip('${controller.totalItems}', 'Total', AppColors.goldPrimary),
          _statChip(
            '${controller.inStockCount}',
            'In Stock',
            AppColors.success,
          ),
          _statChip(
            '${controller.lowStockCount}',
            'Low Stock',
            AppColors.warning,
          ),
          _statChipWide(
            controller.stockValueFormatted,
            'Value',
            AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _statChip(String val, String label, Color color) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    ),
  );

  Widget _statChipWide(String val, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    ),
  );

  // ── Filter pill ──
  Widget _pill(
    String value,
    String label, {
    bool warning = false,
    bool danger = false,
  }) {
    return Obx(() {
      final active = controller.selectedFilter.value == value;
      final color = danger
          ? AppColors.error
          : warning
          ? AppColors.warning
          : AppColors.goldPrimary;
      return GestureDetector(
        onTap: () => controller.selectedFilter.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : color,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  // ── Export bottom sheet ──
  void _showExportSheet() {
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
            const SizedBox(height: 16),
            const Text(
              'Export Inventory',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${controller.filteredInventory.length} items will be exported',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _exportBtn('CSV', Icons.table_chart_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _exportBtn('Excel', Icons.grid_on_outlined)),
                const SizedBox(width: 10),
                Expanded(
                  child: _exportBtn('PDF', Icons.picture_as_pdf_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportBtn(String label, IconData icon) => GestureDetector(
    onTap: () {
      Get.back();
      Get.snackbar(
        'Export',
        '$label export coming soon',
        backgroundColor: AppColors.bgCard,
        colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.goldPrimary, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
