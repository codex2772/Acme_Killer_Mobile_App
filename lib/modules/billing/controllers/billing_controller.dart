import 'package:get/get.dart';
import '../../../models/billing/billing_item_model.dart';
import '../../../models/billing/invoice_model.dart';
import '../../../models/billing/payment_split_model.dart';
import '../../../models/inventory_model.dart';
import '../../inventory/controllers/inventory_controller.dart';
import '../../../core/controllers/store_controller.dart';

class BillingController extends GetxController {
  final InventoryController _inventory = Get.find<InventoryController>();
  final StoreController _store = Get.find<StoreController>();

  // ── All billing records ──
  final RxList<Invoice> allBills = <Invoice>[].obs;

  // ── Active invoice builder state ──
  final RxList<BillingItem> items    = <BillingItem>[].obs;
  final RxString  customer           = ''.obs;
  final RxString  customerId         = ''.obs;
  final RxString  paymentMode        = 'Cash'.obs;
  final RxInt     discount           = 0.obs;
  final RxInt     oldGoldValue       = 0.obs;
  final RxInt     gstRate            = 3.obs;
  final RxString  selectedInvoiceId  = ''.obs;
  final RxBool    isLoading          = false.obs;

  // ── Search / filter ──
  final RxString searchQuery   = ''.obs;
  final RxString statusFilter  = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _seedDemoData();
  }

  // ─── Demo data (mirrors state.js invoices) ───
  void _seedDemoData() {
    allBills.assignAll([
      Invoice(
        id: 'BIL001', customer: 'Priya Sharma', customerId: 'CUS001',
        date: DateTime(2026,3,9), paymentMode: 'UPI', status: 'Paid',
        store: 'Rajmahal Jewellers - Main',
        subtotal: 353324, gst: 10928, discount: 0, roundOff: -2,
        total: 364250, type: BillingType.invoice,
        items: [BillingItem(name:'22K Gold Necklace',weight:45.5,rate:6285,making:12)],
        digitalSignature: 'Arjun Kapoor',
      ),
      Invoice(
        id: 'BIL002', customer: 'Rahul Mehta', customerId: 'CUS002',
        date: DateTime(2026,3,8), paymentMode: 'Card', status: 'Paid',
        store: 'Rajmahal Jewellers - Mall Road',
        subtotal: 140650, gst: 4350, discount: 0, roundOff: 0,
        total: 145000, type: BillingType.invoice,
        items: [BillingItem(name:'Platinum Wedding Band',weight:6.0,rate:18500,making:18)],
      ),
      Invoice(
        id: 'BIL003', customer: 'Anita Desai', customerId: 'CUS003',
        date: DateTime(2026,3,7), paymentMode: 'Cash + UPI', status: 'Partial',
        store: 'Rajmahal Jewellers - Main',
        subtotal: 580545, gst: 17955, discount: 0, roundOff: 0,
        total: 598500, paidAmount: 400000,
        type: BillingType.invoice,
        dueDate: '2026-04-07',
        notes: 'Remaining ₹1,98,500 to be paid by April 7',
        items: [BillingItem(name:'Kundan Bridal Set',weight:85,rate:5140,making:16)],
      ),
      Invoice(
        id: 'BIL004', customer: 'Vikram Singh', customerId: 'CUS004',
        date: DateTime(2026,3,5), paymentMode: 'Cash', status: 'Pending',
        store: 'Rajmahal Jewellers - City Center',
        subtotal: 50485, gst: 1515, discount: 0, roundOff: 0,
        total: 52000, type: BillingType.invoice,
        dueDate: '2026-03-20',
        items: [BillingItem(name:'Silver Chain',weight:35,rate:92,making:10)],
      ),
      Invoice(
        id: 'EST001', customer: 'Suresh Kumar', customerId: 'CUS005',
        date: DateTime(2026,3,6), paymentMode: '—', status: 'Draft',
        store: 'Rajmahal Jewellers - Mall Road',
        subtotal: 407767, gst: 12233, discount: 0, roundOff: 0,
        total: 420000, type: BillingType.estimate,
        items: [BillingItem(name:'Diamond Solitaire Ring',weight:3.5,rate:45000,making:20)],
      ),
      Invoice(
        id: 'CN001', customer: 'Kavita Nair', customerId: 'CUS006',
        date: DateTime(2026,3,3), paymentMode: 'Cash Refund', status: 'Processed',
        store: 'Rajmahal Jewellers - Main',
        subtotal: 17961, gst: 539, discount: 0, roundOff: 0,
        total: 18500, type: BillingType.creditNote,
        notes: 'Design Issue. Customer returned necklace.',
        items: [BillingItem(name:'18K Gold Chain (Returned)',weight:10,rate:5140,making:13)],
      ),
    ]);
  }

  // ─── Filtered lists (mirrors renderBilling tabs in billing.js) ───
  List<Invoice> get invoices => _filterStore(allBills.where((b) => b.type == BillingType.invoice).toList());
  List<Invoice> get estimates => _filterStore(allBills.where((b) => b.type == BillingType.estimate).toList());
  List<Invoice> get creditNotes => _filterStore(allBills.where((b) => b.type == BillingType.creditNote).toList());

  List<Invoice> get filteredInvoices {
    var list = invoices;
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((i) =>
          i.id.toLowerCase().contains(q) ||
          i.customer.toLowerCase().contains(q)).toList();
    }
    final f = statusFilter.value;
    if (f != 'all') {
      list = list.where((i) => i.status.toLowerCase() == f).toList();
    }
    return list;
  }

  List<Invoice> _filterStore(List<Invoice> list) {
    final sel = _store.selectedStoreName;
    if (sel == null) return list;
    return list.where((b) => b.store == sel).toList();
  }

  Invoice? getById(String id) {
    try { return allBills.firstWhere((b) => b.id == id); } catch (_) { return null; }
  }

  // ─── Stats ───
  int get paidCount    => invoices.where((i) => i.status == 'Paid').length;
  int get pendingCount => invoices.where((i) => i.status == 'Pending' || i.status == 'Partial').length;
  int get totalRevenue => invoices.where((i) => i.status == 'Paid').fold(0, (s, i) => s + i.total);

  String formatCurrency(int v) {
    if (v >= 10000000) return '₹${(v/10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '₹${(v/100000).toStringAsFixed(1)}L';
    if (v >= 1000)     return '₹${(v/1000).toStringAsFixed(0)}K';
    return '₹$v';
  }

  // ─── Invoice builder ───
  int get subtotal => items.fold(0, (s, i) => s + i.total);
  int get gstAmount => (subtotal * gstRate.value / 100).round();
  int get grandTotal => subtotal + gstAmount - discount.value - oldGoldValue.value;

  void addItem() => items.add(BillingItem());
  void removeItem(int index) { items.removeAt(index); items.refresh(); }

  List<InventoryItem> get availableItems =>
      _inventory.inventory.where((i) => i.status == 'In Stock' || i.status == 'Low Stock').toList();

  void recalculate() => items.refresh();

  void setDiscount(String v) => discount.value = int.tryParse(v) ?? 0;
  void setOldGold(String v) => oldGoldValue.value = int.tryParse(v) ?? 0;

  void clearBuilder() {
    items.clear();
    customer.value = '';
    customerId.value = '';
    paymentMode.value = 'Cash';
    discount.value = 0;
    oldGoldValue.value = 0;
    oldGoldValue.value = 0;
  }

  // ─── Save invoice (mirrors createInvoice submit in billing.js) ───
  Invoice saveInvoice({String? dueDateStr, String? sig, String? notes}) {
    final now = DateTime.now();
    final newId = 'BIL${(allBills.where((b) => b.type == BillingType.invoice).length + 5).toString().padLeft(3,'0')}';

    final isPaid = paymentMode.value != 'Split Payment' && dueDateStr == null;
    final status = isPaid ? 'Paid' : (dueDateStr != null ? 'Pending' : 'Paid');

    final inv = Invoice(
      id: newId,
      customer: customer.value,
      customerId: customerId.value,
      date: now,
      paymentMode: paymentMode.value,
      status: status,
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

    // Mark inventory items sold
    for (final item in items) {
      if (item.inventoryId.isNotEmpty) {
        _inventory.sellItem(item.inventoryId);
      }
    }

    clearBuilder();
    return inv;
  }

  // ─── Save estimate ───
  Invoice saveEstimate({String? validUntil, String? notes}) {
    final newId = 'EST${(allBills.where((b) => b.type == BillingType.estimate).length + 2).toString().padLeft(3,'0')}';
    final est = Invoice(
      id: newId, customer: customer.value, customerId: customerId.value,
      date: DateTime.now(), paymentMode: '—', status: 'Draft',
      store: _store.selectedStoreName ?? 'Main',
      type: BillingType.estimate,
      subtotal: subtotal, gst: gstAmount, discount: discount.value,
      roundOff: 0, total: grandTotal,
      items: List.from(items), notes: notes ?? '',
      dueDate: validUntil,
    );
    allBills.add(est);
    clearBuilder();
    return est;
  }

  // ─── Save credit note ───
  Invoice saveCreditNote({
    required String invoiceId, required String itemDesc,
    required int refundAmount, required String reason, required String refundMode, String notes = '',
  }) {
    final newId = 'CN${(allBills.where((b) => b.type == BillingType.creditNote).length + 2).toString().padLeft(3,'0')}';
    final orig = getById(invoiceId);
    final gst = (refundAmount * 0.03).round();
    final cn = Invoice(
      id: newId, customer: orig?.customer ?? 'Customer', customerId: orig?.customerId ?? '',
      date: DateTime.now(), paymentMode: refundMode, status: 'Processed',
      store: _store.selectedStoreName ?? 'Main',
      type: BillingType.creditNote,
      subtotal: refundAmount - gst, gst: gst, discount: 0, roundOff: 0,
      total: refundAmount,
      items: [BillingItem(name: itemDesc, weight: 0, rate: 0)],
      notes: '$reason. $notes',
    );
    allBills.add(cn);
    return cn;
  }

  // ─── Record payment (mirrors recordPayment in billing.js) ───
  void recordPayment(String invoiceId, int amount, String mode) {
    final idx = allBills.indexWhere((b) => b.id == invoiceId);
    if (idx == -1) return;
    final inv = allBills[idx];
    final newPayments = [...inv.payments, PaymentSplit(mode: mode, amount: amount)];
    final newPaid = inv.paidAmount + amount;
    allBills[idx] = inv.copyWith(
      paidAmount: newPaid,
      status: newPaid >= inv.total ? 'Paid' : 'Partial',
      payments: newPayments,
    );
    allBills.refresh();
  }

  // ─── Convert estimate → invoice ───
  Invoice convertEstimate(String estimateId) {
    final est = getById(estimateId);
    if (est == null) throw Exception('Estimate not found');
    final newId = 'BIL${(allBills.where((b) => b.type == BillingType.invoice).length + 5).toString().padLeft(3,'0')}';
    final inv = Invoice(
      id: newId, customer: est.customer, customerId: est.customerId,
      date: DateTime.now(), paymentMode: 'Cash', status: 'Pending',
      store: est.store, type: BillingType.invoice,
      subtotal: est.subtotal, gst: est.gst, discount: est.discount,
      roundOff: est.roundOff, total: est.total,
      items: List.from(est.items),
      notes: 'Converted from Estimate #${est.id}. ${est.notes}',
    );
    // Mark estimate as converted
    final estIdx = allBills.indexWhere((b) => b.id == estimateId);
    if (estIdx != -1) allBills[estIdx] = allBills[estIdx].copyWith(status: 'Converted');
    allBills.add(inv);
    allBills.refresh();
    return inv;
  }

  // ─── Cancel invoice ───
  void cancelInvoice(String id) {
    final idx = allBills.indexWhere((b) => b.id == id);
    if (idx != -1) { allBills[idx] = allBills[idx].copyWith(status: 'Cancelled'); allBills.refresh(); }
  }
}
