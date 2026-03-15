import 'package:get/get.dart';

import '../../../models/billing/billing_item_model.dart';
import '../../../models/billing/invoice_model.dart';
import '../../../models/billing/payment_split_model.dart';

import '../../../models/inventory_model.dart';
import '../../inventory/controllers/inventory_controller.dart';

import '../../../core/controllers/store_controller.dart';

class BillingController extends GetxController {
  /// CONTROLLERS

  final inventoryController = Get.find<InventoryController>();
  final storeController = Get.find<StoreController>();

  /// SEARCH

  var searchQuery = "".obs;

  /// INVOICE ITEMS

  var items = <BillingItem>[].obs;

  /// CUSTOMER

  var customer = "".obs;

  /// PAYMENT

  var paymentMode = "Cash".obs;

  var splitPayments = <PaymentSplit>[].obs;

  /// BILL VALUES

  var subtotal = 0.obs;
  var gst = 0.obs;
  var discount = 0.obs;
  var roundOff = 0.obs;

  var oldGoldValue = 0.obs;

  var gstRate = 3.obs;

  /// INVOICES

  var invoices = <Invoice>[].obs;

  /// TOTAL CALCULATION

  int get total =>
      subtotal.value +
      gst.value -
      discount.value -
      oldGoldValue.value +
      roundOff.value;

  /// INVENTORY ITEMS AVAILABLE FOR BILLING

  List<InventoryItem> get availableItems {
    return inventoryController.inventory
        .where((i) => i.status == "In Stock" || i.status == "Low Stock")
        .toList();
  }

  /// FILTERED INVOICES

  List<Invoice> get filteredInvoices {
    if (searchQuery.value.isEmpty) {
      return invoices;
    }

    return invoices
        .where(
          (i) => i.customer.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }

  /// ADD BILL ITEM

  void addItem() {
    items.add(BillingItem());
  }

  /// REMOVE BILL ITEM

  void removeItem(int index) {
    items.removeAt(index);

    calculate();
  }

  /// CLEAR CURRENT BILL

  void clearInvoice() {
    items.clear();

    subtotal.value = 0;
    gst.value = 0;
    discount.value = 0;
    roundOff.value = 0;
    oldGoldValue.value = 0;

    splitPayments.clear();
  }

  /// ADD SPLIT PAYMENT

  void addPayment(String mode, int amount) {
    splitPayments.add(PaymentSplit(mode: mode, amount: amount));
  }

  /// SAVE INVOICE

  void saveInvoice() {
    final invoice = Invoice(
      id: "INV${DateTime.now().millisecondsSinceEpoch}",
      customer: customer.value,
      date: DateTime.now(),
      paymentMode: paymentMode.value,
      subtotal: subtotal.value,
      gst: gst.value,
      discount: discount.value,
      roundOff: roundOff.value,
      total: total,
      status: "Paid",
      items: List.from(items),
      store: storeController.selectedStore.value,
    );

    /// MARK INVENTORY ITEMS SOLD

    for (var item in items) {
      final index = inventoryController.inventory.indexWhere(
        (i) => i.name == item.name,
      );

      if (index != -1) {
        inventoryController.inventory[index] = inventoryController
            .inventory[index]
            .copyWith(status: "Sold");
      }
    }

    invoices.add(invoice);

    clearInvoice();
  }

  /// CONVERT ESTIMATE → INVOICE

  void convertEstimateToInvoice(Invoice estimate) {
    final invoice = Invoice(
      id: "INV${DateTime.now().millisecondsSinceEpoch}",
      customer: estimate.customer,
      date: DateTime.now(),
      paymentMode: "Cash",
      subtotal: estimate.subtotal,
      gst: estimate.gst,
      discount: estimate.discount,
      roundOff: estimate.roundOff,
      total: estimate.total,
      status: "Pending",
      items: estimate.items,
      store: estimate.store,
    );

    invoices.add(invoice);

    estimate.status = "Converted";
  }

  /// RECORD PAYMENT

  void recordPayment(String invoiceId, int amount, String mode) {
    final inv = invoices.firstWhere((i) => i.id == invoiceId);

    inv.payments.add(PaymentSplit(mode: mode, amount: amount));

    inv.paidAmount += amount;

    if (inv.paidAmount >= inv.total) {
      inv.status = "Paid";
    } else {
      inv.status = "Partial";
    }

    invoices.refresh();
  }

  /// CALCULATE BILL

  void calculate() {
    int sub = 0;

    for (var i in items) {
      sub += i.total;
    }

    subtotal.value = sub;

    gst.value = (sub * 0.03).round();

    /// 🔥 IMPORTANT
    items.refresh();
  }

  /// DISCOUNT

  void setDiscount(String value) {
    discount.value = int.tryParse(value) ?? 0;
  }

  /// OLD GOLD

  void setOldGold(String value) {
    oldGoldValue.value = int.tryParse(value) ?? 0;
  }

  /// ROUND OFF

  void setRoundOff(int value) {
    roundOff.value = value;
  }

  /// STATS

  int get totalInvoices => invoices.length;

  int get paidInvoices => invoices.where((i) => i.status == "Paid").length;
}
