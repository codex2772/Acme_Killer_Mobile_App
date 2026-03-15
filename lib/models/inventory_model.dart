class InventoryItem {
  final String id;
  final String name;
  final String category;

  final String metal;
  final String purity;

  final double netWeight;
  final double grossWeight;
  final double stoneWeight;

  final double makingCharge;

  final String huid;
  final String barcode;

  final String status;
  final String store;

  final int costPrice;
  final int sellingPrice;

  final String showcaseLocation;
  final String hallmarkCert;

  final DateTime? hallmarkDate;
  final DateTime dateAdded;

  final String description;

  final Map<String, dynamic>? stoneDetails;
  final List<Map<String, dynamic>> transferHistory;
  

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.metal,
    required this.purity,
    required this.netWeight,
    required this.grossWeight,
    required this.stoneWeight,
    required this.makingCharge,
    required this.huid,
    required this.barcode,
    required this.status,
    required this.store,
    required this.costPrice,
    required this.sellingPrice,
    required this.showcaseLocation,
    required this.hallmarkCert,
    this.hallmarkDate,
    required this.dateAdded,
    required this.description,
    this.stoneDetails,
    this.transferHistory = const [],
  });

  /// Margin %
  double get margin {
    if (costPrice == 0) return 0;
    return ((sellingPrice - costPrice) / costPrice) * 100;
  }

  /// Profit
  int get profit => sellingPrice - costPrice;

  /// Stock age
  int get stockAge => DateTime.now().difference(dateAdded).inDays;

  InventoryItem copyWith({
    String? name,
    String? category,
    String? metal,
    String? purity,
    double? netWeight,
    double? grossWeight,
    double? stoneWeight,
    double? makingCharge,
    String? huid,
    String? barcode,
    String? status,
    String? store,
    int? sellingPrice,
    int? costPrice,
    String? showcaseLocation,
    String? hallmarkCert,
    DateTime? hallmarkDate,
    DateTime? dateAdded,
    String? description,
    Map<String, dynamic>? stoneDetails,
    List<Map<String, dynamic>>? transferHistory,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      metal: metal ?? this.metal,
      purity: purity ?? this.purity,
      netWeight: netWeight ?? this.netWeight,
      grossWeight: grossWeight ?? this.grossWeight,
      stoneWeight: stoneWeight ?? this.stoneWeight,
      makingCharge: makingCharge ?? this.makingCharge,
      huid: huid ?? this.huid,
      barcode: barcode ?? this.barcode,
      status: status ?? this.status,
      store: store ?? this.store,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      showcaseLocation: showcaseLocation ?? this.showcaseLocation,
      hallmarkCert: hallmarkCert ?? this.hallmarkCert,
      hallmarkDate: hallmarkDate ?? this.hallmarkDate,
      dateAdded: dateAdded ?? this.dateAdded,
      description: description ?? this.description,
      stoneDetails: stoneDetails ?? this.stoneDetails,
      transferHistory: transferHistory ?? this.transferHistory,
    );
  }

  String get stockStatus {
    if (status == "Sold") return "Sold";
    if (status == "Reserved") return "Reserved";
    if (status == "Transferred") return "Transferred";
    return "In Stock";
  }

  
}
