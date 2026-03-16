import 'package:acme_killer_mobile_app/modules/billing/controllers/billing_controller.dart';
import 'package:get/get.dart';

class BillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BillingController(), permanent: true);
  }
}
