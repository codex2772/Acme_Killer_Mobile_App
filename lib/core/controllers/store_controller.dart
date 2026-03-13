import 'package:get/get.dart';

class StoreController extends GetxController {

  var stores = [
    "Main Store",
    "Gold Palace",
    "City Branch"
  ].obs;

  /// null = All stores
  var selectedStore = RxnString();

  void changeStore(String? store) {
    selectedStore.value = store;
  }

}