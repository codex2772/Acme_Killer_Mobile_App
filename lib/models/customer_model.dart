class Customer {
  final String id;
  final String name;

  final String? phone;
  final String? email;

  final String? city;
  final String? address;

  final String? pan;
  final String? gstNumber;

  final String type;

  final int totalPurchasesNum;
  final int totalPurchases;

  final int visits;

  final DateTime? dob;
  final DateTime? anniversary;

  final String loyaltyTier;
  final int loyaltyPoints;

  final List<Map<String, dynamic>> purchaseHistory;
  final List<Map<String, dynamic>> ledger;

  final String notes;
  final int orders;
  final List<Map<String, dynamic>>? wishlist;

  String get outstanding {
    if (ledger.isEmpty) return "₹0";

    final last = ledger.last;

    return last["balance"] ?? "₹0";
  }

  Customer({
    required this.id,
    required this.name,

    this.phone,
    this.email,

    this.city,
    this.address,

    this.pan,
    this.gstNumber,

    required this.type,

    this.totalPurchasesNum = 0,
    this.totalPurchases = 0,

    this.visits = 0,

    this.dob,
    this.anniversary,

    this.loyaltyTier = "Silver",
    this.loyaltyPoints = 0,

    this.purchaseHistory = const [],
    this.ledger = const [],

    this.notes = "",
    this.orders = 0,
    this.wishlist,
  });

  /// Safe getters (prevents crashes)

  String get safePhone => phone ?? "-";

  String get safeEmail => email ?? "-";

  String get safeCity => city ?? "-";

  String get safeAddress => address ?? "-";

  String get safePan => pan ?? "-";

  String get safeGst => gstNumber ?? "-";

  /// Stats

  int get totalOrders => purchaseHistory.length;

  bool get hasLedger => ledger.isNotEmpty;

  List<Map<String, dynamic>> get safeWishlist => wishlist ?? [];
}
