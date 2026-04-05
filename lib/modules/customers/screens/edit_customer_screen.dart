import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../controllers/customer_controller.dart';

class EditCustomerScreen extends StatefulWidget {
  const EditCustomerScreen({super.key});
  @override State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = Get.find<CustomerController>();
  late Customer _customer;

  late TextEditingController _name, _phone, _email, _whatsapp,
      _address, _city, _state, _pincode, _pan, _aadhaar, _gst;

  String _type = 'Regular';
  DateTime? _dob;
  DateTime? _anniversary;

  @override
  void initState() {
    super.initState();
    _customer = Get.arguments as Customer;
    _name     = TextEditingController(text: _customer.name);
    _phone    = TextEditingController(text: _customer.phone);
    _email    = TextEditingController(text: _customer.email);
    _whatsapp = TextEditingController(text: _customer.whatsapp);
    _address  = TextEditingController(text: _customer.address);
    _city     = TextEditingController(text: _customer.city);
    _state    = TextEditingController(text: _customer.state);
    _pincode  = TextEditingController(text: _customer.pincode);
    _pan      = TextEditingController(text: _customer.pan);
    _aadhaar  = TextEditingController(text: _customer.aadhaar);
    _gst      = TextEditingController(text: _customer.gstNumber);
    _type     = _customer.type;
    _dob      = _customer.dob;
    _anniversary = _customer.anniversary;
  }

  @override
  void dispose() {
    for (final c in [_name,_phone,_email,_whatsapp,_address,_city,_state,_pincode,_pan,_aadhaar,_gst]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = _customer.copyWith(
      name: _name.text.trim(), phone: _phone.text.trim(),
      email: _email.text.trim(), whatsapp: _whatsapp.text.trim().isEmpty ? _phone.text.trim() : _whatsapp.text.trim(),
      type: _type, dob: _dob, anniversary: _anniversary,
      address: _address.text.trim(), city: _city.text.trim(),
      state: _state.text.trim(), pincode: _pincode.text.trim(),
      pan: _pan.text.trim(), aadhaar: _aadhaar.text.trim(), gstNumber: _gst.text.trim(),
    );

    // Always update local state first
    _ctrl.updateCustomer(updated);

    // mirrors Electron: try API update — PUT /api/customers/:id
    if (_customer.backendId != null) {
      final nameParts = updated.name.split(' ');
      _ctrl.updateViaApi(_customer.backendId, {
        'firstName':   nameParts[0],
        'lastName':    nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
        'phone':       updated.phone.replaceAll(RegExp(r'[\s+\-]'), ''),
        'email':       updated.email.isEmpty ? null : updated.email,
        'addressLine1': updated.address.isEmpty ? null : updated.address,
        'city':        updated.city.isEmpty ? null : updated.city,
        'state':       updated.state.isEmpty ? null : updated.state,
        'pincode':     updated.pincode.isEmpty ? null : updated.pincode,
        'pan':         updated.pan.isEmpty ? null : updated.pan,
        'gstin':       updated.gstNumber.isEmpty ? null : updated.gstNumber,
      });
    }

    Get.back();
    Get.snackbar('Updated', '"${updated.name}" saved!',
        backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
  }

  void _delete() {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      title: const Text('Delete Customer', style: TextStyle(color: AppColors.textPrimary)),
      content: Text('Delete "${_customer.name}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () {
            _ctrl.deleteCustomer(_customer.id);
            Get.until((r) => r.settings.name == '/customers');
            Get.snackbar('Deleted', '"${_customer.name}" removed',
                backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
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
        title: Text('Edit ${_customer.name}',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sec('Basic Information', Icons.person_outline),
            _row2(_tf(_name, 'Full Name *', validator: _req), _tf(_phone, 'Phone *', keyboardType: TextInputType.phone, validator: _req)),
            _row2(_tf(_email, 'Email', keyboardType: TextInputType.emailAddress), _tf(_whatsapp, 'WhatsApp')),
            _row3(
              _dd('Type', ['Regular','Premium','VIP'], _type, (v) => setState(() => _type = v!)),
              _datePicker('Date of Birth', _dob, (d) => setState(() => _dob = d)),
              _datePicker('Anniversary', _anniversary, (d) => setState(() => _anniversary = d)),
            ),

            _sec('Address', Icons.location_on_outlined),
            _tf(_address, 'Street Address'),
            _row3(_tf(_city, 'City'), _tf(_state, 'State'), _tf(_pincode, 'PIN Code', keyboardType: TextInputType.number)),

            _sec('KYC', Icons.shield_outlined),
            _row3(_tf(_pan, 'PAN'), _tf(_aadhaar, 'Aadhaar'), _tf(_gst, 'GST Number')),

            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Cancel'),
              )),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check, size: 18, color: Colors.black),
                label: const Text('Save Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              )),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sec(String t, IconData i) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(i, color: AppColors.goldPrimary, size: 15), const SizedBox(width: 7),
      Text(t, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );

  Widget _tf(TextEditingController ctrl, String label,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border)),
        child: TextFormField(controller: ctrl, keyboardType: keyboardType, validator: validator,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11))),
      ),
      const SizedBox(height: 10),
    ]);
  }

  Widget _dd(String label, List<String> items, String val, ValueChanged<String?> onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(value: val, isExpanded: true, dropdownColor: AppColors.bgSecondary,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            items: items.map((i) => DropdownMenuItem(value: i,
                child: Text(i, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
            onChanged: onChange),
        ),
      ),
      const SizedBox(height: 10),
    ]);
  }

  Widget _datePicker(String label, DateTime? val, ValueChanged<DateTime?> onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      GestureDetector(
        onTap: () async {
          final d = await showDatePicker(context: context,
              initialDate: val ?? DateTime(1990), firstDate: DateTime(1950), lastDate: DateTime(2030),
              builder: (c, w) => Theme(data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(primary: AppColors.goldPrimary)), child: w!));
          if (d != null) onChange(d);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 14),
            const SizedBox(width: 8),
            Text(val == null ? 'Select date' : '${val.day}/${val.month}/${val.year}',
                style: TextStyle(color: val == null ? AppColors.textMuted : AppColors.textPrimary, fontSize: 13)),
          ]),
        ),
      ),
      const SizedBox(height: 10),
    ]);
  }

  Widget _row2(Widget a, Widget b) => Row(children: [
    Expanded(child: Padding(padding: const EdgeInsets.only(right: 6), child: a)),
    Expanded(child: Padding(padding: const EdgeInsets.only(left: 6), child: b)),
  ]);
  Widget _row3(Widget a, Widget b, Widget c) => Row(children: [
    Expanded(child: Padding(padding: const EdgeInsets.only(right: 4), child: a)),
    Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: b)),
    Expanded(child: Padding(padding: const EdgeInsets.only(left: 4), child: c)),
  ]);
  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
}