import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/staff_controller.dart';

class EditStaffScreen extends StatefulWidget {
  const EditStaffScreen({super.key});
  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  late final StaffController _ctrl;
  late final String _staffId;
  late dynamic _staff;

  late TextEditingController _nameCtrl, _phoneCtrl, _emailCtrl,
      _salaryCtrl, _commCtrl, _targetCtrl;
  late String _role, _status;
  late Set<String> _perms;

  @override
  void initState() {
    super.initState();
    _ctrl    = Get.find<StaffController>();
    _staffId = Get.arguments as String;
    _staff   = _ctrl.staffMembers.firstWhereOrNull((s) => s.id == _staffId);

    if (_staff == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => Get.back());
      return;
    }

    _nameCtrl   = TextEditingController(text: _staff.name);
    _phoneCtrl  = TextEditingController(text: _staff.phone);
    _emailCtrl  = TextEditingController(text: _staff.email);
    _salaryCtrl = TextEditingController(text: _staff.salary.toStringAsFixed(0));
    _commCtrl   = TextEditingController(text: _staff.commission.toString());
    _targetCtrl = TextEditingController(text: _staff.salesTarget.toStringAsFixed(0));
    _role   = _staff.role as String;
    _status = _staff.status as String;
    _perms  = Set<String>.from(_staff.permissions as List);
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl,_phoneCtrl,_emailCtrl,_salaryCtrl,_commCtrl,_targetCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final perms = _role == 'admin'
        ? List<String>.from(kAdminPermissions)
        : List<String>.from(_perms);
    _ctrl.updateStaff(
      _staffId,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      salary: double.tryParse(_salaryCtrl.text),
      commission: double.tryParse(_commCtrl.text),
      salesTarget: double.tryParse(_targetCtrl.text),
      status: _status,
      role: _role,
      permissions: perms,
    );
    Get.back();
    Get.snackbar('Saved', '"${_nameCtrl.text.trim()}" updated!',
        backgroundColor: AppColors.bgCard,
        colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12));
  }

  @override
  Widget build(BuildContext context) {
    if (_staff == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back()),
        title: Text('Edit ${_staff.name}',
            style: const TextStyle(color: AppColors.textPrimary,
                fontWeight: FontWeight.w600, fontSize: 15),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ── Personal info ──
        _sectionCard('Personal Info', Icons.person_outline,
          Column(children: [
            _row2(_tf(_nameCtrl,  'Full Name'),
                  _tf(_phoneCtrl, 'Phone', keyboardType: TextInputType.phone)),
            _row2(_tf(_emailCtrl, 'Email', keyboardType: TextInputType.emailAddress),
                  _dd('Status', ['Active','Inactive'], _status,
                      (v) => setState(() => _status = v!))),
          ])),
        const SizedBox(height: 12),

        // ── Compensation ──
        _sectionCard('Compensation', Icons.currency_rupee_rounded,
          _row3(
            _tf(_salaryCtrl, 'Salary (₹/mo)', keyboardType: TextInputType.number),
            _tf(_commCtrl,   'Commission (%)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            _tf(_targetCtrl, 'Sales Target (₹)', keyboardType: TextInputType.number),
          )),
        const SizedBox(height: 12),

        // ── Role & Permissions ──
        _sectionCard('Role & Permissions', Icons.shield_outlined,
          Column(children: [
            Row(children: [
              Expanded(child: _roleBtn('admin', 'Admin', 'Full store access',
                  Icons.manage_accounts_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _roleBtn('staff', 'Staff', 'Custom permissions',
                  Icons.person_outline)),
            ]),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _role == 'admin' ? _adminNotice() : _permissionsSection(),
            ),
          ])),
        const SizedBox(height: 24),

        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Cancel'))),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check, size: 18, color: Colors.black),
            label: const Text('Save Changes',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0))),
        ]),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _roleBtn(String role, String title, String sub, IconData icon) {
    final active = _role == role;
    final color = role == 'admin' ? const Color(0xFFF472B6) : AppColors.info;
    return GestureDetector(
      onTap: () => setState(() { _role = role; if (role == 'admin') _perms.clear(); }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? color : AppColors.border, width: active ? 1.5 : 1)),
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
    key: const ValueKey('admin_edit'),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.info.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.info.withOpacity(0.3))),
    child: const Row(children: [
      Icon(Icons.shield_outlined, color: AppColors.info, size: 18),
      SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Admin Access', style: TextStyle(color: AppColors.info,
            fontWeight: FontWeight.bold, fontSize: 13)),
        Text('Full store operations. Revenue Dashboard exclusive to owner.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ])),
    ]),
  );

  Widget _permissionsSection() {
    final groups = kPermGroups;
    return Column(key: const ValueKey('staff_edit'),
        children: groups.keys.map((group) {
      final perms = groups[group]!;
      final allChecked = perms.every((p) => _perms.contains(p.id));
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border)),
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
              Text(p.label, style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13)),
            ]),
          )),
        ]),
      );
    }).toList());
  }

  // ── Shared helpers ──
  Widget _sectionCard(String title, IconData icon, Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
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
      {TextInputType? keyboardType}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary,
            fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: TextField(
            controller: ctrl, keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11)))),
        const SizedBox(height: 10),
      ]);

  Widget _dd(String label, List<String> items, String val,
      ValueChanged<String?> onChange) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary,
            fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: val, isExpanded: true, dropdownColor: AppColors.bgSecondary,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
            onChanged: onChange))),
        const SizedBox(height: 10),
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
