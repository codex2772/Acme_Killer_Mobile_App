import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/store_controller.dart';
import '../../modules/dashboard/controllers/drawer_controller.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // StorageService is already put in main() — find it here
    Get.find<StorageService>();

    // AuthService needs StorageService
    Get.put<AuthService>(AuthService(), permanent: true);

    // Global controllers — permanent so they survive page changes
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<StoreController>(StoreController(), permanent: true);
    Get.put<AppDrawerController>(AppDrawerController(), permanent: true);
  }
}
