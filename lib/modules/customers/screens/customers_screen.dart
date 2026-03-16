import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/customer_controller.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_reminders.dart';
import '../widgets/customer_stats.dart';

class CustomersScreen extends GetView<CustomerController> {
  const CustomersScreen({super.key});

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
          'Customers',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Export CSV',
            onPressed: () => Get.snackbar(
              'Export',
              'Customers exported to CSV',
              backgroundColor: AppColors.bgCard,
              colorText: AppColors.textPrimary,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addCustomer),
              icon: const Icon(Icons.add, color: Colors.black, size: 16),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Stats ──
          const CustomerStats(),
          const SizedBox(height: 10),

          // ── Reminders ──
          const CustomerReminders(),

          // ── Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search customers...',
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
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _pill('all', 'All'),
                _pill('vip', 'VIP'),
                _pill('premium', 'Premium'),
                _pill('regular', 'Regular'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── List ──
          Expanded(
            child: Obx(() {
              final list = controller.filteredCustomers;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        color: AppColors.textMuted,
                        size: 52,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No customers found',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.addCustomer),
                        child: const Text(
                          'Add first customer',
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
                onRefresh: () async => controller.customers.refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final c = list[i];
                    return CustomerCard(
                      customer: c,
                      onTap: () =>
                          Get.toNamed(AppRoutes.customerProfile, arguments: c),
                      onWhatsApp: () => _openWhatsApp(c),
                      onNewInvoice: () => Get.toNamed(AppRoutes.createInvoice),
                      onEdit: () =>
                          Get.toNamed(AppRoutes.editCustomer, arguments: c),
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

  void _openWhatsApp(customer) {
    Get.snackbar(
      'WhatsApp',
      'Opening WhatsApp for ${customer.name}',
      backgroundColor: AppColors.bgCard,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  Widget _pill(String value, String label) {
    return Obx(() {
      final active = controller.filter.value == value;
      return GestureDetector(
        onTap: () => controller.filter.value = value,
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
}
