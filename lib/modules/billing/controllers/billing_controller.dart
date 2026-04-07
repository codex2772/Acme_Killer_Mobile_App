import 'package:acme_killer_mobile_app/services/settings_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../../../models/billing/billing_item_model.dart';
import '../../../models/billing/invoice_model.dart';
import '../../../models/billing/payment_split_model.dart';
import '../../../models/inventory_model.dart';
import '../../inventory/controllers/inventory_controller.dart';
import '../../rates_schemes/controllers/rates_schemes_controller.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/store_controller.dart';
import '../../../services/auth_service.dart';
import '../../../services/billing_service.dart';
import '../../../services/accounts_service.dart';
import '../../../services/api_client.dart';

// ════════════════════════════════════════════════════════════════════
// SplitPaymentEntry — one row in the split payments array
// mirrors Electron: splitPayments = [{mode:'Cash',amount:50000},{mode:'UPI',amount:30000}]
// ════════════════════════════════════════════════════════════════════
class SplitPaymentEntry {
  String mode;
  int amount;
  SplitPaymentEntry({this.mode = 'Cash', this.amount = 0});
}

// ════════════════════════════════════════════════════════════════════
// BillingController
// mirrors Electron billing.js
//
// Key patterns from Electron:
//  • fetchAllStores for invoices/estimates/creditNotes
//  • On create invoice: also POST /api/ledger (DR+CR entries)
//  • On create invoice: PUT /api/jewelry-items/:id to decrement qty
//  • On credit note: re-stock inventory via PUT /api/jewelry-items/:id
//  • Convert estimate: POST /api/estimates/:id/convert
//  • Record payment: POST /api/invoices/:id/payments
//  • Store picker: when owner is in "All Stores" mode, user must
//    pick a store for each billing transaction
// ════════════════════════════════════════════════════════════════════
class BillingController extends GetxController {
  final InventoryController _inventory = Get.find<InventoryController>();
  final StoreController _store = Get.find<StoreController>();

  final RxList<Invoice> allBills = <Invoice>[].obs;
  final RxBool isLoading = false.obs;

  DateTime? _lastFetched;
  static const _staleDuration = Duration(seconds: 60);
  bool get isStale =>
      _lastFetched == null ||
      DateTime.now().difference(_lastFetched!) > _staleDuration;

  // ── Invoice builder state ──
  final RxList<BillingItem> items = <BillingItem>[].obs;
  final RxString customer = ''.obs;
  final RxString customerId = ''.obs;
  final RxString paymentMode = 'Cash'.obs;
  final RxInt discount = 0.obs;
  final RxInt oldGoldValue = 0.obs;
  final RxInt gstRate = 3.obs;
  final RxString selectedInvoiceId = ''.obs;

  // ── Multi-mode split payments — mirrors Electron splitPayments[] ──
  // Default: one Cash row (user can add more modes)
  final RxList<SplitPaymentEntry> splitPayments = <SplitPaymentEntry>[
    SplitPaymentEntry(mode: 'Cash', amount: 0),
  ].obs;

  // ── Store picker state — mirrors Electron billing.js ──
  // When owner is in "All Stores" mode (selectedStore == null),
  // the user must pick a store for each billing transaction.
  // billingStoreId/Name hold the per-transaction selection.
  final Rx<StoreInfo?> billingStore = Rx<StoreInfo?>(null);

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;

  // ── Store picker helpers — mirrors Electron isAllStoresMode() ──
  // Returns true when owner has multiple stores and no specific store selected
  bool get isAllStoresMode {
    final auth = Get.find<AuthController>();
    return auth.isOwner &&
        auth.stores.length > 1 &&
        _store.selectedStore.value == null;
  }

  /// The list of stores available for the picker
  List<StoreInfo> get availableStores => _store.stores;

  /// The effective store name for this billing transaction.
  /// If a specific store is selected globally → use that.
  /// If "All Stores" mode + user picked via billing picker → use that.
  /// Mirrors Electron: billingStoreName || state.selectedStore || state.stores[0]
  String get effectiveStoreName {
    if (!isAllStoresMode) {
      return _store.selectedStoreName ?? 'Main';
    }
    return billingStore.value?.name ?? '';
  }

  /// The effective store ID for this billing transaction.
  int? get effectiveStoreId {
    if (!isAllStoresMode) {
      return _store.selectedStore.value?.id;
    }
    return billingStore.value?.id;
  }

  /// Select a store for the current billing transaction (All Stores mode).
  /// Mirrors Electron: switchStoreForBilling(storeId)
  /// Also sets the X-Store-Id header so the API call goes to the right store.
  Future<void> selectBillingStore(StoreInfo? store) async {
    billingStore.value = store;
    if (store != null) {
      try {
        final ctx = Get.find<StoreContextService>();
        await ctx.switchStore(store.id);
      } catch (_) {}
    }
  }

  /// Restore original store context after billing transaction
  /// Mirrors Electron: if (isAllStoresMode() && state.selectedStoreId) {
  ///   await switchStoreForBilling(state.selectedStoreId); }
  Future<void> restoreStoreContext() async {
    if (isAllStoresMode) {
      try {
        final ctx = Get.find<StoreContextService>();
        ctx.clearStore();
      } catch (_) {}
    }
  }

  /// Validate store selection — returns error message or null if valid
  String? validateStoreSelection() {
    if (isAllStoresMode && billingStore.value == null) {
      return 'Please select a store for this transaction';
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _seedDemoData();
    _fetchFromApi();
    // Refresh when user switches store
    ever(_store.selectedStore, (_) {
      _lastFetched = null;
      _fetchFromApi();
    });
  }

  // ════════════════════════════════════════════════════════════════
  // API LOAD — mirrors Electron renderBilling()
  // fetchAllStores: invoices + estimates + creditNotes in parallel
  // ════════════════════════════════════════════════════════════════
  Future<void> _fetchFromApi() async {
    if (isLoading.value) return; // guard against concurrent fetches
    isLoading.value = true;
    try {
      final billing = Get.find<BillingService>();
      final estimates = Get.find<EstimatesService>();
      final creditNotes = Get.find<CreditNotesService>();
      final storeCtx = Get.find<StoreContextService>();
      final stores = _store.stores;

      final List<Map<String, dynamic>> rawInv = [];
      final List<Map<String, dynamic>> rawEst = [];
      final List<Map<String, dynamic>> rawCn = [];

      if (stores.length > 1 && _store.selectedStore.value == null) {
        // ── Parallel multi-store fetch (mirrors Electron Promise.all per store) ──
        await Future.wait(
          stores.map((s) async {
            storeCtx.switchStore(s.id);
            final results = await Future.wait([
              billing.listInvoices(),
              estimates.list(),
              creditNotes.list(),
            ]);
            _tagStore(results[0], s.name, rawInv);
            _tagStore(results[1], s.name, rawEst);
            _tagStore(results[2], s.name, rawCn);
          }),
        );
        storeCtx.clearStore();
      } else {
        // ── Single store — fetch all 3 in parallel ──
        final results = await Future.wait([
          billing.listInvoices(),
          estimates.list(),
          creditNotes.list(),
        ]);
        final storeName = _store.selectedStoreName ?? '';
        _tagStore(results[0], storeName, rawInv);
        _tagStore(results[1], storeName, rawEst);
        _tagStore(results[2], storeName, rawCn);
      }

      final fetched = <Invoice>[];
      for (final r in rawInv) fetched.add(_mapInvoice(r, BillingType.invoice));
      for (final r in rawEst) fetched.add(_mapInvoice(r, BillingType.estimate));
      for (final r in rawCn)
        fetched.add(_mapInvoice(r, BillingType.creditNote));

      if (fetched.isNotEmpty) {
        allBills.assignAll(fetched);
        _lastFetched = DateTime.now();
      }
    } catch (e) {
      debugPrint('[BillingController] _fetchFromApi failed: $e');
    }
    isLoading.value = false;
  }

  void _tagStore(
    dynamic result,
    String storeName,
    List<Map<String, dynamic>> out,
  ) {
    if (result != null && result.success == true && result.data is List) {
      for (final item in (result.data as List)) {
        final m = Map<String, dynamic>.from(item as Map);
        m['_storeName'] = storeName;
        out.add(m);
      }
    }
  }

  // mirrors Electron mapBackendInvoice()
  Invoice _mapInvoice(Map<String, dynamic> m, BillingType type) {
    const psMap = {
      'PAID': 'Paid',
      'PARTIAL': 'Partial',
      'PENDING': 'Pending',
      'CANCELLED': 'Cancelled',
      'DRAFT': 'Draft',
      'PROCESSED': 'Processed',
      'CONVERTED': 'Converted',
    };
    final status =
        psMap[m['paymentStatus']?.toString()] ??
        psMap[m['status']?.toString()] ??
        'Pending';
    final total = (m['total'] ?? m['totalAmount'] ?? 0) as num;
    final paid = (m['paidAmount'] ?? 0) as num;
    DateTime date;
    try {
      date = DateTime.parse(
        m['date']?.toString() ?? m['createdAt']?.toString() ?? '',
      );
    } catch (_) {
      date = DateTime.now();
    }

    return Invoice(
      id: m['invoiceNumber']?.toString() ?? m['id']?.toString() ?? '',
      backendId: m['id'],
      customer:
          m['customer']?.toString() ?? m['customerName']?.toString() ?? '',
      customerId: m['customerId']?.toString() ?? '',
      date: date,
      paymentMode: m['paymentMode']?.toString() ?? '—',
      status: status,
      store: m['_storeName']?.toString() ?? '',
      type: type,
      subtotal: ((m['subtotal'] ?? m['total'] ?? m['totalAmount'] ?? 0) as num)
          .toInt(),
      gst: ((m['gstAmount'] ?? m['gst'] ?? 0) as num).toInt(),
      discount: ((m['discount'] ?? 0) as num).toInt(),
      roundOff: ((m['roundOff'] ?? 0) as num).toInt(),
      total: total.toInt(),
      paidAmount: paid.toInt(),
      dueDate: m['dueDate']?.toString(),
      notes: m['notes']?.toString() ?? '',
      items: [],
    );
  }

  Future<void> refresh() => _fetchFromApi();

  Future<void> refreshIfStale() async {
    if (isStale && !isLoading.value) await _fetchFromApi();
  }

  // ════════════════════════════════════════════════════════════════
  // CREATE INVOICE — mirrors Electron createInvoice submit
  // POST /api/invoices
  // → POST /api/ledger (DR entry for invoice, CR for payment)
  // → PUT /api/jewelry-items/:id (decrement qty)
  // ════════════════════════════════════════════════════════════════
  Future<bool> createInvoiceViaApi({
    required dynamic customerId,
    required String customerName,
    required int total,
    required int gstAmount,
    required int discountAmount,
    required String paymentMode,
    required String paymentStatus,
    required List<Map<String, dynamic>> lineItems,
    String? dueDate,
    String? notes,
  }) async {
    try {
      final billing = Get.find<BillingService>();
      final ledger = Get.find<LedgerService>();

      final payload = {
        // Backend expects Long — parse from string if needed
        'customerId': int.tryParse(customerId.toString()) ?? customerId,
        'customerName': customerName,
        'paymentMode': paymentMode,
        'paymentStatus': paymentStatus,
        'total': total,
        'gstAmount': gstAmount,
        'discount': discountAmount,
        'dueDate': dueDate,
        'notes': notes ?? '',
        'items': lineItems,
      };

      final result = await billing.createInvoice(payload);
      if (!result.success) return false;

      final backendId = (result.data as Map?)?['id'];

      // ── Auto-create ledger entries (mirrors Electron billing.js) ──
      if (backendId != null) {
        // DR entry (charge to customer)
        await ledger.create({
          'type': 'DR',
          'party': customerName,
          'amount': total,
          'mode': paymentMode,
          'category': 'Sales',
          'description': 'Invoice #$backendId',
        });
        // CR entry if paid now
        if (paymentStatus == 'PAID') {
          await ledger.create({
            'type': 'CR',
            'party': customerName,
            'amount': total,
            'mode': paymentMode,
            'category': 'Sales',
            'description': 'Payment for Invoice #$backendId',
          });
        }
      }

      // ── Decrement inventory qty for each item (mirrors Electron billing.js) ──
      for (final item in lineItems) {
        final bid = item['backendId'];
        if (bid != null) {
          try {
            final invCtrl = Get.find<InventoryController>();
            await invCtrl.updateItemViaApi(
              backendId: bid,
              changes: {'status': 'SOLD', 'quantity': 0},
            );
          } catch (e) {
            debugPrint('[BillingController] Inventory decrement failed: $e');
          }
        }
      }

      _fetchFromApi();
      return true;
    } catch (e) {
      debugPrint('[BillingController] API call failed: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // CREATE ESTIMATE — mirrors Electron createEstimate submit
  // ════════════════════════════════════════════════════════════════
  Future<bool> createEstimateViaApi(Map<String, dynamic> payload) async {
    try {
      final r = await Get.find<EstimatesService>().create(payload);
      if (r.success) _fetchFromApi();
      return r.success;
    } catch (e) {
      debugPrint('[BillingController] API call failed: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // CREATE CREDIT NOTE — mirrors Electron createCreditNote submit
  // POST /api/credit-notes
  // → re-stock inventory if items specified
  // ════════════════════════════════════════════════════════════════
  Future<bool> createCreditNoteViaApi({
    required Map<String, dynamic> payload,
    List<Map<String, dynamic>> restockItems = const [],
  }) async {
    try {
      final r = await Get.find<CreditNotesService>().create(payload);
      if (!r.success) return false;

      // Re-stock inventory (mirrors Electron credit note handler)
      for (final item in restockItems) {
        final bid = item['backendId'];
        if (bid != null) {
          try {
            final invCtrl = Get.find<InventoryController>();
            await invCtrl.restockItem(bid, (item['quantity'] as int?) ?? 1);
          } catch (e) {
            debugPrint('[BillingController] Inventory decrement failed: $e');
          }
        }
      }

      _fetchFromApi();
      return true;
    } catch (e) {
      debugPrint('[BillingController] API call failed: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // RECORD PAYMENT — mirrors Electron: invoices:record-payment
  // POST /api/invoices/:id/payments
  // ════════════════════════════════════════════════════════════════
  Future<bool> recordPaymentViaApi(
    dynamic backendId,
    int amount,
    String mode,
  ) async {
    try {
      final r = await Get.find<BillingService>().recordPayment(backendId, {
        'amount': amount,
        'mode': mode,
      });
      if (r.success) _fetchFromApi();
      return r.success;
    } catch (e) {
      debugPrint('[BillingController] API call failed: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // CONVERT ESTIMATE → INVOICE
  // ════════════════════════════════════════════════════════════════
  Future<bool> convertEstimateViaApi(dynamic backendId) async {
    try {
      final r = await Get.find<EstimatesService>().convert(backendId);
      if (r.success) _fetchFromApi();
      return r.success;
    } catch (e) {
      debugPrint('[BillingController] API call failed: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // CANCEL INVOICE
  // ════════════════════════════════════════════════════════════════
  Future<bool> cancelInvoiceViaApi(dynamic backendId) async {
    try {
      final r = await Get.find<BillingService>().updateStatus(backendId, {
        'status': 'CANCELLED',
      });
      if (r.success) _fetchFromApi();
      return r.success;
    } catch (e) {
      debugPrint('[BillingController] API call failed: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // FILTERED LISTS (unchanged logic, matches Electron)
  // ════════════════════════════════════════════════════════════════
  List<Invoice> get invoices => _filterStore(
    allBills.where((b) => b.type == BillingType.invoice).toList(),
  );
  List<Invoice> get estimates => _filterStore(
    allBills.where((b) => b.type == BillingType.estimate).toList(),
  );
  List<Invoice> get creditNotes => _filterStore(
    allBills.where((b) => b.type == BillingType.creditNote).toList(),
  );

  List<Invoice> get filteredInvoices {
    var list = invoices;
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list
          .where(
            (i) =>
                i.id.toLowerCase().contains(q) ||
                i.customer.toLowerCase().contains(q),
          )
          .toList();
    }
    final f = statusFilter.value;
    if (f != 'all')
      list = list.where((i) => i.status.toLowerCase() == f).toList();
    return list;
  }

  List<Invoice> _filterStore(List<Invoice> list) {
    final sel = _store.selectedStoreName;
    if (sel == null) return list;
    return list.where((b) => b.store == sel).toList();
  }

  Invoice? getById(String id) {
    try {
      return allBills.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Stats ──
  int get paidCount => invoices.where((i) => i.status == 'Paid').length;
  int get pendingCount => invoices
      .where((i) => i.status == 'Pending' || i.status == 'Partial')
      .length;
  int get totalRevenue =>
      invoices.where((i) => i.status == 'Paid').fold(0, (s, i) => s + i.total);

  String formatCurrency(int v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹$v';
  }

  // ── Invoice builder ──
  int get subtotal => items.fold(0, (s, i) => s + i.total);
  int get gstAmount => (subtotal * gstRate.value / 100).round();
  int get grandTotal =>
      subtotal + gstAmount - discount.value - oldGoldValue.value;

  void addItem() => items.add(BillingItem());
  void removeItem(int index) {
    items.removeAt(index);
    items.refresh();
  }

  void recalculate() => items.refresh();
  void setDiscount(String v) => discount.value = int.tryParse(v) ?? 0;
  void setOldGold(String v) => oldGoldValue.value = int.tryParse(v) ?? 0;

  // ── Split payment management (mirrors Electron splitPayments[]) ──
  void addSplitPayment() {
    splitPayments.add(SplitPaymentEntry(mode: 'Cash', amount: 0));
  }

  void removeSplitPayment(int index) {
    if (splitPayments.length > 1) {
      splitPayments.removeAt(index);
    }
  }

  void updateSplitPayment(int index, {String? mode, int? amount}) {
    if (index >= splitPayments.length) return;
    final entry = splitPayments[index];
    if (mode != null) entry.mode = mode;
    if (amount != null) entry.amount = amount;
    splitPayments.refresh();
  }

  /// Total paid across all split modes
  int get totalSplitPaid => splitPayments.fold<int>(0, (s, p) => s + p.amount);

  /// Primary mode label for display (first split's mode)
  String get primaryPaymentMode =>
      splitPayments.isNotEmpty ? splitPayments[0].mode : 'Cash';

  List<InventoryItem> get availableItems => _inventory.inventory
      .where((i) => i.status == 'In Stock' || i.status == 'Low Stock')
      .toList();

  void clearBuilder() {
    items.clear();
    customer.value = '';
    customerId.value = '';
    paymentMode.value = 'Cash';
    discount.value = 0;
    oldGoldValue.value = 0;
    splitPayments.assignAll([SplitPaymentEntry(mode: 'Cash', amount: 0)]);
    billingStore.value = null;
  }

  // Pre-select an inventory item when navigating from inventory detail
  // ── Shared rate/making helpers (same logic as InvoiceItemRow) ──
  // mirrors Electron: state.goldRate[item.purity] || sellingPrice/weight
  double _liveRateForItem(InventoryItem inv) {
    try {
      final rates = Get.find<RatesSchemesController>();
      int r = 0;
      if (inv.metal == 'Gold' ||
          inv.metal == 'Rose Gold' ||
          inv.metal == 'White Gold') {
        switch (inv.purity) {
          case '24K':
            r = rates.metals[0].rate.value;
            break;
          case '22K':
            r = rates.metals[1].rate.value;
            break;
          case '18K':
            r = rates.metals[2].rate.value;
            break;
          case '14K':
            r = rates.metals[3].rate.value;
            break;
          default:
            r = rates.metals[1].rate.value;
        }
      } else if (inv.metal == 'Silver') {
        r = rates.metals[4].rate.value;
      } else if (inv.metal == 'Platinum') {
        r = rates.metals[5].rate.value;
      }
      if (r > 0) return r.toDouble();
    } catch (_) {}
    return inv.netWeight > 0 ? inv.sellingPrice / inv.netWeight : 0.0;
  }

  // Inventory makingCharge = flat ₹, BillingItem.making = %
  // makingPct = (flatMaking / metalValue) * 100
  double _flatMakingToPct(double flatMaking, double weight, double rate) {
    final metalValue = weight * rate;
    if (metalValue <= 0 || flatMaking <= 0) return 0.0;
    return double.parse(((flatMaking / metalValue) * 100).toStringAsFixed(2));
  }

  // Pre-select an inventory item when navigating from inventory detail
  void preSelectItem(InventoryItem invItem) {
    final rate = _liveRateForItem(invItem);
    final weight = double.parse(invItem.netWeight.toStringAsFixed(3));
    // makingCharge from inventory is flat ₹ — convert to % for BillingItem
    final makingPct = _flatMakingToPct(invItem.makingCharge, weight, rate);

    final item = BillingItem(
      name: invItem.name,
      inventoryId: invItem.id,
      backendId: invItem.backendId,
      weight: weight,
      rate: rate,
      making: makingPct,
      purity: invItem.purity,
    );
    items.add(item);
  }

  // ── Local save (fallback when offline) ──
  Invoice saveInvoice({String? dueDateStr, String? sig, String? notes}) {
    final newId =
        'BIL${(allBills.where((b) => b.type == BillingType.invoice).length + 5).toString().padLeft(3, '0')}';
    final isPaid = paymentMode.value != 'Split Payment' && dueDateStr == null;
    final inv = Invoice(
      id: newId,
      customer: customer.value,
      customerId: customerId.value,
      date: DateTime.now(),
      paymentMode: paymentMode.value,
      status: isPaid ? 'Paid' : (dueDateStr != null ? 'Pending' : 'Paid'),
      store: _store.selectedStoreName ?? 'Main',
      type: BillingType.invoice,
      subtotal: subtotal,
      gst: gstAmount,
      discount: discount.value,
      roundOff: 0,
      total: grandTotal,
      oldGoldAdjustment: oldGoldValue.value,
      items: List.from(items),
      dueDate: dueDateStr,
      digitalSignature: sig,
      notes: notes ?? '',
    );
    allBills.add(inv);
    for (final item in items) {
      if (item.inventoryId.isNotEmpty) _inventory.sellItem(item.inventoryId);
    }
    clearBuilder();
    return inv;
  }

  Invoice saveEstimate({String? validUntil, String? notes}) {
    final newId =
        'EST${(allBills.where((b) => b.type == BillingType.estimate).length + 2).toString().padLeft(3, '0')}';
    final est = Invoice(
      id: newId,
      customer: customer.value,
      customerId: customerId.value,
      date: DateTime.now(),
      paymentMode: '—',
      status: 'Draft',
      store: _store.selectedStoreName ?? 'Main',
      type: BillingType.estimate,
      subtotal: subtotal,
      gst: gstAmount,
      discount: discount.value,
      roundOff: 0,
      total: grandTotal,
      items: List.from(items),
      notes: notes ?? '',
      dueDate: validUntil,
    );
    allBills.add(est);
    clearBuilder();
    return est;
  }

  Invoice saveCreditNote({
    required String invoiceId,
    required String itemDesc,
    required int refundAmount,
    required String reason,
    required String refundMode,
    String notes = '',
  }) {
    final newId =
        'CN${(allBills.where((b) => b.type == BillingType.creditNote).length + 2).toString().padLeft(3, '0')}';
    final orig = getById(invoiceId);
    final gst = (refundAmount * 0.03).round();
    final cn = Invoice(
      id: newId,
      customer: orig?.customer ?? 'Customer',
      customerId: orig?.customerId ?? '',
      date: DateTime.now(),
      paymentMode: refundMode,
      status: 'Processed',
      store: _store.selectedStoreName ?? 'Main',
      type: BillingType.creditNote,
      subtotal: refundAmount - gst,
      gst: gst,
      discount: 0,
      roundOff: 0,
      total: refundAmount,
      items: [BillingItem(name: itemDesc, weight: 0, rate: 0)],
      notes: '$reason. $notes',
    );
    allBills.add(cn);
    return cn;
  }

  void recordPayment(String invoiceId, int amount, String mode) {
    final idx = allBills.indexWhere((b) => b.id == invoiceId);
    if (idx == -1) return;
    final inv = allBills[idx];
    final newPaid = inv.paidAmount + amount;
    allBills[idx] = inv.copyWith(
      paidAmount: newPaid,
      status: newPaid >= inv.total ? 'Paid' : 'Partial',
      payments: [
        ...inv.payments,
        PaymentSplit(mode: mode, amount: amount),
      ],
    );
    allBills.refresh();
  }

  Invoice convertEstimate(String estimateId) {
    final est = getById(estimateId);
    if (est == null) throw Exception('Estimate not found');
    final newId =
        'BIL${(allBills.where((b) => b.type == BillingType.invoice).length + 5).toString().padLeft(3, '0')}';
    final inv = Invoice(
      id: newId,
      customer: est.customer,
      customerId: est.customerId,
      date: DateTime.now(),
      paymentMode: 'Cash',
      status: 'Pending',
      store: est.store,
      type: BillingType.invoice,
      subtotal: est.subtotal,
      gst: est.gst,
      discount: est.discount,
      roundOff: est.roundOff,
      total: est.total,
      items: List.from(est.items),
      notes: 'Converted from Estimate #${est.id}. ${est.notes}',
    );
    final estIdx = allBills.indexWhere((b) => b.id == estimateId);
    if (estIdx != -1)
      allBills[estIdx] = allBills[estIdx].copyWith(status: 'Converted');
    allBills.add(inv);
    allBills.refresh();
    return inv;
  }

  void cancelInvoice(String id) {
    final idx = allBills.indexWhere((b) => b.id == id);
    if (idx != -1) {
      allBills[idx] = allBills[idx].copyWith(status: 'Cancelled');
      allBills.refresh();
    }
  }

  // ── Demo seed ──
  void _seedDemoData() {
    allBills.assignAll([
      Invoice(
        id: 'BIL001',
        customer: 'Priya Sharma',
        customerId: 'CUS001',
        date: DateTime(2026, 3, 9),
        paymentMode: 'UPI',
        status: 'Paid',
        store: 'Rajmahal Jewellers - Main',
        subtotal: 353324,
        gst: 10928,
        discount: 0,
        roundOff: -2,
        total: 364250,
        type: BillingType.invoice,
        items: [
          BillingItem(
            name: '22K Gold Necklace',
            weight: 45.5,
            rate: 6285,
            making: 12,
          ),
        ],
        digitalSignature: 'Arjun Kapoor',
      ),
      Invoice(
        id: 'BIL002',
        customer: 'Rahul Mehta',
        customerId: 'CUS002',
        date: DateTime(2026, 3, 8),
        paymentMode: 'Card',
        status: 'Paid',
        store: 'Rajmahal Jewellers - Mall Road',
        subtotal: 140650,
        gst: 4350,
        discount: 0,
        roundOff: 0,
        total: 145000,
        type: BillingType.invoice,
        items: [
          BillingItem(
            name: 'Platinum Wedding Band',
            weight: 6.0,
            rate: 18500,
            making: 18,
          ),
        ],
      ),
      Invoice(
        id: 'BIL003',
        customer: 'Anita Desai',
        customerId: 'CUS003',
        date: DateTime(2026, 3, 7),
        paymentMode: 'Cash + UPI',
        status: 'Partial',
        store: 'Rajmahal Jewellers - Main',
        subtotal: 580545,
        gst: 17955,
        discount: 0,
        roundOff: 0,
        total: 598500,
        paidAmount: 400000,
        type: BillingType.invoice,
        dueDate: '2026-04-07',
        notes: 'Remaining ₹1,98,500 due April 7',
        items: [
          BillingItem(
            name: 'Kundan Bridal Set',
            weight: 85,
            rate: 5140,
            making: 16,
          ),
        ],
      ),
      Invoice(
        id: 'BIL004',
        customer: 'Vikram Singh',
        customerId: 'CUS004',
        date: DateTime(2026, 3, 5),
        paymentMode: 'Cash',
        status: 'Pending',
        store: 'Rajmahal Jewellers - City Center',
        subtotal: 50485,
        gst: 1515,
        discount: 0,
        roundOff: 0,
        total: 52000,
        type: BillingType.invoice,
        dueDate: '2026-03-20',
        items: [
          BillingItem(name: 'Silver Chain', weight: 35, rate: 92, making: 10),
        ],
      ),
      Invoice(
        id: 'EST001',
        customer: 'Suresh Kumar',
        customerId: 'CUS005',
        date: DateTime(2026, 3, 6),
        paymentMode: '—',
        status: 'Draft',
        store: 'Rajmahal Jewellers - Mall Road',
        subtotal: 407767,
        gst: 12233,
        discount: 0,
        roundOff: 0,
        total: 420000,
        type: BillingType.estimate,
        items: [
          BillingItem(
            name: 'Diamond Solitaire Ring',
            weight: 3.5,
            rate: 45000,
            making: 20,
          ),
        ],
      ),
      Invoice(
        id: 'CN001',
        customer: 'Kavita Nair',
        customerId: 'CUS006',
        date: DateTime(2026, 3, 3),
        paymentMode: 'Cash Refund',
        status: 'Processed',
        store: 'Rajmahal Jewellers - Main',
        subtotal: 17961,
        gst: 539,
        discount: 0,
        roundOff: 0,
        total: 18500,
        type: BillingType.creditNote,
        notes: 'Design Issue. Customer returned necklace.',
        items: [
          BillingItem(
            name: '18K Gold Chain (Returned)',
            weight: 10,
            rate: 5140,
            making: 13,
          ),
        ],
      ),
    ]);
  }
}
