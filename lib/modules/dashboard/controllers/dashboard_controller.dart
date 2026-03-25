import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/store_controller.dart';
import '../../../services/api_service.dart';

// ── Invoice model for dashboard ──────────────────────────────────────────────
class DashInvoice {
  final String id;
  final String customer;
  final int    amount;
  final String status; // Paid | Pending | Partial
  final String date;
  final String store;
  final String type;   // invoice | estimate | credit-note

  const DashInvoice({
    required this.id, required this.customer, required this.amount,
    required this.status, required this.date, required this.store,
    required this.type,
  });

  String get formattedAmount {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)   return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹$amount';
  }

  String get formattedDate {
    try {
      final d = DateTime.parse(date);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${months[d.month - 1]}';
    } catch (_) { return date; }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DASHBOARD CONTROLLER — mirrors Electron dashboard.js
// ════════════════════════════════════════════════════════════════════════════
class DashboardController extends GetxController {
  final AuthController  _auth  = Get.find<AuthController>();
  final StoreController _store = Get.find<StoreController>();

  final RxBool isLoading = false.obs;

  // ── Stats (populated by _loadStats, fall back to demo) ──
  final RxInt totalInventory      = 1240.obs;
  final RxInt lowStockCount       = 3.obs;
  final RxInt todaySales          = 332000.obs;
  final RxInt pendingInvoiceCount = 2.obs;
  final RxInt activeCustomers     = 845.obs;
  final RxInt vipCustomers        = 12.obs;
  final RxInt gold22k             = 6285.obs;
  final RxInt gold24k             = 7350.obs;
  final RxInt silverRate          = 92.obs;
  final RxInt lowStockAlerts      = 3.obs;
  final RxInt pendingDueCount     = 2.obs;
  final RxInt pendingDueAmount    = 250000.obs;

  // ── Identity ──
  String get role      => _auth.role;
  bool   get isOwner   => _auth.isOwner;
  bool   get isDemo    => _auth.isDemo.value;
  String get userName  => _auth.userName;
  String get storeName => _store.activeLabel;

  // ── Recent invoices (demo — replaced by API on load) ──
  final RxList<DashInvoice> _invoiceList = <DashInvoice>[
    const DashInvoice(id:'BIL001', customer:'Priya Sharma',  amount:364250, status:'Paid',    date:'2026-03-09', store:'Rajmahal Jewellers - Main',        type:'invoice'),
    const DashInvoice(id:'BIL002', customer:'Rahul Mehta',   amount:145000, status:'Paid',    date:'2026-03-08', store:'Rajmahal Jewellers - Mall Road',    type:'invoice'),
    const DashInvoice(id:'BIL003', customer:'Anita Desai',   amount:598500, status:'Partial', date:'2026-03-07', store:'Rajmahal Jewellers - Main',        type:'invoice'),
    const DashInvoice(id:'BIL004', customer:'Vikram Singh',  amount:52000,  status:'Pending', date:'2026-03-05', store:'Rajmahal Jewellers - City Center', type:'invoice'),
    const DashInvoice(id:'BIL005', customer:'Meera Patel',   amount:198000, status:'Pending', date:'2026-03-04', store:'Rajmahal Jewellers - Main',        type:'invoice'),
    const DashInvoice(id:'EST001', customer:'Suresh Kumar',  amount:420000, status:'Pending', date:'2026-03-06', store:'Rajmahal Jewellers - Mall Road',   type:'estimate'),
    const DashInvoice(id:'CN001',  customer:'Kavita Nair',   amount:18500,  status:'Paid',    date:'2026-03-03', store:'Rajmahal Jewellers - Main',        type:'credit-note'),
  ].obs;

  List<DashInvoice> get invoices {
    final sel = _store.selectedStoreName;
    if (sel == null) return _invoiceList.toList();
    return _invoiceList.where((i) => i.store == sel).toList();
  }

  List<DashInvoice> get recentInvoices   => invoices.take(5).toList();
  List<DashInvoice> get pendingInvoices  => invoices.where((i) => i.status == 'Pending' || i.status == 'Partial').toList();
  int get pendingTotalAmount             => pendingInvoices.fold(0, (s, i) => s + i.amount);

  String get gold22kDisplay => '₹${_formatNum(gold22k.value)}/g';
  String get gold22kTola    => '₹${_formatNum((gold22k.value * 11.664).round())}/tola';

  // ── Quick actions ──
  List<_QuickAction> get quickActions => [
    const _QuickAction(label:'New Invoice',    route:'/create-invoice', color:0xFFD4AF37, iconCode:Icons.receipt_long_outlined),
    const _QuickAction(label:'Add Item',       route:'/add-inventory',  color:0xFF4ADE80, iconCode:Icons.inventory_2_outlined),
    const _QuickAction(label:'Add Customer',   route:'/add-customer',   color:0xFF60A5FA, iconCode:Icons.person_add_alt_1_outlined),
    if (isOwner)
      const _QuickAction(label:'Add Staff',    route:'/add-staff',      color:0xFFF472B6, iconCode:Icons.badge_outlined)
    else
      const _QuickAction(label:'Record Payment',route:'/accounts',      color:0xFFC084FC, iconCode:Icons.payments_outlined),
  ];

  // ════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ════════════════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _loadStats();
    ever(_store.selectedStore, (_) => _recalcFromStore());
  }

  void _recalcFromStore() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final filtered = invoices.where((i) => i.date == today).toList();
    if (filtered.isNotEmpty) {
      todaySales.value = filtered.fold(0, (s, i) => s + i.amount);
    }
  }

  // ════════════════════════════════════════════════════════════════
  // API CALL — mirrors Electron's dashboard:summary IPC handler
  // GET /api/dashboard/summary
  // ════════════════════════════════════════════════════════════════
  Future<void> _loadStats() async {
    isLoading.value = true;
    try {
      final api    = Get.find<ApiService>();
      final result = await api.dashboardSummary();

      if (result.success && result.data is Map) {
        final d = result.data as Map<String, dynamic>;
        // Map backend summary fields to local state
        if (d['totalInventory']      != null) totalInventory.value      = (d['totalInventory']      as num).toInt();
        if (d['lowStockCount']       != null) lowStockCount.value       = (d['lowStockCount']       as num).toInt();
        if (d['todaySales']          != null) todaySales.value          = (d['todaySales']          as num).toInt();
        if (d['pendingInvoiceCount'] != null) pendingInvoiceCount.value = (d['pendingInvoiceCount'] as num).toInt();
        if (d['activeCustomers']     != null) activeCustomers.value     = (d['activeCustomers']     as num).toInt();
        if (d['gold22k']             != null) gold22k.value             = (d['gold22k']             as num).toInt();
        if (d['gold24k']             != null) gold24k.value             = (d['gold24k']             as num).toInt();
      }
      // Also fetch recent invoices if API provides them
      final invResult = await api.invoicesList();
      if (invResult.success && invResult.data is List) {
        final list = (invResult.data as List).take(10).map((i) {
          final m = i as Map<String, dynamic>;
          return DashInvoice(
            id:       m['id']?.toString()       ?? '',
            customer: m['customerName']?.toString() ?? m['customer']?.toString() ?? '',
            amount:   (m['total'] as num?)?.toInt() ?? 0,
            status:   m['status']?.toString()   ?? 'Pending',
            date:     (m['date'] ?? m['createdAt'] ?? '').toString().substring(0, 10),
            store:    m['storeName']?.toString() ?? '',
            type:     m['type']?.toString()      ?? 'invoice',
          );
        }).toList();
        _invoiceList.assignAll(list);
      }
    } catch (_) {
      // Demo data already set — silently fall through
    }
    isLoading.value = false;
  }

  Future<void> refresh() => _loadStats();

  // ════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════
  String _formatNum(int n) {
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(2)}Cr';
    if (n >= 100000)   return '${(n / 100000).toStringAsFixed(2)}L';
    if (n >= 1000)     return '${(n / 1000).toStringAsFixed(0)},${(n % 1000).toString().padLeft(3, '0')}';
    return '$n';
  }

  String formatCurrency(int val) {
    if (val >= 10000000) return '₹${(val / 10000000).toStringAsFixed(1)}Cr';
    if (val >= 100000)   return '₹${(val / 100000).toStringAsFixed(1)}L';
    if (val >= 1000)     return '₹${(val / 1000).toStringAsFixed(0)}K';
    return '₹$val';
  }
}

class _QuickAction {
  final String   label;
  final String   route;
  final int      color;
  final IconData iconCode;
  const _QuickAction({required this.label, required this.route, required this.color, required this.iconCode});
}
