import 'package:acme_killer_mobile_app/core/constants/app_colors.dart';
import 'package:acme_killer_mobile_app/models/inventory_model.dart';
import 'package:acme_killer_mobile_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryDetailScreen extends StatelessWidget {
  const InventoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryItem item = Get.arguments as InventoryItem;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Text(
          item.name,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Get.toNamed(AppRoutes.editInventory, arguments: item);
                },
                child: const Text(
                  "Edit Item",
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Get.toNamed(AppRoutes.transferInventory, arguments: item);
                },
                child: const Text(
                  "Transfer Item",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEADER CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.diamond,
                    size: 40,
                    color: AppColors.goldPrimary,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          item.category,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        Text(
                          "HUID: ${item.huid}",
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    "₹${item.sellingPrice}",
                    style: const TextStyle(
                      color: AppColors.goldPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// DETAILS CARD
            detailCard("Metal", item.metal),
            detailCard("Purity", item.purity),
            detailCard("Net Weight", "${item.netWeight} g"),
            detailCard("Gross Weight", "${item.grossWeight} g"),
            detailCard("Cost Price", "₹${item.costPrice}"),
            detailCard("Selling Price", "₹${item.sellingPrice}"),
            detailCard("Status", item.stockStatus),
            detailCard("Store", item.store),
            detailCard("Margin", "${item.margin.toStringAsFixed(1)} %"),
            detailCard("Profit", "₹${item.profit}"),

            const SizedBox(height: 20),

            /// QR CODE BUTTON
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
              ),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    backgroundColor: AppColors.bgCard,
                    title: const Text("QR Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code,
                          size: 150,
                          color: AppColors.goldPrimary,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          item.id,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code, color: Colors.black),
              label: const Text(
                "Show QR",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
