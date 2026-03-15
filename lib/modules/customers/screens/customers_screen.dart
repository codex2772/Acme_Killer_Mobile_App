import 'package:acme_killer_mobile_app/modules/customers/widgets/customer_card.dart';
import 'package:acme_killer_mobile_app/modules/customers/widgets/customer_reminders.dart';
import 'package:acme_killer_mobile_app/modules/customers/widgets/customer_stats.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/customer_controller.dart';

class CustomersScreen extends GetView<CustomerController> {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: const Text(
          "Customers",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.goldPrimary,
        onPressed: () => Get.toNamed(AppRoutes.addCustomer),
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: Column(
        children: [
          const CustomerStats(),
          const CustomerReminders(),
          SizedBox(height: 10),

          /// =========================
          /// SEARCH
          /// =========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: "Search customers...",
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),

          const SizedBox(height: 10),

          /// =========================
          /// FILTERS
          /// =========================
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                filterChip("all"),
                filterChip("vip"),
                filterChip("premium"),
                filterChip("regular"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// =========================
          /// CUSTOMER LIST
          /// =========================
          Expanded(
            child: Obx(() {
              final list = controller.filteredCustomers;

              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    "No customers found",
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                );
              }

              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, index) {
                  final customer = list[index];

                  return CustomerCard(
                    customer: customer,
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.customerProfile,
                        arguments: customer,
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// FILTER CHIP
  /// =========================

  Widget filterChip(String value) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ChoiceChip(
          label: Text(
            value,
            style: TextStyle(
              color: controller.filter.value == value
                  ? Colors.black
                  : AppColors.textPrimary,
            ),
          ),
          selected: controller.filter.value == value,
          selectedColor: AppColors.goldPrimary,
          backgroundColor: AppColors.bgCard,
          onSelected: (_) => controller.filter.value = value,
        ),
      ),
    );
  }
}
