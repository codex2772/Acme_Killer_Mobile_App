import 'package:get/get.dart';
import '../controllers/rates_schemes_controller.dart';

class RatesSchemesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RatesSchemesController());
  }
}
