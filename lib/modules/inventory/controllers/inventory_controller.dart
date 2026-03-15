import 'package:get/get.dart';
import '../../../models/inventory_model.dart';
import '../../../core/controllers/store_controller.dart';

class InventoryController extends GetxController {
  final storeController = Get.find<StoreController>();

  var inventory = <InventoryItem>[].obs;

  var searchQuery = "".obs;
  var selectedFilter = "all".obs;

  @override
  void onInit() {
    super.onInit();
    seedDummyData();
  }

  void seedDummyData() {
    inventory.addAll([
      InventoryItem(
        id: "INV001",
        name: "Diamond Ring",
        category: "Ring",
        metal: "Gold",
        purity: "22K",
        netWeight: 4.2,
        grossWeight: 4.5,
        stoneWeight: 0.3,
        makingCharge: 12,
        huid: "HUID001",
        barcode: "BR001",
        status: "In Stock",
        store: "Main Store",
        costPrice: 35000,
        sellingPrice: 42000,
        showcaseLocation: "Tray A1",
        hallmarkCert: "HC001",
        hallmarkDate: DateTime.now(),
        dateAdded: DateTime.now(),
        description: "22K Diamond Ring",
      ),

      InventoryItem(
        id: "INV002",
        name: "Gold Necklace",
        category: "Necklace",
        metal: "Gold",
        purity: "22K",
        netWeight: 20,
        grossWeight: 20.5,
        stoneWeight: 0.5,
        makingCharge: 10,
        huid: "HUID002",
        barcode: "BR002",
        status: "Low Stock",
        store: "Main Store",
        costPrice: 90000,
        sellingPrice: 110000,
        showcaseLocation: "Tray B2",
        hallmarkCert: "HC002",
        hallmarkDate: DateTime.now(),
        dateAdded: DateTime.now(),
        description: "Heavy Gold Necklace",
      ),

      InventoryItem(
        id: "INV003",
        name: "Silver Bracelet",
        category: "Bracelet",
        metal: "Silver",
        purity: "925 Silver",
        netWeight: 15,
        grossWeight: 15,
        stoneWeight: 0,
        makingCharge: 8,
        huid: "HUID003",
        barcode: "BR003",
        status: "In Stock",
        store: "Gold Palace",
        costPrice: 3000,
        sellingPrice: 4500,
        showcaseLocation: "Tray C3",
        hallmarkCert: "HC003",
        hallmarkDate: DateTime.now(),
        dateAdded: DateTime.now(),
        description: "Silver Bracelet",
      ),

      InventoryItem(
        id: "INV004",
        name: "Platinum Ring",
        category: "Ring",
        metal: "Platinum",
        purity: "950 Platinum",
        netWeight: 6,
        grossWeight: 6,
        stoneWeight: 0,
        makingCharge: 15,
        huid: "HUID004",
        barcode: "BR004",
        status: "In Stock",
        store: "City Branch",
        costPrice: 45000,
        sellingPrice: 60000,
        showcaseLocation: "Tray D1",
        hallmarkCert: "HC004",
        hallmarkDate: DateTime.now(),
        dateAdded: DateTime.now(),
        description: "Platinum Ring",
      ),
    ]);
  }

  List<InventoryItem> get filteredInventory {
    List<InventoryItem> items = inventory.toList();

    /// STORE FILTER
    final store = storeController.selectedStore.value;

    if (store != null) {
      items = items.where((i) => i.store == store).toList();
    }

    /// SEARCH
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();

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

    /// FILTER
    if (selectedFilter.value == "lowstock") {
      items = items.where((i) => i.status == "Low Stock").toList();
    } else if (selectedFilter.value != "all") {
      items = items
          .where((i) => i.metal.toLowerCase() == selectedFilter.value)
          .toList();
    }

    return items;
  }

  void sellItem(String id) {
    final index = inventory.indexWhere((i) => i.id == id);

    if (index == -1) return;

    final item = inventory[index];

    final updated = item.copyWith(status: "Sold");

    inventory[index] = updated;
    inventory.refresh();
  }

  void reserveItem(String id) {
    final index = inventory.indexWhere((i) => i.id == id);

    if (index == -1) return;

    final item = inventory[index];

    final updated = item.copyWith(status: "Reserved");

    inventory[index] = updated;
    inventory.refresh();
  }

  /// STATS

  int get totalItems => filteredInventory.length;

  int get inStock =>
      filteredInventory.where((i) => i.stockStatus == "In Stock").length;

  int get soldItems =>
      filteredInventory.where((i) => i.stockStatus == "Sold").length;

  int get lowStock =>
      filteredInventory.where((i) => i.status == "Low Stock").length;

  int get totalValue =>
      filteredInventory.fold(0, (sum, i) => sum + i.sellingPrice);

  double get totalWeight =>
      filteredInventory.fold(0, (sum, i) => sum + i.netWeight);
      

  /// CRUD

  void addItem(InventoryItem item) {
    inventory.add(item);
  }

  void updateItem(String id, InventoryItem updated) {
    final index = inventory.indexWhere((e) => e.id == id);

    if (index != -1) {
      inventory[index] = updated;
      inventory.refresh();
    }
  }

  void deleteItem(String id) {
    inventory.removeWhere((i) => i.id == id);
  }

  /// TRANSFER ITEM

  void transferItem(String id, String newStore) {
    final index = inventory.indexWhere((i) => i.id == id);

    if (index == -1) return;

    final item = inventory[index];

    final updated = item.copyWith(
      store: newStore,
      transferHistory: [
        ...item.transferHistory,
        {
          "from": item.store,
          "to": newStore,
          "date": DateTime.now().toString(),
          "by": "Admin",
        },
      ],
    );

    inventory[index] = updated;
    inventory.refresh();
  }

  void exportCSV() {
    String csv = "Name,Category,Metal,Purity,Weight,Price\n";

    for (var item in inventory) {
      csv +=
          "${item.name},${item.category},${item.metal},${item.purity},${item.netWeight},${item.sellingPrice}\n";
    }

    print(csv);
  }
}
