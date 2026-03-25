import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/store_controller.dart';
import '../../modules/dashboard/controllers/drawer_controller.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/api_client.dart';
import '../../services/module_gating_service.dart';
import '../../services/localization_service.dart';
import '../../services/staff_service.dart';
import '../../services/inventory_service.dart';
import '../../services/billing_service.dart';
import '../../services/customer_service.dart';
import '../../services/accounts_service.dart';
import '../../services/rates_service.dart';
import '../../services/enquiries_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/settings_service.dart';

// ════════════════════════════════════════════════════════════════════
// InitialBinding — registers every service at app startup
//
// New services in this build:
//   ModuleGatingService  → isModuleEnabled(), isPageEnabled()
//   LocalizationService  → t('key'), setLanguage(), EN/MR/HI
// ════════════════════════════════════════════════════════════════════
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Already initialised in main()
    Get.find<StorageService>();

    // Auth — must come before ApiClient
    Get.put<AuthService>(AuthService(), permanent: true);

    // Core HTTP engine (JWT, X-Store-Id, 401-refresh, image upload)
    Get.put<ApiClient>(ApiClient(), permanent: true);

    // NEW: Module gating — mirrors Electron helpers.js isModuleEnabled()
    Get.put<ModuleGatingService>(ModuleGatingService(), permanent: true);

    // NEW: Localization — mirrors Electron i18n.js t() function
    // (init is called async in main.dart)
    Get.put<LocalizationService>(LocalizationService(), permanent: true);

    // ── Module services — one per Electron ipc-handler group ────────
    Get.put<StaffService>(StaffService(),               permanent: true);
    Get.put<InventoryService>(InventoryService(),       permanent: true);
    Get.put<CategoriesService>(CategoriesService(),     permanent: true);
    Get.put<MetalTypesService>(MetalTypesService(),     permanent: true);
    Get.put<BillingService>(BillingService(),           permanent: true);
    Get.put<EstimatesService>(EstimatesService(),       permanent: true);
    Get.put<CreditNotesService>(CreditNotesService(),   permanent: true);
    Get.put<CustomerService>(CustomerService(),         permanent: true);
    Get.put<LedgerService>(LedgerService(),             permanent: true);
    Get.put<ExpensesService>(ExpensesService(),         permanent: true);
    Get.put<SuppliersService>(SuppliersService(),       permanent: true);
    Get.put<CashRegisterService>(CashRegisterService(), permanent: true);
    Get.put<RatesService>(RatesService(),               permanent: true);
    Get.put<OldGoldService>(OldGoldService(),           permanent: true);
    Get.put<SchemesService>(SchemesService(),           permanent: true);
    Get.put<EnquiriesService>(EnquiriesService(),       permanent: true);
    Get.put<DashboardService>(DashboardService(),       permanent: true);
    Get.put<AdminService>(AdminService(),               permanent: true);
    Get.put<HealthService>(HealthService(),             permanent: true);
    Get.put<ActivityLogsService>(ActivityLogsService(), permanent: true);
    Get.put<SettingsService>(SettingsService(),         permanent: true);
    Get.put<StoreContextService>(StoreContextService(), permanent: true);
    Get.put<ImagesService>(ImagesService(),             permanent: true);

    // ── Global controllers ───────────────────────────────────────────
    Get.put<AuthController>(AuthController(),           permanent: true);
    Get.put<StoreController>(StoreController(),         permanent: true);
    Get.put<AppDrawerController>(AppDrawerController(), permanent: true);
  }
}
