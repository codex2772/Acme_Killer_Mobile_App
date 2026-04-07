import 'package:get/get.dart';
import '../controllers/rates_schemes_controller.dart';

class RatesSchemesBinding extends Bindings {
  @override
  void dependencies() {
    // Controller is already permanent from DashboardBinding.
    // Only register if not already present (e.g. deep link directly to rates).
    if (!Get.isRegistered<RatesSchemesController>()) {
      Get.put(RatesSchemesController(), permanent: true);
    }
  }
}
