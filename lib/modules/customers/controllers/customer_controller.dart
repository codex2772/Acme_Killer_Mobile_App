import 'package:get/get.dart';
import '../../../models/customer_model.dart';
import '../../../core/controllers/store_controller.dart';

class CustomerController extends GetxController {
  final StoreController _store = Get.find<StoreController>();

  final RxList<Customer> customers = <Customer>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString filter = 'all'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _seed();
  }

  // ── Demo data mirrors state.js customers ──
  void _seed() {
    customers.assignAll([
      Customer(
        id: 'CUS001', name: 'Priya Sharma',
        phone: '+91 98765 43210', whatsapp: '+91 98765 43210',
        email: 'priya@example.com', city: 'Mumbai',
        address: '12, Juhu Scheme, Andheri West', state: 'Maharashtra', pincode: '400049',
        pan: 'ABCPS1234F', aadhaar: '1234 5678 9012',
        type: 'VIP', store: 'Rajmahal Jewellers - Main',
        dob: DateTime(1985, DateTime.now().month, DateTime.now().day + 3),
        anniversary: DateTime(2010, DateTime.now().month, DateTime.now().day + 12),
        memberSince: '2022-03-15',
        loyaltyPoints: 3642, loyaltyTier: 'Gold', creditLimit: 500000,
        tags: ['Festival Buyer', 'Gold Lover', 'Bridal'],
        referredBy: 'Rahul Mehta', referralCount: 3,
        preferences: const CustomerPreferences(
          metal: 'Gold', purity: '22K', style: 'Temple & Traditional',
          ringSize: '14', wristSize: '6.5 inch', chainLength: '18 inch',
        ),
        notes: [
          CustomerNote(text: 'Prefers temple jewellery. Usually buys during Diwali & Akshaya Tritiya.', date: '2026-01-10', addedBy: 'Owner'),
          CustomerNote(text: 'Allergic to certain metals — only 22K+.', date: '2025-11-05', addedBy: 'Staff'),
        ],
        wishlist: [
          WishlistItem(itemName: 'Temple Gold Necklace Set', price: '₹2.8L', addedDate: '2026-02-01'),
          WishlistItem(itemName: 'Diamond Stud Earrings', price: '₹65,000', addedDate: '2026-02-10'),
        ],
        purchaseHistory: [
          PurchaseHistoryItem(invoiceId: 'BIL001', date: '2026-03-09', items: '22K Gold Necklace, Temple Earrings', itemCount: 2, total: '₹3.64L', totalNum: 364250, status: 'Paid'),
          PurchaseHistoryItem(invoiceId: 'BIL-P02', date: '2025-11-02', items: 'Kundan Bangle Set', itemCount: 1, total: '₹1.2L', totalNum: 120000, status: 'Paid'),
        ],
        ledger: [
          LedgerEntry(date: '2026-03-09', type: 'DR', desc: 'Invoice #BIL001', amount: '₹3.64L', amountNum: 364250, balance: '-₹3.64L', balanceNum: -364250),
          LedgerEntry(date: '2026-03-09', type: 'CR', desc: 'UPI Payment', amount: '₹3.64L', amountNum: 364250, balance: '₹0', balanceNum: 0),
        ],
      ),
      Customer(
        id: 'CUS002', name: 'Rahul Mehta',
        phone: '+91 87654 32109', email: 'rahul@example.com', city: 'Surat',
        address: '45, Ring Road, Vesu', state: 'Gujarat', pincode: '395007',
        pan: 'ABCRM5678G',
        type: 'Premium', store: 'Rajmahal Jewellers - Mall Road',
        dob: DateTime(1980, 7, 22),
        memberSince: '2021-06-10',
        loyaltyPoints: 1450, loyaltyTier: 'Silver', creditLimit: 200000,
        tags: ['Platinum Buyer', 'Wedding'],
        preferences: const CustomerPreferences(
          metal: 'Platinum', purity: '950 Platinum', style: 'Modern & Minimalist',
          ringSize: '16', wristSize: '7 inch',
        ),
        notes: [CustomerNote(text: 'Interested in platinum jewellery for gifting.', date: '2026-01-20', addedBy: 'Staff')],
        purchaseHistory: [
          PurchaseHistoryItem(invoiceId: 'BIL002', date: '2026-03-08', items: 'Platinum Wedding Band', itemCount: 1, total: '₹1.45L', totalNum: 145000, status: 'Paid'),
        ],
        ledger: [
          LedgerEntry(date: '2026-03-08', type: 'DR', desc: 'Invoice #BIL002', amount: '₹1.45L', amountNum: 145000, balance: '-₹1.45L', balanceNum: -145000),
          LedgerEntry(date: '2026-03-08', type: 'CR', desc: 'Card Payment', amount: '₹1.45L', amountNum: 145000, balance: '₹0', balanceNum: 0),
        ],
      ),
      Customer(
        id: 'CUS003', name: 'Anita Desai',
        phone: '+91 76543 21098', email: 'anita@example.com', city: 'Pune',
        address: 'B-12, Koregaon Park', state: 'Maharashtra', pincode: '411001',
        type: 'VIP', store: 'Rajmahal Jewellers - Main',
        dob: DateTime(1978, 11, 15),
        anniversary: DateTime(2005, DateTime.now().month, DateTime.now().day + 5),
        memberSince: '2020-01-05',
        loyaltyPoints: 5980, loyaltyTier: 'Platinum', creditLimit: 1000000,
        tags: ['Bridal', 'Kundan Lover', 'High Value'],
        preferences: const CustomerPreferences(
          metal: 'Gold', purity: '18K', style: 'Kundan & Polki',
          ringSize: '13', bangleSize: '2.4',
        ),
        purchaseHistory: [
          PurchaseHistoryItem(invoiceId: 'BIL003', date: '2026-03-07', items: 'Kundan Bridal Set, Temple Earrings, Gold Bangles', itemCount: 3, total: '₹5.98L', totalNum: 598500, status: 'Partial'),
        ],
        ledger: [
          LedgerEntry(date: '2026-03-07', type: 'DR', desc: 'Invoice #BIL003', amount: '₹5.98L', amountNum: 598500, balance: '-₹5.98L', balanceNum: -598500),
          LedgerEntry(date: '2026-03-07', type: 'CR', desc: 'Cash + UPI Payment', amount: '₹4.00L', amountNum: 400000, balance: '-₹1.98L', balanceNum: -198500),
        ],
        wishlist: [WishlistItem(itemName: 'Diamond Necklace Set', price: '₹4.5L', addedDate: '2026-01-15')],
      ),
      Customer(
        id: 'CUS004', name: 'Vikram Singh',
        phone: '+91 65432 10987', email: 'vikram@example.com', city: 'Delhi',
        address: '7, Defence Colony', state: 'Delhi', pincode: '110024',
        pan: 'ABCVS9012H',
        type: 'Regular', store: 'Rajmahal Jewellers - City Center',
        memberSince: '2024-08-20',
        loyaltyPoints: 52, loyaltyTier: 'Silver',
        purchaseHistory: [
          PurchaseHistoryItem(invoiceId: 'BIL004', date: '2026-03-05', items: 'Silver Chain', itemCount: 1, total: '₹52,000', totalNum: 52000, status: 'Pending'),
        ],
        ledger: [
          LedgerEntry(date: '2026-03-05', type: 'DR', desc: 'Invoice #BIL004', amount: '₹52,000', amountNum: 52000, balance: '-₹52,000', balanceNum: -52000),
        ],
      ),
      Customer(
        id: 'CUS005', name: 'Meera Patel',
        phone: '+91 54321 09876', email: 'meera@example.com', city: 'Ahmedabad',
        address: '23, Bodakdev', state: 'Gujarat', pincode: '380054',
        type: 'Premium', store: 'Rajmahal Jewellers - Main',
        dob: DateTime(1990, DateTime.now().month, DateTime.now().day + 8),
        memberSince: '2023-04-01',
        loyaltyPoints: 1980, loyaltyTier: 'Silver', creditLimit: 250000,
        tags: ['Festival Buyer', 'Gold Lover'],
        preferences: const CustomerPreferences(metal: 'Gold', purity: '22K', style: 'Temple & Traditional'),
        purchaseHistory: [
          PurchaseHistoryItem(invoiceId: 'BIL005', date: '2026-03-04', items: 'Gold Earrings Set', itemCount: 1, total: '₹1.98L', totalNum: 198000, status: 'Pending'),
        ],
        ledger: [
          LedgerEntry(date: '2026-03-04', type: 'DR', desc: 'Invoice #BIL005', amount: '₹1.98L', amountNum: 198000, balance: '-₹1.98L', balanceNum: -198000),
        ],
      ),
    ]);
  }

  // ── Filtered list ──
  List<Customer> get filteredCustomers {
    var list = customers.toList();

    final sel = _store.selectedStoreName;
    if (sel != null) list = list.where((c) => c.store == sel).toList();

    final f = filter.value;
    if (f != 'all') list = list.where((c) => c.type.toLowerCase() == f.toLowerCase()).toList();

    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.city.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  // ── Reminders (birthdays + anniversaries in next 30 days) ──
  List<Map<String, dynamic>> get upcomingReminders {
    final result = <Map<String, dynamic>>[];
    for (final c in customers) {
      final bd = c.daysUntilBirthday;
      if (bd != null && bd <= 30) {
        result.add({'customer': c, 'type': 'birthday', 'days': bd});
      }
      final an = c.daysUntilAnniversary;
      if (an != null && an <= 30) {
        result.add({'customer': c, 'type': 'anniversary', 'days': an});
      }
    }
    result.sort((a, b) => (a['days'] as int).compareTo(b['days'] as int));
    return result;
  }

  // ── Stats ──
  int get totalCount      => customers.length;
  int get vipCount        => customers.where((c) => c.type == 'VIP').length;
  int get outstandingCount=> customers.where((c) => c.hasOutstanding).length;
  int get lifetimeRevenue => customers.fold(0, (s, c) => s + c.totalPurchasesNum);

  String get lifetimeRevenueFormatted {
    final v = lifetimeRevenue;
    if (v >= 10000000) return '₹${(v/10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '₹${(v/100000).toStringAsFixed(1)}L';
    return '₹${(v/1000).toStringAsFixed(0)}K';
  }

  // ── CRUD ──
  Customer? getById(String id) {
    try { return customers.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }

  void addCustomer(Customer c) => customers.add(c);

  void updateCustomer(Customer updated) {
    final idx = customers.indexWhere((c) => c.id == updated.id);
    if (idx != -1) { customers[idx] = updated; customers.refresh(); }
  }

  void deleteCustomer(String id) => customers.removeWhere((c) => c.id == id);

  void addNote(String customerId, String text, String addedBy) {
    final idx = customers.indexWhere((c) => c.id == customerId);
    if (idx == -1) return;
    final updated = customers[idx].copyWith(
      notes: [CustomerNote(text: text, date: DateTime.now().toIso8601String().substring(0,10), addedBy: addedBy), ...customers[idx].notes],
    );
    customers[idx] = updated;
    customers.refresh();
  }
}
