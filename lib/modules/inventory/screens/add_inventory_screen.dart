import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/inventory_model.dart';
import '../controllers/inventory_controller.dart';

class AddInventoryScreen extends StatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final controller = Get.find<InventoryController>();
  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final netWeight = TextEditingController();
  final grossWeight = TextEditingController();
  final stoneWeight = TextEditingController();
  final costPrice = TextEditingController();
  final sellingPrice = TextEditingController();
  final makingCharge = TextEditingController(text: "12");
  final huid = TextEditingController();
  final barcode = TextEditingController();
  final hallmark = TextEditingController();
  final location = TextEditingController();
  final description = TextEditingController();

  final stoneCarat = TextEditingController();
  final stoneColor = TextEditingController();

  String category = "Ring";
  String metal = "Gold";
  String purity = "22K";

  String stoneType = "";
  String stoneCut = "";
  String stoneClarity = "";
  String stoneCertification = "";

  DateTime? hallmarkDate;

  double fieldWidth(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    if (w > 900) return (w / 3) - 40;
    if (w > 600) return (w / 2) - 32;
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: const Text(
          "Add Jewelry Item",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: formKey,

          child: Column(
            children: [
              formCard("Item Information", Icons.inventory_2_outlined, [
                field(textField(name, "Item Name", Icons.label)),
                field(categoryDropdown()),
                field(metalDropdown()),
                field(purityDropdown()),
              ]),

              formCard("Weight Details", Icons.scale, [
                field(numberField(netWeight, "Net Weight", "g")),
                field(numberField(grossWeight, "Gross Weight", "g")),
                field(numberField(stoneWeight, "Stone Weight", "g")),
              ]),

              formCard("Pricing", Icons.currency_rupee, [
                field(numberField(costPrice, "Cost Price", "₹")),
                field(numberField(sellingPrice, "Selling Price", "₹")),
                field(numberField(makingCharge, "Making Charge", "%")),
              ]),

              formCard("Identification", Icons.qr_code, [
                field(textField(huid, "HUID Number", Icons.tag)),
                field(textField(barcode, "Barcode", Icons.qr_code)),
                field(
                  textField(hallmark, "Hallmark Certificate", Icons.verified),
                ),
                field(textField(location, "Showcase Location", Icons.store)),
                field(dateField()),
              ]),

              formCard("Stone Details (Optional)", Icons.diamond, [
                field(stoneTypeDropdown()),
                field(numberField(stoneCarat, "Stone Carat", "ct")),
                field(stoneCutDropdown()),
                field(stoneClarityDropdown()),
                field(textField(stoneColor, "Stone Color", Icons.palette)),
                field(stoneCertDropdown()),
              ]),

              formCard("Description", Icons.notes, [
                field(textField(description, "Notes", Icons.notes, lines: 3)),
              ]),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      bottomNavigationBar: bottomButtons(),
    );
  }

  /// FORM CARD

  Widget formCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.goldPrimary, size: 20),

              const SizedBox(width: 8),

              Text(
                title,
                style: const TextStyle(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Wrap(spacing: 12, runSpacing: 12, children: children),
        ],
      ),
    );
  }

  /// FIELD WRAPPER

  Widget field(Widget child) {
    return SizedBox(width: fieldWidth(context), child: child);
  }

  /// TEXT FIELD

  Widget textField(
    TextEditingController c,
    String label,
    IconData icon, {
    int lines = 1,
  }) {
    return TextFormField(
      controller: c,
      maxLines: lines,
      style: const TextStyle(color: AppColors.textPrimary),

      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: AppColors.goldPrimary),

        filled: true,
        fillColor: AppColors.inputFill,

        hintStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// NUMBER FIELD

  Widget numberField(TextEditingController c, String label, String suffix) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),

      decoration: InputDecoration(
        hintText: label,
        suffixText: suffix,
        filled: true,
        fillColor: AppColors.inputFill,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// DROPDOWNS

  Widget categoryDropdown() => dropdown("Category", category, [
    "Necklace",
    "Ring",
    "Earring",
    "Bracelet",
    "Anklet",
    "Bangle",
    "Chain",
    "Pendant",
    "Set",
    "Mangalsutra",
    "Nose Ring",
    "Toe Ring",
    "Other",
  ], (v) => setState(() => category = v!));

  Widget metalDropdown() => dropdown("Metal", metal, [
    "Gold",
    "Silver",
    "Platinum",
    "Diamond",
    "Rose Gold",
    "White Gold",
  ], (v) => setState(() => metal = v!));

  Widget purityDropdown() => dropdown("Purity", purity, [
    "24K",
    "22K",
    "18K",
    "14K",
    "925 Silver",
    "950 Platinum",
  ], (v) => setState(() => purity = v!));

  Widget stoneTypeDropdown() => dropdown("Stone Type", stoneType, [
    "",
    "Diamond",
    "Ruby",
    "Emerald",
    "Sapphire",
    "Pearl",
  ], (v) => setState(() => stoneType = v!));

  Widget stoneCutDropdown() => dropdown("Stone Cut", stoneCut, [
    "",
    "Brilliant",
    "Princess",
    "Oval",
    "Cushion",
  ], (v) => setState(() => stoneCut = v!));

  Widget stoneClarityDropdown() => dropdown("Stone Clarity", stoneClarity, [
    "",
    "FL",
    "IF",
    "VVS1",
    "VVS2",
    "VS1",
    "VS2",
    "SI",
  ], (v) => setState(() => stoneClarity = v!));

  Widget stoneCertDropdown() => dropdown(
    "Certification",
    stoneCertification,
    ["", "GIA", "IGI", "AGS", "HRD"],
    (v) => setState(() => stoneCertification = v!),
  );

  Widget dropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,

      dropdownColor: Colors.white,
      iconEnabledColor: Colors.white,

      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      /// Selected value style
      selectedItemBuilder: (context) {
        return items.map((item) {
          return Text(
            item.isEmpty ? "Select $label" : item,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          );
        }).toList();
      },

      items: items.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(
            e.isEmpty ? "Select $label" : e,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }

  /// DATE FIELD

  Widget dateField() {
    return TextFormField(
      readOnly: true,
      style: const TextStyle(color: AppColors.textPrimary),

      decoration: InputDecoration(
        hintText: hallmarkDate == null
            ? "Hallmark Date"
            : "${hallmarkDate!.day}-${hallmarkDate!.month}-${hallmarkDate!.year}",

        prefixIcon: const Icon(
          Icons.calendar_today,
          color: AppColors.goldPrimary,
        ),

        filled: true,
        fillColor: AppColors.inputFill,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      onTap: () async {
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDate: DateTime.now(),
        );

        if (d != null) {
          setState(() => hallmarkDate = d);
        }
      },
    );
  }

  /// BOTTOM BUTTONS

  Widget bottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),

      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel"),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                saveItem();
                if (name.text.isEmpty) {
                  Get.snackbar("Error", "Item name required");
                  return;
                }
              },
              child: const Text("Save Item"),
            ),
          ),
        ],
      ),
    );
  }

  /// SAVE

  void saveItem() {
    controller.addItem(
      InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.text,
        category: category,
        metal: metal,
        purity: purity,
        netWeight: double.tryParse(netWeight.text) ?? 0,
        grossWeight: double.tryParse(grossWeight.text) ?? 0,
        stoneWeight: double.tryParse(stoneWeight.text) ?? 0,
        makingCharge: double.tryParse(makingCharge.text) ?? 0,
        huid: huid.text,
        barcode: barcode.text,
        status: "In Stock",
        store: controller.storeController.selectedStore.value ?? "Main Store",
        costPrice: int.tryParse(costPrice.text) ?? 0,
        sellingPrice: int.tryParse(sellingPrice.text) ?? 0,
        showcaseLocation: location.text,
        hallmarkCert: hallmark.text,
        hallmarkDate: hallmarkDate,
        dateAdded: DateTime.now(),
        description: description.text,
      ),
    );

    Get.back();
  }
}
