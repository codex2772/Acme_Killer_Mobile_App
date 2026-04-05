class InventoryItem {
  final String id;
  final int? backendId;

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

  String status;
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

  /// ✅ FIXED (nullable)
  final int? quantity;

  final String? imageUrl;

  InventoryItem({
    required this.id,
    this.backendId,
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
    this.quantity,
    this.imageUrl,
  });

  /// ✅ SAFE GETTERS
  int get safeQty => quantity ?? 0;

  double get margin =>
      costPrice == 0 ? 0 : ((sellingPrice - costPrice) / costPrice) * 100;

  int get profit => sellingPrice - costPrice;

  int get stockAge => DateTime.now().difference(dateAdded).inDays;

  String get stockStatus {
    final qty = safeQty;

    if (status == 'Sold') return 'Sold';
    if (status == 'Reserved') return 'Reserved';
    if (qty <= 0) return 'Out of Stock';
    if (qty <= 2) return 'Low Stock';
    return 'In Stock';
  }

  String get formattedPrice {
    if (sellingPrice >= 10000000) {
      return '₹${(sellingPrice / 10000000).toStringAsFixed(1)}Cr';
    }
    if (sellingPrice >= 100000) {
      return '₹${(sellingPrice / 100000).toStringAsFixed(1)}L';
    }
    if (sellingPrice >= 1000) {
      return '₹${(sellingPrice / 1000).toStringAsFixed(0)}K';
    }
    return '₹$sellingPrice';
  }

  /// ✅ SAFE FROM JSON
  factory InventoryItem.fromJson(
    Map<String, dynamic> j, {
    String storeName = '',
  }) {
    const statusMap = {
      'IN_STOCK': 'In Stock',
      'SOLD': 'Sold',
      'ON_APPROVAL': 'Low Stock',
      'OUT_OF_STOCK': 'Out of Stock',
    };

    final categoryObj = j['category'] ?? {};
    String rawCategory = categoryObj['name'] ?? '';

    const categoryMap = {
      'Necklaces': 'Necklace',
      'Rings': 'Ring',
      'Bangles': 'Bangle',
      'Chains': 'Chain',
    };

    final category = categoryMap[rawCategory] ?? rawCategory;
    final metalObj = j['metalType'] ?? {};

    final netWeight = (j['netWeight'] ?? 0).toDouble();
    final making = (j['makingCharges'] ?? 0).toDouble();
    final rate = (metalObj['currentRate'] ?? 0).toDouble();
    final stone = (j['stoneCharges'] ?? 0).toDouble();
    final other = (j['otherCharges'] ?? 0).toDouble();

    final qty = (j['quantity'] as num?)?.toInt() ?? 0;

    String status = statusMap[j['status']?.toString()] ?? 'In Stock';

    if (qty <= 0 && j['status'] != 'SOLD') {
      status = 'Out of Stock';
    } else if (qty <= 2 && status == 'In Stock') {
      status = 'Low Stock';
    }

    DateTime created = DateTime.now();
    if (j['createdAt'] != null) {
      created = DateTime.tryParse(j['createdAt']) ?? DateTime.now();
    }

    return InventoryItem(
      id: j['sku'] ?? 'INV${j['id']}',
      backendId: j['id'],

      name: j['name'] ?? '',
      description: j['description'] ?? '',

      category: category,
      metal: metalObj['name'] ?? '—',
      purity: metalObj['purity'] ?? '—',

      netWeight: netWeight,
      grossWeight: (j['grossWeight'] ?? 0).toDouble(),
      stoneWeight: 0,

      makingCharge: making,

      huid: j['hsnCode'] ?? '—',
      barcode: j['barcode'] ?? 'JE-${j['id']}',

      status: status,
      store: storeName,

      costPrice: (netWeight * rate + making).round(),
      sellingPrice: (netWeight * rate + making + stone + other).round(),

      showcaseLocation: j['location'] ?? '',
      hallmarkCert: j['hsnCode'] ?? '',

      dateAdded: created,

      quantity: qty,
      imageUrl: j['imageUrl'],
    );
  }

  /// ✅ SAFE COPY
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
    int? costPrice,
    int? sellingPrice,
    String? showcaseLocation,
    String? hallmarkCert,
    DateTime? hallmarkDate,
    String? description,
    Map<String, dynamic>? stoneDetails,
    List<Map<String, dynamic>>? transferHistory,
    int? quantity,
    String? imageUrl,
  }) => InventoryItem(
    id: id,
    backendId: backendId,
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
    dateAdded: dateAdded,
    description: description ?? this.description,
    stoneDetails: stoneDetails ?? this.stoneDetails,
    transferHistory: transferHistory ?? this.transferHistory,
    quantity: quantity ?? this.quantity,
    imageUrl: imageUrl ?? this.imageUrl,
  );
}
