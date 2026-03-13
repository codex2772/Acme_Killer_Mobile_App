import 'package:acme_killer_mobile_app/core/controllers/store_controller.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final storeController = Get.find<StoreController>();

  /// Stats
  var activeCustomers = 845.obs;
  var goldRate = 6550.obs;

  /// Stores
  var stores = ["Main Store", "Gold Palace", "City Branch"].obs;

  var role = "owner".obs; // owner | admin | staff

  var invoices = [
    {
      "id": "INV-001",
      "customer": "Rahul Shah",
      "amount": 45000,
      "status": "Pending",
      "date": "12 Mar",
      "store": "Main Store",
    },
    {
      "id": "INV-002",
      "customer": "Priya Patel",
      "amount": 120000,
      "status": "Paid",
      "date": "11 Mar",
      "store": "Gold Palace",
    },
    {
      "id": "INV-003",
      "customer": "Amit Kumar",
      "amount": 75000,
      "status": "Pending",
      "date": "10 Mar",
      "store": "City Branch",
    },
    {
      "id": "INV-004",
      "customer": "Neha Sharma",
      "amount": 92000,
      "status": "Paid",
      "date": "09 Mar",
      "store": "Main Store",
    },
  ].obs;

  var inventory = [
    {"name": "Gold Ring", "status": "Available", "store": "Main Store"},
    {"name": "Diamond Necklace", "status": "Low Stock", "store": "Main Store"},
    {"name": "Gold Chain", "status": "Available", "store": "Gold Palace"},
    {"name": "Bangles Set", "status": "Low Stock", "store": "Gold Palace"},
    {"name": "Silver Anklet", "status": "Available", "store": "City Branch"},
    {"name": "Wedding Necklace", "status": "Low Stock", "store": "City Branch"},
  ].obs;

  // ADD HERE
  List<T> filterByStore<T>(List<T> items, String? Function(T) storeGetter) {
    if (storeController.selectedStore.value == null) {
      return items;
    }

    return items.where((item) {
      return storeGetter(item) == storeController.selectedStore.value;
    }).toList();
  }

  List<Map> get storeInvoices =>
      filterByStore(invoices.toList().cast<Map>(), (i) => i["store"]);

  List<Map> get storeInventory =>
      filterByStore(inventory.toList().cast<Map>(), (i) => i["store"]);

  /// Quick Actions
  final quickActions = [
    {"title": "New Invoice", "icon": "invoice"},
    {"title": "Add Item", "icon": "inventory"},
    {"title": "Add Customer", "icon": "customer"},
    {"title": "Add Staff", "icon": "staff"},
  ].obs;

  /// Modules
  final modules = [
    {"title": "Inventory", "count": "1240 items"},
    {"title": "Billing", "count": "5 pending"},
    {"title": "Customers", "count": "845 active"},
    {"title": "Accounts", "count": "230 entries"},
    {"title": "Rates", "count": "Updated"},
    {"title": "Old Gold", "count": "15 entries"},
    {"title": "Schemes", "count": "3 active"},
    {"title": "Reports", "count": "10 types"},
  ].obs;

  //Alerts
  int get lowStockItems =>
      storeInventory.where((i) => i["status"] == "Low Stock").length;

  int get pendingInvoices =>
      storeInvoices.where((i) => i["status"] == "Pending").length;

  int get pendingAmount => storeInvoices
      .where((i) => i["status"] == "Pending")
      .fold(0, (sum, i) => sum + (i["amount"] as int));

  int get totalInventory =>
      storeInventory.where((i) => i["status"] != "Sold").length;

  int get todaySales =>
      storeInvoices.fold(0, (sum, i) => sum + (i["amount"] as int));
}
