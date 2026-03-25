import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/module_gating_service.dart';
import '../../services/settings_service.dart';
import 'auth_controller.dart';

// ════════════════════════════════════════════════════════════════════
// StoreController — manages active store selection
//
// New: when store changes, calls:
//   1. StoreContextService.switchStore(id) → sets X-Store-Id header
//   2. ModuleGatingService.switchToStore(id) → updates currentModules
//
// mirrors Electron: store switch handler in sidebar +
//   state.currentModules = storeModules[storeId] || []
// ════════════════════════════════════════════════════════════════════
class StoreController extends GetxController {
  final RxList<StoreInfo>  stores        = <StoreInfo>[].obs;
  final Rx<StoreInfo?>     selectedStore = Rx(null);

  @override
  void onInit() {
    super.onInit();
    _sync();
  }

  void _sync() {
    try {
      final auth = Get.find<AuthController>();
      ever(auth.user, (_) {
        if (auth.stores.isNotEmpty) {
          stores.assignAll(auth.stores);
          if (selectedStore.value == null) _selectStore(auth.stores.first);
        }
      });
      if (auth.stores.isNotEmpty) {
        stores.assignAll(auth.stores);
        _selectStore(auth.stores.first);
      }
    } catch (_) {
      final demo = [
        StoreInfo(id: 1, name: 'Rajmahal Jewellers - Main',
            enabledModules: ['DASHBOARD','INVENTORY','BILLING','CUSTOMERS','ACCOUNTS','RATES','SCHEMES','REPORTS','SETTINGS']),
        StoreInfo(id: 2, name: 'Rajmahal Jewellers - Mall Road',
            enabledModules: ['DASHBOARD','INVENTORY','BILLING','CUSTOMERS','ACCOUNTS','RATES']),
        StoreInfo(id: 3, name: 'Rajmahal Jewellers - City Center',
            enabledModules: ['DASHBOARD','INVENTORY','BILLING','CUSTOMERS']),
      ];
      stores.assignAll(demo);
      _selectStore(demo.first);
    }
  }

  void _selectStore(StoreInfo store) {
    selectedStore.value = store;
    // Sync X-Store-Id header
    try { Get.find<StoreContextService>().switchStore(store.id); } catch (_) {}
    // Update module gating for the selected store
    try { Get.find<ModuleGatingService>().switchToStore(store.id); } catch (_) {}
  }

  List<String> get storeNames        => stores.map((s) => s.name).toList();
  String?      get selectedStoreName  => selectedStore.value?.name;
  String       get activeLabel        => selectedStore.value?.shortName ?? 'All Stores';

  void changeStore(StoreInfo? s) {
    if (s == null) {
      selectedStore.value = null;
      try { Get.find<StoreContextService>().clearStore(); } catch (_) {}
      try { Get.find<ModuleGatingService>().switchToStore(null); } catch (_) {}
      return;
    }
    _selectStore(s);
    try { Get.find<AuthController>().selectedStore.value = s; } catch (_) {}
  }

  void changeStoreByName(String? name) {
    if (name == null) { changeStore(null); return; }
    final match = stores.firstWhereOrNull((s) => s.name == name);
    if (match != null) changeStore(match);
  }
}
