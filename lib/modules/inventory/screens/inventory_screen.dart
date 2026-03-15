import 'package:acme_killer_mobile_app/core/constants/app_colors.dart';
import 'package:acme_killer_mobile_app/core/controllers/store_controller.dart';
import 'package:acme_killer_mobile_app/modules/inventory/controllers/inventory_controller.dart';
import 'package:acme_killer_mobile_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryScreen extends GetView<InventoryController> {
  InventoryScreen({super.key});

  final storeController = Get.find<StoreController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: const Text(
          "Inventory",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.goldPrimary,
        onPressed: () => Get.toNamed(AppRoutes.addInventory),
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: Column(
        children: [
          /// STORE SELECTOR
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Obx(() {
              final stores = storeController.stores;
              final selected = storeController.selectedStore.value;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selected,
                    dropdownColor: AppColors.bgCard,
                    icon: const Icon(Icons.store, color: AppColors.goldPrimary),
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: stores.map((store) {
                      return DropdownMenuItem(
                        value: store,
                        child: Text(
                          store,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      storeController.selectedStore.value = value!;
                    },
                  ),
                ),
              );
            }),
          ),

          /// STATS
          Obx(() {
            final items = controller.filteredInventory;

            final inStock = items.where((e) => e.status == "In Stock").length;
            final lowStock = items.where((e) => e.status == "Low Stock").length;
            final value = items.fold(0, (sum, i) => sum + i.sellingPrice);

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  statCard("Total", items.length.toString()),
                  statCard("Stock", inStock.toString()),
                  statCard("Low", lowStock.toString()),
                  statCard("Value", "₹$value"),
                ],
              ),
            );
          }),

          /// SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: "Search item, HUID...",
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),

          const SizedBox(height: 10),

          /// FILTER CHIPS
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                filterChip("all"),
                filterChip("gold"),
                filterChip("silver"),
                filterChip("platinum"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// INVENTORY LIST
          Expanded(
            child: Obx(() {
              final items = controller.filteredInventory;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];

                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.inventoryDetail, arguments: item);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          /// ICON
                          const Icon(
                            Icons.diamond,
                            color: AppColors.goldPrimary,
                          ),

                          const SizedBox(width: 12),

                          /// ITEM INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  "${item.metal} • ${item.purity}",
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),

                                Text(
                                  "${item.netWeight} g",
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// PRICE + STATUS
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₹${item.sellingPrice}",
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: item.stockStatus == "Low Stock"
                                      ? AppColors.warning.withOpacity(.15)
                                      : AppColors.success.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.stockStatus,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: item.stockStatus == "Low Stock"
                                        ? AppColors.warning
                                        : AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void exportCSV() {
    String csv = "Name,Category,Metal,Purity,Weight,Price\n";

    for (var item in controller.inventory) {
      csv +=
          "${item.name},${item.category},${item.metal},${item.purity},${item.netWeight},${item.sellingPrice}\n";
    }

    print(csv); // later download

    Get.snackbar("Export", "Inventory exported successfully");
  }

  // void importCSV() {
  //   controller.inventory.add(
  //     Inventory(
  //       name: "Imported Ring",
  //       category: "Ring",
  //       metal: "Gold",
  //       purity: "22K",
  //       weight: 5,
  //       sellingPrice: 20000,
  //       status: "In Stock",
  //     ),
  //   );

  //   Get.snackbar("Import", "CSV Imported");
  // }

  /// STATS CARD
  Widget statCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.goldPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FILTER CHIP
  Widget filterChip(String value) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ChoiceChip(
          label: Text(value),
          labelStyle: const TextStyle(color: AppColors.textPrimary),
          selected: controller.selectedFilter.value == value,
          selectedColor: AppColors.goldPrimary,
          backgroundColor: AppColors.bgCard,
          onSelected: (_) => controller.selectedFilter.value = value,
        ),
      ),
    );
  }
}
