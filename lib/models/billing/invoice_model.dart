import 'billing_item_model.dart';
import 'payment_split_model.dart';

/// Billing type
enum BillingType { invoice, estimate, creditNote }

/// Full Invoice / Estimate / Credit Note model
/// Mirrors the desktop state.js invoice objects exactly
class Invoice {
  String id;
  int? backendId;
  String customer;
  String customerId;
  DateTime date;
  String paymentMode;
  String status;        // Paid | Pending | Partial | Draft | Cancelled | Converted
  String? store;
  BillingType type;

  int subtotal;
  int gst;
  int discount;
  int roundOff;
  int total;
  int paidAmount;
  int oldGoldAdjustment;

  String? dueDate;
  String? digitalSignature;
  String notes;

  List<BillingItem> items;
  List<PaymentSplit> payments;

  Invoice({
    required this.id,
    this.backendId,
    required this.customer,
    this.customerId = '',
    required this.date,
    required this.paymentMode,
    required this.subtotal,
    required this.gst,
    required this.discount,
    required this.roundOff,
    required this.total,
    required this.status,
    required this.items,
    this.store,
    this.type = BillingType.invoice,
    this.paidAmount = 0,
    this.oldGoldAdjustment = 0,
    this.dueDate,
    this.digitalSignature,
    this.notes = '',
    this.payments = const [],
  });

  String get typeLabel {
    switch (type) {
      case BillingType.creditNote: return 'Credit Note';
      case BillingType.estimate:   return 'Estimate';
      default:                     return 'Invoice';
    }
  }

  String get formattedTotal {
    if (total >= 10000000) return '₹${(total / 10000000).toStringAsFixed(1)}Cr';
    if (total >= 100000)   return '₹${(total / 100000).toStringAsFixed(1)}L';
    if (total >= 1000)     return '₹${(total / 1000).toStringAsFixed(0)}K';
    return '₹$total';
  }

  String get formattedDate {
    try {
      final d = date;
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${m[d.month - 1]}';
    } catch (_) { return ''; }
  }

  int get remaining => total - paidAmount;

  // Backend mapper (mirrors mapBackendInvoice in billing.js)
  factory Invoice.fromJson(Map<String, dynamic> j, {String storeName = ''}) {
    const sm = <String,String>{
      'PAID':'Paid','UNPAID':'Pending','PARTIAL':'Partial',
      'CONFIRMED':'Pending','DRAFT':'Pending','CANCELLED':'Cancelled',
    };
    final items = (j['items'] as List<dynamic>? ?? [])
        .map((i) => BillingItem.fromJson(i as Map<String,dynamic>))
        .toList();
    return Invoice(
      id: j['invoiceNumber']?.toString() ?? 'BIL${j['id']}',
      backendId: j['id'] as int?,
      customer: j['customer']?.toString() ?? 'Customer #${j['customerId']}',
      customerId: j['customerId']?.toString() ?? '',
      date: j['date'] != null ? DateTime.tryParse(j['date'].toString()) ?? DateTime.now() : DateTime.now(),
      paymentMode: j['paymentMode']?.toString() ?? 'Cash',
      status: sm[j['paymentStatus']?.toString()] ?? sm[j['status']?.toString()] ?? 'Pending',
      store: storeName,
      type: BillingType.invoice,
      subtotal: (j['subtotal'] ?? 0) as int,
      gst: (j['gstAmount'] ?? 0) as int,
      discount: (j['discount'] ?? 0) as int,
      roundOff: (j['roundOff'] ?? 0) as int,
      total: (j['total'] ?? 0) as int,
      dueDate: j['dueDate']?.toString(),
      digitalSignature: j['digitalSignature']?.toString(),
      notes: j['notes']?.toString() ?? '',
      items: items,
    );
  }

  Invoice copyWith({String? status, int? paidAmount, List<PaymentSplit>? payments}) => Invoice(
    id: id, backendId: backendId, customer: customer, customerId: customerId,
    date: date, paymentMode: paymentMode,
    subtotal: subtotal, gst: gst, discount: discount, roundOff: roundOff,
    total: total, status: status ?? this.status, items: items, store: store,
    type: type, paidAmount: paidAmount ?? this.paidAmount,
    oldGoldAdjustment: oldGoldAdjustment, dueDate: dueDate,
    digitalSignature: digitalSignature, notes: notes,
    payments: payments ?? this.payments,
  );
}
