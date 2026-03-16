import 'package:get/get.dart';
import '../../../models/inventory_model.dart';
import '../../../core/controllers/store_controller.dart';

class InventoryController extends GetxController {
  final StoreController _store = Get.find<StoreController>();

  final RxList<InventoryItem> inventory = <InventoryItem>[].obs;
  final RxString searchQuery    = ''.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxBool   isLoading      = false.obs;

  // Selected item id passed between screens
  final RxString selectedId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _seedDemoData();
  }

  // ── Demo data matching state.js inventory ──
  void _seedDemoData() {
    inventory.assignAll([
      InventoryItem(
        id: 'INV001', name: '22K Gold Necklace',     category: 'Necklace',
        metal: 'Gold',   purity: '22K', netWeight: 45.50, grossWeight: 48.20,
        stoneWeight: 2.70, makingCharge: 12, huid: 'HUID78234', barcode: 'JE-NK-001',
        status: 'In Stock',  store: 'Rajmahal Jewellers - Main',
        costPrice: 248000,   sellingPrice: 285750,
        showcaseLocation: 'Showcase A - Tray 3',
        hallmarkCert: 'HC-2026-78234', hallmarkDate: DateTime(2026,1,15),
        dateAdded: DateTime(2026,1,15), description: 'Traditional 22K gold necklace',
      ),
      InventoryItem(
        id: 'INV002', name: 'Temple Gold Earrings',   category: 'Earring',
        metal: 'Gold',   purity: '22K', netWeight: 12.30, grossWeight: 13.00,
        stoneWeight: 0.70, makingCharge: 14, huid: 'HUID45892', barcode: 'JE-ER-001',
        status: 'In Stock',  store: 'Rajmahal Jewellers - Main',
        costPrice: 67500,    sellingPrice: 78500,
        showcaseLocation: 'Showcase B - Tray 1',
        hallmarkCert: 'HC-2026-45892', hallmarkDate: DateTime(2026,1,20),
        dateAdded: DateTime(2026,1,20), description: 'South Indian temple design earrings',
      ),
      InventoryItem(
        id: 'INV003', name: 'Platinum Wedding Band',  category: 'Ring',
        metal: 'Platinum', purity: '950 Platinum', netWeight: 6.00, grossWeight: 6.00,
        stoneWeight: 0, makingCharge: 18, huid: 'HUID23456', barcode: 'JE-RG-001',
        status: 'In Stock',  store: 'Rajmahal Jewellers - Mall Road',
        costPrice: 118500,   sellingPrice: 145000,
        showcaseLocation: 'Showcase C - Tray 2',
        hallmarkCert: 'HC-2026-23456', hallmarkDate: DateTime(2026,2,1),
        dateAdded: DateTime(2026,2,1),  description: 'Classic platinum wedding band',
      ),
      InventoryItem(
        id: 'INV004', name: 'Kundan Bridal Set',      category: 'Set',
        metal: 'Gold',   purity: '18K', netWeight: 85.00, grossWeight: 92.00,
        stoneWeight: 7.00, makingCharge: 16, huid: 'HUID67890', barcode: 'JE-ST-001',
        status: 'In Stock',  store: 'Rajmahal Jewellers - Main',
        costPrice: 420000,   sellingPrice: 598500,
        showcaseLocation: 'Showcase D - Tray 1',
        hallmarkCert: 'HC-2026-67890', hallmarkDate: DateTime(2026,2,10),
        dateAdded: DateTime(2025,12,1), description: 'Bridal kundan set with necklace and earrings',
        stoneDetails: {'type':'Kundan/Polki','carat':'5.20','cut':'Uncut','clarity':'Eye Clean','color':'White','certification':'None'},
      ),
      InventoryItem(
        id: 'INV005', name: 'Silver Anklet Pair',     category: 'Anklet',
        metal: 'Silver', purity: '925 Silver', netWeight: 35.00, grossWeight: 35.00,
        stoneWeight: 0, makingCharge: 10, huid: 'HUID34521', barcode: 'JE-AK-001',
        status: 'Low Stock', store: 'Rajmahal Jewellers - City Center',
        costPrice: 2800,     sellingPrice: 3800,
        showcaseLocation: 'Showcase E - Tray 4',
        hallmarkCert: 'HC-2026-34521',
        dateAdded: DateTime(2026,1,5),  description: 'Traditional silver anklets',
      ),
      InventoryItem(
        id: 'INV006', name: 'Diamond Solitaire Ring', category: 'Ring',
        metal: 'Gold',   purity: '18K', netWeight: 3.50, grossWeight: 3.80,
        stoneWeight: 0.30, makingCharge: 20, huid: 'HUID89012', barcode: 'JE-RG-002',
        status: 'In Stock',  store: 'Rajmahal Jewellers - Main',
        costPrice: 185000,   sellingPrice: 245000,
        showcaseLocation: 'Showcase A - Tray 1',
        hallmarkCert: 'HC-2026-89012', hallmarkDate: DateTime(2026,2,15),
        dateAdded: DateTime(2026,2,15), description: '0.5ct diamond solitaire',
        stoneDetails: {'type':'Diamond','carat':'0.50','cut':'Brilliant Round','clarity':'VS1','color':'F','certification':'GIA'},
      ),
      InventoryItem(
        id: 'INV007', name: '22K Gold Bangles (pair)', category: 'Bangle',
        metal: 'Gold',   purity: '22K', netWeight: 28.00, grossWeight: 28.50,
        stoneWeight: 0, makingCharge: 12, huid: 'HUID56789', barcode: 'JE-BG-001',
        status: 'Sold',   store: 'Rajmahal Jewellers - Mall Road',
        costPrice: 153000,   sellingPrice: 176400,
        showcaseLocation: '',
        hallmarkCert: 'HC-2026-56789',
        dateAdded: DateTime(2025,11,15), description: 'Classic plain gold bangles',
      ),
      InventoryItem(
        id: 'INV008', name: 'Rose Gold Chain',         category: 'Chain',
        metal: 'Rose Gold', purity: '18K', netWeight: 10.00, grossWeight: 10.20,
        stoneWeight: 0, makingCharge: 13, huid: 'HUID11223', barcode: 'JE-CH-001',
        status: 'Low Stock', store: 'Rajmahal Jewellers - Main',
        costPrice: 52000,    sellingPrice: 63000,
        showcaseLocation: 'Showcase B - Tray 3',
        hallmarkCert: 'HC-2026-11223',
        dateAdded: DateTime(2026,3,1),  description: '18K rose gold chain',
      ),
    ]);
  }

  // ── Filtered list (mirrors applyInventoryFilters in inventory.js) ──
  List<InventoryItem> get filteredInventory {
    List<InventoryItem> items = inventory.toList();

    // Store filter
    final store = _store.selectedStoreName;
    if (store != null) {
      items = items.where((i) => i.store == store).toList();
    }

    // Metal / status filter
    final f = selectedFilter.value;
    if (f == 'lowstock') {
      items = items.where((i) => i.status == 'Low Stock').toList();
    } else if (f != 'all') {
      items = items.where((i) => i.metal.toLowerCase() == f.toLowerCase()).toList();
    }

    // Search
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      items = items.where((i) =>
          i.name.toLowerCase().contains(q) ||
          i.id.toLowerCase().contains(q) ||
          i.huid.toLowerCase().contains(q) ||
          i.barcode.toLowerCase().contains(q) ||
          i.category.toLowerCase().contains(q)).toList();
    }

    return items;
  }

  // ── Stats ──
  int get totalItems   => filteredInventory.length;
  int get inStockCount => filteredInventory.where((i) => i.status == 'In Stock').length;
  int get lowStockCount=> filteredInventory.where((i) => i.status == 'Low Stock').length;
  int get soldCount    => filteredInventory.where((i) => i.status == 'Sold').length;
  int get stockValue   => filteredInventory.where((i) => i.status != 'Sold').fold(0, (s,i) => s + i.sellingPrice);

  String get stockValueFormatted {
    final v = stockValue;
    if (v >= 10000000) return '₹${(v/10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '₹${(v/100000).toStringAsFixed(1)}L';
    return '₹${v.toString()}';
  }

  // ── Selected item helper ──
  InventoryItem? getById(String id) {
    try { return inventory.firstWhere((i) => i.id == id); } catch (_) { return null; }
  }

  // ── CRUD ──
  void addItem(InventoryItem item) => inventory.add(item);

  void updateItem(String id, InventoryItem updated) {
    final idx = inventory.indexWhere((i) => i.id == id);
    if (idx != -1) { inventory[idx] = updated; inventory.refresh(); }
  }

  void deleteItem(String id) => inventory.removeWhere((i) => i.id == id);

  void sellItem(String id) => _changeStatus(id, 'Sold');
  void reserveItem(String id) => _changeStatus(id, 'Reserved');

  void _changeStatus(String id, String status) {
    final idx = inventory.indexWhere((i) => i.id == id);
    if (idx != -1) { inventory[idx] = inventory[idx].copyWith(status: status); inventory.refresh(); }
  }

  void transferItem(String id, String newStore) {
    final idx = inventory.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final item = inventory[idx];
    inventory[idx] = item.copyWith(
      store: newStore,
      transferHistory: [
        ...item.transferHistory,
        {'from': item.store, 'to': newStore, 'date': DateTime.now().toIso8601String().substring(0,10), 'by': 'Admin'},
      ],
    );
    inventory.refresh();
  }
}
