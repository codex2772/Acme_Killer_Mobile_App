class CustomerPreferences {
  final String metal;
  final String purity;
  final String style;
  final String ringSize;
  final String wristSize;
  final String chainLength;
  final String bangleSize;
  final String ankletSize;

  const CustomerPreferences({
    this.metal = 'Gold',
    this.purity = '22K',
    this.style = 'Temple & Traditional',
    this.ringSize = '',
    this.wristSize = '',
    this.chainLength = '',
    this.bangleSize = '',
    this.ankletSize = '',
  });

  CustomerPreferences copyWith({
    String? metal,
    String? purity,
    String? style,
    String? ringSize,
    String? wristSize,
    String? chainLength,
    String? bangleSize,
    String? ankletSize,
  }) => CustomerPreferences(
    metal: metal ?? this.metal,
    purity: purity ?? this.purity,
    style: style ?? this.style,
    ringSize: ringSize ?? this.ringSize,
    wristSize: wristSize ?? this.wristSize,
    chainLength: chainLength ?? this.chainLength,
    bangleSize: bangleSize ?? this.bangleSize,
    ankletSize: ankletSize ?? this.ankletSize,
  );
}

class CustomerNote {
  final String text;
  final String date;
  final String addedBy;
  const CustomerNote({
    required this.text,
    required this.date,
    required this.addedBy,
  });
}

class WishlistItem {
  final String itemName;
  final String price;
  final String addedDate;
  const WishlistItem({
    required this.itemName,
    required this.price,
    required this.addedDate,
  });
}

class LedgerEntry {
  final String date;
  final String type; // DR | CR
  final String desc;
  final String amount;
  final int amountNum;
  final String balance;
  final int balanceNum;
  const LedgerEntry({
    required this.date,
    required this.type,
    required this.desc,
    required this.amount,
    required this.amountNum,
    required this.balance,
    required this.balanceNum,
  });
  bool get hasBalance => balanceNum < 0;
}

class PurchaseHistoryItem {
  final String invoiceId;
  final String date;
  final String items;
  final int itemCount;
  final String total;
  final int totalNum;
  final String status;
  const PurchaseHistoryItem({
    required this.invoiceId,
    required this.date,
    required this.items,
    required this.itemCount,
    required this.total,
    required this.totalNum,
    required this.status,
  });
}

class Customer {
  final String id;
  final int? backendId;
  final String name;
  final String phone;
  final String whatsapp;
  final String email;
  final String city;
  final String address;
  final String state;
  final String pincode;
  final String pan;
  final String aadhaar;
  final String gstNumber;
  final String type; // Regular | Premium | VIP
  final String store;
  final DateTime? dob;
  final DateTime? anniversary;
  final String memberSince;
  final int loyaltyPoints;
  final String loyaltyTier; // Silver | Gold | Platinum | Bronze
  final int creditLimit;
  final bool commSms;
  final bool commWhatsapp;
  final bool commEmail;
  final List<String> tags;
  final String referredBy;
  final int referralCount;
  final CustomerPreferences preferences;
  final List<CustomerNote> notes;
  final List<WishlistItem> wishlist;
  final List<PurchaseHistoryItem> purchaseHistory;
  final List<LedgerEntry> ledger;

  const Customer({
    required this.id,
    this.backendId,
    required this.name,
    this.phone = '',
    this.whatsapp = '',
    this.email = '',
    this.city = '',
    this.address = '',
    this.state = '',
    this.pincode = '',
    this.pan = '',
    this.aadhaar = '',
    this.gstNumber = '',
    required this.type,
    this.store = '',
    this.dob,
    this.anniversary,
    this.memberSince = '',
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'Silver',
    this.creditLimit = 100000,
    this.commSms = true,
    this.commWhatsapp = true,
    this.commEmail = false,
    this.tags = const [],
    this.referredBy = '',
    this.referralCount = 0,
    this.preferences = const CustomerPreferences(),
    this.notes = const [],
    this.wishlist = const [],
    this.purchaseHistory = const [],
    this.ledger = const [],
  });

  // ─── Computed ───
  String get initials {
    final trimmed = name.trim();

    if (trimmed.isEmpty) return 'C';

    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }

  int get totalPurchasesNum =>
      purchaseHistory.fold(0, (s, p) => s + p.totalNum);

  String get totalPurchasesFormatted {
    final v = totalPurchasesNum;
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹$v';
  }

  LedgerEntry? get lastLedgerEntry => ledger.isNotEmpty ? ledger.last : null;
  bool get hasOutstanding => lastLedgerEntry?.hasBalance ?? false;
  String get outstandingDisplay =>
      hasOutstanding ? lastLedgerEntry!.balance : '₹0';

  // Tier upgrade progress
  String get nextTier {
    switch (loyaltyTier) {
      case 'Silver':
        return 'Gold';
      case 'Gold':
        return 'Platinum';
      default:
        return '';
    }
  }

  int get nextTierThreshold {
    switch (loyaltyTier) {
      case 'Silver':
        return 500000;
      case 'Gold':
        return 1000000;
      default:
        return 0;
    }
  }

  double get loyaltyProgress => nextTierThreshold > 0
      ? (totalPurchasesNum / nextTierThreshold).clamp(0.0, 1.0)
      : 1.0;
  int get remainingToNextTier =>
      (nextTierThreshold - totalPurchasesNum).clamp(0, nextTierThreshold);

  // Birthday/Anniversary in next 30 days
  int? get daysUntilBirthday {
    if (dob == null) return null;
    final today = DateTime.now();
    var next = DateTime(today.year, dob!.month, dob!.day);
    if (next.isBefore(today))
      next = DateTime(today.year + 1, dob!.month, dob!.day);
    return next.difference(today).inDays;
  }

  int? get daysUntilAnniversary {
    if (anniversary == null) return null;
    final today = DateTime.now();
    var next = DateTime(today.year, anniversary!.month, anniversary!.day);
    if (next.isBefore(today))
      next = DateTime(today.year + 1, anniversary!.month, anniversary!.day);
    return next.difference(today).inDays;
  }

  // Backend mapper (mirrors mapBackendCustomer in customers.js)
  factory Customer.fromJson(Map<String, dynamic> j, {String storeName = ''}) {
    final fullName = [
      j['firstName'],
      j['lastName'],
    ].where((p) => p != null && p.toString().isNotEmpty).join(' ');
    return Customer(
      id: 'CUS${j['id']}',
      backendId: j['id'] as int?,
      name: fullName.isNotEmpty ? fullName : 'Unknown',
      phone: j['phone']?.toString() ?? '',
      whatsapp: j['phone']?.toString() ?? '',
      email: j['email']?.toString() ?? '',
      city: j['city']?.toString() ?? '',
      address: [
        j['addressLine1'],
        j['addressLine2'],
      ].where((p) => p != null).join(', '),
      state: j['state']?.toString() ?? '',
      pincode: j['pincode']?.toString() ?? '',
      pan: j['pan']?.toString() ?? '',
      gstNumber: j['gstin']?.toString() ?? '',
      type: 'Regular',
      store: storeName,
      memberSince: j['createdAt']?.toString().substring(0, 10) ?? '',
    );
  }

  Customer copyWith({
    String? name,
    String? phone,
    String? whatsapp,
    String? email,
    String? city,
    String? address,
    String? state,
    String? pincode,
    String? pan,
    String? aadhaar,
    String? gstNumber,
    String? type,
    DateTime? dob,
    DateTime? anniversary,
    List<String>? tags,
    String? referredBy,
    CustomerPreferences? preferences,
    List<CustomerNote>? notes,
    List<WishlistItem>? wishlist,
    List<PurchaseHistoryItem>? purchaseHistory,
    List<LedgerEntry>? ledger,
  }) => Customer(
    id: id,
    backendId: backendId,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    whatsapp: whatsapp ?? this.whatsapp,
    email: email ?? this.email,
    city: city ?? this.city,
    address: address ?? this.address,
    state: state ?? this.state,
    pincode: pincode ?? this.pincode,
    pan: pan ?? this.pan,
    aadhaar: aadhaar ?? this.aadhaar,
    gstNumber: gstNumber ?? this.gstNumber,
    type: type ?? this.type,
    store: store,
    dob: dob ?? this.dob,
    anniversary: anniversary ?? this.anniversary,
    memberSince: memberSince,
    loyaltyPoints: loyaltyPoints,
    loyaltyTier: loyaltyTier,
    creditLimit: creditLimit,
    commSms: commSms,
    commWhatsapp: commWhatsapp,
    commEmail: commEmail,
    tags: tags ?? this.tags,
    referredBy: referredBy ?? this.referredBy,
    referralCount: referralCount,
    preferences: preferences ?? this.preferences,
    notes: notes ?? this.notes,
    wishlist: wishlist ?? this.wishlist,
    purchaseHistory: purchaseHistory ?? this.purchaseHistory,
    ledger: ledger ?? this.ledger,
  );
}
