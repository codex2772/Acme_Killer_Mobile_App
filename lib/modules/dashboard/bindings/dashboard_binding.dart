import 'package:acme_killer_mobile_app/modules/billing/controllers/billing_controller.dart';
import 'package:acme_killer_mobile_app/modules/customers/controllers/customer_controller.dart';
import 'package:acme_killer_mobile_app/modules/inventory/controllers/inventory_controller.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CustomerController(), permanent: true);

    // INVENTORY FIRST
    Get.put(InventoryController(), permanent: true);

    // BILLING AFTER INVENTORY
    Get.put(BillingController(), permanent: true);

    Get.put(DashboardController());
  }
}
