import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../controllers/customer_controller.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});
  @override State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = Get.find<CustomerController>();

  // Basic
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _whatsapp = TextEditingController();
  // Address
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  // KYC
  final _pan = TextEditingController();
  final _aadhaar = TextEditingController();
  final _gst = TextEditingController();
  // Preferences
  final _ringSize = TextEditingController();
  final _wristSize = TextEditingController();
  final _chainLength = TextEditingController();
  final _bangleSize = TextEditingController();
  final _ankletSize = TextEditingController();
  final _referredBy = TextEditingController();
  final _tags = TextEditingController();
  final _notes = TextEditingController();

  String _type = 'Regular';
  String _metal = 'Gold';
  String _purity = '22K';
  String _style = 'Temple & Traditional';
  DateTime? _dob;
  DateTime? _anniversary;
  bool _commSms = true, _commWhatsapp = true, _commEmail = false;

  @override
  void dispose() {
    for (final c in [_name,_phone,_email,_whatsapp,_address,_city,_state,_pincode,
        _pan,_aadhaar,_gst,_ringSize,_wristSize,_chainLength,_bangleSize,
        _ankletSize,_referredBy,_tags,_notes]) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final newId = 'CUS${(_ctrl.customers.length + 1).toString().padLeft(3,'0')}';
    final tags = _tags.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    final customer = Customer(
      id: newId,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      whatsapp: _whatsapp.text.trim().isEmpty ? _phone.text.trim() : _whatsapp.text.trim(),
      email: _email.text.trim(),
      city: _city.text.trim(),
      address: _address.text.trim(),
      state: _state.text.trim(),
      pincode: _pincode.text.trim(),
      pan: _pan.text.trim(),
      aadhaar: _aadhaar.text.trim(),
      gstNumber: _gst.text.trim(),
      type: _type,
      store: 'Rajmahal Jewellers - Main',
      dob: _dob,
      anniversary: _anniversary,
      memberSince: DateTime.now().toIso8601String().substring(0, 10),
      loyaltyPoints: 0, loyaltyTier: 'Silver', creditLimit: 100000,
      commSms: _commSms, commWhatsapp: _commWhatsapp, commEmail: _commEmail,
      tags: tags, referredBy: _referredBy.text.trim(),
      preferences: CustomerPreferences(
        metal: _metal, purity: _purity, style: _style,
        ringSize: _ringSize.text.trim(), wristSize: _wristSize.text.trim(),
        chainLength: _chainLength.text.trim(), bangleSize: _bangleSize.text.trim(),
        ankletSize: _ankletSize.text.trim(),
      ),
      notes: _notes.text.trim().isNotEmpty
          ? [CustomerNote(text: _notes.text.trim(), date: DateTime.now().toIso8601String().substring(0,10), addedBy: 'Staff')]
          : [],
    );

    _ctrl.addCustomer(customer);
    Get.back();
    Get.snackbar('Customer Added', '"${customer.name}" registered!',
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
        title: const Text('Add Customer',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sec('Basic Information', Icons.person_outline),
            _row2(_tf(_name, 'Full Name *', validator: _req),
                  _tf(_phone, 'Phone *', keyboardType: TextInputType.phone, validator: _req)),
            _row2(_tf(_email, 'Email', keyboardType: TextInputType.emailAddress),
                  _tf(_whatsapp, 'WhatsApp')),
            _row3(
              _dd('Customer Type', ['Regular','Premium','VIP'], _type, (v) => setState(() => _type = v!)),
              _datePicker('Date of Birth', _dob, (d) => setState(() => _dob = d)),
              _datePicker('Anniversary', _anniversary, (d) => setState(() => _anniversary = d)),
            ),

            _sec('Address', Icons.location_on_outlined),
            _tf(_address, 'Street Address'),
            _row3(_tf(_city, 'City *', validator: _req),
                  _tf(_state, 'State'),
                  _tf(_pincode, 'PIN Code', keyboardType: TextInputType.number)),

            _sec('KYC / Identification', Icons.shield_outlined),
            _row3(_tf(_pan, 'PAN Number'),
                  _tf(_aadhaar, 'Aadhaar Number', keyboardType: TextInputType.number),
                  _tf(_gst, 'GST Number')),

            _sec('Communication', Icons.notifications_outlined),
            Row(children: [
              _check('SMS',       _commSms,       (v) => setState(() => _commSms = v!)),
              _check('WhatsApp',  _commWhatsapp,  (v) => setState(() => _commWhatsapp = v!)),
              _check('Email',     _commEmail,     (v) => setState(() => _commEmail = v!)),
            ]),

            _sec('Preferences (Optional)', Icons.tag_outlined),
            _row3(
              _dd('Metal', ['Gold','Silver','Platinum','Diamond'], _metal, (v) => setState(() => _metal = v!)),
              _dd('Purity', ['22K','24K','18K','14K','925 Silver','950 Platinum'], _purity, (v) => setState(() => _purity = v!)),
              _dd('Style', ['Temple & Traditional','Modern & Minimalist','Kundan & Polki','Antique & South Indian','Contemporary','Bridal'], _style, (v) => setState(() => _style = v!)),
            ),
            _row3(_tf(_ringSize, 'Ring Size'),
                  _tf(_wristSize, 'Wrist Size'),
                  _tf(_chainLength, 'Chain Length')),
            _row3(_tf(_bangleSize, 'Bangle Size'),
                  _tf(_ankletSize, 'Anklet Size'),
                  _tf(_referredBy, 'Referred By')),

            _tf(_tags, 'Tags (comma separated)', hint: 'e.g., Festival Buyer, Gold Lover'),
            _tf(_notes, 'Notes', hint: 'Any special preferences...', maxLines: 3),

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
                onPressed: _submit,
                icon: const Icon(Icons.check, size: 18, color: Colors.black),
                label: const Text('Save Customer', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
      Icon(i, color: AppColors.goldPrimary, size: 15),
      const SizedBox(width: 7),
      Text(t, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );

  Widget _tf(TextEditingController ctrl, String label,
      {String? hint, TextInputType? keyboardType, int maxLines = 1,
       String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12,
          fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border)),
        child: TextFormField(
          controller: ctrl, keyboardType: keyboardType, maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11)),
        ),
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
          child: DropdownButton<String>(
            value: val, isExpanded: true, dropdownColor: AppColors.bgSecondary,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            items: items.map((i) => DropdownMenuItem(value: i,
                child: Text(i, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
            onChanged: onChange,
          ),
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
          final d = await showDatePicker(
            context: context,
            initialDate: val ?? DateTime(1990, 1, 1),
            firstDate: DateTime(1950), lastDate: DateTime(2030),
            builder: (c, w) => Theme(data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(primary: AppColors.goldPrimary)), child: w!),
          );
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
                style: TextStyle(
                    color: val == null ? AppColors.textMuted : AppColors.textPrimary,
                    fontSize: 13)),
          ]),
        ),
      ),
      const SizedBox(height: 10),
    ]);
  }

  Widget _check(String label, bool val, ValueChanged<bool?> onChange) => Expanded(
    child: Row(children: [
      Checkbox(value: val, onChanged: onChange,
          activeColor: AppColors.goldPrimary, checkColor: Colors.black,
          side: const BorderSide(color: AppColors.border)),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ]),
  );

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
