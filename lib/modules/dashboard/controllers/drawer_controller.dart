import 'package:get/get.dart';

class AppDrawerController extends GetxController {
  var role = "owner".obs;

  var stores = [
    "Rajmahal Jewellers - Main",
    "Rajmahal Jewellers - Surat",
    "Rajmahal Jewellers - Mumbai",
  ];

  var selectedStore = RxnString();

  void changeStore(String? value) {
    selectedStore.value = value;
  }

  String get activeStore {
    if (selectedStore.value == null) {
      return "All Stores";
    }
    return selectedStore.value!.replaceAll("Rajmahal Jewellers - ", "");
  }

  void logout() {
    Get.offAllNamed("/role-select");
  }
}