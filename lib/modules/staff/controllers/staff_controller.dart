import 'package:acme_killer_mobile_app/core/controllers/store_controller.dart';
import 'package:get/get.dart';
import 'package:acme_killer_mobile_app/models/staff/staff_model.dart';

class StaffController extends GetxController {
  var staffList = <Staff>[].obs;

  var search = "".obs;

  var filter = "all".obs;

  final storeController = Get.find<StoreController>();

  @override
  void onInit() {
    super.onInit();

    loadDummyStaff();

    /// 🔥 Listen to store change and refresh UI
    ever(storeController.selectedStore, (_) {
      staffList.refresh();
    });
  }

  /// =========================
  /// DUMMY STAFF
  /// =========================

  void loadDummyStaff() {
    staffList.addAll([
      Staff(
        id: "STF001",
        name: "Arjun Mehta",
        phone: "9876543210",
        email: "arjun@store.com",
        role: "admin",
        store: "Main Store",
        status: "Active",
        salary: 45000,
        commission: 2,
        salesTarget: 500000,
        currentSales: 320000,
        joinDate: "2024-01-10",
        permissions: [
          "inventory_manage",
          "customer_manage",
          "billing_create",
          "reports_view",
        ],
        attendance: [],
        leaves: {"total": 24, "used": 4, "pending": 1, "balance": 19},
        storeIds: [],
      ),

      Staff(
        id: "STF002",
        name: "Priya Sharma",
        phone: "9123456780",
        email: "priya@store.com",
        role: "staff",
        store: "Main Store",
        status: "Active",
        salary: 25000,
        commission: 1.5,
        salesTarget: 300000,
        currentSales: 210000,
        joinDate: "2024-02-15",
        permissions: ["billing_create", "customer_view"],
        attendance: [],
        leaves: {"total": 18, "used": 3, "pending": 0, "balance": 15},
        storeIds: [],
      ),

      Staff(
        id: "STF003",
        name: "Rohit Verma",
        phone: "9988776655",
        email: "rohit@store.com",
        role: "staff",
        store: "City Branch",
        status: "Inactive",
        salary: 22000,
        commission: 1,
        salesTarget: 200000,
        currentSales: 120000,
        joinDate: "2023-11-01",
        permissions: ["billing_view"],
        attendance: [],
        leaves: {"total": 18, "used": 6, "pending": 2, "balance": 10},
        storeIds: [],
      ),

      Staff(
        id: "STF004",
        name: "Sneha Kapoor",
        phone: "9812345678",
        email: "sneha@store.com",
        role: "admin",
        store: "Gold Palace",
        status: "Active",
        salary: 40000,
        commission: 2,
        salesTarget: 450000,
        currentSales: 390000,
        joinDate: "2023-09-20",
        permissions: [
          "inventory_manage",
          "billing_create",
          "reports_view",
          "accounts_manage",
        ],
        attendance: [],
        leaves: {"total": 24, "used": 5, "pending": 0, "balance": 19},
        storeIds: [],
      ),
    ]);
  }

  /// =========================
  /// FILTERED STAFF
  /// =========================

  List<Staff> get filteredStaff {
    List<Staff> list = staffList.toList();

    /// STORE FILTER
    final selectedStore = storeController.selectedStore.value;

    if (selectedStore != null) {
      list = list.where((e) => e.store == selectedStore).toList();
    }

    /// ROLE FILTER

    if (filter.value == "admin") {
      list = list.where((e) => e.role == "admin").toList();
    }

    if (filter.value == "staff") {
      list = list.where((e) => e.role == "staff").toList();
    }

    if (filter.value == "active") {
      list = list.where((e) => e.status == "Active").toList();
    }

    if (filter.value == "inactive") {
      list = list.where((e) => e.status == "Inactive").toList();
    }

    /// SEARCH

    if (search.value.isNotEmpty) {
      final q = search.value.toLowerCase();

      list = list
          .where(
            (e) =>
                e.name.toLowerCase().contains(q) ||
                e.phone.contains(q) ||
                e.email.toLowerCase().contains(q),
          )
          .toList();
    }

    return list;
  }

  /// ADD STAFF

  void addStaff(Staff staff) {
    staffList.add(staff);
  }

  /// UPDATE STAFF

  void updateStaff(Staff staff) {
    int index = staffList.indexWhere((e) => e.id == staff.id);

    if (index != -1) {
      staffList[index] = staff;
      staffList.refresh();
    }
  }

  /// TOGGLE STATUS

  void toggleStatus(String id) {
    int index = staffList.indexWhere((e) => e.id == id);

    if (index == -1) return;

    if (staffList[index].status == "Active") {
      staffList[index].status = "Inactive";
    } else {
      staffList[index].status = "Active";
    }

    staffList.refresh();
  }
}
