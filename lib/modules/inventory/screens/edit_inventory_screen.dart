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
  final _ctrl    = Get.find<InventoryController>();
  final _formKey = GlobalKey<FormState>();
  late InventoryItem _item;

  late TextEditingController _name, _netWeight, _grossWeight, _stoneWeight,
      _costPrice, _sellingPrice, _makingCharge, _location, _description;

  String _category = '', _metal = '', _purity = '', _status = 'In Stock';

  static const _categories = ['Necklace','Ring','Earring','Bracelet','Anklet','Bangle','Chain','Pendant','Set','Mangalsutra','Nose Ring','Toe Ring','Other'];
  static const _metals     = ['Gold','Silver','Platinum','Diamond','Rose Gold','White Gold','Other'];
  static const _purities   = ['24K','22K','18K','14K','925 Silver','950 Platinum'];
  static const _statuses   = ['In Stock','Low Stock','Sold','Reserved'];

  @override
  void initState() {
    super.initState();
    _item         = Get.arguments as InventoryItem;
    _name         = TextEditingController(text: _item.name);
    _netWeight    = TextEditingController(text: _item.netWeight.toString());
    _grossWeight  = TextEditingController(text: _item.grossWeight.toString());
    _stoneWeight  = TextEditingController(text: _item.stoneWeight.toString());
    _costPrice    = TextEditingController(text: _item.costPrice.toString());
    _sellingPrice = TextEditingController(text: _item.sellingPrice.toString());
    _makingCharge = TextEditingController(text: _item.makingCharge.toString());
    _location     = TextEditingController(text: _item.showcaseLocation);
    _description  = TextEditingController(text: _item.description);
    _category     = _item.category;
    _metal        = _item.metal;
    _purity       = _item.purity;
    _status       = _item.status;
  }

  @override
  void dispose() {
    for (final c in [_name,_netWeight,_grossWeight,_stoneWeight,_costPrice,
        _sellingPrice,_makingCharge,_location,_description]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = _item.copyWith(
      name:             _name.text.trim(),
      category:         _category,
      metal:            _metal,
      purity:           _purity,
      netWeight:        double.tryParse(_netWeight.text) ?? _item.netWeight,
      grossWeight:      double.tryParse(_grossWeight.text) ?? _item.grossWeight,
      stoneWeight:      double.tryParse(_stoneWeight.text) ?? _item.stoneWeight,
      makingCharge:     double.tryParse(_makingCharge.text) ?? _item.makingCharge,
      costPrice:        int.tryParse(_costPrice.text) ?? _item.costPrice,
      sellingPrice:     int.tryParse(_sellingPrice.text) ?? _item.sellingPrice,
      showcaseLocation: _location.text.trim(),
      description:      _description.text.trim(),
      status:           _status,
    );

    // ── Always update local state ──
    _ctrl.updateItem(_item.id, updated);

    // ── Try API update — mirrors Electron renderEditInventory submit ──
    if (_item.backendId != null) {
      const statusMap = {
        'In Stock':    'IN_STOCK',
        'Low Stock':   'ON_APPROVAL',
        'Sold':        'SOLD',
        'Reserved':    'ON_APPROVAL',
        'Out of Stock':'OUT_OF_STOCK',
      };
      _ctrl.updateItemViaApi(
        backendId: _item.backendId,
        changes: {
          'name':          updated.name,
          'description':   updated.description,
          'grossWeight':   updated.grossWeight,
          'netWeight':     updated.netWeight,
          'makingCharges': updated.makingCharge,
          'status':        statusMap[updated.status] ?? 'IN_STOCK',
        },
      );
    }

    Get.back();
    Get.snackbar('Updated', '"${updated.name}" saved!',
        backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
  }

  void _delete() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('Delete Item',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "${_item.name}"? This cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              _ctrl.deleteItem(_item.id);
              Get.until((r) => r.settings.name == '/inventory');
              Get.snackbar('Deleted', '"${_item.name}" removed',
                  backgroundColor: AppColors.bgCard,
                  colorText: AppColors.textPrimary,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(12));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text('Edit ${_item.name}',
            style: const TextStyle(color: AppColors.textPrimary,
                fontWeight: FontWeight.w600, fontSize: 15),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _delete,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Basic Information', Icons.inventory_2_outlined),
            _field(_name, 'Item Name *', validator: _req),
            _row2(
              _dropdown('Category', _categories, _category,
                  (v) => setState(() => _category = v!)),
              _dropdown('Metal Type', _metals, _metal,
                  (v) => setState(() => _metal = v!)),
            ),
            _row2(
              _dropdown('Purity', _purities, _purity,
                  (v) => setState(() => _purity = v!)),
              _dropdown('Status', _statuses, _status,
                  (v) => setState(() => _status = v!)),
            ),

            const SizedBox(height: 6),
            _section('Weight Details', Icons.scale_outlined),
            _row3(
              _numField(_netWeight,   'Net Weight (g)'),
              _numField(_grossWeight, 'Gross Weight (g)'),
              _numField(_stoneWeight, 'Stone Weight (g)'),
            ),

            const SizedBox(height: 6),
            _section('Pricing', Icons.currency_rupee),
            _row3(
              _numField(_costPrice,    'Cost Price (₹)'),
              _numField(_sellingPrice, 'Selling Price (₹)'),
              _numField(_makingCharge, 'Making %'),
            ),

            const SizedBox(height: 6),
            _section('Location & Notes', Icons.location_on_outlined),
            _field(_location,    'Showcase Location'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextFormField(
                controller: _description,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Description / notes...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check, size: 18, color: Colors.black),
                  label: const Text('Save Changes',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── Shared helpers ───
  Widget _section(String t, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, color: AppColors.goldPrimary, size: 15),
      const SizedBox(width: 7),
      Text(t, style: const TextStyle(color: AppColors.textPrimary,
          fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );

  Widget _wrap(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(
          color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
      const SizedBox(height: 10),
    ],
  );

  Widget _field(TextEditingController ctrl, String label,
      {String? Function(String?)? validator}) =>
      _wrap(label, TextFormField(
        controller: ctrl, validator: validator,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: const InputDecoration(border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
      ));

  Widget _numField(TextEditingController ctrl, String label) =>
      _wrap(label, TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: const InputDecoration(border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
      ));

  Widget _dropdown(String label, List<String> items, String val,
      ValueChanged<String?> onChanged) =>
      _wrap(label, DropdownButtonFormField<String>(
        value: val, dropdownColor: AppColors.bgSecondary,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: const InputDecoration(border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
        items: items.map((i) => DropdownMenuItem(value: i,
            child: Text(i, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
        onChanged: onChanged,
      ));

  Widget _row2(Widget a, Widget b) => Row(children: [
    Expanded(child: Padding(padding: const EdgeInsets.only(right: 6), child: a)),
    Expanded(child: Padding(padding: const EdgeInsets.only(left: 6), child: b)),
  ]);

  Widget _row3(Widget a, Widget b, Widget c) => Row(children: [
    Expanded(child: Padding(padding: const EdgeInsets.only(right: 4), child: a)),
    Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: b)),
    Expanded(child: Padding(padding: const EdgeInsets.only(left: 4), child: c)),
  ]);

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}