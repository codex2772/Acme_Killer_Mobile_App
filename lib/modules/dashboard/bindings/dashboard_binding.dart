import 'package:acme_killer_mobile_app/modules/billing/controllers/billing_controller.dart';
import 'package:acme_killer_mobile_app/modules/customers/controllers/customer_controller.dart';
import 'package:acme_killer_mobile_app/modules/inventory/controllers/inventory_controller.dart';
import 'package:acme_killer_mobile_app/modules/rates_schemes/controllers/rates_schemes_controller.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CustomerController(), permanent: true);
    Get.put(InventoryController(), permanent: true);
    Get.put(BillingController(), permanent: true);
    // RatesSchemesController permanent so live rates are always available
    // (AddInventoryScreen, InvoiceItemRow, and dashboard all read gold rates)
    Get.put(RatesSchemesController(), permanent: true);
    Get.put(DashboardController());
  }
}
