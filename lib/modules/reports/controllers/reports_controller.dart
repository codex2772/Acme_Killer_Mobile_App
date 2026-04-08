import 'package:acme_killer_mobile_app/services/settings_service.dart';
import 'package:get/get.dart';
import '../../../services/billing_service.dart';
import '../../../services/inventory_service.dart';
import '../../../services/customer_service.dart';
import '../../../services/accounts_service.dart';
import '../../../services/dashboard_service.dart';
import '../../../core/controllers/store_controller.dart';
import '../../../services/api_client.dart';

class ReportType {
  final String id, title, desc, iconKey;
  final int colorValue;
  const ReportType({
    required this.id,
    required this.title,
    required this.desc,
    required this.iconKey,
    required this.colorValue,
  });
}

// ════════════════════════════════════════════════════════════════════
// ReportsController
// mirrors Electron reports.js
// _rptFetchData() pattern: each report fetches its own API data
// Store comparison switches stores (mirrors Electron storeComp logic)
// ════════════════════════════════════════════════════════════════════
class ReportsController extends GetxController {
  final StoreController _store = Get.find<StoreController>();

  final RxString selectedReportId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList reportData = [].obs; // raw data for selected report

  static const List<ReportType> reportTypes = [
    ReportType(
      id: 'salesTrend',
      title: 'Sales Trend',
      desc: 'Daily, weekly & monthly sales trends with charts',
      iconKey: 'trending',
      colorValue: 0xFFD4AF37,
    ),
    ReportType(
      id: 'topSelling',
      title: 'Top Selling Items',
      desc: 'Most sold items ranked by revenue & quantity',
      iconKey: 'barChart',
      colorValue: 0xFF4ADE80,
    ),
    ReportType(
      id: 'deadStock',
      title: 'Dead Stock',
      desc: 'Items sitting in inventory beyond 90 days',
      iconKey: 'alert',
      colorValue: 0xFFF87171,
    ),
    ReportType(
      id: 'customerAcq',
      title: 'Customer Acquisition',
      desc: 'New vs returning customers per month',
      iconKey: 'people',
      colorValue: 0xFF60A5FA,
    ),
    ReportType(
      id: 'storeComp',
      title: 'Store Comparison',
      desc: 'Revenue & performance across all stores',
      iconKey: 'store',
      colorValue: 0xFFC084FC,
    ),
    ReportType(
      id: 'makingCharge',
      title: 'Making Charge Revenue',
      desc: 'Income from making charges breakdown',
      iconKey: 'rupee',
      colorValue: 0xFFF0D060,
    ),
    ReportType(
      id: 'schemeCollection',
      title: 'Scheme Collection',
      desc: 'Monthly scheme collection vs expected',
      iconKey: 'gift',
      colorValue: 0xFFF472B6,
    ),
    ReportType(
      id: 'outstandingDues',
      title: 'Outstanding Dues',
      desc: 'All customers with pending payments',
      iconKey: 'clock',
      colorValue: 0xFFFBBF24,
    ),
    ReportType(
      id: 'dayBook',
      title: 'Day Book / Cash Book',
      desc: 'All transactions for a specific day',
      iconKey: 'calendar',
      colorValue: 0xFF94A3B8,
    ),
    ReportType(
      id: 'gstReport',
      title: 'GST Report',
      desc: 'GSTR-1 & GSTR-3B summary for filing',
      iconKey: 'fileText',
      colorValue: 0xFF4ADE80,
    ),
  ];

  ReportType? get selectedReport {
    if (selectedReportId.value.isEmpty) return null;
    try {
      return reportTypes.firstWhere((r) => r.id == selectedReportId.value);
    } catch (_) {
      return null;
    }
  }

  // ── Load data for the selected report — mirrors Electron _rptFetchData ──
  Future<void> loadReport(String reportId) async {
    selectedReportId.value = reportId;
    isLoading.value = true;
    reportData.clear();

    try {
      switch (reportId) {
        case 'salesTrend':
        case 'makingCharge':
        case 'outstandingDues':
        case 'gstReport':
          await _fetchInvoices();
          break;
        case 'topSelling':
        case 'deadStock':
          await _fetchInventory();
          break;
        case 'customerAcq':
          await _fetchCustomers();
          break;
        case 'storeComp':
          await _fetchStoreComparison();
          break;
        case 'dayBook':
          await _fetchLedger();
          break;
        case 'schemeCollection':
          // Uses existing schemes data — no separate fetch needed
          break;
      }
    } catch (_) {}

    isLoading.value = false;
  }

  // ── Fetch invoices for sales/GST/making/outstanding reports ──
  Future<void> _fetchInvoices() async {
    final storeCtx = Get.find<StoreContextService>();
    final stores = _store.stores;
    final billing = Get.find<BillingService>();
    final allRaw = <Map<String, dynamic>>[];

    if (stores.length > 1 && _store.selectedStore.value == null) {
      for (final s in stores) {
        storeCtx.switchStore(s.id);
        final r = await billing.listInvoices();
        if (r.success && r.data is List) {
          for (final item in (r.data as List)) {
            final m = Map<String, dynamic>.from(item as Map);
            m['_storeName'] = s.name;
            allRaw.add(m);
          }
        }
      }
      storeCtx.clearStore();
    } else {
      final r = await billing.listInvoices();
      if (r.success && r.data is List)
        allRaw.addAll(List<Map<String, dynamic>>.from(r.data as List));
    }

    reportData.assignAll(allRaw);
  }

  // ── Fetch inventory for dead stock / top selling ──
  Future<void> _fetchInventory() async {
    final r = await Get.find<InventoryService>().list();
    if (r.success && r.data is List) reportData.assignAll(r.data as List);
  }

  // ── Fetch customers ──
  Future<void> _fetchCustomers() async {
    final r = await Get.find<CustomerService>().list();
    if (r.success && r.data is List) reportData.assignAll(r.data as List);
  }

  // ── Store comparison — mirrors Electron: switch per store, fetch invoices + customers ──
  Future<void> _fetchStoreComparison() async {
    final storeCtx = Get.find<StoreContextService>();
    final stores = _store.stores;
    final billing = Get.find<BillingService>();
    final customers = Get.find<CustomerService>();
    final result = <Map<String, dynamic>>[];

    for (final s in stores) {
      storeCtx.switchStore(s.id);
      int revenue = 0;
      int invoiceCount = 0;
      int customerCount = 0;

      final ir = await billing.listInvoices();
      if (ir.success && ir.data is List) {
        final invoices = ir.data as List;
        invoiceCount = invoices.length;
        revenue = invoices.fold<int>(
          0,
          (sum, i) => sum + ((i as Map)['total'] as num? ?? 0).toInt(),
        );
      }
      final cr = await customers.list();
      if (cr.success && cr.data is List)
        customerCount = (cr.data as List).length;

      result.add({
        'name': s.name,
        'short': s.shortName,
        'invoices': invoiceCount,
        'revenue': revenue,
        'customers': customerCount,
        'avg': invoiceCount > 0 ? revenue ~/ invoiceCount : 0,
      });
    }
    storeCtx.clearStore();
    reportData.assignAll(result);
  }

  // ── Fetch ledger for day book ──
  Future<void> _fetchLedger({String? date}) async {
    final params = date != null ? {'from': date, 'to': date} : null;
    final r = await Get.find<LedgerService>().list(params: params);
    if (r.success && r.data is List) reportData.assignAll(r.data as List);
  }

  // ── Dashboard summary ──
  Future<Map<String, dynamic>> fetchSummary() async {
    try {
      final r = await Get.find<DashboardService>().summary();
      if (r.success && r.data is Map) return r.data as Map<String, dynamic>;
    } catch (_) {}
    return {};
  }

  // ── Demo data (fallback) ──
  static const weeklyBars = [85, 62, 78, 95, 45, 68, 92];
  static const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const topSellingItems = [
    {
      'rank': 1,
      'name': '22K Gold Chain',
      'category': 'Chain',
      'units': 45,
      'revenue': 2850000,
    },
    {
      'rank': 2,
      'name': '22K Gold Bangles',
      'category': 'Bangle',
      'units': 38,
      'revenue': 2280000,
    },
    {
      'rank': 3,
      'name': 'Diamond Solitaire Ring',
      'category': 'Ring',
      'units': 22,
      'revenue': 3190000,
    },
    {
      'rank': 4,
      'name': 'Temple Gold Earrings',
      'category': 'Earring',
      'units': 35,
      'revenue': 1575000,
    },
    {
      'rank': 5,
      'name': 'Silver Anklet Pair',
      'category': 'Anklet',
      'units': 60,
      'revenue': 744000,
    },
  ];

  static const deadStockItems = [
    {
      'name': 'Kundan Bridal Set',
      'category': 'Set',
      'days': 105,
      'value': 598500,
      'location': 'Showcase D - Tray 1',
    },
    {
      'name': '22K Gold Bangles (pair)',
      'category': 'Bangle',
      'days': 121,
      'value': 176400,
      'location': '',
    },
    {
      'name': 'Rose Gold Chain',
      'category': 'Chain',
      'days': 15,
      'value': 63000,
      'location': 'Showcase B - Tray 3',
    },
  ];

  static const custMonthly = [
    {'month': 'Oct', 'count': 2},
    {'month': 'Nov', 'count': 3},
    {'month': 'Dec', 'count': 1},
    {'month': 'Jan', 'count': 4},
    {'month': 'Feb', 'count': 2},
    {'month': 'Mar', 'count': 3},
  ];

  static const makingChargeInvoices = [
    {
      'id': 'BIL001',
      'customer': 'Priya Sharma',
      'subtotal': 353324,
      'mc': 42399,
      'date': '2026-03-09',
    },
    {
      'id': 'BIL002',
      'customer': 'Rahul Mehta',
      'subtotal': 140650,
      'mc': 16878,
      'date': '2026-03-08',
    },
    {
      'id': 'BIL003',
      'customer': 'Anita Desai',
      'subtotal': 580545,
      'mc': 69665,
      'date': '2026-03-07',
    },
  ];
  static const outstandingDues = [
    {
      'id': 'BIL003',
      'customer': 'Anita Desai',
      'total': '₹5.98L',
      'totalNum': 598500,
      'dueDate': '2026-04-07',
      'status': 'Partial',
      'daysOverdue': 0,
    },
    {
      'id': 'BIL004',
      'customer': 'Vikram Singh',
      'total': '₹52,000',
      'totalNum': 52000,
      'dueDate': '2026-03-20',
      'status': 'Pending',
      'daysOverdue': 0,
    },
  ];
  static const gstInvoices = [
    {
      'id': 'BIL001',
      'customer': 'Priya Sharma',
      'taxable': 353324,
      'gst': 10600,
      'total': 364250,
    },
    {
      'id': 'BIL002',
      'customer': 'Rahul Mehta',
      'taxable': 140650,
      'gst': 4350,
      'total': 145000,
    },
    {
      'id': 'BIL003',
      'customer': 'Anita Desai',
      'taxable': 580545,
      'gst': 17455,
      'total': 598500,
    },
  ];
  static const dayBookEntries = [
    {
      'time': '10:15 AM',
      'type': 'CR',
      'party': 'Priya Sharma',
      'desc': 'Bill #BIL001',
      'amount': '₹3,64,250',
      'mode': 'UPI',
    },
    {
      'time': '11:30 AM',
      'type': 'CR',
      'party': 'Rahul Mehta',
      'desc': 'Bill #BIL002',
      'amount': '₹1,45,000',
      'mode': 'Card',
    },
    {
      'time': '12:45 PM',
      'type': 'DR',
      'party': 'Staff Salary',
      'desc': 'March Salaries',
      'amount': '₹85,000',
      'mode': 'Bank Transfer',
    },
  ];
  static const storeData = [
    {
      'name': 'Main',
      'invoices': 4,
      'revenue': 1159750,
      'customers': 3,
      'avg': 289938,
    },
    {
      'name': 'Mall Road',
      'invoices': 2,
      'revenue': 465000,
      'customers': 2,
      'avg': 232500,
    },
    {
      'name': 'City Center',
      'invoices': 1,
      'revenue': 52000,
      'customers': 1,
      'avg': 52000,
    },
  ];
  static const schemeData = [
    {
      'name': 'Gold Savings Plan',
      'monthly': '₹5,000',
      'members': 28,
      'collected': 476000,
      'due': 3,
    },
    {
      'name': 'Diamond Collection',
      'monthly': '₹10,000',
      'members': 15,
      'collected': 210000,
      'due': 1,
    },
  ];

  String fmt(int v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹$v';
  }
}
