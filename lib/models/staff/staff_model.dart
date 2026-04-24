class Staff {
  final String id;
  final String? backendId; // numeric id from API (e.g. 3)
  final String name;
  final String phone;
  final String email;
  final String role;
  final String store;
  final List<int> storeIds;
  String status;
  final double salary;
  final double commission;
  final double salesTarget;
  final double currentSales;
  final String joinDate;
  final List<String> permissions;
  final List attendance;
  final Map<String, dynamic> leaves;
  final String aadhaar;
  final String pan;

  Staff({
    required this.id,
    this.backendId,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.store,
    required this.storeIds,
    required this.status,
    required this.salary,
    required this.commission,
    required this.salesTarget,
    required this.currentSales,
    required this.joinDate,
    required this.permissions,
    required this.attendance,
    required this.leaves,
    this.aadhaar = '',
    this.pan = '',
  });

  // ── Create from backend JSON ─────────────────────────────────────────────
  factory Staff.fromBackend(
    Map<String, dynamic> s, {
    String fallbackStore = 'Store',
  }) {
    // ── Permission map: backend enum → local id ──
    const permMap = {
      'VIEW_INVENTORY': 'inventory_view',
      'MANAGE_INVENTORY': 'inventory_manage',
      'VIEW_CUSTOMERS': 'customer_view',
      'MANAGE_CUSTOMERS': 'customer_manage',
      'VIEW_BILLING': 'billing_view',
      'MANAGE_BILLING': 'billing_create',
      'VIEW_ACCOUNTS': 'accounts_view',
      'MANAGE_ACCOUNTS': 'accounts_manage',
      'VIEW_REPORTS': 'reports_view',
      'MANAGE_OLD_GOLD': 'old_gold_manage',
      'MANAGE_SCHEMES': 'schemes_manage',
      'MANAGE_RATES': 'rates_manage',
      'MANAGE_STAFF': 'staff_manage',
    };

    // ── Resolve store name ──
    String storeName = fallbackStore;
    final stores = s['stores'];
    if (stores is List && stores.isNotEmpty) {
      final first = stores[0];
      storeName = first is Map
          ? (first['name'] ?? storeName)
          : first.toString();
    }

    // ── Parse createdAt (ISO string, epoch ms, or Java array) ──
    String joinDate = '';
    final ca = s['createdAt'];
    if (ca is String && ca.isNotEmpty) {
      joinDate = ca.length >= 10 ? ca.substring(0, 10) : ca;
    } else if (ca is int) {
      joinDate = DateTime.fromMillisecondsSinceEpoch(
        ca,
      ).toIso8601String().substring(0, 10);
    } else if (ca is List && ca.length >= 3) {
      final y = ca[0].toString().padLeft(4, '0');
      final m = ca[1].toString().padLeft(2, '0');
      final d = ca[2].toString().padLeft(2, '0');
      joinDate = '$y-$m-$d';
    }

    final backendId = s['id']?.toString();
    final localPerms = ((s['permissions'] ?? []) as List)
        .map((p) => permMap[p.toString()] ?? p.toString().toLowerCase())
        .toList()
        .cast<String>();

    return Staff(
      id: 'STF${s['id']}',
      backendId: backendId,
      name: s['name'] ?? '',
      phone: s['mobile'] ?? '',
      email: s['email'] ?? '',
      role: (s['role'] ?? 'STAFF').toString().toLowerCase(),
      store: storeName,
      storeIds: [],
      status: s['active'] != false ? 'Active' : 'Inactive',
      salary: (s['salary'] ?? 0).toDouble(),
      commission: (s['commission'] ?? 0).toDouble(),
      salesTarget: (s['salesTarget'] ?? 0).toDouble(),
      currentSales: (s['currentSales'] ?? 0).toDouble(),
      joinDate: joinDate,
      permissions: localPerms,
      attendance: [],
      leaves: {'total': 24, 'used': 0, 'pending': 0, 'balance': 24},
      aadhaar: s['aadhaar'] ?? '',
      pan: s['pan'] ?? '',
    );
  }

  // ── Serialize for CREATE — POST /api/staff ───────────────────────────────
  // mirrors Electron renderAddStaff() apiPayload:
  //   name, mobile, password, role, storeIds, permissions
  //   (salary/commission/salesTarget are bonus fields)
  Map<String, dynamic> toCreatePayload({
    required List<int> storeIds,
    required String password,
  }) {
    final backendPerms = _mapPermsToBackend();
    return {
      'name': name,
      'mobile': phone.replaceAll(RegExp(r'[\s+\-]'), ''),
      'email': email,
      'password': password,
      'role': role.toUpperCase(),
      'storeIds': storeIds, // ← required for create
      'status': status == 'Active' ? 'ACTIVE' : 'INACTIVE',
      'permissions': role == 'admin' ? <String>[] : backendPerms,
      'salary': salary,
      'commission': commission,
      'salesTarget': salesTarget,
      if (aadhaar.isNotEmpty) 'aadhaar': aadhaar,
      if (pan.isNotEmpty) 'pan': pan,
    };
  }

  // ── Serialize for UPDATE — PUT /api/staff/:id ─────────────────────────────
  // mirrors Electron renderEditStaff() apiPayload exactly:
  //   name, mobile, email, role, salary, commission, salesTarget, status, permissions
  //   NO storeIds — Electron never sends it on update, backend keeps existing
  //   assignments. Sending storeIds on update resets store access → user "disappears"
  Map<String, dynamic> toUpdatePayload() {
    final backendPerms = _mapPermsToBackend();
    return {
      'name': name,
      'mobile': phone.replaceAll(RegExp(r'[\s+\-]'), ''),
      'email': email,
      'role': role.toUpperCase(),
      'salary': salary,
      'commission': commission,
      'salesTarget': salesTarget,
      'status': status == 'Active' ? 'ACTIVE' : 'INACTIVE',
      'permissions': role == 'admin' ? <String>[] : backendPerms,
      if (aadhaar.isNotEmpty) 'aadhaar': aadhaar,
      if (pan.isNotEmpty) 'pan': pan,
    };
  }

  // ── Kept for backward-compat — delegates to create/update based on password ──
  Map<String, dynamic> toBackendPayload({
    required List<int> storeIds,
    String? password,
  }) {
    if (password != null) {
      return toCreatePayload(storeIds: storeIds, password: password);
    }
    return toUpdatePayload();
  }

  List<String> _mapPermsToBackend() {
    const permMap = {
      'inventory_view': 'VIEW_INVENTORY',
      'inventory_manage': 'MANAGE_INVENTORY',
      'customer_view': 'VIEW_CUSTOMERS',
      'customer_manage': 'MANAGE_CUSTOMERS',
      'billing_view': 'VIEW_BILLING',
      'billing_create': 'MANAGE_BILLING',
      'accounts_view': 'VIEW_ACCOUNTS',
      'accounts_manage': 'MANAGE_ACCOUNTS',
      'reports_view': 'VIEW_REPORTS',
      'old_gold_manage': 'MANAGE_OLD_GOLD',
      'schemes_manage': 'MANAGE_SCHEMES',
      'rates_manage': 'MANAGE_RATES',
      'staff_manage': 'MANAGE_STAFF',
    };
    return permissions
        .map((p) => permMap[p] ?? p.toUpperCase())
        .where((p) => p.isNotEmpty)
        .toList();
  }
}
