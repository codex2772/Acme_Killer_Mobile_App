// ════════════════════════════════════════════════════════════════════
// customer_controller.dart
// mirrors Electron customers.js renderCustomers()
// fetchAllStores → GET /api/customers
// ════════════════════════════════════════════════════════════════════
import 'package:acme_killer_mobile_app/services/settings_service.dart';
import 'package:get/get.dart';
import '../../../models/customer_model.dart';
import '../../../core/controllers/store_controller.dart';
import '../../../services/customer_service.dart';
import '../../../services/api_client.dart';

class CustomerController extends GetxController {
  final StoreController _store = Get.find<StoreController>();

  final RxList<Customer> customers = <Customer>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString filter = 'all'.obs;
  final RxBool isLoading = false.obs;

  // mirrors Electron: cache TTL — re-fetch if data is older than 60 seconds
  DateTime? _lastFetched;
  static const _staleDuration = Duration(seconds: 60);

  bool get isStale =>
      _lastFetched == null ||
      DateTime.now().difference(_lastFetched!) > _staleDuration;

  @override
  void onInit() {
    super.onInit();
    _seed();
    _fetchFromApi();
  }

  // ── API LOAD — mirrors Electron fetchAllStores → customers.list() ──
  Future<void> _fetchFromApi() async {
    isLoading.value = true;
    try {
      final svc = Get.find<CustomerService>();
      final storeCtx = Get.find<StoreContextService>();
      final stores = _store.stores;

      final List<Map<String, dynamic>> allRaw = [];

      if (stores.length > 1 && _store.selectedStore.value == null) {
        for (final s in stores) {
          storeCtx.switchStore(s.id);
          final r = await svc.list();
          if (r.success && r.data is List) {
            for (final c in (r.data as List)) {
              final m = Map<String, dynamic>.from(c as Map);
              m['_storeName'] = s.name;
              allRaw.add(m);
            }
          }
        }
        storeCtx.clearStore();
      } else {
        final r = await svc.list();
        if (r.success && r.data is List)
          allRaw.addAll(List<Map<String, dynamic>>.from(r.data as List));
      }

      if (allRaw.isNotEmpty) {
        // Deduplicate
        final seen = <dynamic>{};
        final deduped = allRaw.where((c) {
          if (seen.contains(c['id'])) return false;
          seen.add(c['id']);
          return true;
        }).toList();

        final mapped = deduped.map((c) => _mapBackendCustomer(c)).toList();
        customers.assignAll(mapped);
        _lastFetched = DateTime.now();
      }
    } catch (_) {}
    isLoading.value = false;
  }

  // mirrors Electron mapBackendCustomer()
  Customer _mapBackendCustomer(Map<String, dynamic> c) {
    final fullName =
        c['name']?.toString() ??
        [c['firstName'], c['lastName']].where((s) => s != null).join(' ');
    return Customer(
      id: 'CUS${c['id']}',
      backendId: c['id'],
      name: fullName.isEmpty ? 'Unknown' : fullName,
      phone: c['phone']?.toString() ?? '',
      whatsapp: c['phone']?.toString() ?? '',
      email: c['email']?.toString() ?? '',
      city: c['city']?.toString() ?? '',
      address: [
        c['addressLine1'],
        c['addressLine2'],
      ].where((s) => s != null && s.toString().isNotEmpty).join(', '),
      state: c['state']?.toString() ?? '',
      pincode: c['pincode']?.toString() ?? '',
      pan: c['pan']?.toString() ?? '',
      aadhaar: '',
      type: 'Regular',
      store: c['_storeName']?.toString() ?? _store.selectedStoreName ?? '',
      memberSince: c['createdAt'] != null
          ? c['createdAt'].toString().substring(0, 10)
          : '',
      loyaltyPoints: 0,
      loyaltyTier: 'Silver',
      creditLimit: 100000,
      tags: [],
      referredBy: '',
      referralCount: 0,
      preferences: const CustomerPreferences(metal: 'Gold', purity: '22K'),
      notes: [],
      wishlist: [],
      purchaseHistory: [],
      ledger: [],
    );
  }

  Future<void> refresh() => _fetchFromApi();

  // Called when the Customers screen becomes visible again.
  // Only re-fetches if data is stale (> 60s old) — avoids hammering the API
  // on every tab switch while still catching updates from other devices.
  Future<void> refreshIfStale() async {
    if (isStale && !isLoading.value) await _fetchFromApi();
  }

  // mirrors Electron: debounced API search merges new results
  Future<void> searchFromApi(String query) async {
    try {
      final r = await Get.find<CustomerService>().search(query);
      if (r.success && r.data is List) {
        final existingIds = customers.map((c) => c.id).toSet();
        final newOnes = (r.data as List)
            .map((c) => _mapBackendCustomer(c as Map<String, dynamic>))
            .where((c) => !existingIds.contains(c.id))
            .toList();
        if (newOnes.isNotEmpty) {
          customers.addAll(newOnes);
        }
      }
    } catch (_) {}
  }

  // ── CREATE — mirrors Electron: customers:create → POST /api/customers ──
  Future<bool> createViaApi(Map<String, dynamic> payload) async {
    try {
      final r = await Get.find<CustomerService>().create(payload);
      if (r.success) _fetchFromApi();
      return r.success;
    } catch (_) {
      return false;
    }
  }

  // ── UPDATE — mirrors Electron: customers:update → PUT /api/customers/:id ──
  Future<bool> updateViaApi(
    dynamic backendId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final r = await Get.find<CustomerService>().update(backendId, payload);
      if (r.success) _fetchFromApi();
      return r.success;
    } catch (_) {
      return false;
    }
  }

  // ── DELETE — mirrors Electron: customers:delete → DELETE /api/customers/:id ──
  Future<bool> deleteViaApi(dynamic backendId) async {
    try {
      final r = await Get.find<CustomerService>().delete(backendId);
      if (r.success) _fetchFromApi();
      return r.success;
    } catch (_) {
      return false;
    }
  }

  // ── Filtered list ──
  List<Customer> get filteredCustomers {
    var list = customers.toList();
    final sel = _store.selectedStoreName;
    if (sel != null) list = list.where((c) => c.store == sel).toList();
    final f = filter.value;
    if (f != 'all')
      list = list
          .where((c) => c.type.toLowerCase() == f.toLowerCase())
          .toList();
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.name.toLowerCase().contains(q) ||
                c.phone.contains(q) ||
                c.email.toLowerCase().contains(q) ||
                c.city.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  List<Map<String, dynamic>> get upcomingReminders {
    final result = <Map<String, dynamic>>[];
    for (final c in customers) {
      final bd = c.daysUntilBirthday;
      if (bd != null && bd <= 30)
        result.add({'customer': c, 'type': 'birthday', 'days': bd});
      final an = c.daysUntilAnniversary;
      if (an != null && an <= 30)
        result.add({'customer': c, 'type': 'anniversary', 'days': an});
    }
    result.sort((a, b) => (a['days'] as int).compareTo(b['days'] as int));
    return result;
  }

  int get totalCount => customers.length;
  int get vipCount => customers.where((c) => c.type == 'VIP').length;
  int get outstandingCount => customers.where((c) => c.hasOutstanding).length;
  int get lifetimeRevenue =>
      customers.fold(0, (s, c) => s + c.totalPurchasesNum);

  String get lifetimeRevenueFormatted {
    final v = lifetimeRevenue;
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    return '₹${(v / 1000).toStringAsFixed(0)}K';
  }

  Customer? getById(String id) {
    try {
      return customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void addCustomer(Customer c) => customers.add(c);
  void updateCustomer(Customer updated) {
    final idx = customers.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      customers[idx] = updated;
      customers.refresh();
    }
  }

  void deleteCustomer(String id) => customers.removeWhere((c) => c.id == id);
  void addNote(String customerId, String text, String addedBy) {
    final idx = customers.indexWhere((c) => c.id == customerId);
    if (idx == -1) return;
    customers[idx] = customers[idx].copyWith(
      notes: [
        CustomerNote(
          text: text,
          date: DateTime.now().toIso8601String().substring(0, 10),
          addedBy: addedBy,
        ),
        ...customers[idx].notes,
      ],
    );
    customers.refresh();
  }

  void _seed() {
    customers.assignAll([
      Customer(
        id: 'CUS001',
        name: 'Priya Sharma',
        phone: '+91 98765 43210',
        whatsapp: '+91 98765 43210',
        email: 'priya@example.com',
        city: 'Mumbai',
        address: '12, Juhu Scheme, Andheri West',
        state: 'Maharashtra',
        pincode: '400049',
        pan: 'ABCPS1234F',
        aadhaar: '1234 5678 9012',
        type: 'VIP',
        store: 'Rajmahal Jewellers - Main',
        dob: DateTime(1985, DateTime.now().month, DateTime.now().day + 3),
        anniversary: DateTime(
          2010,
          DateTime.now().month,
          DateTime.now().day + 12,
        ),
        memberSince: '2022-03-15',
        loyaltyPoints: 3642,
        loyaltyTier: 'Gold',
        creditLimit: 500000,
        tags: ['Festival Buyer', 'Gold Lover', 'Bridal'],
        referredBy: 'Rahul Mehta',
        referralCount: 3,
        preferences: const CustomerPreferences(
          metal: 'Gold',
          purity: '22K',
          style: 'Temple & Traditional',
          ringSize: '14',
          wristSize: '6.5 inch',
          chainLength: '18 inch',
        ),
        notes: [
          CustomerNote(
            text: 'Prefers temple jewellery.',
            date: '2026-01-10',
            addedBy: 'Owner',
          ),
        ],
        wishlist: [
          WishlistItem(
            itemName: 'Temple Gold Necklace Set',
            price: '₹2.8L',
            addedDate: '2026-02-01',
          ),
        ],
        purchaseHistory: [
          PurchaseHistoryItem(
            invoiceId: 'BIL001',
            date: '2026-03-09',
            items: '22K Gold Necklace',
            itemCount: 2,
            total: '₹3.64L',
            totalNum: 364250,
            status: 'Paid',
          ),
        ],
        ledger: [
          LedgerEntry(
            date: '2026-03-09',
            type: 'CR',
            desc: 'UPI Payment',
            amount: '₹3.64L',
            amountNum: 364250,
            balance: '₹0',
            balanceNum: 0,
          ),
        ],
      ),
      Customer(
        id: 'CUS002',
        name: 'Rahul Mehta',
        phone: '+91 87654 32109',
        email: 'rahul@example.com',
        city: 'Surat',
        address: '45, Ring Road, Vesu',
        state: 'Gujarat',
        pincode: '395007',
        pan: 'ABCRM5678G',
        type: 'Premium',
        store: 'Rajmahal Jewellers - Mall Road',
        dob: DateTime(1980, 7, 22),
        memberSince: '2021-06-10',
        loyaltyPoints: 1450,
        loyaltyTier: 'Silver',
        creditLimit: 200000,
        tags: ['Platinum Buyer', 'Wedding'],
        preferences: const CustomerPreferences(
          metal: 'Platinum',
          purity: '950 Platinum',
          style: 'Modern & Minimalist',
          ringSize: '16',
          wristSize: '7 inch',
        ),
        notes: [],
        purchaseHistory: [
          PurchaseHistoryItem(
            invoiceId: 'BIL002',
            date: '2026-03-08',
            items: 'Platinum Wedding Band',
            itemCount: 1,
            total: '₹1.45L',
            totalNum: 145000,
            status: 'Paid',
          ),
        ],
        ledger: [],
      ),
      Customer(
        id: 'CUS003',
        name: 'Anita Desai',
        phone: '+91 76543 21098',
        email: 'anita@example.com',
        city: 'Pune',
        address: 'B-12, Koregaon Park',
        state: 'Maharashtra',
        pincode: '411001',
        type: 'VIP',
        store: 'Rajmahal Jewellers - Main',
        dob: DateTime(1978, 11, 15),
        anniversary: DateTime(
          2005,
          DateTime.now().month,
          DateTime.now().day + 5,
        ),
        memberSince: '2020-01-05',
        loyaltyPoints: 5980,
        loyaltyTier: 'Platinum',
        creditLimit: 1000000,
        tags: ['Bridal', 'Kundan Lover', 'High Value'],
        preferences: const CustomerPreferences(
          metal: 'Gold',
          purity: '18K',
          style: 'Kundan & Polki',
          ringSize: '13',
          bangleSize: '2.4',
        ),
        notes: [],
        purchaseHistory: [],
        ledger: [],
        wishlist: [
          WishlistItem(
            itemName: 'Diamond Necklace Set',
            price: '₹4.5L',
            addedDate: '2026-01-15',
          ),
        ],
      ),
      Customer(
        id: 'CUS004',
        name: 'Vikram Singh',
        phone: '+91 65432 10987',
        email: 'vikram@example.com',
        city: 'Delhi',
        address: '7, Defence Colony',
        state: 'Delhi',
        pincode: '110024',
        pan: 'ABCVS9012H',
        type: 'Regular',
        store: 'Rajmahal Jewellers - City Center',
        memberSince: '2024-08-20',
        loyaltyPoints: 52,
        loyaltyTier: 'Silver',
        notes: [],
        purchaseHistory: [],
        ledger: [],
      ),
      Customer(
        id: 'CUS005',
        name: 'Meera Patel',
        phone: '+91 54321 09876',
        email: 'meera@example.com',
        city: 'Ahmedabad',
        address: '23, Bodakdev',
        state: 'Gujarat',
        pincode: '380054',
        type: 'Premium',
        store: 'Rajmahal Jewellers - Main',
        dob: DateTime(1990, DateTime.now().month, DateTime.now().day + 8),
        memberSince: '2023-04-01',
        loyaltyPoints: 1980,
        loyaltyTier: 'Silver',
        creditLimit: 250000,
        tags: ['Festival Buyer', 'Gold Lover'],
        preferences: const CustomerPreferences(
          metal: 'Gold',
          purity: '22K',
          style: 'Temple & Traditional',
        ),
        notes: [],
        purchaseHistory: [],
        ledger: [],
      ),
    ]);
  }
}
