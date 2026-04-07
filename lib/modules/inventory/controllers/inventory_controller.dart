import 'package:get/get.dart';
import '../../../models/inventory_model.dart';
import '../../../core/controllers/store_controller.dart';
import '../../../services/api_client.dart';
import '../../../services/inventory_service.dart';
import '../../../services/settings_service.dart';

// ════════════════════════════════════════════════════════════════════
// InventoryController
// mirrors Electron inventory.js renderInventory() / renderAddInventory()
//
// API pattern (same as Electron):
//  1. Check cache → render instantly (_apiInventory)
//  2. Fetch list per store (multi-store switch pattern)
//  3. Two-phase enrichment: categories + metal-types lookup
//  4. invalidateCache() after create/update/delete
// ════════════════════════════════════════════════════════════════════
class InventoryController extends GetxController {
  final StoreController _store = Get.find<StoreController>();

  final RxList<InventoryItem> inventory = <InventoryItem>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs;

  DateTime? _lastFetched;
  static const _staleDuration = Duration(seconds: 60);
  bool get isStale =>
      _lastFetched == null ||
      DateTime.now().difference(_lastFetched!) > _staleDuration;
  final RxString selectedId = ''.obs;

  // Cache of last API fetch (mirrors Electron state._apiInventory)
  List<InventoryItem>? _apiInventory;

  // Category + metal type lookup maps (mirrors Electron categoryMap/metalTypeMap)
  Map<int, String> _categoryMap = {};
  Map<int, Map<String, dynamic>> _metalTypeMap = {};

  @override
  void onInit() {
    super.onInit();
    _seedDemoData();
    _fetchFromApi();
    // Refresh when user switches store — permanent controller won't recreate
    ever(_store.selectedStore, (_) {
      _lastFetched = null; // invalidate cache
      _fetchFromApi();
    });
  }

  // ════════════════════════════════════════════════════════════════
  // API LOAD — mirrors Electron renderInventory()
  // ════════════════════════════════════════════════════════════════
  Future<void> _fetchFromApi() async {
    isLoading.value = true;
    try {
      final inv = Get.find<InventoryService>();
      final cat = Get.find<CategoriesService>();
      final metal = Get.find<MetalTypesService>();
      final store = Get.find<StoreContextService>();

      List<Map<String, dynamic>> allRaw = [];
      final stores = _store.stores;

      if (stores.length > 1 && _store.selectedStore.value == null) {
        // ── Multi-store fetch (mirrors Electron All Stores mode) ──
        for (final s in stores) {
          store.switchStore(s.id);
          final r = await inv.list();
          if (r.success && r.data is List) {
            for (final item in (r.data as List)) {
              (item as Map<String, dynamic>)['_storeName'] = s.name;
              (item)['_storeId'] = s.id;
              allRaw.add(item);
            }
          }
        }
        store.clearStore(); // restore
      } else {
        // ── Single store fetch ──
        final r = await inv.list();
        if (r.success && r.data is List) {
          allRaw = List<Map<String, dynamic>>.from(r.data as List);
        }
      }

      if (allRaw.isEmpty) {
        isLoading.value = false;
        return;
      }

      // Deduplicate by backend id
      final seen = <dynamic>{};
      allRaw = allRaw.where((item) {
        if (seen.contains(item['id'])) return false;
        seen.add(item['id']);
        return true;
      }).toList();

      // Phase 1 — map from backend
      var mapped = allRaw.map((raw) {
        final storeName =
            raw['_storeName']?.toString() ?? _store.selectedStoreName ?? '';
        return InventoryItem.fromJson(raw, storeName: storeName);
      }).toList();

      // Phase 2 — enrich from lookup tables (mirrors Electron two-phase enrichment)
      try {
        final catRes = await cat.list();
        final metalRes = await metal.list();

        if (catRes.success && catRes.data is List) {
          _categoryMap = {};
          for (final c in (catRes.data as List)) {
            if (c['id'] != null)
              _categoryMap[c['id']] = c['name']?.toString() ?? '';
          }
        }
        if (metalRes.success && metalRes.data is List) {
          _metalTypeMap = {};
          for (final m in (metalRes.data as List)) {
            if (m['id'] != null) {
              _metalTypeMap[m['id']] = {
                'name': m['name']?.toString() ?? '',
                'purity': m['purity']?.toString() ?? '',
                'rate': (m['currentRate'] as num?)?.toDouble() ?? 0,
              };
            }
          }
        }

        // Re-map with enriched lookups
        mapped = allRaw.map((raw) {
          final storeName =
              raw['_storeName']?.toString() ?? _store.selectedStoreName ?? '';
          final item = InventoryItem.fromJson(raw, storeName: storeName);

          // Resolve category if still '—'
          String cat2 = item.category;
          String metal2 = item.metal;
          String purity2 = item.purity;

          final catId = raw['categoryId'] as int?;
          final metId = raw['metalTypeId'] as int?;

          if ((cat2 == '—' || cat2.isEmpty) && catId != null) {
            cat2 = _categoryMap[catId] ?? cat2;
          }
          if (metId != null) {
            final m = _metalTypeMap[metId];
            if (m != null) {
              if (metal2 == '—' || metal2.isEmpty) metal2 = m['name'] ?? metal2;
              if (purity2 == '—' || purity2.isEmpty)
                purity2 = m['purity'] ?? purity2;
            }
          }

          if (cat2 != item.category ||
              metal2 != item.metal ||
              purity2 != item.purity) {
            return item.copyWith(
              category: cat2,
              metal: metal2,
              purity: purity2,
            );
          }
          return item;
        }).toList();
      } catch (_) {
        /* Lookup enrichment failed — use phase-1 data */
      }

      _apiInventory = mapped;
      inventory.assignAll(mapped);
      _lastFetched = DateTime.now();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> refresh() {
    _apiInventory = null;
    return _fetchFromApi();
  }

  Future<void> refreshIfStale() async {
    if (isStale && !isLoading.value) await _fetchFromApi();
  }

  void invalidateCache() {
    _apiInventory = null;
  }

  void addItem(InventoryItem item) => inventory.add(item);
  // ════════════════════════════════════════════════════════════════
  // CREATE — mirrors Electron renderAddInventory form submit
  // POST /api/jewelry-items (nested category + metalType objects)
  // Then upload image to S3 if provided
  // ════════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> createItem({
    required String name,
    required String description,
    required int categoryId,
    required int metalTypeId,
    required double netWeight,
    required double grossWeight,
    required double makingCharges,
    required double stoneCharges,
    required int quantity,
    String? hsnCode,
    String? barcode,
    String? imageUrl,
    int? targetStoreId,
  }) async {
    final inv = Get.find<InventoryService>();
    final store = Get.find<StoreContextService>();

    // SKU generation mirrors Electron
    final count = (_apiInventory ?? inventory).length;
    final skuRand = DateTime.now().millisecondsSinceEpoch
        .toRadixString(36)
        .substring(7)
        .toUpperCase();
    final sku = 'ITM-$count-$skuRand';

    if (targetStoreId != null && _store.selectedStore.value == null) {
      store.switchStore(targetStoreId);
    }

    final payload = {
      'name': name,
      'description': description,
      'sku': sku,
      'category': {'id': categoryId},
      'metalType': {'id': metalTypeId},
      'grossWeight': grossWeight,
      'netWeight': netWeight,
      'makingCharges': makingCharges,
      'stoneCharges': stoneCharges,
      'otherCharges': 0,
      'quantity': quantity,
      'hsnCode': hsnCode ?? '7113',
      'barcode': barcode,
      'imageUrl': imageUrl,
      'status': 'IN_STOCK',
    };

    final result = await inv.create(payload);

    if (targetStoreId != null && _store.selectedStore.value == null) {
      store.clearStore();
    }

    if (result.success) {
      invalidateCache();
      _fetchFromApi(); // refresh in background
    }

    return {'success': result.success, 'error': result.error};
  }

  // ════════════════════════════════════════════════════════════════
  // UPDATE — mirrors Electron renderEditInventory form submit
  // GET /api/jewelry-items/:id (full entity fetch) → PUT with full entity
  // ════════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> updateItemViaApi({
    required dynamic backendId,
    required Map<String, dynamic> changes,
    String? newImageUrl,
    bool imageRemoved = false,
    int? storeIdForSwitch,
  }) async {
    final inv = Get.find<InventoryService>();
    final store = Get.find<StoreContextService>();

    if (storeIdForSwitch != null && _store.selectedStore.value == null) {
      store.switchStore(storeIdForSwitch);
    }

    // Fetch full entity first (mirrors Electron: GET then PUT full entity)
    Map<String, dynamic> base = {};
    try {
      final getRes = await inv.get(backendId);
      if (getRes.success && getRes.data is Map) {
        base = Map<String, dynamic>.from(getRes.data as Map);
      }
    } catch (_) {}

    // Merge changes over base
    final payload = {...base, ...changes};
    if (newImageUrl != null) payload['imageUrl'] = newImageUrl;
    if (imageRemoved) payload['imageUrl'] = null;

    final result = await inv.update(backendId, payload);

    if (storeIdForSwitch != null && _store.selectedStore.value == null) {
      store.clearStore();
    }

    if (result.success) {
      invalidateCache();
      _fetchFromApi();
    }

    return {'success': result.success, 'error': result.error};
  }

  // ════════════════════════════════════════════════════════════════
  // RESTOCK — mirrors Electron restock button handler
  // GET item → update quantity → PUT
  // ════════════════════════════════════════════════════════════════
  Future<bool> restockItem(dynamic backendId, int addQty) async {
    final inv = Get.find<InventoryService>();
    try {
      final getRes = await inv.get(backendId);
      if (getRes.success && getRes.data is Map) {
        final existing = Map<String, dynamic>.from(getRes.data as Map);
        final currentQty = (existing['quantity'] as num?)?.toInt() ?? 0;
        existing['quantity'] = currentQty + addQty;
        existing['status'] = 'IN_STOCK';
        final updRes = await inv.update(backendId, existing);
        if (updRes.success) {
          invalidateCache();
          _fetchFromApi();
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  // ════════════════════════════════════════════════════════════════
  // DELETE — mirrors Electron: DELETE /api/jewelry-items/:id
  // ════════════════════════════════════════════════════════════════
  Future<bool> deleteItemViaApi(dynamic backendId, String localId) async {
    try {
      final result = await Get.find<InventoryService>().delete(backendId);
      if (result.success) {
        inventory.removeWhere(
          (i) => i.id == localId || i.backendId == backendId,
        );
        invalidateCache();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ════════════════════════════════════════════════════════════════
  // IMAGE UPLOAD — mirrors Electron images:upload
  // ════════════════════════════════════════════════════════════════
  Future<String?> uploadImage(
    List<int> bytes,
    String fileName,
    String mimeType,
  ) async {
    try {
      final r = await Get.find<ImagesService>().upload(
        bytes,
        fileName,
        mimeType,
      );
      if (r.success && r.data is Map) {
        return (r.data as Map)['imageUrl']?.toString();
      }
    } catch (_) {}
    return null;
  }

  Future<void> deleteImageUrl(String imageUrl) async {
    try {
      await Get.find<ImagesService>().delete(imageUrl);
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════════════
  // CATEGORY + METAL TYPE LISTS (for add/edit forms)
  // ════════════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final r = await Get.find<CategoriesService>().list();
      if (r.success && r.data is List)
        return List<Map<String, dynamic>>.from(r.data as List);
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchMetalTypes() async {
    try {
      final r = await Get.find<MetalTypesService>().list();
      if (r.success && r.data is List)
        return List<Map<String, dynamic>>.from(r.data as List);
    } catch (_) {}
    return [];
  }

  // ════════════════════════════════════════════════════════════════
  // LOCAL HELPERS (unchanged)
  // ════════════════════════════════════════════════════════════════
  List<InventoryItem> get filteredInventory {
    List<InventoryItem> items = inventory.toList();

    final store = _store.selectedStoreName;
    if (store != null) items = items.where((i) => i.store == store).toList();

    final f = selectedFilter.value;
    if (f == 'lowstock') {
      items = items.where((i) => i.status == 'Low Stock').toList();
    } else if (f == 'outofstock') {
      items = items
          .where((i) => i.status == 'Out of Stock' || i.status == 'Sold')
          .toList();
    } else if (f != 'all') {
      items = items
          .where((i) => i.metal.toLowerCase() == f.toLowerCase())
          .toList();
    }

    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      items = items
          .where(
            (i) =>
                i.name.toLowerCase().contains(q) ||
                i.id.toLowerCase().contains(q) ||
                i.huid.toLowerCase().contains(q) ||
                i.barcode.toLowerCase().contains(q) ||
                i.category.toLowerCase().contains(q),
          )
          .toList();
    }
    return items;
  }

  int get totalItems => filteredInventory.length;
  int get inStockCount =>
      filteredInventory.where((i) => i.status == 'In Stock').length;
  int get lowStockCount =>
      filteredInventory.where((i) => i.status == 'Low Stock').length;
  int get soldCount =>
      filteredInventory.where((i) => i.status == 'Sold').length;
  int get stockValue => filteredInventory
      .where((i) => i.status != 'Sold')
      .fold(0, (s, i) => s + i.sellingPrice);

  String get stockValueFormatted {
    final v = stockValue;
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    return '₹$v';
  }

  InventoryItem? getById(String id) {
    try {
      return inventory.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Local CRUD helpers called by screens ──────────────────────
  // Edit screen calls: _ctrl.updateItem(_item.id, updated)
  // This is the local-only version; updateItem() with named params is the API version
  void updateItem(String id, InventoryItem updated) =>
      updateLocalItem(id, updated);

  // Edit screen calls: _ctrl.deleteItem(_item.id) — local only (no backend id available)
  // Falls back to removing from local list only
  void deleteItem(String id) {
    inventory.removeWhere((i) => i.id == id);
    invalidateCache();
  }

  void updateLocalItem(String id, InventoryItem updated) {
    final idx = inventory.indexWhere((i) => i.id == id);
    if (idx != -1) {
      inventory[idx] = updated;
      inventory.refresh();
    }
  }

  void removeLocalItem(String id) => inventory.removeWhere((i) => i.id == id);

  void sellItem(String id) => _changeStatus(id, 'Sold');
  void reserveItem(String id) => _changeStatus(id, 'Reserved');

  void _changeStatus(String id, String status) {
    final idx = inventory.indexWhere((i) => i.id == id);
    if (idx != -1) {
      inventory[idx] = inventory[idx].copyWith(status: status);
      inventory.refresh();
    }
  }

  void transferItem(String id, String newStore) {
    final idx = inventory.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final item = inventory[idx];
    inventory[idx] = item.copyWith(
      store: newStore,
      transferHistory: [
        ...item.transferHistory,
        {
          'from': item.store,
          'to': newStore,
          'date': DateTime.now().toIso8601String().substring(0, 10),
          'by': 'Admin',
        },
      ],
    );
    inventory.refresh();
  }

  // ════════════════════════════════════════════════════════════════
  // DEMO SEED (shown while API loads)
  // ════════════════════════════════════════════════════════════════
  void _seedDemoData() {
    inventory.assignAll([
      InventoryItem(
        id: 'INV001',
        name: '22K Gold Necklace',
        category: 'Necklace',
        metal: 'Gold',
        purity: '22K',
        netWeight: 45.50,
        grossWeight: 48.20,
        stoneWeight: 2.70,
        makingCharge: 12,
        huid: 'HUID78234',
        barcode: 'JE-NK-001',
        status: 'In Stock',
        store: 'Rajmahal Jewellers - Main',
        costPrice: 248000,
        sellingPrice: 285750,
        showcaseLocation: 'Showcase A - Tray 3',
        hallmarkCert: 'HC-2026-78234',
        hallmarkDate: DateTime(2026, 1, 15),
        dateAdded: DateTime(2026, 1, 15),
        description: 'Traditional 22K gold necklace',
        quantity: 3,
      ),
      InventoryItem(
        id: 'INV002',
        name: 'Temple Gold Earrings',
        category: 'Earring',
        metal: 'Gold',
        purity: '22K',
        netWeight: 12.30,
        grossWeight: 13.00,
        stoneWeight: 0.70,
        makingCharge: 14,
        huid: 'HUID45892',
        barcode: 'JE-ER-001',
        status: 'In Stock',
        store: 'Rajmahal Jewellers - Main',
        costPrice: 67500,
        sellingPrice: 78500,
        showcaseLocation: 'Showcase B - Tray 1',
        hallmarkCert: 'HC-2026-45892',
        hallmarkDate: DateTime(2026, 1, 20),
        dateAdded: DateTime(2026, 1, 20),
        description: 'South Indian temple design earrings',
        quantity: 2,
      ),
      InventoryItem(
        id: 'INV003',
        name: 'Platinum Wedding Band',
        category: 'Ring',
        metal: 'Platinum',
        purity: '950 Platinum',
        netWeight: 6.00,
        grossWeight: 6.00,
        stoneWeight: 0,
        makingCharge: 18,
        huid: 'HUID23456',
        barcode: 'JE-RG-001',
        status: 'In Stock',
        store: 'Rajmahal Jewellers - Mall Road',
        costPrice: 118500,
        sellingPrice: 145000,
        showcaseLocation: 'Showcase C - Tray 2',
        hallmarkCert: 'HC-2026-23456',
        hallmarkDate: DateTime(2026, 2, 1),
        dateAdded: DateTime(2026, 2, 1),
        description: 'Classic platinum wedding band',
        quantity: 5,
      ),
      InventoryItem(
        id: 'INV004',
        name: 'Kundan Bridal Set',
        category: 'Set',
        metal: 'Gold',
        purity: '18K',
        netWeight: 85.00,
        grossWeight: 92.00,
        stoneWeight: 7.00,
        makingCharge: 16,
        huid: 'HUID67890',
        barcode: 'JE-ST-001',
        status: 'In Stock',
        store: 'Rajmahal Jewellers - Main',
        costPrice: 420000,
        sellingPrice: 598500,
        showcaseLocation: 'Showcase D - Tray 1',
        hallmarkCert: 'HC-2026-67890',
        hallmarkDate: DateTime(2026, 2, 10),
        dateAdded: DateTime(2025, 12, 1),
        description: 'Bridal kundan set',
        stoneDetails: {
          'type': 'Kundan/Polki',
          'carat': '5.20',
          'cut': 'Uncut',
          'clarity': 'Eye Clean',
          'color': 'White',
          'certification': 'None',
        },
        quantity: 1,
      ),
      InventoryItem(
        id: 'INV005',
        name: 'Silver Anklet Pair',
        category: 'Anklet',
        metal: 'Silver',
        purity: '925 Silver',
        netWeight: 35.00,
        grossWeight: 35.00,
        stoneWeight: 0,
        makingCharge: 10,
        huid: 'HUID34521',
        barcode: 'JE-AK-001',
        status: 'Low Stock',
        store: 'Rajmahal Jewellers - City Center',
        costPrice: 2800,
        sellingPrice: 3800,
        showcaseLocation: 'Showcase E - Tray 4',
        hallmarkCert: 'HC-2026-34521',
        dateAdded: DateTime(2026, 1, 5),
        description: 'Traditional silver anklets',
        quantity: 2,
      ),
      InventoryItem(
        id: 'INV006',
        name: 'Diamond Solitaire Ring',
        category: 'Ring',
        metal: 'Gold',
        purity: '18K',
        netWeight: 3.50,
        grossWeight: 3.80,
        stoneWeight: 0.30,
        makingCharge: 20,
        huid: 'HUID89012',
        barcode: 'JE-RG-002',
        status: 'In Stock',
        store: 'Rajmahal Jewellers - Main',
        costPrice: 185000,
        sellingPrice: 245000,
        showcaseLocation: 'Showcase A - Tray 1',
        hallmarkCert: 'HC-2026-89012',
        hallmarkDate: DateTime(2026, 2, 15),
        dateAdded: DateTime(2026, 2, 15),
        description: '0.5ct diamond solitaire',
        stoneDetails: {
          'type': 'Diamond',
          'carat': '0.50',
          'cut': 'Brilliant Round',
          'clarity': 'VS1',
          'color': 'F',
          'certification': 'GIA',
        },
        quantity: 1,
      ),
      InventoryItem(
        id: 'INV007',
        name: '22K Gold Bangles (pair)',
        category: 'Bangle',
        metal: 'Gold',
        purity: '22K',
        netWeight: 28.00,
        grossWeight: 28.50,
        stoneWeight: 0,
        makingCharge: 12,
        huid: 'HUID56789',
        barcode: 'JE-BG-001',
        status: 'Sold',
        store: 'Rajmahal Jewellers - Mall Road',
        costPrice: 153000,
        sellingPrice: 176400,
        showcaseLocation: '',
        hallmarkCert: 'HC-2026-56789',
        dateAdded: DateTime(2025, 11, 15),
        description: 'Classic plain gold bangles',
        quantity: 0,
      ),
      InventoryItem(
        id: 'INV008',
        name: 'Rose Gold Chain',
        category: 'Chain',
        metal: 'Rose Gold',
        purity: '18K',
        netWeight: 10.00,
        grossWeight: 10.20,
        stoneWeight: 0,
        makingCharge: 13,
        huid: 'HUID11223',
        barcode: 'JE-CH-001',
        status: 'Low Stock',
        store: 'Rajmahal Jewellers - Main',
        costPrice: 52000,
        sellingPrice: 63000,
        showcaseLocation: 'Showcase B - Tray 3',
        hallmarkCert: 'HC-2026-11223',
        dateAdded: DateTime(2026, 3, 1),
        description: '18K rose gold chain',
        quantity: 1,
      ),
    ]);
  }
}
