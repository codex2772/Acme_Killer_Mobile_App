import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/module_gating_service.dart';
import '../../services/inventory_service.dart';
import '../../services/customer_service.dart';
import '../../services/staff_service.dart';

// ════════════════════════════════════════════════════════════════════
// AuthController — FUNCTIONALITY CHANGES
//
// New vs previous build:
//
// 1. Store selection logic on login/restore (mirrors Electron auth.js):
//    OWNER + multiple stores  → selectedStore = null ("All Stores")
//    ADMIN/STAFF or 1 store   → selectedStore = stores[0]
//    (Previously always set stores[0] regardless of role)
//
// 2. preloadData() — new method (mirrors Electron Auth.preloadData())
//    Called after login AND after session restore.
//    Parallel pre-fetch: inventory + customers + staff → caches in background
//
// 3. Logout clears all module-level caches (mirrors Electron Auth.logout())
// ════════════════════════════════════════════════════════════════════
class AuthController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final Rx<UserSession?> user            = Rx(null);
  final RxBool           isAuthenticated = false.obs;
  final RxBool           isOnline        = false.obs;
  final RxBool           isDemo          = false.obs;
  final Rx<StoreInfo?>   selectedStore   = Rx(null);

  String get role             => user.value?.role ?? '';
  String get userName         => user.value?.name ?? '';
  String get userInitials     => user.value?.initials ?? 'U';
  String get userMobile       => user.value?.mobile ?? '';
  List<StoreInfo> get stores  => user.value?.stores ?? [];
  List<String> get permissions => user.value?.permissions ?? [];
  bool get forcePasswordChange => user.value?.forcePasswordChange ?? false;
  bool get isOwner  => role == 'owner';
  bool get isAdmin  => role == 'admin';

  bool hasPermission(String p) => user.value?.hasPermission(p) ?? false;
  bool canAccess(String module) => user.value?.canAccess(module) ?? false;

  // ── Login ─────────────────────────────────────────────────────────
  Future<AuthResult> login(String mobile, String password) async {
    final result = await _auth.login(mobile, password);
    if (result.success && result.user != null) {
      _apply(result.user!, isDemo: result.isDemo);
      if (!result.isDemo) preloadData(); // mirrors Electron Auth.preloadData()
    }
    return result;
  }

  // ── Restore session on splash ─────────────────────────────────────
  Future<bool> tryRestoreSession() async {
    final result = await _auth.tryRestoreSession();
    if (result.success && result.user != null) {
      _apply(result.user!, isDemo: result.isDemo);
      return true;
    }
    return false;
  }

  // ── Change password ───────────────────────────────────────────────
  Future<AuthResult> changePassword(String current, String newPass) =>
      _auth.changePassword(current, newPass);

  // ── Logout ────────────────────────────────────────────────────────
  // mirrors Electron Auth.logout() — clears ALL module caches
  Future<void> logout() async {
    await _auth.logout();
    user.value            = null;
    isAuthenticated.value = false;
    isOnline.value        = false;
    isDemo.value          = false;
    selectedStore.value   = null;
    try { Get.find<ModuleGatingService>().clear(); } catch (_) {}
    Get.offAllNamed(AppRoutes.roleSelect);
  }

  // ── Pre-fetch module data in background after login ───────────────
  // mirrors Electron Auth.preloadData():
  //   Promise.all([inventory.list(), customers.list(), staff.list()])
  //   → caches results so first page loads are instant
  Future<void> preloadData() async {
    try {
      await Future.wait([
        _prefetchInventory(),
        _prefetchCustomers(),
        _prefetchStaff(),
      ]);
    } catch (_) {}
  }

  Future<void> _prefetchInventory() async {
    try { await Get.find<InventoryService>().list(); } catch (_) {}
  }
  Future<void> _prefetchCustomers() async {
    try { await Get.find<CustomerService>().list(); } catch (_) {}
  }
  Future<void> _prefetchStaff() async {
    try { await Get.find<StaffService>().list(); } catch (_) {}
  }

  // ── Apply session ─────────────────────────────────────────────────
  // KEY CHANGE: store selection logic now mirrors Electron auth.js:
  //   owner + multiple stores → selectedStore = null (All Stores)
  //   admin/staff or 1 store  → selectedStore = stores[0]
  void _apply(UserSession u, {bool isDemo = false}) {
    user.value            = u;
    isAuthenticated.value = true;
    isOnline.value        = u.isOnline;
    this.isDemo.value     = isDemo;

    // ── Store selection: mirrors Electron auth.js logic ──
    // if (role === 'owner' && stores.length > 1) → All Stores (null)
    // else                                        → stores[0]
    if (u.role == 'owner' && u.stores.length > 1) {
      selectedStore.value = null; // "All Stores"
    } else if (u.stores.isNotEmpty) {
      selectedStore.value = u.stores.first;
    }

    // ── CRITICAL: Sync X-Store-Id header with ApiClient IMMEDIATELY ──
    // Mirrors Electron auth.js:
    //   if (state.selectedStoreId && window.jewelERP.store) {
    //     await window.jewelERP.store.switch(state.selectedStoreId);
    //   }
    // Without this, every API call after login sends NO X-Store-Id → 401
    try {
      final apiClient = Get.find<ApiClient>();
      if (selectedStore.value != null) {
        apiClient.setCurrentStoreId(selectedStore.value!.id);
      } else {
        apiClient.setCurrentStoreId(null);
      }
    } catch (_) {}

    // Init module gating from stores[].enabledModules
    try { Get.find<ModuleGatingService>().initFromLogin(u.stores); } catch (_) {}
  }
}
