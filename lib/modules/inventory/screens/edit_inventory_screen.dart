import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/inventory_model.dart';
import '../controllers/inventory_controller.dart';

class EditInventoryScreen extends StatefulWidget {
  const EditInventoryScreen({super.key});

  @override
  State<EditInventoryScreen> createState() => _EditInventoryScreenState();
}

class _EditInventoryScreenState extends State<EditInventoryScreen> {

  final controller = Get.find<InventoryController>();
  final formKey = GlobalKey<FormState>();

  late InventoryItem item;

  late TextEditingController name;
  late TextEditingController netWeight;
  late TextEditingController grossWeight;
  late TextEditingController stoneWeight;
  late TextEditingController costPrice;
  late TextEditingController sellingPrice;
  late TextEditingController makingCharge;
  late TextEditingController location;
  late TextEditingController description;

  String category = "";
  String metal = "";
  String purity = "";
  String status = "In Stock";

  @override
  void initState() {
    super.initState();

    item = Get.arguments;

    name = TextEditingController(text: item.name);
    netWeight = TextEditingController(text: item.netWeight.toString());
    grossWeight = TextEditingController(text: item.grossWeight.toString());
    stoneWeight = TextEditingController(text: item.stoneWeight.toString());
    costPrice = TextEditingController(text: item.costPrice.toString());
    sellingPrice = TextEditingController(text: item.sellingPrice.toString());
    makingCharge = TextEditingController(text: item.makingCharge.toString());
    location = TextEditingController(text: item.showcaseLocation ?? "");
    description = TextEditingController(text: item.description ?? "");

    category = item.category;
    metal = item.metal;
    purity = item.purity;
    status = item.status;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: Text(
          "Edit ${item.name}",
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: formKey,

          child: Column(
            children: [

              /// ITEM INFO
              formCard("Item Information", Icons.inventory_2_outlined, [

                field(textField(name,"Item Name",Icons.label)),

                field(dropdown(
                    "Category",
                    category,
                    ["Necklace","Ring","Earring","Bracelet","Anklet","Bangle","Chain","Pendant","Set","Mangalsutra","Nose Ring","Toe Ring","Other"],
                        (v)=>setState(()=>category=v!)
                )),

                field(dropdown(
                    "Metal",
                    metal,
                    ["Gold","Silver","Platinum","Diamond","Rose Gold","White Gold"],
                        (v)=>setState(()=>metal=v!)
                )),

                field(dropdown(
                    "Purity",
                    purity,
                    ["24K","22K","18K","14K","925 Silver","950 Platinum"],
                        (v)=>setState(()=>purity=v!)
                )),

              ]),

              /// WEIGHT
              formCard("Weight Details", Icons.scale, [

                field(numberField(netWeight,"Net Weight","g")),
                field(numberField(grossWeight,"Gross Weight","g")),
                field(numberField(stoneWeight,"Stone Weight","g")),

              ]),

              /// PRICING
              formCard("Pricing", Icons.currency_rupee, [

                field(numberField(costPrice,"Cost Price","₹")),
                field(numberField(sellingPrice,"Selling Price","₹")),
                field(numberField(makingCharge,"Making %","%")),

              ]),

              /// IDENTIFICATION
              formCard("Identification", Icons.qr_code, [

                field(textField(location,"Showcase Location",Icons.store)),

                field(dropdown(
                    "Status",
                    status,
                    ["In Stock","Low Stock","Sold","Reserved"],
                        (v)=>setState(()=>status=v!)
                )),

              ]),

              /// DESCRIPTION
              formCard("Description", Icons.notes, [
                field(textField(description,"Notes",Icons.notes,lines:3)),
              ]),

              const SizedBox(height:40),

              /// BUTTONS

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: ()=>Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),

                  const SizedBox(width:10),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        foregroundColor: Colors.black,
                      ),

                      onPressed: updateItem,

                      child: const Text("Save Changes"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height:10),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),

                  onPressed: deleteItem,

                  child: const Text("Delete Item"),
                ),
              ),

              const SizedBox(height:60),
            ],
          ),
        ),
      ),
    );
  }

  /// UPDATE ITEM

  void updateItem(){

    final updated = item.copyWith(
      name: name.text,
      category: category,
      metal: metal,
      purity: purity,
      netWeight: double.tryParse(netWeight.text) ?? 0,
      grossWeight: double.tryParse(grossWeight.text) ?? 0,
      stoneWeight: double.tryParse(stoneWeight.text) ?? 0,
      costPrice: int.tryParse(costPrice.text) ?? 0,
      sellingPrice: int.tryParse(sellingPrice.text) ?? 0,
      makingCharge: double.tryParse(makingCharge.text) ?? 0,
      showcaseLocation: location.text,
      status: status,
      description: description.text,
    );

    controller.updateItem(item.id, updated);

    Get.back();
  }

  /// DELETE ITEM

  void deleteItem(){

    Get.defaultDialog(
      title: "Delete Item",
      middleText: "Are you sure you want to delete this item?",
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: (){
          controller.deleteItem(item.id);
          Get.back();
          Get.back();
        },
        child: const Text("Delete"),
      ),
      cancel: TextButton(
        onPressed: ()=>Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }

  /// CARD

  Widget formCard(String title,IconData icon,List<Widget> children){

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom:20),
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

              Icon(icon,color: AppColors.goldPrimary,size:20),

              const SizedBox(width:8),

              Text(
                title,
                style: const TextStyle(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height:16),

          Wrap(
            spacing:12,
            runSpacing:12,
            children: children,
          ),
        ],
      ),
    );
  }

  /// FIELD WRAPPER

  Widget field(Widget child){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: child,
    );
  }

  /// TEXTFIELD

  Widget textField(TextEditingController c,String label,IconData icon,{int lines=1}){

    return TextFormField(
      controller: c,
      maxLines: lines,
      style: const TextStyle(color: AppColors.textPrimary),

      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon,color: AppColors.goldPrimary),
        filled: true,
        fillColor: AppColors.inputFill,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// NUMBER FIELD

  Widget numberField(TextEditingController c,String label,String suffix){

    return TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),

      decoration: InputDecoration(
        hintText: label,
        suffixText: suffix,
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// DROPDOWN

  Widget dropdown(String label,String value,List<String> items,Function(String?) onChanged){

    return DropdownButtonFormField<String>(

      value: value.isEmpty ? null : value,

      dropdownColor: Colors.white,
      iconEnabledColor: Colors.white,

      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      selectedItemBuilder: (context){
        return items.map((e){
          return Text(e,style: const TextStyle(color: Colors.white));
        }).toList();
      },

      items: items.map((e)=>DropdownMenuItem(
        value: e,
        child: Text(e,style: const TextStyle(color: Colors.black)),
      )).toList(),

      onChanged: onChanged,
    );
  }
}