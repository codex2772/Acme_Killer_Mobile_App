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

  const InventoryItem({
    required this.id, this.backendId,
    required this.name, required this.category, required this.metal,
    required this.purity, required this.netWeight, required this.grossWeight,
    required this.stoneWeight, required this.makingCharge,
    required this.huid, required this.barcode, required this.status,
    required this.store, required this.costPrice, required this.sellingPrice,
    required this.showcaseLocation, required this.hallmarkCert,
    this.hallmarkDate, required this.dateAdded, required this.description,
    this.stoneDetails, this.transferHistory = const [],
  });

  double get margin => costPrice == 0 ? 0 : ((sellingPrice - costPrice) / costPrice) * 100;
  int    get profit => sellingPrice - costPrice;
  int    get stockAge => DateTime.now().difference(dateAdded).inDays;

  String get stockStatus {
    switch (status) {
      case 'Sold':      return 'Sold';
      case 'Reserved':  return 'Reserved';
      case 'Low Stock': return 'Low Stock';
      default:          return 'In Stock';
    }
  }

  String get formattedPrice {
    if (sellingPrice >= 10000000) return '₹${(sellingPrice/10000000).toStringAsFixed(1)}Cr';
    if (sellingPrice >= 100000)   return '₹${(sellingPrice/100000).toStringAsFixed(1)}L';
    if (sellingPrice >= 1000)     return '₹${(sellingPrice/1000).toStringAsFixed(0)}K';
    return '₹$sellingPrice';
  }

  factory InventoryItem.fromJson(Map<String, dynamic> j, {String storeName = ''}) {
    const sm = <String,String>{'IN_STOCK':'In Stock','SOLD':'Sold','ON_APPROVAL':'Low Stock','RETURNED':'In Stock','DAMAGED':'Low Stock'};
    final nw=( j['netWeight']??0).toDouble();
    final mk=(j['makingCharges']??0).toDouble();
    final rt=(j['rate']??0).toDouble();
    final st=(j['stoneCharges']??0).toDouble();
    final ot=(j['otherCharges']??0).toDouble();
    DateTime da=DateTime.now();
    final ca=j['createdAt'];
    if(ca is String && ca.length>=10) da=DateTime.tryParse(ca)??DateTime.now();
    return InventoryItem(
      id: j['sku']?.toString()??'INV${j['id']}', backendId: j['id'] as int?,
      name: j['name']?.toString()??'',
      category: (j['categoryName']??j['category']??'—').toString(),
      metal: (j['metalTypeName']??j['metalType']??'—').toString(),
      purity: j['purity']?.toString()??'—',
      netWeight: nw, grossWeight: (j['grossWeight']??0).toDouble(),
      stoneWeight: 0, makingCharge: mk,
      huid: (j['barcode']??j['hsnCode']??'—').toString(),
      barcode: j['barcode']?.toString()??'JE-INV${j['id']}',
      status: sm[j['status']?.toString()]??'In Stock',
      store: storeName,
      costPrice: (nw*rt+mk).round(), sellingPrice: (nw*rt+mk+st+ot).round(),
      showcaseLocation: '', hallmarkCert: j['hsnCode']?.toString()??'',
      dateAdded: da, description: j['description']?.toString()??'',
    );
  }

  InventoryItem copyWith({
    String? name, String? category, String? metal, String? purity,
    double? netWeight, double? grossWeight, double? stoneWeight, double? makingCharge,
    String? huid, String? barcode, String? status, String? store,
    int? costPrice, int? sellingPrice, String? showcaseLocation,
    String? hallmarkCert, DateTime? hallmarkDate, String? description,
    Map<String,dynamic>? stoneDetails, List<Map<String,dynamic>>? transferHistory,
  }) => InventoryItem(
    id: id, backendId: backendId,
    name: name??this.name, category: category??this.category,
    metal: metal??this.metal, purity: purity??this.purity,
    netWeight: netWeight??this.netWeight, grossWeight: grossWeight??this.grossWeight,
    stoneWeight: stoneWeight??this.stoneWeight, makingCharge: makingCharge??this.makingCharge,
    huid: huid??this.huid, barcode: barcode??this.barcode,
    status: status??this.status, store: store??this.store,
    costPrice: costPrice??this.costPrice, sellingPrice: sellingPrice??this.sellingPrice,
    showcaseLocation: showcaseLocation??this.showcaseLocation,
    hallmarkCert: hallmarkCert??this.hallmarkCert,
    hallmarkDate: hallmarkDate??this.hallmarkDate, dateAdded: dateAdded,
    description: description??this.description,
    stoneDetails: stoneDetails??this.stoneDetails,
    transferHistory: transferHistory??this.transferHistory,
  );
}
