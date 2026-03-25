import 'package:get/get.dart';
import 'auth_service.dart';

// ════════════════════════════════════════════════════════════════════
// ModuleGatingService — mirrors Electron helpers.js module gating
//
// What it does:
//   • Stores enabledModules per store (from login response stores[].enabledModules)
//   • Updates currentModules when store switches
//   • isModuleEnabled(code) → bool
//   • isPageEnabled(routeName) → bool
//   • Sidebar nav items filtered by enabled modules
//
// Backend module codes (uppercase strings):
//   DASHBOARD, INVENTORY, BILLING, CUSTOMERS, ACCOUNTS,
//   RATES, SCHEMES, REPORTS, SETTINGS
//
// null module = always visible (staff pages, core pages)
// ════════════════════════════════════════════════════════════════════
class ModuleGatingService extends GetxService {

  // storeModules: { storeId: ['DASHBOARD','BILLING',...] }
  // mirrors Electron: state.storeModules
  final RxMap<int, List<String>> storeModules  = <int, List<String>>{}.obs;

  // currentModules: enabled modules for the active store
  // mirrors Electron: state.currentModules
  final RxList<String> currentModules = <String>[].obs;

  // ── Page → module code mapping ────────────────────────────────────
  // mirrors Electron: PAGE_MODULE_MAP in helpers.js
  static const Map<String, String?> pageModuleMap = {
    'dashboard':        'DASHBOARD',
    'inventory':        'INVENTORY',
    'add-inventory':    'INVENTORY',
    'inventory-detail': 'INVENTORY',
    'edit-inventory':   'INVENTORY',
    'billing':          'BILLING',
    'create-invoice':   'BILLING',
    'create-estimate':  'BILLING',
    'create-credit-note': 'BILLING',
    'invoice-detail':   'BILLING',
    'customers':        'CUSTOMERS',
    'add-customer':     'CUSTOMERS',
    'customer-profile': 'CUSTOMERS',
    'edit-customer':    'CUSTOMERS',
    'enquiries':        'CUSTOMERS',
    'enquiry-detail':   'CUSTOMERS',
    'accounts':         'ACCOUNTS',
    'add-ledger-entry': 'ACCOUNTS',
    'add-supplier':     'ACCOUNTS',
    'today-rates':      'RATES',
    'old-gold':         'ACCOUNTS',
    'add-old-gold':     'ACCOUNTS',
    'old-gold-detail':  'ACCOUNTS',
    'schemes':          'SCHEMES',
    'add-scheme':       'SCHEMES',
    'scheme-detail':    'SCHEMES',
    'edit-scheme':      'SCHEMES',
    'reports':          'REPORTS',
    'report-detail':    'REPORTS',
    // null = always enabled (owner/staff pages, login, etc.)
    'staff':            null,
    'add-staff':        null,
    'staff-detail':     null,
    'edit-staff':       null,
    'settings':         'SETTINGS',
    'settings-detail':  'SETTINGS',
    'role-select':      null,
    'login':            null,
    'change-password':  null,
  };

  // ── Parse stores from login response ─────────────────────────────
  // mirrors Electron auth.js: userData.stores.forEach(s => storeModules[s.id] = s.enabledModules)
  void initFromLogin(List<StoreInfo> stores) {
    final map = <int, List<String>>{};
    for (final s in stores) {
      // StoreInfo.enabledModules will be set if backend provides it
      map[s.id] = s.enabledModules ?? [];
    }
    storeModules.value = map;

    // Set currentModules to merged (all stores) initially
    currentModules.value = _mergeAllModules();
  }

  // ── Switch to a specific store ────────────────────────────────────
  // mirrors Electron: state.currentModules = state.storeModules[storeId] || []
  void switchToStore(int? storeId) {
    if (storeId == null) {
      // "All Stores" → merge modules from all stores
      currentModules.value = _mergeAllModules();
    } else {
      currentModules.value = storeModules[storeId] ?? [];
    }
  }

  // ── Clear on logout ───────────────────────────────────────────────
  void clear() {
    storeModules.clear();
    currentModules.clear();
  }

  // ── isModuleEnabled — mirrors Electron isModuleEnabled() ─────────
  // If currentModules is empty (old backend), allow everything
  bool isModuleEnabled(String? moduleCode) {
    if (moduleCode == null) return true; // always enabled
    if (currentModules.isEmpty) return true; // old backend fallback
    return currentModules.contains(moduleCode);
  }

  // ── isPageEnabled — mirrors Electron isPageEnabled() ─────────────
  bool isPageEnabled(String routeName) {
    // Strip leading '/' if present
    final key = routeName.startsWith('/') ? routeName.substring(1) : routeName;
    final moduleCode = pageModuleMap[key];
    return isModuleEnabled(moduleCode);
  }

  // ── isModuleEnabledForStore — used in multi-store fetches ─────────
  // mirrors Electron isModuleEnabledForStore()
  bool isModuleEnabledForStore(int storeId, String? moduleCode) {
    if (moduleCode == null) return true;
    final mods = storeModules[storeId] ?? [];
    if (mods.isEmpty) return true; // fallback: allow all
    return mods.contains(moduleCode);
  }

  // ── Visible nav items for the sidebar ────────────────────────────
  // mirrors Electron sidebarHTML nav filter
  List<NavItem> get visibleNavItems {
    final items = <NavItem>[
      NavItem(route: '/dashboard',  label: 'Dashboard',  icon: 'dashboard',  module: 'DASHBOARD'),
      NavItem(route: '/inventory',  label: 'Inventory',  icon: 'inventory',  module: 'INVENTORY'),
      NavItem(route: '/billing',    label: 'Billing',    icon: 'billing',    module: 'BILLING'),
      NavItem(route: '/customers',  label: 'Customers',  icon: 'customers',  module: 'CUSTOMERS'),
      NavItem(route: '/accounts',   label: 'Accounts',   icon: 'accounts',   module: 'ACCOUNTS'),
      NavItem(route: '/today-rates',label: 'Rates',      icon: 'rates',      module: 'RATES'),
      NavItem(route: '/old-gold',   label: 'Old Gold',   icon: 'old_gold',   module: 'ACCOUNTS'),
      NavItem(route: '/schemes',    label: 'Schemes',    icon: 'schemes',    module: 'SCHEMES'),
      NavItem(route: '/reports',    label: 'Reports',    icon: 'reports',    module: 'REPORTS'),
      NavItem(route: '/enquiries',  label: 'Enquiries',  icon: 'enquiries',  module: 'CUSTOMERS'),
      NavItem(route: '/staff',      label: 'Staff',      icon: 'staff',      module: null),
      NavItem(route: '/settings',   label: 'Settings',   icon: 'settings',   module: 'SETTINGS'),
    ];
    return items.where((n) => isModuleEnabled(n.module)).toList();
  }

  // ── Merge enabled modules from all stores ─────────────────────────
  // mirrors Electron mergeAllStoreModules()
  List<String> _mergeAllModules() {
    final merged = <String>{};
    for (final mods in storeModules.values) {
      merged.addAll(mods);
    }
    return merged.toList();
  }
}

// ── Nav item model ────────────────────────────────────────────────
class NavItem {
  final String  route;
  final String  label;
  final String  icon;
  final String? module; // null = always show
  const NavItem({required this.route, required this.label, required this.icon, this.module});
}

// ── Extended StoreInfo with enabledModules ────────────────────────
// Extend the base StoreInfo from auth_service to carry enabledModules
extension StoreInfoModules on StoreInfo {
  // enabledModules is stored as a nullable annotation — accessed via extension
  // In practice, store this by modifying StoreInfo.fromJson to read enabledModules
  List<String>? get enabledModules => null; // Override in StoreInfo.fromJson
}
