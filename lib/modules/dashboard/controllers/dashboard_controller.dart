import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/store_controller.dart';

// ── Invoice model for dashboard ──
class DashInvoice {
  final String id;
  final String customer;
  final int amount;
  final String status; // Paid | Pending | Partial
  final String date;
  final String store;
  final String type; // invoice | estimate | credit-note

  const DashInvoice({
    required this.id,
    required this.customer,
    required this.amount,
    required this.status,
    required this.date,
    required this.store,
    required this.type,
  });

  String get formattedAmount {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹$amount';
  }

  String get formattedDate {
    try {
      final d = DateTime.parse(date);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${d.day} ${months[d.month - 1]}';
    } catch (_) {
      return date;
    }
  }
}

// ── Module item for modules grid ──
class DashModule {
  final String title;
  final String desc;
  final String count;
  final String route;
  final dynamic icon; // IconData
  final int color;
  final String? permModule; // permission gate key

  const DashModule({
    required this.title,
    required this.desc,
    required this.count,
    required this.route,
    required this.icon,
    required this.color,
    this.permModule,
  });
}

class DashboardController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final StoreController _store = Get.find<StoreController>();

  // ── Reactive state ──
  final RxBool isLoading = false.obs;

  // Stats
  final RxInt totalInventory = 1240.obs;
  final RxInt lowStockCount = 3.obs;
  final RxInt todaySales = 332000.obs;
  final RxInt pendingInvoiceCount = 2.obs;
  final RxInt activeCustomers = 845.obs;
  final RxInt vipCustomers = 12.obs;
  final RxInt gold22k = 6285.obs;
  final RxInt gold24k = 7350.obs;
  final RxInt silverRate = 92.obs;

  // Alerts
  final RxInt lowStockAlerts = 3.obs;
  final RxInt pendingDueCount = 2.obs;
  final RxInt pendingDueAmount = 250000.obs;

  // Role (reads from AuthController)
  String get role => _auth.role;
  bool get isOwner => _auth.isOwner;
  bool get isDemo => _auth.isDemo.value;
  String get userName => _auth.userName;
  String get storeName => _store.activeLabel;

  // ── All invoices (demo data — mirrors state.js invoices) ──
  final List<DashInvoice> _allInvoices = const [
    DashInvoice(
      id: 'BIL001',
      customer: 'Priya Sharma',
      amount: 364250,
      status: 'Paid',
      date: '2026-03-09',
      store: 'Rajmahal Jewellers - Main',
      type: 'invoice',
    ),
    DashInvoice(
      id: 'BIL002',
      customer: 'Rahul Mehta',
      amount: 145000,
      status: 'Paid',
      date: '2026-03-08',
      store: 'Rajmahal Jewellers - Mall Road',
      type: 'invoice',
    ),
    DashInvoice(
      id: 'BIL003',
      customer: 'Anita Desai',
      amount: 598500,
      status: 'Partial',
      date: '2026-03-07',
      store: 'Rajmahal Jewellers - Main',
      type: 'invoice',
    ),
    DashInvoice(
      id: 'BIL004',
      customer: 'Vikram Singh',
      amount: 52000,
      status: 'Pending',
      date: '2026-03-05',
      store: 'Rajmahal Jewellers - City Center',
      type: 'invoice',
    ),
    DashInvoice(
      id: 'BIL005',
      customer: 'Meera Patel',
      amount: 198000,
      status: 'Pending',
      date: '2026-03-04',
      store: 'Rajmahal Jewellers - Main',
      type: 'invoice',
    ),
    DashInvoice(
      id: 'EST001',
      customer: 'Suresh Kumar',
      amount: 420000,
      status: 'Pending',
      date: '2026-03-06',
      store: 'Rajmahal Jewellers - Mall Road',
      type: 'estimate',
    ),
    DashInvoice(
      id: 'CN001',
      customer: 'Kavita Nair',
      amount: 18500,
      status: 'Paid',
      date: '2026-03-03',
      store: 'Rajmahal Jewellers - Main',
      type: 'credit-note',
    ),
  ];

  // ── Store-filtered invoices (mirrors filterByStore in dashboard.js) ──
  List<DashInvoice> get invoices {
    final selected = _store.selectedStoreName;
    if (selected == null) return _allInvoices;
    return _allInvoices.where((i) => i.store == selected).toList();
  }

  List<DashInvoice> get recentInvoices => invoices.take(5).toList();

  List<DashInvoice> get pendingInvoices => invoices
      .where((i) => i.status == 'Pending' || i.status == 'Partial')
      .toList();

  int get pendingTotalAmount =>
      pendingInvoices.fold(0, (sum, i) => sum + i.amount);

  // ── Gold rate formatted ──
  String get gold22kDisplay => '₹${_formatNum(gold22k.value)}/g';
  String get gold22kTola =>
      '₹${_formatNum((gold22k.value * 11.664).round())}/tola';

  // ── Quick actions (role-aware, mirrors dashboard.js quickActions) ──
  List<_QuickAction> get quickActions => [
    const _QuickAction(
      label: 'New Invoice',
      route: '/create-invoice',
      color: 0xFFD4AF37,
      iconCode: Icons.receipt_long_outlined,
    ),

    const _QuickAction(
      label: 'Add Item',
      route: '/add-inventory',
      color: 0xFF4ADE80,
      iconCode: Icons.inventory_2_outlined,
    ),

    const _QuickAction(
      label: 'Add Customer',
      route: '/add-customer',
      color: 0xFF60A5FA,
      iconCode: Icons.person_add_alt_1_outlined,
    ),

    if (isOwner)
      const _QuickAction(
        label: 'Add Staff',
        route: '/add-staff',
        color: 0xFFF472B6,
        iconCode: Icons.badge_outlined,
      )
    else
      const _QuickAction(
        label: 'Record Payment',
        route: '/accounts',
        color: 0xFFC084FC,
        iconCode: Icons.payments_outlined ,
      ),
  ];

  // ── Load stats from API (with demo fallback) ──
  @override
  void onInit() {
    super.onInit();
    _loadStats();
    // Reload when store changes
    ever(_store.selectedStore, (_) => _recalcFromStore());
  }

  void _recalcFromStore() {
    // Recalculate today's sales from filtered invoices
    final filtered = invoices
        .where(
          (i) => i.date == DateTime.now().toIso8601String().substring(0, 10),
        )
        .toList();
    if (filtered.isNotEmpty) {
      todaySales.value = filtered.fold(0, (s, i) => s + i.amount);
    }
  }

  Future<void> _loadStats() async {
    isLoading.value = true;
    // In real app: call API endpoint GET /dashboard/summary
    // For now use demo values that mirror state.js
    await Future.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;
  }

  Future<void> refresh() => _loadStats();

  String _formatNum(int n) {
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(2)}Cr';
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(2)}L';
    if (n >= 1000)
      return '${(n / 1000).toStringAsFixed(0)},${(n % 1000).toString().padLeft(3, '0')}';
    return '$n';
  }

  String formatCurrency(int val) {
    if (val >= 10000000) return '₹${(val / 10000000).toStringAsFixed(1)}Cr';
    if (val >= 100000) return '₹${(val / 100000).toStringAsFixed(1)}L';
    if (val >= 1000) return '₹${(val / 1000).toStringAsFixed(0)}K';
    return '₹$val';
  }
}

class _QuickAction {
  final String label;
  final String route;
  final int color;
  final IconData iconCode;
  const _QuickAction({
    required this.label,
    required this.route,
    required this.color,
    required this.iconCode,
  });
}
