import 'package:acme_killer_mobile_app/modules/dashboard/controllers/drawer_controller.dart';
import 'package:get/get.dart';
import '../controllers/store_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {

    Get.put(StoreController(), permanent: true);
    // Get.put(AuthController(), permanent: true);
    Get.put(AppDrawerController(), permanent: true);

  }
}