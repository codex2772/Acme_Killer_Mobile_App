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
import 'package:acme_killer_mobile_app/modules/inventory/bindings/inventory_binding.dart';
import 'package:acme_killer_mobile_app/modules/inventory/screens/add_inventory_screen.dart';
import 'package:acme_killer_mobile_app/modules/inventory/screens/edit_inventory_screen.dart';
import 'package:acme_killer_mobile_app/modules/inventory/screens/inventory_detail_screen.dart';
import 'package:acme_killer_mobile_app/modules/inventory/screens/inventory_screen.dart';
import 'package:acme_killer_mobile_app/modules/inventory/screens/transfer_inventory_screen.dart';
import 'package:acme_killer_mobile_app/modules/rates_schemes/bindings/rates_schemes_binding.dart';
import 'package:acme_killer_mobile_app/modules/rates_schemes/screens/old_gold_screen.dart';
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
import 'package:acme_killer_mobile_app/modules/staff/screens/staff_detail_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/staff_management_screen.dart';
import 'package:acme_killer_mobile_app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    // ── Auth flow ──
    GetPage(name: AppRoutes.splash,      page: () => const SplashScreen()),
    GetPage(name: AppRoutes.roleSelect,  page: () => const RoleSelectScreen()),
    GetPage(name: AppRoutes.login,       page: () => const LoginScreen(), binding: LoginBinding()),
    GetPage(name: AppRoutes.changePassword, page: () => const ChangePasswordScreen(), binding: ChangePasswordBinding()),

    // ── Dashboard ──
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardScreen(), binding: DashboardBinding()),

    // ── Inventory ──
    GetPage(name: AppRoutes.inventory,         page: () => InventoryScreen(),            binding: InventoryBinding()),
    GetPage(name: AppRoutes.addInventory,      page: () => AddInventoryScreen()),
    GetPage(name: AppRoutes.inventoryDetail,   page: () => const InventoryDetailScreen()),
    GetPage(name: AppRoutes.editInventory,     page: () => EditInventoryScreen()),
    GetPage(name: AppRoutes.transferInventory, page: () => TransferInventoryScreen()),

    // ── Customers ──
    GetPage(name: AppRoutes.customers,      page: () => const CustomersScreen(), binding: CustomerBinding()),
    GetPage(name: AppRoutes.addCustomer,    page: () => AddCustomerScreen()),
    GetPage(name: AppRoutes.customerProfile,page: () => CustomerProfileScreen()),
    GetPage(name: AppRoutes.editCustomer,   page: () => EditCustomerScreen()),

    // ── Billing ──
    GetPage(name: AppRoutes.billing,         page: () => BillingScreen(),              binding: BillingBinding()),
    GetPage(name: AppRoutes.createInvoice,   page: () => CreateInvoiceScreen()),
    GetPage(name: AppRoutes.invoiceDetail,   page: () => InvoiceDetailScreen()),
    GetPage(name: AppRoutes.createEstimate,  page: () => const CreateEstimateScreen()),
    GetPage(name: AppRoutes.createCreditNote,page: () => const CreateCreditNoteScreen()),

    // // ── Staff ──
    GetPage(name: AppRoutes.staff,       page: () => StaffManagementScreen(), binding: StaffBinding()),
    GetPage(name: AppRoutes.addStaff,    page: () => AddStaffScreen()),
    GetPage(name: AppRoutes.staffDetail, page: () => StaffDetailScreen()),

        // ── Accounts ──
    GetPage(name: AppRoutes.accounts,       page: () => AccountsScreen(), binding: AccountsBinding()),
    GetPage(name: AppRoutes.addLedgerEntry, page: () => const AddLedgerEntryScreen()),

    // ── Reports ──
    GetPage(name: AppRoutes.reports,      page: () => const ReportsScreen(), binding: ReportsBinding()),
    GetPage(name: AppRoutes.reportDetail, page: () => const ReportDetailScreen()),

    // ── Rates / Old Gold / Schemes ──
    GetPage(name: AppRoutes.todayRates,    page: () => const TodayRatesScreen(),    binding: RatesSchemesBinding()),
    GetPage(name: AppRoutes.oldGold,       page: () => const OldGoldScreen(),       binding: RatesSchemesBinding()),
    GetPage(name: AppRoutes.addOldGold,    page: () => const AddOldGoldScreen()),
    GetPage(name: AppRoutes.oldGoldDetail, page: () => const OldGoldDetailScreen()),
    GetPage(name: AppRoutes.schemes,       page: () => const SchemesScreen(),       binding: RatesSchemesBinding()),
    GetPage(name: AppRoutes.addScheme,     page: () => const AddSchemeScreen()),
    GetPage(name: AppRoutes.schemeDetail,  page: () => const SchemeDetailScreen()),
    GetPage(name: AppRoutes.editScheme,    page: () => const EditSchemeScreen()),

    // ── Settings ──
    GetPage(name: AppRoutes.settings,       page: () => const SettingsScreen(), binding: SettingsBinding()),
    GetPage(name: AppRoutes.settingsDetail, page: () => const SettingsDetailScreen()),
  ];
}
