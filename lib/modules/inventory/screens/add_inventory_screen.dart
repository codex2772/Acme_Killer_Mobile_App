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
  final _ctrl     = Get.find<InventoryController>();
  final _formKey  = GlobalKey<FormState>();

  final _name         = TextEditingController();
  final _netWeight    = TextEditingController();
  final _grossWeight  = TextEditingController();
  final _stoneWeight  = TextEditingController(text: '0');
  final _costPrice    = TextEditingController();
  final _sellingPrice = TextEditingController();
  final _makingCharge = TextEditingController(text: '12');
  final _huid         = TextEditingController();
  final _barcode      = TextEditingController();
  final _hallmarkCert = TextEditingController();
  final _location     = TextEditingController();
  final _description  = TextEditingController();
  final _stoneCarat   = TextEditingController();
  final _stoneColor   = TextEditingController();

  String _category  = 'Necklace';
  String _metal     = 'Gold';
  String _purity    = '22K';
  String _stoneType = '';
  String _stoneCut  = '';
  String _stoneClarity = '';
  String _stoneCert    = '';
  DateTime? _hallmarkDate;

  static const _categories = ['Necklace','Ring','Earring','Bracelet','Anklet','Bangle','Chain','Pendant','Set','Mangalsutra','Nose Ring','Toe Ring','Other'];
  static const _metals     = ['Gold','Silver','Platinum','Diamond','Rose Gold','White Gold','Other'];
  static const _purities   = ['24K','22K','18K','14K','925 Silver','950 Platinum'];
  static const _stoneTypes = ['','Diamond','Ruby','Emerald','Sapphire','Kundan/Polki','Pearl','Other'];
  static const _stoneCuts  = ['','Brilliant Round','Princess','Oval','Cushion','Pear','Marquise','Cabochon','Uncut'];
  static const _clarities  = ['','FL','IF','VVS1','VVS2','VS1','VS2','SI','Eye Clean'];
  static const _certs      = ['None','GIA','IGI','AGS','HRD','Other'];

  @override
  void dispose() {
    for (final c in [_name,_netWeight,_grossWeight,_stoneWeight,_costPrice,
        _sellingPrice,_makingCharge,_huid,_barcode,_hallmarkCert,_location,
        _description,_stoneCarat,_stoneColor]) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final newId = 'INV${(_ctrl.inventory.length + 1).toString().padLeft(3,'0')}';
    final item = InventoryItem(
      id: newId,
      name:             _name.text.trim(),
      category:         _category,
      metal:            _metal,
      purity:           _purity,
      netWeight:        double.tryParse(_netWeight.text) ?? 0,
      grossWeight:      double.tryParse(_grossWeight.text) ?? 0,
      stoneWeight:      double.tryParse(_stoneWeight.text) ?? 0,
      makingCharge:     double.tryParse(_makingCharge.text) ?? 12,
      huid:             _huid.text.trim(),
      barcode:          _barcode.text.trim().isEmpty ? 'JE-$newId' : _barcode.text.trim(),
      status:           'In Stock',
      store:            'Rajmahal Jewellers - Main',
      costPrice:        int.tryParse(_costPrice.text) ?? 0,
      sellingPrice:     int.tryParse(_sellingPrice.text) ?? 0,
      showcaseLocation: _location.text.trim(),
      hallmarkCert:     _hallmarkCert.text.trim(),
      hallmarkDate:     _hallmarkDate,
      dateAdded:        DateTime.now(),
      description:      _description.text.trim(),
      stoneDetails: _stoneType.isEmpty ? null : {
        'type': _stoneType, 'carat': _stoneCarat.text,
        'cut': _stoneCut, 'clarity': _stoneClarity,
        'color': _stoneColor.text, 'certification': _stoneCert,
      },
    );
    _ctrl.addItem(item);
    Get.back();
    Get.snackbar('Item Added', '"${item.name}" added to inventory!',
        backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text('Add Jewelry Item',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Item Information', Icons.inventory_2_outlined),
            _field(_name, 'Item Name *', validator: _req),
            _row2(_dropdown('Category', _categories, _category, (v) => setState(() => _category = v!)),
                  _dropdown('Metal Type', _metals, _metal, (v) => setState(() => _metal = v!))),
            _dropdown('Purity', _purities, _purity, (v) => setState(() => _purity = v!)),

            const SizedBox(height: 8),
            _section('Weight Details', Icons.scale_outlined),
            _row3(
              _numField(_netWeight,    'Net Weight (g) *', validator: _req),
              _numField(_grossWeight,  'Gross Weight (g) *', validator: _req),
              _numField(_stoneWeight,  'Stone Weight (g)'),
            ),

            const SizedBox(height: 8),
            _section('Pricing', Icons.currency_rupee),
            _row3(
              _numField(_costPrice,    'Cost Price (₹) *', validator: _req),
              _numField(_sellingPrice, 'Selling Price (₹) *', validator: _req),
              _numField(_makingCharge, 'Making %'),
            ),

            const SizedBox(height: 8),
            _section('Identification', Icons.tag_outlined),
            _row3(
              _field(_huid,        'HUID *', validator: _req),
              _field(_barcode,     'Barcode'),
              _field(_hallmarkCert,'Hallmark Cert'),
            ),
            _row2(
              _field(_location, 'Showcase Location'),
              _datePicker(),
            ),

            const SizedBox(height: 8),
            _section('Stone Details (Optional)', Icons.diamond_outlined),
            _row3(
              _dropdown('Stone Type', _stoneTypes, _stoneType, (v) => setState(() => _stoneType = v!)),
              _numField(_stoneCarat, 'Carat'),
              _dropdown('Cut', _stoneCuts, _stoneCut, (v) => setState(() => _stoneCut = v!)),
            ),
            _row3(
              _dropdown('Clarity', _clarities, _stoneClarity, (v) => setState(() => _stoneClarity = v!)),
              _field(_stoneColor, 'Color (e.g. D, E-F)'),
              _dropdown('Certification', _certs, _stoneCert.isEmpty ? 'None' : _stoneCert,
                  (v) => setState(() => _stoneCert = v == 'None' ? '' : v!)),
            ),

            const SizedBox(height: 8),
            _section('Notes', Icons.notes_outlined),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextFormField(
                controller: _description,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Any additional notes...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check, size: 18, color: Colors.black),
                  label: const Text('Save Item',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // ─── Helpers ───
  Widget _section(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, color: AppColors.goldPrimary, size: 15),
      const SizedBox(width: 7),
      Text(title, style: const TextStyle(
          color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );

  Widget _inputDeco(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12,
          fontWeight: FontWeight.w500)),
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
      _inputDeco(label, TextFormField(
        controller: ctrl,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
      ));

  Widget _numField(TextEditingController ctrl, String label,
      {String? Function(String?)? validator}) =>
      _inputDeco(label, TextFormField(
        controller: ctrl,
        validator: validator,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
      ));

  Widget _dropdown(String label, List<String> items, String val,
      ValueChanged<String?> onChanged) =>
      _inputDeco(label, DropdownButtonFormField<String>(
        value: val,
        dropdownColor: AppColors.bgSecondary,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: const InputDecoration(border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
        items: items.map((i) => DropdownMenuItem(value: i,
            child: Text(i, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
        onChanged: onChanged,
      ));

  Widget _datePicker() => _inputDeco('Hallmark Date',
      GestureDetector(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (c, w) => Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(primary: AppColors.goldPrimary),
              ),
              child: w!,
            ),
          );
          if (d != null) setState(() => _hallmarkDate = d);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.textMuted, size: 16),
            const SizedBox(width: 8),
            Text(
              _hallmarkDate == null
                  ? 'Select date'
                  : '${_hallmarkDate!.day}/${_hallmarkDate!.month}/${_hallmarkDate!.year}',
              style: TextStyle(
                  color: _hallmarkDate == null
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                  fontSize: 14),
            ),
          ]),
        ),
      ));

  Widget _row2(Widget a, Widget b) => Row(
    children: [
      Expanded(child: Padding(padding: const EdgeInsets.only(right: 6), child: a)),
      Expanded(child: Padding(padding: const EdgeInsets.only(left: 6), child: b)),
    ],
  );

  Widget _row3(Widget a, Widget b, Widget c) => Row(
    children: [
      Expanded(child: Padding(padding: const EdgeInsets.only(right: 4), child: a)),
      Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: b)),
      Expanded(child: Padding(padding: const EdgeInsets.only(left: 4), child: c)),
    ],
  );

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}
