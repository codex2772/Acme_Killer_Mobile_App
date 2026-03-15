import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/billing_controller.dart';

class BillingScreen extends GetView<BillingController> {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.bgPrimary,
          title: const Text("Billing"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Invoices"),
              Tab(text: "Estimates"),
              Tab(text: "Credit Notes"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.goldPrimary,
          child: const Icon(Icons.add, color: Colors.black),
          onPressed: () => Get.toNamed("/create-invoice"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Search invoice"),
                onChanged: (v) => controller.searchQuery.value = v,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  invoiceList(),
                  const Center(child: Text("Estimates Coming Soon")),
                  const Center(child: Text("Credit Notes Coming Soon")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget invoiceList() {
    return Obx(() {
      if (controller.filteredInvoices.isEmpty) {
        return const Center(
          child: Text("No invoices yet", style: TextStyle(color: Colors.grey)),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredInvoices.length,
        itemBuilder: (_, i) {
          final inv = controller.filteredInvoices[i];

          return Card(
            color: AppColors.bgCard,
            child: ListTile(
              title: Text(inv.id),
              subtitle: Text(inv.customer),
              trailing: Text(
                "₹${inv.total}",
                style: const TextStyle(color: AppColors.goldPrimary),
              ),
              onTap: () {
                Get.toNamed("/invoice-detail", arguments: inv);
              },
            ),
          );
        },
      );
    });
  }
}
