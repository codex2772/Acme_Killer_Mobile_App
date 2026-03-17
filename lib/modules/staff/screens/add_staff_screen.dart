import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/staff/staff_model.dart';
import '../controllers/staff_controller.dart';

// ════════════════════════════════════════════════════════════════
// ADD STAFF SCREEN — mirrors Electron's renderAddStaff()
// ════════════════════════════════════════════════════════════════

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});
  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _ctrl = Get.find<StaffController>();

  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _salaryCtrl   = TextEditingController();
  final _commCtrl     = TextEditingController();
  final _targetCtrl   = TextEditingController();
  final _aadhaarCtrl  = TextEditingController();
  final _panCtrl      = TextEditingController();

  String        _role  = 'admin';
  String        _store = StaffController.kStores[0];
  final Set<String> _perms = {};
  bool          _isSubmitting = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl, _passwordCtrl,
        _salaryCtrl, _commCtrl, _targetCtrl, _aadhaarCtrl, _panCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      Get.snackbar('Error', 'Name, phone and email are required',
          backgroundColor: AppColors.error.withOpacity(0.2),
          colorText: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12));
      return;
    }

    setState(() => _isSubmitting = true);

    final perms = _role == 'admin'
        ? List<String>.from(kAdminPermissions)
        : List<String>.from(_perms);

    final newId = 'STF${(_ctrl.staffMembers.length + 1).toString().padLeft(3, '0')}';
    final newStaff = Staff(
      id:           newId,
      name:         name,
      phone:        phone,
      email:        email,
      role:         _role,
      store:        _store,
      storeIds:     _ctrl.storeIdsFor(_store),
      status:       'Active',
      salary:       double.tryParse(_salaryCtrl.text) ?? 25000,
      commission:   double.tryParse(_commCtrl.text)   ?? 0,
      salesTarget:  double.tryParse(_targetCtrl.text) ?? 0,
      currentSales: 0,
      joinDate:     DateTime.now().toIso8601String().substring(0, 10),
      permissions:  perms,
      attendance:   [],
      leaves:       {'total': _role == 'admin' ? 24 : 18, 'used': 0, 'pending': 0, 'balance': _role == 'admin' ? 24 : 18},
      aadhaar:      _aadhaarCtrl.text.trim(),
      pan:          _panCtrl.text.trim(),
    );

    // ── Try backend API (mirrors Electron's window.jewelERP.staff.create) ──
    bool savedToBackend = false;
    if (_ctrl.isOnline.value) {
      final password = _passwordCtrl.text.trim().isEmpty ? 'JewelERP@123' : _passwordCtrl.text.trim();
      final result = await _ctrl.createViaApi(newStaff, password);
      if (result.success) {
        savedToBackend = true;
      }
    }

    // ── Always update local state ──
    _ctrl.addStaff(newStaff);

    setState(() => _isSubmitting = false);
    Get.back();
    Get.snackbar(
      'Staff Added',
      savedToBackend
          ? '"$name" saved to database!'
          : '"$name" added as ${_role == 'admin' ? 'Admin' : 'Staff'}',
      backgroundColor: AppColors.bgCard,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
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
        title: const Text('Add New Staff',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ── Personal Info ──
        _sectionCard('Personal Info', Icons.person_outline, Column(children: [
          _row2(
            _tf(_nameCtrl,     'Full Name *',  hint: 'e.g., Arjun Kapoor'),
            _tf(_phoneCtrl,    'Phone *',      hint: '+91 98765 43210', keyboardType: TextInputType.phone),
          ),
          _row2(
            _tf(_emailCtrl,    'Email *',      hint: 'email@jewelerp.com', keyboardType: TextInputType.emailAddress),
            _tf(_passwordCtrl, 'Password *',   hint: '••••••••', obscure: true),
          ),
        ])),
        const SizedBox(height: 12),

        // ── Compensation ──
        _sectionCard('Compensation', Icons.currency_rupee_rounded, _row3(
          _tf(_salaryCtrl, 'Salary (₹/mo)',    hint: '25000', keyboardType: TextInputType.number),
          _tf(_commCtrl,   'Commission (%)',    hint: '0.5',   keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          _tf(_targetCtrl, 'Sales Target (₹)', hint: '500000', keyboardType: TextInputType.number),
        )),
        const SizedBox(height: 12),

        // ── Store Assignment ──
        _sectionCard('Store Assignment', Icons.store_outlined,
          _dd('Assign to Store', StaffController.kStores, _store,
              (v) => setState(() => _store = v!)),
        ),
        const SizedBox(height: 12),

        // ── Role & Permissions ──
        _sectionCard('Role & Permissions', Icons.shield_outlined, Column(children: [
          Row(children: [
            Expanded(child: _roleBtn('admin', 'Admin', 'Full store access',  Icons.manage_accounts_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _roleBtn('staff', 'Staff', 'Custom permissions', Icons.person_outline)),
          ]),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _role == 'admin' ? _adminNotice() : _permissionsSection(),
          ),
        ])),
        const SizedBox(height: 12),

        // ── KYC Documents ──
        _sectionCard('KYC Documents', Icons.badge_outlined, _row2(
          _tf(_aadhaarCtrl, 'Aadhaar Number', hint: '0000 0000 0000'),
          _tf(_panCtrl,     'PAN Number',      hint: 'ABCDE1234F'),
        )),
        const SizedBox(height: 24),

        // ── Actions ──
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Cancel'),
          )),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.check, size: 18, color: Colors.black),
            label: const Text('Add Staff', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0),
          )),
        ]),
        const SizedBox(height: 40),
      ]),
    );
  }

  // ── Role Toggle Button ──
  Widget _roleBtn(String role, String title, String sub, IconData icon) {
    final active = _role == role;
    final color  = role == 'admin' ? const Color(0xFFF472B6) : AppColors.info;
    return GestureDetector(
      onTap: () => setState(() { _role = role; if (role == 'admin') _perms.clear(); }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? color : AppColors.border, width: active ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(icon, color: active ? color : AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: active ? color : AppColors.textPrimary,
                fontWeight: FontWeight.bold, fontSize: 13)),
            Text(sub, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }

  Widget _adminNotice() => Container(
    key: const ValueKey('admin_add'),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.info.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.info.withOpacity(0.3)),
    ),
    child: const Row(children: [
      Icon(Icons.shield_outlined, color: AppColors.info, size: 18),
      SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Admin Access', style: TextStyle(color: AppColors.info, fontWeight: FontWeight.bold, fontSize: 13)),
        Text('Full store operations access. Revenue Dashboard exclusive to owner.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ])),
    ]),
  );

  Widget _permissionsSection() {
    final groups = kPermGroups;
    return Column(key: const ValueKey('staff_add'), children: groups.keys.map((group) {
      final perms      = groups[group]!;
      final allChecked = perms.every((p) => _perms.contains(p.id));
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(group, style: const TextStyle(color: AppColors.textPrimary,
                fontWeight: FontWeight.w600, fontSize: 13)),
            Row(children: [
              Checkbox(
                value: allChecked,
                onChanged: (v) => setState(() {
                  if (v == true) for (final p in perms) _perms.add(p.id);
                  else           for (final p in perms) _perms.remove(p.id);
                }),
                activeColor: AppColors.goldPrimary,
                side: const BorderSide(color: AppColors.border),
              ),
              const Text('All', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 6),
          ...perms.map((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              Checkbox(
                value: _perms.contains(p.id),
                onChanged: (v) => setState(() {
                  v == true ? _perms.add(p.id) : _perms.remove(p.id);
                }),
                activeColor: AppColors.goldPrimary,
                side: const BorderSide(color: AppColors.border),
              ),
              Text(p.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            ]),
          )),
        ]),
      );
    }).toList());
  }

  // ── Input helpers ──
  Widget _sectionCard(String title, IconData icon, Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: AppColors.goldPrimary, size: 15),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(color: AppColors.textPrimary,
            fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
      const SizedBox(height: 12),
      child,
    ]),
  );

  Widget _tf(TextEditingController ctrl, String label,
      {String? hint, TextInputType? keyboardType, bool obscure = false}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: TextField(
            controller: ctrl, keyboardType: keyboardType, obscureText: obscure,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ]);

  Widget _dd(String label, List<String> items, String val, ValueChanged<String?> onChange) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: val, isExpanded: true, dropdownColor: AppColors.bgSecondary,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            items: items.map((i) => DropdownMenuItem(value: i,
                child: Text(i, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
            onChanged: onChange,
          )),
        ),
      ]);

  Widget _row2(Widget a, Widget b) => Row(children: [
    Expanded(child: Padding(padding: const EdgeInsets.only(right: 6), child: a)),
    Expanded(child: Padding(padding: const EdgeInsets.only(left: 6), child: b)),
  ]);

  Widget _row3(Widget a, Widget b, Widget c) => Row(children: [
    Expanded(child: Padding(padding: const EdgeInsets.only(right: 4), child: a)),
    Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: b)),
    Expanded(child: Padding(padding: const EdgeInsets.only(left: 4), child: c)),
  ]);
}
