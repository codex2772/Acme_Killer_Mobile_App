import 'package:acme_killer_mobile_app/modules/customers/controllers/customer_controller.dart';
import 'package:get/get.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CustomerController>(CustomerController(), permanent: true);
  }
}
