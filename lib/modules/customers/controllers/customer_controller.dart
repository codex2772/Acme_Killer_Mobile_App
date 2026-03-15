import 'package:get/get.dart';
import '../../../models/customer_model.dart';

class CustomerController extends GetxController {
  var customers = <Customer>[].obs;

  var searchQuery = "".obs;
  var filter = "all".obs;

  @override
  void onInit() {
    super.onInit();
    seedData();
  }

  void seedData() {
    customers.addAll([
      /// CUSTOMER 1
      Customer(
        id: "C001",
        name: "Rahul Shah",
        phone: "9876543210",
        email: "rahul@gmail.com",
        city: "Mumbai",
        type: "vip",

        visits: 5,
        totalPurchases: 250000,
        totalPurchasesNum: 250000,

        loyaltyTier: "Gold",
        loyaltyPoints: 500,

        address: "Pune",
        pan: "ABCDE1234F",
        gstNumber: "27ABCDE1234F1Z5",

        /// 🎂 BIRTHDAY
        dob: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 5,
        ),

        /// 💍 ANNIVERSARY
        anniversary: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 10,
        ),

        /// PURCHASE HISTORY
        purchaseHistory: [
          {"item": "Gold Ring", "date": "2025-12-12", "amount": 45000},
          {"item": "Diamond Necklace", "date": "2025-10-01", "amount": 120000},
        ],

        /// LEDGER (KHATA)
        ledger: [
          {
            "type": "debit",
            "note": "Invoice INV-1001",
            "amount": 45000,
            "date": "2025-12-12",
            "balance": "₹25000",
          },
          {
            "type": "credit",
            "note": "Payment received",
            "amount": 20000,
            "date": "2025-12-15",
            "balance": "₹5000",
          },
        ],

        /// ⭐ WISHLIST
        wishlist: [
          {
            "itemName": "Temple Gold Necklace",
            "price": "₹180000",
            "addedDate": "2026-02-01",
          },
          {
            "itemName": "Diamond Stud Earrings",
            "price": "₹65000",
            "addedDate": "2026-02-10",
          },
        ],

        notes: "Prefers temple jewellery",
      ),

      /// CUSTOMER 2
      Customer(
        id: "C002",
        name: "Priya Mehta",
        phone: "9876541234",
        email: "priya@gmail.com",
        city: "Surat",
        type: "premium",

        visits: 3,
        totalPurchases: 150000,
        totalPurchasesNum: 150000,

        loyaltyTier: "Silver",
        loyaltyPoints: 200,

        address: "Mumbai",
        pan: "ABCDE1234G",
        gstNumber: "27ABCDE1234G1Z5",

        /// 🎂 BIRTHDAY
        dob: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 2,
        ),

        /// 💍 ANNIVERSARY
        anniversary: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 20,
        ),

        purchaseHistory: [
          {"item": "Gold Bangles", "date": "2025-08-20", "amount": 80000},
        ],

        ledger: [
          {
            "type": "debit",
            "note": "Invoice INV-1021",
            "amount": 80000,
            "date": "2025-08-20",
            "balance": "₹80000",
          },
        ],

        /// ⭐ WISHLIST
        wishlist: [
          {
            "itemName": "Polki Bridal Set",
            "price": "₹350000",
            "addedDate": "2026-03-01",
          },
        ],

        notes: "Loves diamond jewellery",
      ),
    ]);
  }

  /// =========================
  /// ANALYTICS
  /// =========================

  int get totalCustomers => customers.length;

  int get vipCustomers => customers.where((c) => c.type == "vip").length;

  int get lifetimeRevenue =>
      customers.fold(0, (sum, c) => sum + c.totalPurchases);

  int get outstandingCustomers =>
      customers.where((c) => c.outstanding != "₹0").length;

  /// =========================
  /// FILTERED CUSTOMERS
  /// =========================

  List<Customer> get filteredCustomers {
    List<Customer> list = customers.toList();

    if (filter.value != "all") {
      list = list.where((c) => c.type.toLowerCase() == filter.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();

      list = list
          .where(
            (c) =>
                c.name.toLowerCase().contains(q) ||
                (c.phone ?? "").contains(q) ||
                (c.email ?? "").toLowerCase().contains(q),
          )
          .toList();
    }

    return list;
  }

  /// =========================
  /// CRUD
  /// =========================

  void addCustomer(Customer c) {
    customers.add(c);
  }

  void deleteCustomer(String id) {
    customers.removeWhere((c) => c.id == id);
  }

  /// =========================
  /// BIRTHDAY REMINDERS
  /// =========================

  List<Customer> get upcomingBirthdays {
    final today = DateTime.now();

    return customers.where((c) {
      if (c.dob == null) return false;

      final next = DateTime(today.year, c.dob!.month, c.dob!.day);

      final diff = next.difference(today).inDays;

      return diff >= 0 && diff <= 30;
    }).toList();
  }

  /// =========================
  /// ANNIVERSARY REMINDERS
  /// =========================

  List<Customer> get upcomingAnniversaries {
    final today = DateTime.now();

    return customers.where((c) {
      if (c.anniversary == null) return false;

      final next = DateTime(
        today.year,
        c.anniversary!.month,
        c.anniversary!.day,
      );

      final diff = next.difference(today).inDays;

      return diff >= 0 && diff <= 30;
    }).toList();
  }
}
