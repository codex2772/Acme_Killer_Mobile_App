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
import 'package:acme_killer_mobile_app/modules/role_select/screens/role_select_screen.dart';
import 'package:acme_killer_mobile_app/modules/splash/screens/splash_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/bindings/staff_binding.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/add_staff_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/staff_detail_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/staff_management_screen.dart';
import 'package:acme_killer_mobile_app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),

    GetPage(name: AppRoutes.roleSelect, page: () => const RoleSelectScreen()),

    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),

    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),

    GetPage(
      name: AppRoutes.inventory,
      page: () => InventoryScreen(),
      binding: InventoryBinding(),
    ),

    GetPage(name: AppRoutes.addInventory, page: () => AddInventoryScreen()),

    GetPage(
      name: AppRoutes.inventoryDetail,
      page: () => const InventoryDetailScreen(),
    ),

    GetPage(name: AppRoutes.editInventory, page: () => EditInventoryScreen()),

    GetPage(
      name: AppRoutes.transferInventory,
      page: () => TransferInventoryScreen(),
    ),

    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomersScreen(),
      binding: CustomerBinding(),
    ),

    GetPage(name: AppRoutes.addCustomer, page: () => AddCustomerScreen()),

    GetPage(
      name: AppRoutes.customerProfile,
      page: () => CustomerProfileScreen(),
    ),

    GetPage(name: AppRoutes.editCustomer, page: () => EditCustomerScreen()),

    GetPage(
      name: AppRoutes.billing,
      page: () => BillingScreen(),
      binding: BillingBinding(),
    ),

    GetPage(name: AppRoutes.createInvoice, page: () => CreateInvoiceScreen()),

    GetPage(name: AppRoutes.invoiceDetail, page: () => InvoiceDetailScreen()),

    GetPage(
      name: AppRoutes.createEstimate,
      page: () => const CreateEstimateScreen(),
    ),

    GetPage(
      name: AppRoutes.createCreditNote,
      page: () => const CreateCreditNoteScreen(),
    ),

    GetPage(
      name: AppRoutes.staff,
      page: () => StaffManagementScreen(),
      binding: StaffBinding(),
    ),

    GetPage(name: AppRoutes.addStaff, page: () => AddStaffScreen()),

    // GetPage(name: AppRoutes.staffDetail, page: () => StaffDetailScreen),
  ];
}
