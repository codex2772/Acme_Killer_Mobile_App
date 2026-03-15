import 'package:get/get.dart';

class StoreController extends GetxController {

  /// Stores list
  var stores = [
    "Main Store",
    "Gold Palace",
    "City Branch"
  ].obs;

  /// Selected store
  var selectedStore = RxnString();

  void changeStore(String? store) {
    selectedStore.value = store;
  }

  @override
  void onInit() {
    selectedStore.value = stores.first;
    super.onInit();
  }
}