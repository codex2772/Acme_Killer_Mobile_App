import 'package:acme_killer_mobile_app/core/controllers/store_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/drawer_controller.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final controller = Get.put(AppDrawerController());
  final storeController = Get.find<StoreController>();

  Widget navItem({
    required String title,
    required IconData icon,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      ),
      onTap: () {
        Get.back();
        Get.toNamed(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bgSecondary,
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.only(
              top: 40,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                SvgPicture.asset("assets/login/logo.svg", height: 40),

                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "JewelERP",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    Obx(
                      () => Text(
                        controller.role.value.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.goldPrimary,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// NAV ITEMS SCROLLABLE
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                navItem(
                  title: "Dashboard",
                  icon: Icons.diamond,
                  route: AppRoutes.dashboard,
                ),

                navItem(
                  title: "Inventory",
                  icon: Icons.inventory,
                  route: AppRoutes.inventory,
                ),

                navItem(
                  title: "Billing",
                  icon: Icons.receipt_long,
                  route: AppRoutes.billing,
                ),

                navItem(
                  title: "Customers",
                  icon: Icons.people,
                  route: AppRoutes.customers,
                ),

                navItem(
                  title: "Accounts",
                  icon: Icons.account_balance_wallet,
                  route: AppRoutes.accounts,
                ),

                navItem(title: "Rates", icon: Icons.sell, route: "/rates"),

                navItem(
                  title: "Old Gold",
                  icon: Icons.repeat,
                  route: "/old-gold",
                ),

                navItem(
                  title: "Schemes",
                  icon: Icons.card_giftcard,
                  route: "/schemes",
                ),

                navItem(
                  title: "Reports",
                  icon: Icons.bar_chart,
                  route: AppRoutes.reports,
                ),

                if (controller.role.value == "owner") ...[
                  navItem(title: "Staff", icon: Icons.badge, route: "/staff"),
                ],

                navItem(
                  title: "Settings",
                  icon: Icons.settings,
                  route: AppRoutes.settings,
                ),

                const SizedBox(height: 10),

                /// STORE SWITCHER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      dropdownColor: AppColors.bgSecondary,
                      decoration: const InputDecoration(
                        labelText: "Switch Store",
                        labelStyle: TextStyle(color: AppColors.textMuted),
                        border: OutlineInputBorder(),
                      ),
                      value: storeController.selectedStore.value,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text(
                            "All Stores",
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),

                        ...storeController.stores.map(
                          (store) => DropdownMenuItem(
                            value: store,
                            child: Text(
                              store.replaceAll("Rajmahal Jewellers - ", ""),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (String? value) {
                        storeController.changeStore(value);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          /// LOGOUT FIXED AT BOTTOM
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: controller.logout,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
