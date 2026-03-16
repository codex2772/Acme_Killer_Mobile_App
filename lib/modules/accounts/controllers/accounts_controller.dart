import 'package:get/get.dart';
import '../../../core/controllers/store_controller.dart';
import '../../../modules/billing/controllers/billing_controller.dart';

// ─── Models ───

class LedgerEntry {
  final String id;
  final String date;
  final String party;
  final String type; // CR | DR
  final int amountNum;
  final String amount;
  final String mode;
  final String note;
  final String category;
  final String store;
  String balance;
  int balanceNum;

  LedgerEntry({
    required this.id, required this.date, required this.party,
    required this.type, required this.amountNum, required this.amount,
    required this.mode, required this.note, required this.category,
    required this.store, this.balance = '—', this.balanceNum = 0,
  });

  String get formattedAmount {
    final v = amountNum;
    if (v >= 100000) return '₹${(v/100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '₹${(v/1000).toStringAsFixed(0)}K';
    return '₹$v';
  }
}

class Expense {
  final String id;
  String date;
  String category;
  String description;
  int amount;
  String mode;
  final String store;

  Expense({
    required this.id, required this.date, required this.category,
    required this.description, required this.amount, required this.mode,
    required this.store,
  });

  String get formattedAmount {
    if (amount >= 100000) return '₹${(amount/100000).toStringAsFixed(1)}L';
    if (amount >= 1000)   return '₹${(amount/1000).toStringAsFixed(0)}K';
    return '₹$amount';
  }
}

class Supplier {
  final String id;
  String name;
  String phone;
  String email;
  String city;
  String address;
  String gst;
  List<String> metals;
  String status;
  final String store;
  int totalBusinessNum;
  int balanceNum;

  Supplier({
    required this.id, required this.name, required this.phone,
    required this.email, required this.city, required this.address,
    required this.gst, required this.metals, required this.status,
    required this.store, required this.totalBusinessNum, required this.balanceNum,
  });

  String get totalBusinessFormatted {
    if (totalBusinessNum >= 10000000) return '₹${(totalBusinessNum/10000000).toStringAsFixed(1)}Cr';
    if (totalBusinessNum >= 100000)   return '₹${(totalBusinessNum/100000).toStringAsFixed(1)}L';
    return '₹$totalBusinessNum';
  }

  String get balanceFormatted {
    final v = balanceNum.abs();
    final prefix = balanceNum < 0 ? '-₹' : '₹';
    if (v >= 100000) return '$prefix${(v/100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '$prefix${(v/1000).toStringAsFixed(0)}K';
    return '$prefix$v';
  }
}

class CashRegisterEntry {
  final String id;
  final String date;
  int openingBalance;
  int cashIn;
  int cashOut;
  int closingBalance;
  final String store;
  String closedBy;
  String status; // Open | Closed

  CashRegisterEntry({
    required this.id, required this.date, required this.openingBalance,
    required this.cashIn, required this.cashOut, required this.closingBalance,
    required this.store, required this.closedBy, required this.status,
  });

  int get expectedClosing => openingBalance + cashIn - cashOut;

  String fmt(int v) {
    if (v >= 100000) return '₹${(v/100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '₹${(v/1000).toStringAsFixed(0)}K';
    return '₹$v';
  }
}

// ─── Controller ───

const List<String> kExpenseCategories = [
  'Salary', 'Rent', 'Utilities', 'Insurance', 'Maintenance',
  'Marketing', 'Repairs', 'Travel', 'Office Supplies', 'Miscellaneous',
];

class AccountsController extends GetxController {
  final StoreController _store = Get.find<StoreController>();

  final RxList<LedgerEntry>       ledger       = <LedgerEntry>[].obs;
  final RxList<Expense>           expenses     = <Expense>[].obs;
  final RxList<Supplier>          suppliers    = <Supplier>[].obs;
  final RxList<CashRegisterEntry> cashRegister = <CashRegisterEntry>[].obs;

  final RxString ledgerSearch  = ''.obs;
  final RxString ledgerFilter  = 'all'.obs; // all | cr | dr
  final RxString ledgerDate    = 'month'.obs;
  final RxString expenseFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _seedLedger();
    _seedExpenses();
    _seedSuppliers();
    _seedCashRegister();
  }

  // ── Demo data matching state.js ──
  void _seedLedger() {
    ledger.assignAll([
      LedgerEntry(id:'TXN001', date:'2026-03-09', party:'Priya Sharma', type:'CR', amountNum:364250, amount:'₹3,64,250', mode:'UPI', note:'Bill #BIL001', category:'Sales', store:'Rajmahal Jewellers - Main'),
      LedgerEntry(id:'TXN002', date:'2026-03-08', party:'Rahul Mehta', type:'CR', amountNum:145000, amount:'₹1,45,000', mode:'Card', note:'Bill #BIL002', category:'Sales', store:'Rajmahal Jewellers - Mall Road'),
      LedgerEntry(id:'TXN003', date:'2026-03-07', party:'Anita Desai', type:'CR', amountNum:400000, amount:'₹4,00,000', mode:'Cash + UPI', note:'Partial — Bill #BIL003', category:'Sales', store:'Rajmahal Jewellers - Main'),
      LedgerEntry(id:'TXN004', date:'2026-03-06', party:'Staff Salary', type:'DR', amountNum:85000, amount:'₹85,000', mode:'Bank Transfer', note:'March Salaries', category:'Salary', store:'Rajmahal Jewellers - Main'),
      LedgerEntry(id:'TXN005', date:'2026-03-05', party:'Store Rent', type:'DR', amountNum:45000, amount:'₹45,000', mode:'Cheque', note:'March rent', category:'Rent', store:'Rajmahal Jewellers - Main'),
      LedgerEntry(id:'TXN006', date:'2026-03-04', party:'Gold Supplier Pvt Ltd', type:'DR', amountNum:1250000, amount:'₹12,50,000', mode:'Bank Transfer', note:'Gold purchase order', category:'Purchase', store:'Rajmahal Jewellers - Main'),
      LedgerEntry(id:'TXN007', date:'2026-03-03', party:'Electricity Board', type:'DR', amountNum:12500, amount:'₹12,500', mode:'Online', note:'Electricity bill Feb–Mar', category:'Utilities', store:'Rajmahal Jewellers - Main'),
      LedgerEntry(id:'TXN008', date:'2026-03-01', party:'Meera Patel', type:'CR', amountNum:50000, amount:'₹50,000', mode:'UPI', note:'Advance — custom order', category:'Sales', store:'Rajmahal Jewellers - Main'),
    ]);
  }

  void _seedExpenses() {
    expenses.assignAll([
      Expense(id:'EXP001', date:'2026-03-06', category:'Salary',          description:'Staff salaries - March',       amount:85000,  mode:'Bank Transfer', store:'Rajmahal Jewellers - Main'),
      Expense(id:'EXP002', date:'2026-03-05', category:'Rent',            description:'March rent payment',           amount:45000,  mode:'Cheque',        store:'Rajmahal Jewellers - Main'),
      Expense(id:'EXP003', date:'2026-03-04', category:'Utilities',       description:'Electricity bill Feb-Mar',     amount:12500,  mode:'Online',        store:'Rajmahal Jewellers - Main'),
      Expense(id:'EXP004', date:'2026-03-02', category:'Marketing',       description:'Social media & Google Ads',    amount:18000,  mode:'Online',        store:'Rajmahal Jewellers - Main'),
      Expense(id:'EXP005', date:'2026-02-28', category:'Maintenance',     description:'Display case repair',          amount:8500,   mode:'Cash',          store:'Rajmahal Jewellers - Main'),
      Expense(id:'EXP006', date:'2026-02-25', category:'Office Supplies', description:'Stationery & packaging',       amount:3200,   mode:'Cash',          store:'Rajmahal Jewellers - Mall Road'),
    ]);
  }

  void _seedSuppliers() {
    suppliers.assignAll([
      Supplier(id:'SUP001', name:'Gold Supplier Pvt Ltd', phone:'+91 99887 11223', email:'gold@supplier.com', city:'Mumbai', address:'Zaveri Bazaar, Mumbai', gst:'27AABCS1234F1Z5', metals:['Gold'], status:'Active', store:'Rajmahal Jewellers - Main', totalBusinessNum:8500000, balanceNum:-1250000),
      Supplier(id:'SUP002', name:'Diamond World Ltd', phone:'+91 88776 22334', email:'info@diamondworld.com', city:'Surat', address:'Diamond Bourse, Surat', gst:'24AABCD5678G1Z3', metals:['Diamond'], status:'Active', store:'Rajmahal Jewellers - Main', totalBusinessNum:4200000, balanceNum:0),
      Supplier(id:'SUP003', name:'Silver Mart & Co', phone:'+91 77665 33445', email:'silver@mart.com', city:'Jaipur', address:'Johari Bazaar, Jaipur', gst:'08AABCS9012H1Z1', metals:['Silver','Platinum'], status:'Active', store:'Rajmahal Jewellers - Main', totalBusinessNum:1800000, balanceNum:-320000),
    ]);
  }

  void _seedCashRegister() {
    cashRegister.assignAll([
      CashRegisterEntry(id:'CR001', date:'2026-03-12', openingBalance:50000, cashIn:45000, cashOut:16500, closingBalance:78500, store:'Rajmahal Jewellers - Main', closedBy:'Arjun Kapoor', status:'Closed'),
      CashRegisterEntry(id:'CR002', date:'2026-03-12', openingBalance:35000, cashIn:28000, cashOut:12000, closingBalance:0,     store:'Rajmahal Jewellers - Mall Road', closedBy:'', status:'Open'),
      CashRegisterEntry(id:'CR003', date:'2026-03-11', openingBalance:60000, cashIn:52000, cashOut:38000, closingBalance:74000, store:'Rajmahal Jewellers - Main', closedBy:'Arjun Kapoor', status:'Closed'),
      CashRegisterEntry(id:'CR004', date:'2026-03-10', openingBalance:40000, cashIn:31000, cashOut:22500, closingBalance:48500, store:'Rajmahal Jewellers - Main', closedBy:'Sneha Reddy', status:'Closed'),
    ]);
  }

  // ── Filtered lists ──
  List<LedgerEntry> get filteredLedger {
    var list = ledger.toList();
    final sel = _store.selectedStoreName;
    if (sel != null) list = list.where((t) => t.store == sel).toList();

    if (ledgerFilter.value == 'cr') list = list.where((t) => t.type == 'CR').toList();
    else if (ledgerFilter.value == 'dr') list = list.where((t) => t.type == 'DR').toList();

    final q = ledgerSearch.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((t) =>
          t.party.toLowerCase().contains(q) ||
          t.note.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.id.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<Expense> get filteredExpenses {
    var list = expenses.toList();
    final sel = _store.selectedStoreName;
    if (sel != null) list = list.where((e) => e.store == sel).toList();
    final f = expenseFilter.value;
    if (f != 'all') list = list.where((e) => e.category.toLowerCase() == f.toLowerCase()).toList();
    return list;
  }

  List<Supplier> get allSuppliers => suppliers.toList();

  CashRegisterEntry? get openRegister {
    final sel = _store.selectedStoreName ?? _store.stores.firstOrNull?.name ?? '';
    try { return cashRegister.firstWhere((cr) => cr.status == 'Open' && cr.store == sel); }
    catch (_) { return null; }
  }

  // ── Stats (mirrors desktop renderAccounts stats) ──
  int get totalCredit  => ledger.where((t) => t.type == 'CR').fold(0, (s, t) => s + t.amountNum);
  int get totalDebit   => ledger.where((t) => t.type == 'DR').fold(0, (s, t) => s + t.amountNum);
  int get totalExpense => expenses.fold(0, (s, e) => s + e.amount);

  int get totalReceivable {
    try {
      final billing = Get.find<BillingController>();
      return billing.invoices
          .where((i) => i.status == 'Pending' || i.status == 'Partial')
          .fold(0, (s, i) => s + i.total);
    } catch (_) { return 250000; } // fallback demo
  }

  int get totalPayable =>
      suppliers.where((s) => s.balanceNum < 0).fold(0, (s, sup) => s + sup.balanceNum.abs());

  String fmt(int v) {
    if (v >= 10000000) return '₹${(v/10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '₹${(v/100000).toStringAsFixed(1)}L';
    if (v >= 1000)     return '₹${(v/1000).toStringAsFixed(0)}K';
    return '₹$v';
  }

  // ── Add ledger entry ──
  void addEntry({
    required String type, required String date, required String party,
    required int amount, required String mode, required String category, required String note,
  }) {
    final newId = 'TXN${(ledger.length + 1).toString().padLeft(3, '0')}';
    final sel = _store.selectedStoreName ?? 'Rajmahal Jewellers - Main';
    ledger.insert(0, LedgerEntry(
      id: newId, date: date, party: party, type: type,
      amountNum: amount, amount: fmt(amount),
      mode: mode, note: note.isEmpty ? '$category — $party' : note,
      category: category, store: sel,
    ));
    // Also add to expenses if DR + expense category
    if (type == 'DR' && category.isNotEmpty && !['Sales','Purchase'].contains(category)) {
      final expId = 'EXP${(expenses.length + 1).toString().padLeft(3, '0')}';
      expenses.add(Expense(id: expId, date: date, category: category,
          description: note.isEmpty ? party : note, amount: amount, mode: mode, store: sel));
    }
  }

  // ── Add supplier ──
  void addSupplier(Supplier s) => suppliers.add(s);

  void updateSupplier(String id, {String? name, String? phone, String? email, String? city, String? gst}) {
    final idx = suppliers.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    if (name != null) suppliers[idx].name = name;
    if (phone != null) suppliers[idx].phone = phone;
    if (email != null) suppliers[idx].email = email;
    if (city != null) suppliers[idx].city = city;
    if (gst != null) suppliers[idx].gst = gst;
    suppliers.refresh();
  }

  void deleteSupplier(String id) => suppliers.removeWhere((s) => s.id == id);

  // ── Update expense ──
  void updateExpense(String id, {String? category, String? description, int? amount, String? mode}) {
    final idx = expenses.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    if (category != null) expenses[idx].category = category;
    if (description != null) expenses[idx].description = description;
    if (amount != null) expenses[idx].amount = amount;
    if (mode != null) expenses[idx].mode = mode;
    expenses.refresh();
  }

  void deleteExpense(String id) => expenses.removeWhere((e) => e.id == id);

  // ── Cash Register ──
  void openCashRegister(int openingBalance) {
    final sel = _store.selectedStoreName ?? 'Rajmahal Jewellers - Main';
    final newId = 'CR${(cashRegister.length + 1).toString().padLeft(3, '0')}';
    cashRegister.insert(0, CashRegisterEntry(
      id: newId,
      date: DateTime.now().toIso8601String().substring(0, 10),
      openingBalance: openingBalance, cashIn: 0, cashOut: 0, closingBalance: 0,
      store: sel, closedBy: '', status: 'Open',
    ));
  }

  void closeCashRegister(String id, int actualClosing) {
    final idx = cashRegister.indexWhere((cr) => cr.id == id);
    if (idx == -1) return;
    cashRegister[idx].closingBalance = actualClosing;
    cashRegister[idx].closedBy = 'Owner';
    cashRegister[idx].status = 'Closed';
    cashRegister.refresh();
  }
}
