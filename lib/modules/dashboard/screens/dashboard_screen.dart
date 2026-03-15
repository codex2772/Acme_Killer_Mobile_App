import 'package:acme_killer_mobile_app/modules/dashboard/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/stat_card.dart';
import '../widgets/module_card.dart';
import '../widgets/quick_action_card.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        centerTitle: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: AppColors.textPrimary,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),

        title: Row(
          children: [
            Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            /// STORE SELECTOR
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            //   decoration: BoxDecoration(
            //     color: AppColors.bgSecondary,
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: DropdownButtonHideUnderline(
            //     child: DropdownButton<String>(
            //       value: controller.selectedStore.value,
            //       dropdownColor: AppColors.bgSecondary,
            //       icon: const Icon(Icons.keyboard_arrow_down),
            //       style: const TextStyle(
            //         color: AppColors.textPrimary,
            //         fontSize: 10,
            //       ),
            //       items: controller.stores.map((store) {
            //         return DropdownMenuItem(value: store, child: Text(store));
            //       }).toList(),
            //       onChanged: (value) {
            //         controller.selectedStore.value = value!;
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),

        actions: [
          /// NOTIFICATION
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: AppColors.textPrimary,
            onPressed: () {},
          ),

          /// PROFILE
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.goldPrimary, width: 2),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.goldPrimary,
              child: Text(
                "OW",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// =========================
            /// STATS
            /// =========================
            Obx(
              () => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // StatCard(
                  //   title: "Inventory",
                  //   value: controller.totalInventory.toString(),
                  //   icon: Icons.inventory_2_outlined,
                  //   color: AppColors.goldPrimary,
                  // ),
                  StatCard(
                    title: "Today's Sales",
                    value: "₹${controller.todaySales}",
                    icon: Icons.receipt_long,
                    color: Colors.green,
                  ),

                  StatCard(
                    title: "Customers",
                    value: controller.activeCustomers.value.toString(),
                    icon: Icons.people_alt_outlined,
                    color: Colors.blue,
                  ),

                  StatCard(
                    title: "Gold Rate",
                    value: "₹${controller.goldRate.value}/g",
                    icon: Icons.sell_outlined,
                    color: AppColors.goldLight,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// =========================
            /// ALERTS
            /// =========================
            // Obx(() {
            //   if (controller.lowStockItems == 0 &&
            //       controller.pendingInvoices == 0) {
            //     return const SizedBox();
            //   }

            //   return Container(
            //     padding: const EdgeInsets.all(14),
            //     decoration: BoxDecoration(
            //       color: Colors.red.withOpacity(.1),
            //       borderRadius: BorderRadius.circular(14),
            //     ),
            //     child: Row(
            //       children: [
            //         const Icon(Icons.warning_amber_rounded, color: Colors.red),

            //         const SizedBox(width: 10),

            //         Expanded(
            //           child: Text(
            //             "${controller.pendingInvoices} invoices pending • ₹${controller.pendingAmount}",
            //             style: const TextStyle(color: AppColors.textPrimary),
            //           ),
            //         ),
            //       ],
            //     ),
            //   );
            // }),
            const SizedBox(height: 30),

            /// =========================
            /// QUICK ACTIONS
            /// =========================
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  QuickActionCard(title: "New Invoice", icon: Icons.receipt),

                  QuickActionCard(
                    title: "Add Item",
                    icon: Icons.add_box_outlined,
                  ),

                  QuickActionCard(
                    title: "Customer",
                    icon: Icons.person_add_alt,
                  ),

                  if (controller.role.value == "owner")
                    QuickActionCard(title: "Add Staff", icon: Icons.person_add)
                  else
                    QuickActionCard(
                      title: "Record Payment",
                      icon: Icons.currency_rupee,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// =========================
            /// MODULES
            /// =========================
            const Text(
              "Modules",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 14),

            Obx(
              () => GridView.builder(
                itemCount: controller.modules.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (_, index) {
                  final module = controller.modules[index];

                  return ModuleCard(
                    title: module["title"]!,
                    count: module["count"]!,
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            /// =========================
            /// RECENT INVOICES
            /// =========================
            const Text(
              "Recent Invoices",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            Obx(
              () => Column(
                children: controller.invoices.map((invoice) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: AppColors.goldPrimary,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice["customer"].toString(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                invoice["date"].toString(),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          invoice["amount"].toString(),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      /// =========================
      /// BOTTOM NAV
      /// =========================
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgSecondary,
        selectedItemColor: AppColors.goldPrimary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Billing",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Customers"),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: "Modules"),
        ],
      ),
    );
  }
}
