import 'package:get/get.dart';

class LoyaltyConfig {
  double pointsPerRupee;
  int silverThreshold;
  int goldThreshold;
  int platinumThreshold;
  int redemptionRate;

  LoyaltyConfig({
    required this.pointsPerRupee,
    required this.silverThreshold,
    required this.goldThreshold,
    required this.platinumThreshold,
    required this.redemptionRate,
  });
}

class ActivityLog {
  final String id;
  final String timestamp;
  final String user;
  final String action;
  final String detail;
  final String module;
  final String store;

  const ActivityLog({
    required this.id,
    required this.timestamp,
    required this.user,
    required this.action,
    required this.detail,
    required this.module,
    required this.store,
  });
}

class CategoryItem {
  final String id;
  String name;
  String description;
  CategoryItem({required this.id, required this.name, required this.description});
}

class MetalTypeItem {
  final String id;
  String name;
  String description;
  MetalTypeItem({required this.id, required this.name, required this.description});
}

class SettingsController extends GetxController {
  // ── Business info ──
  final RxString businessName   = 'Rajmahal Jewellers'.obs;
  final RxString gstin          = '08AAECR1234F1Z5'.obs;
  final RxString phone          = '+91 141 456 7890'.obs;
  final RxString email          = 'info@rajmahaljewellers.com'.obs;
  final RxString website        = 'rajmahaljewellers.com'.obs;

  // ── Invoice settings ──
  final RxString  invoicePrefix       = 'INV'.obs;
  final RxString  invoiceTemplate     = 'professional'.obs;
  final RxDouble  gstRate             = 3.0.obs;
  final RxDouble  defaultMakingCharge = 12.0.obs;
  final RxDouble  defaultWastage      = 2.0.obs;
  final RxBool    autoPrintInvoice    = false.obs;

  // ── Regional ──
  final RxString currency    = 'INR (₹)'.obs;
  final RxString weightUnit  = 'Grams'.obs;
  final RxString language    = 'English'.obs;
  final RxString dateFormat  = 'DD/MM/YYYY'.obs;

  // ── Appearance ──
  final RxString theme       = 'Dark (Default)'.obs;
  final RxString accentColor = 'Gold (#D4AF37)'.obs;
  final RxString fontSize    = 'Medium'.obs;

  // ── WhatsApp ──
  final RxBool   whatsappEnabled = false.obs;
  final RxString whatsappApiKey  = ''.obs;
  final RxString whatsappProvider = 'WhatsApp Business API'.obs;

  // ── Backup ──
  final RxBool   autoBackup       = true.obs;
  final RxString backupFrequency  = 'Daily'.obs;
  final RxString lastBackup       = '2026-03-12 02:00 AM'.obs;

  // ── Rates ──
  final RxBool   rateAutoFetch  = false.obs;
  final RxString rateApiSource  = 'Manual Entry'.obs;
  final RxString rateFrequency  = 'Every 30 min'.obs;

  // ── Loyalty ──
  final loyaltyConfig = LoyaltyConfig(
    pointsPerRupee: 0.5, silverThreshold: 0,
    goldThreshold: 500000, platinumThreshold: 1000000, redemptionRate: 100,
  );

  // ── Terms ──
  final RxString termsAndConditions = '''1. All jewellery items are hallmarked as per BIS standards.
2. GST @3% applicable on all items.
3. Making charges are non-refundable.
4. Exchange/return within 7 days of purchase with original bill.
5. Old gold exchange accepted at current market rates after purity testing.
6. Payment accepted via Cash, UPI, Card, RTGS, Cheque.'''.obs;

  // ── Activity Logs ──
  final RxList<ActivityLog> activityLogs = <ActivityLog>[
    ActivityLog(id:'AL001', timestamp:'2026-03-12 10:30:15', user:'Arjun Kapoor',
        action:'Created Invoice', detail:'Invoice #BIL001 for Priya Sharma — ₹3,64,250', module:'Billing', store:'Main'),
    ActivityLog(id:'AL002', timestamp:'2026-03-12 09:45:00', user:'System',
        action:'Rate Updated', detail:'Gold 22K: ₹6,270 → ₹6,285 (+₹15)', module:'Rates', store:'All'),
    ActivityLog(id:'AL003', timestamp:'2026-03-11 18:30:00', user:'Sneha Reddy',
        action:'Customer Added', detail:'New customer: Vikram Singh (CUS004)', module:'Customers', store:'City Center'),
    ActivityLog(id:'AL004', timestamp:'2026-03-11 16:00:00', user:'Arjun Kapoor',
        action:'Old Gold Entry', detail:'15.2g 22K from Priya Sharma', module:'Old Gold', store:'Main'),
    ActivityLog(id:'AL005', timestamp:'2026-03-10 14:15:00', user:'Ravi Kumar',
        action:'Inventory Transfer', detail:'Platinum Ring → City Center Branch', module:'Inventory', store:'Main'),
    ActivityLog(id:'AL006', timestamp:'2026-03-10 11:00:00', user:'System',
        action:'Backup Created', detail:'Auto backup completed successfully', module:'Settings', store:'All'),
    ActivityLog(id:'AL007', timestamp:'2026-03-09 17:45:00', user:'Arjun Kapoor',
        action:'Scheme Payment', detail:'₹5,000 recorded for Priya Sharma — Gold Savings Plan', module:'Schemes', store:'Main'),
    ActivityLog(id:'AL008', timestamp:'2026-03-09 15:30:00', user:'Sneha Reddy',
        action:'Invoice Partial', detail:'₹4,00,000 received — BIL003 (Anita Desai)', module:'Billing', store:'Main'),
  ].obs;

  // ── Categories ──
  final RxList<CategoryItem> categories = <CategoryItem>[
    CategoryItem(id:'1', name:'Necklace',    description:'All types of necklaces'),
    CategoryItem(id:'2', name:'Ring',        description:'Rings and bands'),
    CategoryItem(id:'3', name:'Earring',     description:'Studs, hoops, jhumkas'),
    CategoryItem(id:'4', name:'Bracelet',    description:'Bracelets and bangles'),
    CategoryItem(id:'5', name:'Chain',       description:'Gold and silver chains'),
    CategoryItem(id:'6', name:'Pendant',     description:'Pendants and lockets'),
    CategoryItem(id:'7', name:'Set',         description:'Matching jewellery sets'),
    CategoryItem(id:'8', name:'Anklet',      description:'Payal and anklets'),
    CategoryItem(id:'9', name:'Mangalsutra', description:'Traditional mangalsutras'),
    CategoryItem(id:'10',name:'Bangle',      description:'Bangles and kadas'),
  ].obs;

  // ── Metal Types ──
  final RxList<MetalTypeItem> metalTypes = <MetalTypeItem>[
    MetalTypeItem(id:'1', name:'Gold 24K',       description:'24 Karat pure gold'),
    MetalTypeItem(id:'2', name:'Gold 22K',       description:'22 Karat hallmarked gold'),
    MetalTypeItem(id:'3', name:'Gold 18K',       description:'18 Karat gold'),
    MetalTypeItem(id:'4', name:'Gold 14K',       description:'14 Karat gold'),
    MetalTypeItem(id:'5', name:'Silver 925',     description:'Sterling silver'),
    MetalTypeItem(id:'6', name:'Platinum 950',   description:'950 grade platinum'),
    MetalTypeItem(id:'7', name:'Rose Gold 18K',  description:'Rose gold alloy'),
    MetalTypeItem(id:'8', name:'White Gold 18K', description:'White gold alloy'),
    MetalTypeItem(id:'9', name:'Diamond',        description:'Diamond set pieces'),
  ].obs;

  // ── CRUD: Categories ──
  void addCategory(String name, String desc) {
    final newId = (categories.length + 1).toString();
    categories.add(CategoryItem(id: newId, name: name, description: desc));
    _logAction('Category Added', name, 'Settings');
  }

  void updateCategory(String id, String name, String desc) {
    final idx = categories.indexWhere((c) => c.id == id);
    if (idx != -1) {
      categories[idx].name = name;
      categories[idx].description = desc;
      categories.refresh();
    }
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
  }

  // ── CRUD: Metal Types ──
  void addMetalType(String name, String desc) {
    final newId = (metalTypes.length + 1).toString();
    metalTypes.add(MetalTypeItem(id: newId, name: name, description: desc));
    _logAction('Metal Type Added', name, 'Settings');
  }

  void updateMetalType(String id, String name, String desc) {
    final idx = metalTypes.indexWhere((m) => m.id == id);
    if (idx != -1) {
      metalTypes[idx].name = name;
      metalTypes[idx].description = desc;
      metalTypes.refresh();
    }
  }

  void deleteMetalType(String id) {
    metalTypes.removeWhere((m) => m.id == id);
  }

  // ── Save settings section ──
  void saveInvoiceSettings({
    required String prefix, required double gst,
    required double making, required double wastage, required String template,
  }) {
    invoicePrefix.value = prefix;
    gstRate.value = gst;
    defaultMakingCharge.value = making;
    defaultWastage.value = wastage;
    invoiceTemplate.value = template;
    _logAction('Settings Updated', 'Invoice settings saved', 'Settings');
  }

  void saveBackupSettings({required bool auto, required String freq}) {
    autoBackup.value = auto;
    backupFrequency.value = freq;
  }

  void doBackupNow() {
    lastBackup.value = _nowStr();
    _logAction('Backup Created', 'Manual backup completed', 'Settings');
  }

  // ── Log helper ──
  void _logAction(String action, String detail, String module) {
    final newId = 'AL${(activityLogs.length + 1).toString().padLeft(3,'0')}';
    activityLogs.insert(0, ActivityLog(
      id: newId, timestamp: _nowStr(), user: 'Owner',
      action: action, detail: detail, module: module, store: 'All',
    ));
  }

  String _nowStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')} '
        '${n.hour.toString().padLeft(2,'0')}:${n.minute.toString().padLeft(2,'0')}:00';
  }

  // ── Stores count for UI ──
  int get storeCount => 3;
}
