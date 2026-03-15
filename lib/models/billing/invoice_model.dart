import 'package:acme_killer_mobile_app/models/billing/billing_item_model.dart';
import 'package:acme_killer_mobile_app/models/billing/payment_split_model.dart';

class Invoice {
  String id;
  String customer;
  DateTime date;

  String paymentMode;
  String status;
  String? store;

  int subtotal;
  int gst;
  int discount;
  int roundOff;
  int total;
  int paidAmount;

  int oldGoldAdjustment;

  List<BillingItem> items;
  List<PaymentSplit> payments;

  Invoice({
    required this.id,
    required this.customer,
    required this.date,
    required this.paymentMode,
    required this.subtotal,
    required this.gst,
    required this.discount,
    required this.roundOff,
    required this.total,
    required this.status,
    required this.items,
    required this.store,
    this.paidAmount = 0,
    this.oldGoldAdjustment = 0,
    this.payments = const [],
  });

  Invoice copyWith({
    String? id,
    String? customer,
    DateTime? date,
    String? paymentMode,
    String? status,
    String? store,
    int? subtotal,
    int? gst,
    int? discount,
    int? roundOff,
    int? total,
    int? paidAmount,
    int? oldGoldAdjustment,
    List<BillingItem>? items,
    List<PaymentSplit>? payments,
  }) {
    return Invoice(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      date: date ?? this.date,
      paymentMode: paymentMode ?? this.paymentMode,
      status: status ?? this.status,
      store: store ?? this.store,
      subtotal: subtotal ?? this.subtotal,
      gst: gst ?? this.gst,
      discount: discount ?? this.discount,
      roundOff: roundOff ?? this.roundOff,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      oldGoldAdjustment: oldGoldAdjustment ?? this.oldGoldAdjustment,
      items: items ?? this.items,
      payments: payments ?? this.payments,
    );
  }
}
