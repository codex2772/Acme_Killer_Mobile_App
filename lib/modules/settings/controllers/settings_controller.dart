// ════════════════════════════════════════════════════════════════════
// settings_controller.dart
// mirrors Electron settings.js renderSettings()
// GET /api/settings → load; PUT /api/settings → save
// categories + metalTypes CRUD via their respective APIs
// activityLogs → GET /api/activity-logs
// ════════════════════════════════════════════════════════════════════
import 'package:acme_killer_mobile_app/services/dashboard_service.dart';
import 'package:get/get.dart';
import '../../../services/settings_service.dart';
import '../../../services/inventory_service.dart';

class LoyaltyConfig { double pointsPerRupee; int silverThreshold, goldThreshold, platinumThreshold, redemptionRate; LoyaltyConfig({required this.pointsPerRupee, required this.silverThreshold, required this.goldThreshold, required this.platinumThreshold, required this.redemptionRate}); }
class ActivityLog { final String id, timestamp, user, action, detail, module, store; const ActivityLog({required this.id, required this.timestamp, required this.user, required this.action, required this.detail, required this.module, required this.store}); }
class CategoryItem { final String id; String name, description; int? backendId; CategoryItem({required this.id, required this.name, required this.description, this.backendId}); }
class MetalTypeItem { final String id; String name, description; int? backendId; MetalTypeItem({required this.id, required this.name, required this.description, this.backendId}); }

class SettingsController extends GetxController {
  final RxString businessName         = 'Rajmahal Jewellers'.obs;
  final RxString gstin                = '08AAECR1234F1Z5'.obs;
  final RxString phone                = '+91 141 456 7890'.obs;
  final RxString email                = 'info@rajmahaljewellers.com'.obs;
  final RxString website              = 'rajmahaljewellers.com'.obs;
  final RxString invoicePrefix        = 'INV'.obs;
  final RxString invoiceTemplate      = 'professional'.obs;
  final RxDouble gstRate              = 3.0.obs;
  final RxDouble defaultMakingCharge  = 12.0.obs;
  final RxDouble defaultWastage       = 2.0.obs;
  final RxBool   autoPrintInvoice     = false.obs;
  final RxString currency             = 'INR (₹)'.obs;
  final RxString weightUnit           = 'Grams'.obs;
  final RxString language             = 'English'.obs;
  final RxString dateFormat           = 'DD/MM/YYYY'.obs;
  final RxBool   whatsappEnabled      = false.obs;
  final RxString whatsappApiKey       = ''.obs;
  final RxString whatsappProvider     = 'WhatsApp Business API'.obs;
  // Appearance
  final RxString theme                = 'Dark (Default)'.obs;
  final RxString accentColor          = 'Gold (#D4AF37)'.obs;
  final RxString fontSize             = 'Medium'.obs;
  // Rate config
  final RxString rateApiSource        = 'Manual Entry'.obs;
  final RxString rateFrequency        = 'Every 30 min'.obs;
  final RxBool   autoBackup           = true.obs;
  final RxString backupFrequency      = 'Daily'.obs;
  final RxString lastBackup           = '2026-03-12 02:00 AM'.obs;
  final RxBool   rateAutoFetch        = false.obs;
  final loyaltyConfig = LoyaltyConfig(pointsPerRupee: 0.5, silverThreshold: 0, goldThreshold: 500000, platinumThreshold: 1000000, redemptionRate: 100);
  final RxString termsAndConditions   = '''1. All jewellery items are hallmarked as per BIS standards.\n2. GST @3% applicable on all items.\n3. Making charges are non-refundable.\n4. Exchange/return within 7 days of purchase with original bill.\n5. Old gold exchange accepted at current market rates after purity testing.\n6. Payment accepted via Cash, UPI, Card, RTGS, Cheque.'''.obs;
  final RxList<ActivityLog>  activityLogs = <ActivityLog>[].obs;
  final RxList<CategoryItem> categories   = <CategoryItem>[].obs;
  final RxList<MetalTypeItem> metalTypes  = <MetalTypeItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedDefaults();
    _loadFromApi();
  }

  // ── API LOAD — mirrors Electron renderSettings() ──
  Future<void> _loadFromApi() async {
    try {
      final svc = Get.find<SettingsService>();
      // Load settings + categories + metalTypes in parallel
      final results = await Future.wait([svc.get(), Get.find<CategoriesService>().list(), Get.find<MetalTypesService>().list()]);

      // Settings
      if (results[0].success && results[0].data is Map) {
        final d = results[0].data as Map<String, dynamic>;
        if (d['businessName']   != null) businessName.value        = d['businessName'].toString();
        if (d['gstin']          != null) gstin.value               = d['gstin'].toString();
        if (d['phone']          != null) phone.value               = d['phone'].toString();
        if (d['email']          != null) email.value               = d['email'].toString();
        if (d['gstRate']        != null) gstRate.value             = (d['gstRate'] as num).toDouble();
        if (d['defaultMakingCharge'] != null) defaultMakingCharge.value = (d['defaultMakingCharge'] as num).toDouble();
        if (d['invoicePrefix']  != null) invoicePrefix.value       = d['invoicePrefix'].toString();
        if (d['weightUnit']     != null) weightUnit.value          = d['weightUnit'].toString();
        if (d['language']       != null) language.value            = d['language'].toString();
      }

      // Categories from backend
      if (results[1].success && results[1].data is List && (results[1].data as List).isNotEmpty) {
        categories.assignAll((results[1].data as List).map((c) {
          final m = c as Map<String, dynamic>;
          final cat = CategoryItem(id: m['id']?.toString() ?? '', name: m['name']?.toString() ?? '', description: m['description']?.toString() ?? '');
          cat.backendId = m['id'] as int?;
          return cat;
        }).toList());
      }

      // Metal types from backend
      if (results[2].success && results[2].data is List && (results[2].data as List).isNotEmpty) {
        metalTypes.assignAll((results[2].data as List).map((m) {
          final mm = m as Map<String, dynamic>;
          final mt = MetalTypeItem(id: mm['id']?.toString() ?? '', name: mm['name']?.toString() ?? '', description: mm['description']?.toString() ?? '');
          mt.backendId = mm['id'] as int?;
          return mt;
        }).toList());
      }
    } catch (_) {}

    // Activity logs
    try {
      final r = await Get.find<ActivityLogsService>().list();
      if (r.success && r.data is List) {
        activityLogs.assignAll((r.data as List).map((a) {
          final m = a as Map<String, dynamic>;
          return ActivityLog(id: m['id']?.toString() ?? '', timestamp: m['createdAt']?.toString() ?? '', user: m['user']?.toString() ?? 'System', action: m['action']?.toString() ?? '', detail: m['detail']?.toString() ?? m['description']?.toString() ?? '', module: m['module']?.toString() ?? '', store: m['storeName']?.toString() ?? 'All');
        }).toList());
      }
    } catch (_) {}
  }

  Future<bool> saveSettings(Map<String, dynamic> payload) async {
    try {
      final r = await Get.find<SettingsService>().update(payload);
      if (r.success) {
        if (payload['gstRate'] != null) gstRate.value = (payload['gstRate'] as num).toDouble();
        if (payload['defaultMakingCharge'] != null) defaultMakingCharge.value = (payload['defaultMakingCharge'] as num).toDouble();
        if (payload['invoicePrefix'] != null) invoicePrefix.value = payload['invoicePrefix'].toString();
        _logAction('Settings Updated', 'Settings saved', 'Settings');
      }
      return r.success;
    } catch (_) { return false; }
  }

  // ── Categories CRUD ──
  Future<bool> addCategory(String name, String desc) async {
    final cat = CategoryItem(id: (categories.length + 1).toString(), name: name, description: desc);
    categories.add(cat);
    try { final r = await Get.find<CategoriesService>().create({'name': name, 'description': desc}); if (r.success && r.data is Map) cat.backendId = (r.data as Map)['id'] as int?; return r.success; } catch (_) { return false; }
  }
  Future<bool> updateCategory(String id, String name, String desc) async {
    final idx = categories.indexWhere((c) => c.id == id);
    if (idx == -1) return false;
    categories[idx].name = name; categories[idx].description = desc; categories.refresh();
    final bid = categories[idx].backendId;
    if (bid == null) return false;
    try { final r = await Get.find<CategoriesService>().update(bid, {'name': name, 'description': desc}); return r.success; } catch (_) { return false; }
  }
  Future<void> deleteCategory(String id) async {
    final c = categories.firstWhereOrNull((c) => c.id == id);
    categories.removeWhere((c) => c.id == id);
    if (c?.backendId != null) try { await Get.find<CategoriesService>().delete(c!.backendId!); } catch (_) {}
  }

  // ── Metal Types CRUD ──
  Future<bool> addMetalType(String name, String desc) async {
    final mt = MetalTypeItem(id: (metalTypes.length + 1).toString(), name: name, description: desc);
    metalTypes.add(mt);
    try { final r = await Get.find<MetalTypesService>().create({'name': name, 'description': desc}); if (r.success && r.data is Map) mt.backendId = (r.data as Map)['id'] as int?; return r.success; } catch (_) { return false; }
  }
  Future<bool> updateMetalType(String id, String name, String desc) async {
    final idx = metalTypes.indexWhere((m) => m.id == id);
    if (idx == -1) return false;
    metalTypes[idx].name = name; metalTypes[idx].description = desc; metalTypes.refresh();
    final bid = metalTypes[idx].backendId;
    if (bid == null) return false;
    try { final r = await Get.find<MetalTypesService>().update(bid, {'name': name, 'description': desc}); return r.success; } catch (_) { return false; }
  }
  Future<void> deleteMetalType(String id) async {
    final m = metalTypes.firstWhereOrNull((m) => m.id == id);
    metalTypes.removeWhere((m) => m.id == id);
    if (m?.backendId != null) try { await Get.find<MetalTypesService>().delete(m!.backendId!); } catch (_) {}
  }

  void saveInvoiceSettings({required String prefix, required double gst, required double making, required double wastage, required String template}) { invoicePrefix.value = prefix; gstRate.value = gst; defaultMakingCharge.value = making; defaultWastage.value = wastage; invoiceTemplate.value = template; _logAction('Settings Updated', 'Invoice settings saved', 'Settings'); }
  void saveBackupSettings({required bool auto, required String freq}) { autoBackup.value = auto; backupFrequency.value = freq; }
  void doBackupNow() { lastBackup.value = _nowStr(); _logAction('Backup Created', 'Manual backup completed', 'Settings'); }

  void _logAction(String action, String detail, String module) {
    final newId = 'AL${(activityLogs.length + 1).toString().padLeft(3,'0')}';
    activityLogs.insert(0, ActivityLog(id:newId, timestamp:_nowStr(), user:'Owner', action:action, detail:detail, module:module, store:'All'));
  }
  String _nowStr() { final n = DateTime.now(); return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')} ${n.hour.toString().padLeft(2,'0')}:${n.minute.toString().padLeft(2,'0')}:00'; }
  int get storeCount => 3;

  void _seedDefaults() {
    activityLogs.assignAll([ActivityLog(id:'AL001',timestamp:'2026-03-12 10:30:15',user:'Arjun Kapoor',action:'Created Invoice',detail:'Invoice #BIL001 for Priya Sharma — ₹3,64,250',module:'Billing',store:'Main'),ActivityLog(id:'AL002',timestamp:'2026-03-12 09:45:00',user:'System',action:'Rate Updated',detail:'Gold 22K: ₹6,270 → ₹6,285 (+₹15)',module:'Rates',store:'All')]);
    categories.assignAll([CategoryItem(id:'1',name:'Necklace',description:'All types of necklaces'),CategoryItem(id:'2',name:'Ring',description:'Rings and bands'),CategoryItem(id:'3',name:'Earring',description:'Studs, hoops, jhumkas'),CategoryItem(id:'4',name:'Bangle',description:'Bangles and kadas'),CategoryItem(id:'5',name:'Chain',description:'Gold and silver chains'),CategoryItem(id:'6',name:'Pendant',description:'Pendants and lockets'),CategoryItem(id:'7',name:'Set',description:'Matching jewellery sets'),CategoryItem(id:'8',name:'Anklet',description:'Payal and anklets'),CategoryItem(id:'9',name:'Mangalsutra',description:'Traditional mangalsutras')]);
    metalTypes.assignAll([MetalTypeItem(id:'1',name:'Gold 24K',description:'24 Karat pure gold'),MetalTypeItem(id:'2',name:'Gold 22K',description:'22 Karat hallmarked gold'),MetalTypeItem(id:'3',name:'Gold 18K',description:'18 Karat gold'),MetalTypeItem(id:'4',name:'Gold 14K',description:'14 Karat gold'),MetalTypeItem(id:'5',name:'Silver 925',description:'Sterling silver'),MetalTypeItem(id:'6',name:'Platinum 950',description:'950 grade platinum'),MetalTypeItem(id:'7',name:'Rose Gold 18K',description:'Rose gold alloy'),MetalTypeItem(id:'8',name:'White Gold 18K',description:'White gold alloy')]);
  }
}
