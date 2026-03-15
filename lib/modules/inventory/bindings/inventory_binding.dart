import 'package:acme_killer_mobile_app/modules/inventory/controllers/inventory_controller.dart';
import 'package:get/get.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(InventoryController(), permanent: true);
  }
}
