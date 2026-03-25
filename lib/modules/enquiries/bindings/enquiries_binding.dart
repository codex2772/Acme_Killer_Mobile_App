import 'package:get/get.dart';
import '../controllers/enquiries_controller.dart';

class EnquiriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EnquiriesController>(() => EnquiriesController());
  }
}
