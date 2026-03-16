import 'package:get/get.dart';
import '../../services/auth_service.dart';
import 'auth_controller.dart';

class StoreController extends GetxController {
  final RxList<StoreInfo> stores = <StoreInfo>[].obs;
  final Rx<StoreInfo?> selectedStore = Rx(null);

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
          selectedStore.value ??= auth.stores.first;
        }
      });
      if (auth.stores.isNotEmpty) {
        stores.assignAll(auth.stores);
        selectedStore.value = auth.stores.first;
      }
    } catch (_) {
      // fallback demo stores
      stores.assignAll([
        StoreInfo(id: 1, name: 'Rajmahal Jewellers - Main'),
        StoreInfo(id: 2, name: 'Rajmahal Jewellers - Surat'),
        StoreInfo(id: 3, name: 'Rajmahal Jewellers - Mumbai'),
      ]);
      selectedStore.value = stores.first;
    }
  }

  // Used by existing dropdown widgets that pass String store names
  List<String> get storeNames => stores.map((s) => s.name).toList();
  String? get selectedStoreName => selectedStore.value?.name;
  String get activeLabel => selectedStore.value?.shortName ?? 'All Stores';

  void changeStore(StoreInfo? s) {
    selectedStore.value = s;
    try { Get.find<AuthController>().selectedStore.value = s; } catch (_) {}
  }

  void changeStoreByName(String? name) {
    if (name == null) { selectedStore.value = null; return; }
    final match = stores.firstWhereOrNull((s) => s.name == name);
    if (match != null) changeStore(match);
  }
}
