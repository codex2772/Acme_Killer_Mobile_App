import 'package:get/get.dart';

class PermissionController extends GetxController {

  var permissions = <String, bool>{

    "inventory_view": true,
    "inventory_manage": false,
    "billing_create": true,
    "reports_view": true,
    "customer_manage": false,

  }.obs;

  void togglePermission(String key) {
    permissions[key] = !(permissions[key] ?? false);
    permissions.refresh();
  }
}