import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/store_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/drawer_controller.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final AppDrawerController _ctrl = Get.find<AppDrawerController>();
  final StoreController _store = Get.find<StoreController>();
  AuthController get _auth => Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bgSecondary,
      child: Column(
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                // Avatar with initials
                Obx(() => Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(_ctrl.userInitials,
                          style: const TextStyle(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    )),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            _ctrl.userName.isEmpty ? 'JewelERP' : _ctrl.userName,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          )),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            _ctrl.role.toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.goldPrimary, fontSize: 11,
                                letterSpacing: 1.2, fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                ),
                SvgPicture.asset('assets/login/logo.svg', height: 28),
              ],
            ),
          ),

          // ── Nav items ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _item('Dashboard', Icons.diamond_outlined, AppRoutes.dashboard),
                _item('Inventory', Icons.inventory_2_outlined, AppRoutes.inventory, module: 'inventory'),
                _item('Billing', Icons.receipt_long_outlined, AppRoutes.billing, module: 'billing'),
                _item('Customers', Icons.people_outline, AppRoutes.customers, module: 'customers'),
                _item('Accounts', Icons.account_balance_wallet_outlined, AppRoutes.accounts, module: 'accounts'),
                _item("Today's Rates", Icons.sell_outlined, AppRoutes.todayRates, module: 'todayRates'),
                _item('Old Gold', Icons.repeat_rounded, AppRoutes.oldGold, module: 'oldGold'),
                _item('Schemes', Icons.card_giftcard_outlined, AppRoutes.schemes, module: 'schemes'),
                _item('Reports', Icons.bar_chart_rounded, AppRoutes.reports, module: 'reports'),

                // Staff — only if canAccess
                Obx(() => _auth.canAccess('staff')
                    ? _item('Staff', Icons.badge_outlined, AppRoutes.staff)
                    : const SizedBox.shrink()),

                _item('Settings', Icons.settings_outlined, AppRoutes.settings),

                const SizedBox(height: 10),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 10),

                // ── Store switcher ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() => DropdownButtonFormField<String>(
                        dropdownColor: AppColors.bgSecondary,
                        iconEnabledColor: AppColors.textSecondary,
                        decoration: InputDecoration(
                          labelText: 'Switch Store',
                          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.goldPrimary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        value: _store.selectedStoreName,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Stores',
                                style: TextStyle(color: AppColors.textPrimary)),
                          ),
                          ..._store.stores.map((s) => DropdownMenuItem(
                                value: s.name,
                                child: Text(s.shortName,
                                    style: const TextStyle(color: AppColors.textPrimary)),
                              )),
                        ],
                        onChanged: _store.changeStoreByName,
                      )),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Logout ──
          const Divider(color: AppColors.border, height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Logout',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
            onTap: _ctrl.logout,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _item(String title, IconData icon, String route, {String? module}) {
    if (module != null && !_auth.canAccess(module)) return const SizedBox.shrink();

    final isCurrent = Get.currentRoute == route;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(icon,
          color: isCurrent ? AppColors.goldPrimary : AppColors.textSecondary, size: 21),
      title: Text(title,
          style: TextStyle(
              color: isCurrent ? AppColors.goldPrimary : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal)),
      tileColor: isCurrent ? AppColors.goldPrimary.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        Get.back();
        if (Get.currentRoute != route) Get.toNamed(route);
      },
    );
  }
}
