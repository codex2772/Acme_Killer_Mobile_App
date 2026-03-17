import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/alert_banner.dart';
import '../widgets/app_drawer.dart';
import '../widgets/module_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_invoice_row.dart';
import '../widgets/stat_card.dart';

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
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                controller.storeName,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Demo badge
          Obx(
            () => controller.isDemo
                ? Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.4),
                      ),
                    ),
                    child: const Text(
                      'DEMO',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Notification
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),

          // Avatar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Obx(() {
              final auth = Get.find<AuthController>();
              return GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.goldPrimary.withOpacity(0.2),
                    border: Border.all(
                      color: AppColors.goldPrimary,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    auth.userInitials,
                    style: const TextStyle(
                      color: AppColors.goldPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),

      body: RefreshIndicator(
        color: AppColors.goldPrimary,
        backgroundColor: AppColors.bgSecondary,
        onRefresh: controller.refresh,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.goldPrimary),
            );
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting ──
                _greeting(),
                const SizedBox(height: 18),

                // ── Stats grid (2×2) ──
                _sectionLabel('Overview'),
                const SizedBox(height: 10),
                _statsGrid(),
                const SizedBox(height: 16),

                // ── Alerts ──
                _alerts(),

                // ── Quick Actions ──
                _sectionLabel('Quick Actions'),
                const SizedBox(height: 10),
                _quickActions(),
                const SizedBox(height: 20),

                // ── Modules grid ──
                _sectionLabel('Modules'),
                const SizedBox(height: 10),
                _modulesGrid(),
                const SizedBox(height: 20),

                // ── Recent Invoices ──
                _recentInvoicesHeader(),
                const SizedBox(height: 10),
                _recentInvoices(),
              ],
            ),
          );
        }),
      ),

      bottomNavigationBar: _bottomNav(),
    );
  }

  // ─────────────────────────────────────────────────────────
  // GREETING
  // ─────────────────────────────────────────────────────────
  Widget _greeting() {
    final hour = DateTime.now().hour;
    final greet = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greet,',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              Obx(
                () => Text(
                  controller.userName.isEmpty
                      ? 'Welcome back!'
                      : controller.userName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Gold rate pill
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: AppColors.goldPrimary, size: 7),
                const SizedBox(width: 5),
                Text(
                  '22K ₹${controller.gold22k.value}/g',
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // STATS GRID  (2 columns, matches desktop 4 stat cards)
  // ─────────────────────────────────────────────────────────
  Widget _statsGrid() {
    return Obx(
      () => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.30,
        children: [
          StatCard(
            title: 'Total Inventory',
            value: controller.totalInventory.value.toString(),
            sub: '${controller.lowStockCount.value} low stock',
            trend: '+12',
            icon: Icons.inventory_2_outlined,
            color: AppColors.goldPrimary,
          ),
          StatCard(
            title: "Today's Sales",
            value: controller.formatCurrency(controller.todaySales.value),
            sub: '${controller.pendingInvoiceCount.value} pending',
            trend: '+23%',
            icon: Icons.receipt_long_outlined,
            color: AppColors.success,
          ),
          StatCard(
            title: 'Active Customers',
            value: controller.activeCustomers.value.toString(),
            sub: '${controller.vipCustomers.value} VIP',
            trend: '+5',
            icon: Icons.people_alt_outlined,
            color: AppColors.info,
          ),
          StatCard(
            title: 'Gold Rate (22K)',
            value: controller.gold22kDisplay,
            sub: controller.gold22kTola,
            trend: '+0.8%',
            icon: Icons.sell_outlined,
            color: const Color(0xFFF0D060),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // ALERTS (mirrors alerts-banner in dashboard.js)
  // ─────────────────────────────────────────────────────────
  Widget _alerts() {
    return Obx(() {
      final hasLowStock = controller.lowStockAlerts.value > 0;
      final hasPending = controller.pendingDueCount.value > 0;
      if (!hasLowStock && !hasPending) return const SizedBox.shrink();
      return Column(
        children: [
          if (hasLowStock)
            AlertBanner(
              message:
                  '${controller.lowStockAlerts.value} items are low in stock',
              color: AppColors.warning,
              icon: Icons.warning_amber_rounded,
              actionLabel: 'View',
              onAction: () => Get.toNamed(AppRoutes.inventory),
            ),
          if (hasLowStock && hasPending) const SizedBox(height: 8),
          if (hasPending)
            AlertBanner(
              message:
                  '${controller.pendingDueCount.value} invoices pending — ${controller.formatCurrency(controller.pendingDueAmount.value)} outstanding',
              color: AppColors.error,
              icon: Icons.schedule_rounded,
              actionLabel: 'View',
              onAction: () => Get.toNamed(AppRoutes.billing),
            ),
          const SizedBox(height: 16),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────
  // QUICK ACTIONS horizontal scroll
  // ─────────────────────────────────────────────────────────
  Widget _quickActions() {
    return Obx(
      () => SizedBox(
        height: 105,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: controller.quickActions.map((a) {
            return QuickActionCard(
              title: a.label,
              icon: a.iconCode,
              color: Color(a.color),
              onTap: () => Get.toNamed(a.route),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // MODULES GRID (mirrors modules array in dashboard.js)
  // ─────────────────────────────────────────────────────────
  Widget _modulesGrid() {
    final auth = Get.find<AuthController>();

    final modules = <_ModuleDef>[
      _ModuleDef(
        'Inventory',
        'Jewelry stock, categories & HUID tracking',
        '${controller.totalInventory.value} items',
        AppRoutes.inventory,
        Icons.inventory_2_outlined,
        const Color(0xFFD4AF37),
        'inventory',
      ),
      _ModuleDef(
        'Billing',
        'Invoices, estimates, credit notes & GST',
        '${controller.pendingInvoiceCount.value} pending',
        AppRoutes.billing,
        Icons.receipt_long_outlined,
        const Color(0xFF4ADE80),
        'billing',
      ),
      _ModuleDef(
        'Customers',
        'Profiles, purchase history & loyalty',
        '${controller.activeCustomers.value} active',
        AppRoutes.customers,
        Icons.people_alt_outlined,
        const Color(0xFF60A5FA),
        'customers',
      ),
      _ModuleDef(
        'Accounts',
        'CR/DR ledger, expenses & bank reconciliation',
        '230 entries',
        AppRoutes.accounts,
        Icons.account_balance_wallet_outlined,
        const Color(0xFFC084FC),
        'accounts',
      ),
      _ModuleDef(
        "Today's Rates",
        'Live gold, silver & platinum rates',
        'Updated',
        AppRoutes.todayRates,
        Icons.sell_outlined,
        const Color(0xFFF0D060),
        'todayRates',
      ),
      _ModuleDef(
        'Old Gold',
        'Purchase & exchange old gold with purity testing',
        '15 entries',
        AppRoutes.oldGold,
        Icons.repeat_rounded,
        const Color(0xFFFB923C),
        'oldGold',
      ),
      _ModuleDef(
        'Schemes',
        'Monthly savings schemes & member tracking',
        '3 active',
        AppRoutes.schemes,
        Icons.card_giftcard_outlined,
        const Color(0xFF34D399),
        'schemes',
      ),
      _ModuleDef(
        'Reports',
        'Sales analytics, P&L, GST & staff reports',
        '10 types',
        AppRoutes.reports,
        Icons.bar_chart_rounded,
        const Color(0xFF818CF8),
        'reports',
      ),
      if (auth.isOwner || auth.isAdmin)
        _ModuleDef(
          'Staff',
          'Permissions, attendance & payroll',
          '4 members',
          AppRoutes.staff,
          Icons.badge_outlined,
          const Color(0xFFF472B6),
          'staff',
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (_, i) {
        final m = modules[i];
        return ModuleCard(
          title: m.title,
          desc: m.desc,
          count: m.count,
          icon: m.icon,
          color: m.color,
          onTap: () => Get.toNamed(m.route),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // RECENT INVOICES
  // ─────────────────────────────────────────────────────────
  Widget _recentInvoicesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionLabel('Recent Invoices'),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.billing),
          child: const Row(
            children: [
              Text(
                'View All',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 3),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: AppColors.goldPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recentInvoices() {
    return Obx(() {
      final list = controller.recentInvoices;
      if (list.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Text(
              'No invoices yet',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: list
              .map(
                (inv) => RecentInvoiceRow(
                  invoice: inv,
                  onTap: () => Get.toNamed(AppRoutes.invoiceDetail),
                ),
              )
              .toList(),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────────────────────
  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.goldPrimary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (i) {
          switch (i) {
            case 1:
              Get.toNamed(AppRoutes.billing);
              break;
            case 2:
              Get.toNamed(AppRoutes.customers);
              break;
            case 3:
              _showModulesSheet();
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Billing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_rounded),
            label: 'Modules',
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // MODULES BOTTOM SHEET (tapping Modules in bottom nav)
  // ─────────────────────────────────────────────────────────
  void _showModulesSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'All Modules',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _sheetItem(
                  Icons.inventory_2_outlined,
                  'Inventory',
                  AppRoutes.inventory,
                ),
                _sheetItem(
                  Icons.receipt_long_outlined,
                  'Billing',
                  AppRoutes.billing,
                ),
                _sheetItem(
                  Icons.people_alt_outlined,
                  'Customers',
                  AppRoutes.customers,
                ),
                _sheetItem(
                  Icons.account_balance_wallet_outlined,
                  'Accounts',
                  AppRoutes.accounts,
                ),
                _sheetItem(Icons.sell_outlined, 'Rates', AppRoutes.todayRates),
                _sheetItem(Icons.repeat_rounded, 'Old Gold', AppRoutes.oldGold),
                _sheetItem(
                  Icons.card_giftcard_outlined,
                  'Schemes',
                  AppRoutes.schemes,
                ),
                _sheetItem(
                  Icons.bar_chart_rounded,
                  'Reports',
                  AppRoutes.reports,
                ),
                _sheetItem(Icons.badge_outlined, 'Staff', AppRoutes.staff),
                _sheetItem(
                  Icons.settings_outlined,
                  'Settings',
                  AppRoutes.settings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetItem(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () {
        Get.back();
        Get.toNamed(route);
      },
      child: Container(
        width: (Get.width - 60) / 3,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.goldPrimary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper ──
  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}

// ── local helper class ──
class _ModuleDef {
  final String title, desc, count, route;
  final IconData icon;
  final Color color;
  final String permModule;
  const _ModuleDef(
    this.title,
    this.desc,
    this.count,
    this.route,
    this.icon,
    this.color,
    this.permModule,
  );
}
