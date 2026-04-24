import 'package:acme_killer_mobile_app/modules/accounts/bindings/accounts_binding.dart';
import 'package:acme_killer_mobile_app/modules/accounts/screens/accounts_screen.dart';
import 'package:acme_killer_mobile_app/modules/accounts/screens/add_ledger_entry_screen.dart';
import 'package:acme_killer_mobile_app/modules/auth/change_password/bindings/change_password_binding.dart';
import 'package:acme_killer_mobile_app/modules/auth/change_password/screens/change_password_screen.dart';
import 'package:acme_killer_mobile_app/modules/auth/login/bindings/login_binding.dart';
import 'package:acme_killer_mobile_app/modules/auth/login/screens/login_screen.dart';
import 'package:acme_killer_mobile_app/modules/billing/bindings/billing_binding.dart';
import 'package:acme_killer_mobile_app/modules/billing/screens/billing_screen.dart';
import 'package:acme_killer_mobile_app/modules/billing/screens/create_credit_note_screen.dart';
import 'package:acme_killer_mobile_app/modules/billing/screens/create_estimate_screen.dart';
import 'package:acme_killer_mobile_app/modules/billing/screens/create_invoice_screen.dart';
import 'package:acme_killer_mobile_app/modules/billing/screens/invoice_detail_screen.dart';
import 'package:acme_killer_mobile_app/modules/customers/bindings/customer_binding.dart';
import 'package:acme_killer_mobile_app/modules/customers/screens/add_customer_screen.dart';
import 'package:acme_killer_mobile_app/modules/customers/screens/customer_profile_screen.dart';
import 'package:acme_killer_mobile_app/modules/customers/screens/customers_screen.dart';
import 'package:acme_killer_mobile_app/modules/customers/screens/edit_customer_screen.dart';
import 'package:acme_killer_mobile_app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:acme_killer_mobile_app/modules/dashboard/screens/dashboard_screen.dart';
import 'package:acme_killer_mobile_app/modules/enquiries/bindings/enquiries_binding.dart';
import 'package:acme_killer_mobile_app/modules/enquiries/screens/enquiries_screen.dart';
import 'package:acme_killer_mobile_app/modules/enquiries/screens/enquiry_detail_screen.dart';
import 'package:acme_killer_mobile_app/modules/inventory/bindings/inventory_binding.dart';
import 'package:acme_killer_mobile_app/modules/inventory/screens/add_inventory_screen.dart';
import 'package:acme_killer_mobile_app/modules/inventory/screens/edit_inventory_screen.dart';
import 'package:acme_killer_mobile_app/modules/inventory/screens/inventory_detail_screen.dart';
import 'package:acme_killer_mobile_app/modules/inventory/screens/inventory_screen.dart';
import 'package:acme_killer_mobile_app/modules/inventory/screens/transfer_inventory_screen.dart';
import 'package:acme_killer_mobile_app/modules/module_not_available_screen.dart';
import 'package:acme_killer_mobile_app/modules/rates_schemes/bindings/rates_schemes_binding.dart';
import 'package:acme_killer_mobile_app/modules/rates_schemes/screens/old_gold_screen.dart';
import 'package:acme_killer_mobile_app/modules/rates_schemes/screens/rate_board_screen.dart';
import 'package:acme_killer_mobile_app/modules/rates_schemes/screens/schemes_screen.dart';
import 'package:acme_killer_mobile_app/modules/rates_schemes/screens/today_rates_screen.dart';
import 'package:acme_killer_mobile_app/modules/reports/bindings/reports_binding.dart';
import 'package:acme_killer_mobile_app/modules/reports/screens/report_detail_screen.dart';
import 'package:acme_killer_mobile_app/modules/reports/screens/reports_screen.dart';
import 'package:acme_killer_mobile_app/modules/role_select/screens/role_select_screen.dart';
import 'package:acme_killer_mobile_app/modules/settings/bindings/settings_binding.dart';
import 'package:acme_killer_mobile_app/modules/settings/screens/settings_detail_screen.dart';
import 'package:acme_killer_mobile_app/modules/settings/screens/settings_screen.dart';
import 'package:acme_killer_mobile_app/modules/splash/screens/splash_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/bindings/staff_binding.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/add_staff_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/edit_staff_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/staff_detail_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/staff_management_screen.dart';
import 'package:acme_killer_mobile_app/routes/app_routes.dart';
import 'package:acme_killer_mobile_app/services/module_gating_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════════════════════════
// ModuleGatingMiddleware
//
// Runs before every navigation to check if the target page's module
// is enabled for the currently selected store.
//
// mirrors Electron router.js:
//   if (!isPageEnabled(state.currentPage)) { show module-not-available }
// ════════════════════════════════════════════════════════════════════
class ModuleGatingMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (route == null) return null;

    // Skip gating for auth/core routes
    const ungated = {
      AppRoutes.splash,
      AppRoutes.roleSelect,
      AppRoutes.login,
      AppRoutes.changePassword,
      AppRoutes.dashboard,
      AppRoutes.moduleNotAvailable,
    };
    if (ungated.contains(route)) return null;

    try {
      final gating = Get.find<ModuleGatingService>();
      if (!gating.isPageEnabled(route)) {
        // Derive module name for the UI
        final key = route.startsWith('/') ? route.substring(1) : route;
        final moduleName = ModuleGatingService.pageModuleMap[key] ?? '';
        return RouteSettings(
          name: AppRoutes.moduleNotAvailable,
          arguments: moduleName,
        );
      }
    } catch (_) {
      // ModuleGatingService not yet ready — allow navigation
    }
    return null;
  }
}

class AppPages {
  static final _middleware = [ModuleGatingMiddleware()];

  static final pages = [
    // ── Auth flow (no gating) ───────────────────────────────────────
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.roleSelect, page: () => const RoleSelectScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
      binding: ChangePasswordBinding(),
    ),

    // ── Module Not Available ────────────────────────────────────────
    GetPage(
      name: AppRoutes.moduleNotAvailable,
      page: () => const ModuleNotAvailableScreen(),
    ),

    // ── Dashboard ──────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: _middleware,
    ),

    // ── Inventory (INVENTORY module) ───────────────────────────────
    GetPage(
      name: AppRoutes.inventory,
      page: () => InventoryScreen(),
      binding: InventoryBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.addInventory,
      page: () => AddInventoryScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.inventoryDetail,
      page: () => const InventoryDetailScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.editInventory,
      page: () => EditInventoryScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.transferInventory,
      page: () => TransferInventoryScreen(),
      middlewares: _middleware,
    ),

    // ── Customers (CUSTOMERS module) ───────────────────────────────
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomersScreen(),
      binding: CustomerBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.addCustomer,
      page: () => AddCustomerScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.customerProfile,
      page: () => CustomerProfileScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.editCustomer,
      page: () => EditCustomerScreen(),
      middlewares: _middleware,
    ),

    // ── Billing (BILLING module) ───────────────────────────────────
    GetPage(
      name: AppRoutes.billing,
      page: () => BillingScreen(),
      binding: BillingBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.createInvoice,
      page: () => CreateInvoiceScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.invoiceDetail,
      page: () => InvoiceDetailScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.createEstimate,
      page: () => const CreateEstimateScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.createCreditNote,
      page: () => const CreateCreditNoteScreen(),
      middlewares: _middleware,
    ),

    // ── Staff (no module gate — owner only, always visible) ────────
    GetPage(
      name: AppRoutes.staff,
      page: () => StaffManagementScreen(),
      binding: StaffBinding(),
    ),
    GetPage(name: AppRoutes.addStaff, page: () => const AddStaffScreen()),
    GetPage(name: AppRoutes.staffDetail, page: () => const StaffDetailScreen()),
    GetPage(name: AppRoutes.editStaff, page: () => const EditStaffScreen()),

    // ── Accounts (ACCOUNTS module) ─────────────────────────────────
    GetPage(
      name: AppRoutes.accounts,
      page: () => AccountsScreen(),
      binding: AccountsBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.addLedgerEntry,
      page: () => const AddLedgerEntryScreen(),
      middlewares: _middleware,
    ),

    // ── Reports (REPORTS module) ───────────────────────────────────
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsScreen(),
      binding: ReportsBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.reportDetail,
      page: () => const ReportDetailScreen(),
      middlewares: _middleware,
    ),

    // ── Rates / Old Gold / Schemes (RATES / ACCOUNTS / SCHEMES) ────
    GetPage(
      name: AppRoutes.todayRates,
      page: () => const TodayRatesScreen(),
      binding: RatesSchemesBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.rateBoard,
      page: () => const RateBoardScreen(),
      binding: RatesSchemesBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.oldGold,
      page: () => const OldGoldScreen(),
      binding: RatesSchemesBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.addOldGold,
      page: () => const AddOldGoldScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.oldGoldDetail,
      page: () => const OldGoldDetailScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.schemes,
      page: () => const SchemesScreen(),
      binding: RatesSchemesBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.addScheme,
      page: () => const AddSchemeScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.schemeDetail,
      page: () => const SchemeDetailScreen(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.editScheme,
      page: () => const EditSchemeScreen(),
      middlewares: _middleware,
    ),

    // ── Settings (SETTINGS module) ─────────────────────────────────
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.settingsDetail,
      page: () => const SettingsDetailScreen(),
      middlewares: _middleware,
    ),

    // ── Enquiries (CUSTOMERS module) ───────────────────────────────
    GetPage(
      name: AppRoutes.enquiries,
      page: () => const EnquiriesScreen(),
      binding: EnquiriesBinding(),
      middlewares: _middleware,
    ),
    GetPage(
      name: AppRoutes.enquiryDetail,
      page: () => const EnquiryDetailScreen(),
      middlewares: _middleware,
    ),
  ];
}
