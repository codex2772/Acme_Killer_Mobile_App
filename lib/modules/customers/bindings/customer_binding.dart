import 'package:get/get.dart';
import '../controllers/customer_controller.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CustomerController>(CustomerController(), permanent: true);
  }
}
