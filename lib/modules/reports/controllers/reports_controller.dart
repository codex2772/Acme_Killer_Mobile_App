import 'package:get/get.dart';

class ReportType {
  final String id;
  final String title;
  final String desc;
  final String iconKey;
  final int colorValue;

  const ReportType({
    required this.id,
    required this.title,
    required this.desc,
    required this.iconKey,
    required this.colorValue,
  });
}

class ReportsController extends GetxController {
  final RxString selectedReportId = ''.obs;

  static const List<ReportType> reportTypes = [
    ReportType(id: 'salesTrend',       title: 'Sales Trend',            desc: 'Daily, weekly & monthly sales trends with charts',     iconKey: 'trending',   colorValue: 0xFFD4AF37),
    ReportType(id: 'topSelling',       title: 'Top Selling Items',       desc: 'Most sold items ranked by revenue & quantity',          iconKey: 'barChart',   colorValue: 0xFF4ADE80),
    ReportType(id: 'deadStock',        title: 'Dead Stock',              desc: 'Items sitting in inventory beyond 90 days',             iconKey: 'alert',      colorValue: 0xFFF87171),
    ReportType(id: 'customerAcq',      title: 'Customer Acquisition',    desc: 'New vs returning customers per month',                  iconKey: 'people',     colorValue: 0xFF60A5FA),
    ReportType(id: 'storeComp',        title: 'Store Comparison',        desc: 'Revenue & performance across all stores',               iconKey: 'store',      colorValue: 0xFFC084FC),
    ReportType(id: 'makingCharge',     title: 'Making Charge Revenue',   desc: 'Income from making charges breakdown',                  iconKey: 'rupee',      colorValue: 0xFFF0D060),
    ReportType(id: 'schemeCollection', title: 'Scheme Collection',       desc: 'Monthly scheme collection vs expected',                 iconKey: 'gift',       colorValue: 0xFFF472B6),
    ReportType(id: 'outstandingDues',  title: 'Outstanding Dues',        desc: 'All customers with pending payments',                   iconKey: 'clock',      colorValue: 0xFFFBBF24),
    ReportType(id: 'dayBook',          title: 'Day Book / Cash Book',    desc: 'All transactions for a specific day',                   iconKey: 'calendar',   colorValue: 0xFF94A3B8),
    ReportType(id: 'gstReport',        title: 'GST Report',              desc: 'GSTR-1 & GSTR-3B summary for filing',                   iconKey: 'fileText',   colorValue: 0xFF4ADE80),
  ];

  ReportType? get selectedReport {
    if (selectedReportId.value.isEmpty) return null;
    try {
      return reportTypes.firstWhere((r) => r.id == selectedReportId.value);
    } catch (_) {
      return null;
    }
  }

  // ── Sales Trend demo data ──
  static const weeklyBars = [85, 62, 78, 95, 45, 68, 92]; // % heights Mon-Sun
  static const weekDays   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  // ── Top Selling demo data ──
  static const topSellingItems = [
    {'rank':1,'name':'22K Gold Chain',          'category':'Chain',   'units':45,'revenue':2850000},
    {'rank':2,'name':'22K Gold Bangles',         'category':'Bangle',  'units':38,'revenue':2280000},
    {'rank':3,'name':'Diamond Solitaire Ring',   'category':'Ring',    'units':22,'revenue':3190000},
    {'rank':4,'name':'Temple Gold Earrings',     'category':'Earring', 'units':35,'revenue':1575000},
    {'rank':5,'name':'Silver Anklet Pair',       'category':'Anklet',  'units':60,'revenue':744000},
  ];

  // ── Outstanding dues demo data ──
  static const outstandingDues = [
    {'id':'BIL003','customer':'Anita Desai',  'total':'₹5.98L','totalNum':598500,'dueDate':'2026-04-07','status':'Partial','daysOverdue':0},
    {'id':'BIL004','customer':'Vikram Singh', 'total':'₹52,000','totalNum':52000,'dueDate':'2026-03-20','status':'Pending','daysOverdue':0},
    {'id':'BIL005','customer':'Meera Patel',  'total':'₹1.98L','totalNum':198000,'dueDate':null,'status':'Pending','daysOverdue':0},
  ];

  // ── Day Book demo data ──
  static const dayBookEntries = [
    {'time':'10:15 AM','type':'CR','party':'Priya Sharma',        'desc':'Bill #BIL001','amount':'₹3,64,250','mode':'UPI'},
    {'time':'11:30 AM','type':'CR','party':'Rahul Mehta',         'desc':'Bill #BIL002','amount':'₹1,45,000','mode':'Card'},
    {'time':'12:45 PM','type':'DR','party':'Staff Salary',         'desc':'March Salaries','amount':'₹85,000','mode':'Bank Transfer'},
    {'time':'02:00 PM','type':'CR','party':'Anita Desai',         'desc':'Advance — BIL003','amount':'₹4,00,000','mode':'Cash'},
    {'time':'04:30 PM','type':'DR','party':'Electricity Board',   'desc':'Feb-Mar Bill','amount':'₹12,500','mode':'Online'},
  ];

  // ── Store comparison demo data ──
  static const storeData = [
    {'name':'Main','invoices':4,'revenue':1159750,'customers':3,'avg':289938},
    {'name':'Mall Road','invoices':2,'revenue':465000,'customers':2,'avg':232500},
    {'name':'City Center','invoices':1,'revenue':52000,'customers':1,'avg':52000},
  ];

  // ── Customer acquisition monthly data ──
  static const custMonthly = [
    {'month':'Oct','count':2},
    {'month':'Nov','count':3},
    {'month':'Dec','count':1},
    {'month':'Jan','count':4},
    {'month':'Feb','count':2},
    {'month':'Mar','count':3},
  ];

  // ── Dead stock demo (items > 60 days) ──
  static const deadStockItems = [
    {'name':'Kundan Bridal Set',    'category':'Set',     'days':105,'value':598500,'location':'Showcase D - Tray 1'},
    {'name':'22K Gold Bangles (pair)','category':'Bangle','days':121,'value':176400,'location':''},
    {'name':'Rose Gold Chain',      'category':'Chain',   'days':15, 'value':63000, 'location':'Showcase B - Tray 3'},
  ];

  // ── Making charge demo ──
  static const makingChargeInvoices = [
    {'id':'BIL001','customer':'Priya Sharma', 'subtotal':353324,'mc':42399,'date':'2026-03-09'},
    {'id':'BIL002','customer':'Rahul Mehta',  'subtotal':140650,'mc':16878,'date':'2026-03-08'},
    {'id':'BIL003','customer':'Anita Desai',  'subtotal':580545,'mc':69665,'date':'2026-03-07'},
  ];

  // ── Scheme collection demo ──
  static const schemeData = [
    {'name':'Gold Savings Plan','monthly':'₹5,000','members':28,'collected':476000,'due':3},
    {'name':'Diamond Collection','monthly':'₹10,000','members':15,'collected':210000,'due':1},
    {'name':'Silver Plan','monthly':'₹2,000','members':42,'collected':588000,'due':5},
  ];

  // ── GST report demo ──
  static const gstInvoices = [
    {'id':'BIL001','customer':'Priya Sharma', 'taxable':353324,'gst':10600,'total':364250},
    {'id':'BIL002','customer':'Rahul Mehta',  'taxable':140650,'gst':4350,'total':145000},
    {'id':'BIL003','customer':'Anita Desai',  'taxable':580545,'gst':17455,'total':598500},
    {'id':'BIL004','customer':'Vikram Singh', 'taxable':50485,'gst':1515,'total':52000},
  ];

  // ── Format helpers ──
  String fmt(int v) {
    if (v >= 10000000) return '₹${(v/10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '₹${(v/100000).toStringAsFixed(1)}L';
    if (v >= 1000)     return '₹${(v/1000).toStringAsFixed(0)}K';
    return '₹$v';
  }
}
