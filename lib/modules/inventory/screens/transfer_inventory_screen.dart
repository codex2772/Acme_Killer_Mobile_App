import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/store_controller.dart';
import '../controllers/inventory_controller.dart';
import '../../../models/inventory_model.dart';

class TransferInventoryScreen extends StatelessWidget {

  const TransferInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final InventoryItem item = Get.arguments;

    final storeController = Get.find<StoreController>();
    final inventoryController = Get.find<InventoryController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Transfer Item")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Text("Item: ${item.name}"),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              items: storeController.stores
                  .map((store) => DropdownMenuItem(
                        value: store,
                        child: Text(store),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  inventoryController.transferItem(item.id, value);
                  Get.back();
                }
              },
              decoration: const InputDecoration(
                labelText: "Select Store",
              ),
            ),
          ],
        ),
      ),
    );
  }
}