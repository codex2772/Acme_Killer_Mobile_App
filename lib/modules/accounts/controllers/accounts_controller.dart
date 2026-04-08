import 'package:acme_killer_mobile_app/services/settings_service.dart';
import 'package:get/get.dart';
import '../../../core/controllers/store_controller.dart';
import '../../../modules/billing/controllers/billing_controller.dart';
import '../../../services/accounts_service.dart';
import '../../../services/api_client.dart';

// ─── Models (unchanged) ───────────────────────────────────────────
class LedgerEntry {
  final String id, date, party, type, amount, mode, note, category, store;
  final int amountNum;
  String balance;
  int balanceNum;
  LedgerEntry({
    required this.id,
    required this.date,
    required this.party,
    required this.type,
    required this.amountNum,
    required this.amount,
    required this.mode,
    required this.note,
    required this.category,
    required this.store,
    this.balance = '—',
    this.balanceNum = 0,
  });
  String get formattedAmount {
    if (amountNum >= 100000)
      return '₹${(amountNum / 100000).toStringAsFixed(1)}L';
    if (amountNum >= 1000) return '₹${(amountNum / 1000).toStringAsFixed(0)}K';
    return '₹$amountNum';
  }
}

class Expense {
  final String id, store;
  String date, category, description, mode;
  int amount;
  Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.mode,
    required this.store,
  });
  String get formattedAmount {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(0)}K';
    return '₹$amount';
  }

  int? backendId;
}

class Supplier {
  final String id, store;
  String name, phone, email, city, address, gst, status;
  List<String> metals;
  int totalBusinessNum, balanceNum;
  int? backendId;
  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.address,
    required this.gst,
    required this.metals,
    required this.status,
    required this.store,
    required this.totalBusinessNum,
    required this.balanceNum,
    this.backendId,
  });
  String get totalBusinessFormatted {
    if (totalBusinessNum >= 10000000)
      return '₹${(totalBusinessNum / 10000000).toStringAsFixed(1)}Cr';
    if (totalBusinessNum >= 100000)
      return '₹${(totalBusinessNum / 100000).toStringAsFixed(1)}L';
    return '₹$totalBusinessNum';
  }

  String get balanceFormatted {
    final v = balanceNum.abs();
    final p = balanceNum < 0 ? '-₹' : '₹';
    if (v >= 100000) return '$p${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '$p${(v / 1000).toStringAsFixed(0)}K';
    return '$p$v';
  }
}

class CashRegisterEntry {
  final String id, date, store;
  int openingBalance, cashIn, cashOut, closingBalance;
  String closedBy, status;
  int? backendId;
  CashRegisterEntry({
    required this.id,
    required this.date,
    required this.openingBalance,
    required this.cashIn,
    required this.cashOut,
    required this.closingBalance,
    required this.store,
    required this.closedBy,
    required this.status,
    this.backendId,
  });
  int get expectedClosing => openingBalance + cashIn - cashOut;
  String fmt(int v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹$v';
  }
}

const List<String> kExpenseCategories = [
  'Salary',
  'Rent',
  'Utilities',
  'Insurance',
  'Maintenance',
  'Marketing',
  'Repairs',
  'Travel',
  'Office Supplies',
  'Miscellaneous',
];

// ════════════════════════════════════════════════════════════════════
// AccountsController
// mirrors Electron accounts.js renderAccounts()
// All 4 sub-sections use fetchAllStores pattern
// ════════════════════════════════════════════════════════════════════
class AccountsController extends GetxController {
  final StoreController _store = Get.find<StoreController>();

  final RxList<LedgerEntry> ledger = <LedgerEntry>[].obs;
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<Supplier> suppliers = <Supplier>[].obs;
  final RxList<CashRegisterEntry> cashRegister = <CashRegisterEntry>[].obs;

  final RxString ledgerSearch = ''.obs;
  final RxString ledgerFilter = 'all'.obs;
  final RxString ledgerDate = 'month'.obs;
  final RxString expenseFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _seedLedger();
    _seedExpenses();
    _seedSuppliers();
    _seedCashRegister();
    _fetchAll();
  }

  // ════════════════════════════════════════════════════════════════
  // API LOADS — all via fetchAllStores pattern
  // ════════════════════════════════════════════════════════════════
  Future<void> _fetchAll() async {
    await Future.wait([
      _loadLedger(),
      _loadExpenses(),
      _loadSuppliers(),
      _loadCashRegister(),
    ]);
  }

  Future<void> refresh() => _fetchAll();

  Future<void> _loadLedger() async {
    try {
      final r = await _fetchAllStores(
        (storeId) => Get.find<LedgerService>().list(),
      );
      if (r.isNotEmpty) {
        ledger.assignAll(
          r
              .map(
                (m) => LedgerEntry(
                  id: m['id']?.toString() ?? '',
                  date: (m['date'] ?? '').toString().substring(0, 10),
                  party:
                      m['party']?.toString() ??
                      m['description']?.toString() ??
                      '',
                  type: m['type']?.toString() ?? 'CR',
                  amountNum: (m['amount'] as num?)?.toInt() ?? 0,
                  amount: fmt((m['amount'] as num?)?.toInt() ?? 0),
                  mode: m['mode']?.toString() ?? 'Cash',
                  note:
                      m['note']?.toString() ??
                      m['description']?.toString() ??
                      '',
                  category: m['category']?.toString() ?? '',
                  store: m['_storeName']?.toString() ?? '',
                ),
              )
              .toList(),
        );
      }
    } catch (_) {}
  }

  Future<void> _loadExpenses() async {
    try {
      final r = await _fetchAllStores(
        (storeId) => Get.find<ExpensesService>().list(),
      );
      if (r.isNotEmpty) {
        expenses.assignAll(
          r.map((m) {
            final e = Expense(
              id: m['id']?.toString() ?? '',
              date: (m['date'] ?? '').toString().substring(0, 10),
              category: m['category']?.toString() ?? '',
              description: m['description']?.toString() ?? '',
              amount: (m['amount'] as num?)?.toInt() ?? 0,
              mode: m['mode']?.toString() ?? 'Cash',
              store: m['_storeName']?.toString() ?? '',
            );
            e.backendId = m['id'] as int?;
            return e;
          }).toList(),
        );
      }
    } catch (_) {}
  }

  Future<void> _loadSuppliers() async {
    try {
      final r = await _fetchAllStores(
        (storeId) => Get.find<SuppliersService>().list(),
      );
      if (r.isNotEmpty) {
        suppliers.assignAll(
          r.map((m) {
            final s = Supplier(
              id: 'SUP${m['id']}',
              name: m['name']?.toString() ?? '',
              phone: m['phone']?.toString() ?? '',
              email: m['email']?.toString() ?? '',
              city: m['city']?.toString() ?? '',
              address: m['address']?.toString() ?? '',
              gst: m['gst']?.toString() ?? '',
              metals: List<String>.from(m['metals'] ?? []),
              status: m['status']?.toString() ?? 'Active',
              store: m['_storeName']?.toString() ?? '',
              totalBusinessNum: (m['totalBusiness'] as num?)?.toInt() ?? 0,
              balanceNum: (m['balance'] as num?)?.toInt() ?? 0,
              backendId: m['id'] as int?,
            );
            return s;
          }).toList(),
        );
      }
    } catch (_) {}
  }

  Future<void> _loadCashRegister() async {
    try {
      final r = await _fetchAllStores(
        (storeId) => Get.find<CashRegisterService>().list(),
      );
      if (r.isNotEmpty) {
        cashRegister.assignAll(
          r.map((m) {
            final c = CashRegisterEntry(
              id: m['id']?.toString() ?? '',
              date: (m['date'] ?? '').toString().substring(0, 10),
              openingBalance: (m['openingBalance'] as num?)?.toInt() ?? 0,
              cashIn: (m['cashIn'] as num?)?.toInt() ?? 0,
              cashOut: (m['cashOut'] as num?)?.toInt() ?? 0,
              closingBalance: (m['closingBalance'] as num?)?.toInt() ?? 0,
              store: m['_storeName']?.toString() ?? '',
              closedBy: m['closedBy']?.toString() ?? '',
              status: m['status']?.toString() ?? 'Closed',
              backendId: m['id'] as int?,
            );
            return c;
          }).toList(),
        );
      }
    } catch (_) {}
  }

  // ── fetchAllStores helper ──
  Future<List<Map<String, dynamic>>> _fetchAllStores(
    Future<dynamic> Function(int?) fetchFn,
  ) async {
    final allRaw = <Map<String, dynamic>>[];
    final storeCtx = Get.find<StoreContextService>();
    final stores = _store.stores;

    if (stores.length > 1 && _store.selectedStore.value == null) {
      for (final s in stores) {
        storeCtx.switchStore(s.id);
        final r = await fetchFn(s.id);
        if (r != null && r.success == true && r.data is List) {
          for (final item in (r.data as List)) {
            final m = Map<String, dynamic>.from(item as Map);
            m['_storeName'] = s.name;
            allRaw.add(m);
          }
        }
      }
      storeCtx.clearStore();
    } else {
      final r = await fetchFn(_store.selectedStore.value?.id);
      if (r != null && r.success == true && r.data is List) {
        allRaw.addAll(List<Map<String, dynamic>>.from(r.data as List));
      }
    }
    return allRaw;
  }

  // ════════════════════════════════════════════════════════════════
  // API WRITES
  // ════════════════════════════════════════════════════════════════

  Future<void> addEntry({
    required String type,
    required String date,
    required String party,
    required int amount,
    required String mode,
    required String category,
    required String note,
  }) async {
    final sel = _store.selectedStoreName ?? '';
    final newId = 'TXN${(ledger.length + 1).toString().padLeft(3, '0')}';
    ledger.insert(
      0,
      LedgerEntry(
        id: newId,
        date: date,
        party: party,
        type: type,
        amountNum: amount,
        amount: fmt(amount),
        mode: mode,
        note: note.isEmpty ? '$category — $party' : note,
        category: category,
        store: sel,
      ),
    );
    // Mirror Electron: add to expenses if DR + expense category
    if (type == 'DR' && !['Sales', 'Purchase'].contains(category)) {
      final expId = 'EXP${(expenses.length + 1).toString().padLeft(3, '0')}';
      expenses.add(
        Expense(
          id: expId,
          date: date,
          category: category,
          description: note.isEmpty ? party : note,
          amount: amount,
          mode: mode,
          store: sel,
        ),
      );
    }
    // API
    try {
      await Get.find<LedgerService>().create({
        'type': type,
        'date': date,
        'party': party,
        'amount': amount,
        'mode': mode,
        'category': category,
        'description': note,
      });
      if (type == 'DR' && !['Sales', 'Purchase'].contains(category)) {
        await Get.find<ExpensesService>().create({
          'category': category,
          'description': note,
          'amount': amount,
          'mode': mode,
          'date': date,
        });
      }
    } catch (_) {}
  }

  Future<void> addSupplier(Supplier s) async {
    suppliers.add(s);
    try {
      await Get.find<SuppliersService>().create({
        'name': s.name,
        'phone': s.phone,
        'email': s.email,
        'city': s.city,
        'address': s.address,
        'gst': s.gst,
        'metals': s.metals,
        'status': s.status,
      });
    } catch (_) {}
  }

  Future<void> updateSupplier(
    String id, {
    String? name,
    String? phone,
    String? email,
    String? city,
    String? gst,
  }) async {
    final idx = suppliers.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    if (name != null) suppliers[idx].name = name;
    if (phone != null) suppliers[idx].phone = phone;
    if (email != null) suppliers[idx].email = email;
    if (city != null) suppliers[idx].city = city;
    if (gst != null) suppliers[idx].gst = gst;
    suppliers.refresh();
    final bid = suppliers[idx].backendId;
    if (bid != null)
      try {
        await Get.find<SuppliersService>().update(bid, {
          'name': suppliers[idx].name,
          'phone': suppliers[idx].phone,
          'email': suppliers[idx].email,
          'city': suppliers[idx].city,
          'gst': suppliers[idx].gst,
        });
      } catch (_) {}
  }

  Future<void> deleteSupplier(String id) async {
    final s = suppliers.firstWhereOrNull((s) => s.id == id);
    suppliers.removeWhere((s) => s.id == id);
    if (s?.backendId != null)
      try {
        await Get.find<SuppliersService>().delete(s!.backendId!);
      } catch (_) {}
  }

  Future<void> updateExpense(
    String id, {
    String? category,
    String? description,
    int? amount,
    String? mode,
  }) async {
    final idx = expenses.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    if (category != null) expenses[idx].category = category;
    if (description != null) expenses[idx].description = description;
    if (amount != null) expenses[idx].amount = amount;
    if (mode != null) expenses[idx].mode = mode;
    expenses.refresh();
    final bid = expenses[idx].backendId;
    if (bid != null)
      try {
        await Get.find<ExpensesService>().update(bid, {
          'category': expenses[idx].category,
          'amount': expenses[idx].amount,
          'description': expenses[idx].description,
        });
      } catch (_) {}
  }

  Future<void> deleteExpense(String id) async {
    final e = expenses.firstWhereOrNull((e) => e.id == id);
    expenses.removeWhere((e) => e.id == id);
    if (e?.backendId != null)
      try {
        await Get.find<ExpensesService>().delete(e!.backendId!);
      } catch (_) {}
  }

  Future<void> openCashRegister(int openingBalance) async {
    final sel = _store.selectedStoreName ?? '';
    final newId = 'CR${(cashRegister.length + 1).toString().padLeft(3, '0')}';
    cashRegister.insert(
      0,
      CashRegisterEntry(
        id: newId,
        date: DateTime.now().toIso8601String().substring(0, 10),
        openingBalance: openingBalance,
        cashIn: 0,
        cashOut: 0,
        closingBalance: 0,
        store: sel,
        closedBy: '',
        status: 'Open',
      ),
    );
    try {
      await Get.find<CashRegisterService>().open({
        'openingBalance': openingBalance,
        'storeName': sel,
      });
    } catch (_) {}
  }

  Future<void> closeCashRegister(String id, int actualClosing) async {
    final idx = cashRegister.indexWhere((cr) => cr.id == id);
    if (idx == -1) return;
    cashRegister[idx].closingBalance = actualClosing;
    cashRegister[idx].closedBy = 'Owner';
    cashRegister[idx].status = 'Closed';
    cashRegister.refresh();
    final bid = cashRegister[idx].backendId;
    if (bid != null)
      try {
        await Get.find<CashRegisterService>().close(bid, {
          'closingBalance': actualClosing,
          'closedBy': 'Owner',
        });
      } catch (_) {}
  }

  // ── Filtered views ──
  List<LedgerEntry> get filteredLedger {
    var list = ledger.toList();
    final sel = _store.selectedStoreName;
    if (sel != null) list = list.where((t) => t.store == sel).toList();
    if (ledgerFilter.value == 'cr')
      list = list.where((t) => t.type == 'CR').toList();
    else if (ledgerFilter.value == 'dr')
      list = list.where((t) => t.type == 'DR').toList();
    final q = ledgerSearch.value.toLowerCase().trim();
    if (q.isNotEmpty)
      list = list
          .where(
            (t) =>
                t.party.toLowerCase().contains(q) ||
                t.note.toLowerCase().contains(q) ||
                t.category.toLowerCase().contains(q) ||
                t.id.toLowerCase().contains(q),
          )
          .toList();
    return list;
  }

  List<Expense> get filteredExpenses {
    var list = expenses.toList();
    final sel = _store.selectedStoreName;
    if (sel != null) list = list.where((e) => e.store == sel).toList();
    if (expenseFilter.value != 'all')
      list = list
          .where(
            (e) =>
                e.category.toLowerCase() == expenseFilter.value.toLowerCase(),
          )
          .toList();
    return list;
  }

  List<Supplier> get allSuppliers => suppliers.toList();

  CashRegisterEntry? get openRegister {
    final sel =
        _store.selectedStoreName ?? _store.stores.firstOrNull?.name ?? '';
    try {
      return cashRegister.firstWhere(
        (cr) => cr.status == 'Open' && cr.store == sel,
      );
    } catch (_) {
      return null;
    }
  }

  int get totalCredit =>
      ledger.where((t) => t.type == 'CR').fold(0, (s, t) => s + t.amountNum);
  int get totalDebit =>
      ledger.where((t) => t.type == 'DR').fold(0, (s, t) => s + t.amountNum);
  int get totalExpense => expenses.fold(0, (s, e) => s + e.amount);
  int get totalReceivable {
    try {
      return Get.find<BillingController>().invoices
          .where((i) => i.status == 'Pending' || i.status == 'Partial')
          .fold(0, (s, i) => s + i.total);
    } catch (_) {
      return 250000;
    }
  }

  int get totalPayable => suppliers
      .where((s) => s.balanceNum < 0)
      .fold(0, (s, sup) => s + sup.balanceNum.abs());

  String fmt(int v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹$v';
  }

  void _seedLedger() {
    ledger.assignAll([
      LedgerEntry(
        id: 'TXN001',
        date: '2026-03-09',
        party: 'Priya Sharma',
        type: 'CR',
        amountNum: 364250,
        amount: '₹3,64,250',
        mode: 'UPI',
        note: 'Bill #BIL001',
        category: 'Sales',
        store: 'Rajmahal Jewellers - Main',
      ),
      LedgerEntry(
        id: 'TXN002',
        date: '2026-03-08',
        party: 'Rahul Mehta',
        type: 'CR',
        amountNum: 145000,
        amount: '₹1,45,000',
        mode: 'Card',
        note: 'Bill #BIL002',
        category: 'Sales',
        store: 'Rajmahal Jewellers - Mall Road',
      ),
      LedgerEntry(
        id: 'TXN004',
        date: '2026-03-06',
        party: 'Staff Salary',
        type: 'DR',
        amountNum: 85000,
        amount: '₹85,000',
        mode: 'Bank Transfer',
        note: 'March Salaries',
        category: 'Salary',
        store: 'Rajmahal Jewellers - Main',
      ),
      LedgerEntry(
        id: 'TXN006',
        date: '2026-03-04',
        party: 'Gold Supplier',
        type: 'DR',
        amountNum: 1250000,
        amount: '₹12,50,000',
        mode: 'Bank Transfer',
        note: 'Gold purchase order',
        category: 'Purchase',
        store: 'Rajmahal Jewellers - Main',
      ),
    ]);
  }

  void _seedExpenses() {
    expenses.assignAll([
      Expense(
        id: 'EXP001',
        date: '2026-03-06',
        category: 'Salary',
        description: 'Staff salaries - March',
        amount: 85000,
        mode: 'Bank Transfer',
        store: 'Rajmahal Jewellers - Main',
      ),
      Expense(
        id: 'EXP002',
        date: '2026-03-05',
        category: 'Rent',
        description: 'March rent payment',
        amount: 45000,
        mode: 'Cheque',
        store: 'Rajmahal Jewellers - Main',
      ),
      Expense(
        id: 'EXP003',
        date: '2026-03-04',
        category: 'Utilities',
        description: 'Electricity bill',
        amount: 12500,
        mode: 'Online',
        store: 'Rajmahal Jewellers - Main',
      ),
    ]);
  }

  void _seedSuppliers() {
    suppliers.assignAll([
      Supplier(
        id: 'SUP001',
        name: 'Gold Supplier Pvt Ltd',
        phone: '+91 99887 11223',
        email: 'gold@supplier.com',
        city: 'Mumbai',
        address: 'Zaveri Bazaar, Mumbai',
        gst: '27AABCS1234F1Z5',
        metals: ['Gold'],
        status: 'Active',
        store: 'Rajmahal Jewellers - Main',
        totalBusinessNum: 8500000,
        balanceNum: -1250000,
      ),
      Supplier(
        id: 'SUP002',
        name: 'Diamond World Ltd',
        phone: '+91 88776 22334',
        email: 'info@diamondworld.com',
        city: 'Surat',
        address: 'Diamond Bourse, Surat',
        gst: '24AABCD5678G1Z3',
        metals: ['Diamond'],
        status: 'Active',
        store: 'Rajmahal Jewellers - Main',
        totalBusinessNum: 4200000,
        balanceNum: 0,
      ),
    ]);
  }

  void _seedCashRegister() {
    cashRegister.assignAll([
      CashRegisterEntry(
        id: 'CR001',
        date: '2026-03-12',
        openingBalance: 50000,
        cashIn: 45000,
        cashOut: 16500,
        closingBalance: 78500,
        store: 'Rajmahal Jewellers - Main',
        closedBy: 'Arjun Kapoor',
        status: 'Closed',
      ),
      CashRegisterEntry(
        id: 'CR002',
        date: '2026-03-12',
        openingBalance: 35000,
        cashIn: 28000,
        cashOut: 12000,
        closingBalance: 0,
        store: 'Rajmahal Jewellers - Mall Road',
        closedBy: '',
        status: 'Open',
      ),
    ]);
  }
}
