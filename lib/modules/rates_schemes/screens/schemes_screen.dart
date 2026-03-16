import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/rates_schemes_controller.dart';

// ─────────────────────────────────────────────────────────────
// SCHEMES LIST SCREEN
// ─────────────────────────────────────────────────────────────
class SchemesScreen extends GetView<RatesSchemesController> {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back()),
        title: const Text('Savings Schemes',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addScheme),
              icon: const Icon(Icons.add, size: 14, color: Colors.black),
              label: const Text('New', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats
          Obx(() {
            final active = controller.schemes.where((s) => s.status == 'Active').toList();
            final totalMembers = controller.schemes.fold(0, (s, sch) => s + sch.members);
            final totalColl = active.fold(0, (s, sch) => s + sch.totalCollected);
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(children: [
                _chip('${controller.schemes.length}', 'Total',    AppColors.goldPrimary),
                _chip('${active.length}',             'Active',   AppColors.success),
                _chip('$totalMembers',                'Members',  AppColors.info),
                _chip(controller.fmt(totalColl),      'Collected',AppColors.warning),
              ]),
            );
          }),
          const SizedBox(height: 10),

          Expanded(child: Obx(() {
            if (controller.schemes.isEmpty) return const Center(
                child: Text('No schemes yet', style: TextStyle(color: AppColors.textMuted)));
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
              itemCount: controller.schemes.length,
              itemBuilder: (_, i) => _SchemeCard(scheme: controller.schemes[i], ctrl: controller),
            );
          })),
        ],
      ),
    );
  }

  Widget _chip(String v, String l, Color c) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.3))),
      child: Column(children: [
        Text(v, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(l, style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
      ]),
    ),
  );
}

class _SchemeCard extends StatelessWidget {
  final Scheme scheme;
  final RatesSchemesController ctrl;
  const _SchemeCard({required this.scheme, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isActive = scheme.status == 'Active';
    final statusColor = isActive ? AppColors.success : AppColors.textSecondary;
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.schemeDetail, arguments: scheme.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.goldPrimary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.card_giftcard_outlined, color: AppColors.goldPrimary, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(scheme.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              _badge(scheme.status, statusColor),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(scheme.monthlyAmt, style: const TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('/month', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ]),
          ]),
          const SizedBox(height: 10),
          Text(scheme.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(children: [
            _detail('Duration', scheme.duration),
            const SizedBox(width: 20),
            _detail('Members', '${scheme.members}'),
            const SizedBox(width: 20),
            _detail('Bonus', scheme.bonusMonth.contains('Yes') ? '✅ Yes' : '—'),
            const Spacer(),
            if (scheme.dueCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.error.withOpacity(0.3))),
                child: Text('${scheme.dueCount} due', style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _iconBtn(Icons.visibility_outlined, AppColors.goldPrimary,
                  () => Get.toNamed(AppRoutes.schemeDetail, arguments: scheme.id)),
              const SizedBox(width: 6),
              _iconBtn(Icons.edit_outlined, AppColors.info,
                  () => Get.toNamed(AppRoutes.editScheme, arguments: scheme.id)),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(t, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)));

  Widget _detail(String l, String v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    Text(v, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 12)),
  ]);

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Icon(icon, size: 14, color: color)));
}

// ─────────────────────────────────────────────────────────────
// SCHEME DETAIL SCREEN
// ─────────────────────────────────────────────────────────────
class SchemeDetailScreen extends StatelessWidget {
  const SchemeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RatesSchemesController>();
    final schemeId = Get.arguments as String;
    return Obx(() {
      final scheme = ctrl.getScheme(schemeId);
      if (scheme == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.bgPrimary, elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
            onPressed: () => Get.back()),
          title: Text(scheme.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            TextButton(onPressed: () => Get.toNamed(AppRoutes.editScheme, arguments: scheme.id),
                child: const Text('Edit', style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.w600))),
          ],
        ),
        body: ListView(padding: const EdgeInsets.all(14), children: [
          // Header
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.goldPrimary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.card_giftcard_outlined, color: AppColors.goldPrimary, size: 24)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(scheme.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 3),
                  Text('${scheme.startDate} — ${scheme.endDate}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ])),
              ]),
              const SizedBox(height: 10),
              Text(scheme.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
            ])),
          const SizedBox(height: 12),

          // Stats
          Row(children: [
            _mStat(scheme.monthlyAmt,           'Monthly',   AppColors.goldPrimary),
            _mStat(scheme.duration,             'Duration',  AppColors.info),
            _mStat('${scheme.members}',          'Members',   AppColors.success),
            _mStat(ctrl.fmt(scheme.maturityValue), 'Maturity', AppColors.warning),
          ]),
          const SizedBox(height: 14),

          // Members header
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Member Payment Tracker', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            Row(children: [
              ElevatedButton.icon(
                onPressed: () {
                  final due = scheme.memberList.where((m) => m.hasDue).length;
                  Get.snackbar('Reminders Sent', 'Sent to $due members with dues',
                      backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
                },
                icon: const Icon(Icons.notifications_outlined, size: 13, color: Colors.black),
                label: const Text('Remind', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0)),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddMember(context, scheme, ctrl),
                icon: const Icon(Icons.person_add_outlined, size: 13, color: Colors.black),
                label: const Text('Add', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0)),
            ]),
          ]),
          const SizedBox(height: 10),

          if (scheme.memberList.isEmpty)
            Container(padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: const Center(child: Column(children: [
                Icon(Icons.people_outline, color: AppColors.textMuted, size: 40),
                SizedBox(height: 8),
                Text('No members enrolled yet', style: TextStyle(color: AppColors.textMuted)),
              ])))
          else
            ...scheme.memberList.map((m) => _MemberRow(
              member: m, scheme: scheme, ctrl: ctrl,
              onRecord: () => _showRecordPayment(context, m, scheme, ctrl),
              onView: () => _showPaymentHistory(context, m, scheme, ctrl),
            )),
          const SizedBox(height: 30),
        ]),
      );
    });
  }

  Widget _mStat(String v, String l, Color c) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.25))),
      child: Column(children: [
        Text(v, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(l, style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
      ]),
    ),
  );

  void _showAddMember(BuildContext context, Scheme scheme, RatesSchemesController ctrl) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      title: Text('Add Member — ${scheme.name}', style: const TextStyle(color: AppColors.textPrimary)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _dlgField(nameCtrl, 'Member Name *'),
        _dlgField(phoneCtrl, 'Phone', keyboardType: TextInputType.phone),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () {
            if (nameCtrl.text.trim().isEmpty) return;
            final newId = 'SM${(scheme.memberList.length + 10).toString().padLeft(3,'0')}';
            final payments = <SchemePayment>[];
            final start = DateTime.tryParse(scheme.startDate) ?? DateTime.now();
            for (int i = 0; i < scheme.durationMonths; i++) {
              final d = DateTime(start.year, start.month + i);
              const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
              payments.add(SchemePayment(month:'${months[d.month-1]} ${d.year}', amount:scheme.monthlyAmtNum, date:null, status:'Upcoming'));
            }
            if (payments.isNotEmpty) payments[0].status = 'Due';
            ctrl.addMember(scheme.id, SchemeMember(
              id: newId, name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim(),
              joinDate: DateTime.now().toIso8601String().substring(0,10),
              totalPaid: 0, status: 'Active', payments: payments));
            Get.back();
            Get.snackbar('Member Added', '${nameCtrl.text.trim()} added to ${scheme.name}',
                backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
          child: const Text('Add Member', style: TextStyle(color: Colors.black))),
      ],
    ));
  }

  void _showRecordPayment(BuildContext context, SchemeMember member, Scheme scheme, RatesSchemesController ctrl) {
    final due = member.nextDue;
    if (due == null) {
      Get.snackbar('Info', 'No due payments for ${member.name}',
          backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
      return;
    }
    final amtCtrl = TextEditingController(text: '${due.amount}');
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      title: Text('Record Payment — ${member.name}', style: const TextStyle(color: AppColors.textPrimary)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _infoRow('Scheme',   scheme.name),
        _infoRow('Month',    due.month),
        _infoRow('Due',      scheme.monthlyAmt),
        const SizedBox(height: 10),
        _dlgField(amtCtrl, 'Amount (₹)', keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () { ctrl.recordSchemePayment(scheme.id, member.id); Get.back();
            Get.snackbar('Payment Recorded', '₹${amtCtrl.text} recorded for ${member.name}',
                backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12)); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
          child: const Text('Record Payment', style: TextStyle(color: Colors.black))),
      ],
    ));
  }

  void _showPaymentHistory(BuildContext context, SchemeMember member, Scheme scheme, RatesSchemesController ctrl) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      title: Text('${member.name} — Payments', style: const TextStyle(color: AppColors.textPrimary)),
      content: SizedBox(width: 320, child: Column(mainAxisSize: MainAxisSize.min, children: [
        _infoRow('Total Paid', ctrl.fmt(member.totalPaid)),
        _infoRow('Maturity',   ctrl.fmt(scheme.maturityValue)),
        const Divider(color: AppColors.border),
        ...member.payments.map((p) {
          Color c; switch(p.status) { case 'Paid': c = AppColors.success; break; case 'Due': c = AppColors.error; break; default: c = AppColors.textMuted; }
          return Padding(padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(p.month, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(p.status, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
            ]));
        }),
      ])),
      actions: [TextButton(onPressed: () => Get.back(), child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)))],
    ));
  }

  Widget _infoRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      Text(v, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 12)),
    ]));

  Widget _dlgField(TextEditingController c, String label, {TextInputType? keyboardType}) =>
      Padding(padding: const EdgeInsets.only(bottom: 8),
        child: TextField(controller: c, keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            filled: true, fillColor: AppColors.inputFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10))));
}

class _MemberRow extends StatelessWidget {
  final SchemeMember member;
  final Scheme scheme;
  final RatesSchemesController ctrl;
  final VoidCallback onRecord;
  final VoidCallback onView;
  const _MemberRow({required this.member, required this.scheme, required this.ctrl, required this.onRecord, required this.onView});

  @override
  Widget build(BuildContext context) {
    final hasDue = member.hasDue;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: hasDue ? AppColors.error : AppColors.success, width: 3))),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.bgSecondary, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(member.name[0].toUpperCase(), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(member.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          Row(children: [
            Text(member.phone, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (hasDue ? AppColors.error : AppColors.success).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)),
              child: Text(hasDue ? 'Due' : 'Up to date',
                  style: TextStyle(color: hasDue ? AppColors.error : AppColors.success, fontSize: 10, fontWeight: FontWeight.w600))),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(ctrl.fmt(member.totalPaid), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
          Text('paid', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ]),
        const SizedBox(width: 8),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(onTap: onView,
              child: Container(padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.visibility_outlined, size: 14, color: AppColors.info))),
          const SizedBox(height: 4),
          GestureDetector(onTap: onRecord,
              child: Container(padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.currency_rupee_rounded, size: 14, color: AppColors.success))),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADD SCHEME SCREEN
// ─────────────────────────────────────────────────────────────
class AddSchemeScreen extends StatefulWidget {
  const AddSchemeScreen({super.key});
  @override State<AddSchemeScreen> createState() => _AddSchemeScreenState();
}

class _AddSchemeScreenState extends State<AddSchemeScreen> {
  final _ctrl = Get.find<RatesSchemesController>();
  final _nameCtrl     = TextEditingController();
  final _amtCtrl      = TextEditingController();
  final _durationCtrl = TextEditingController(text: '11');
  final _descCtrl     = TextEditingController();
  String _bonus = 'Yes (Free month)';
  DateTime? _startDate;

  @override void dispose() { for (final c in [_nameCtrl,_amtCtrl,_durationCtrl,_descCtrl]) c.dispose(); super.dispose(); }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty || _amtCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Name and monthly amount required',
          backgroundColor: AppColors.error.withOpacity(0.2), colorText: AppColors.error,
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
      return;
    }
    final months = int.tryParse(_durationCtrl.text) ?? 11;
    final amt = int.tryParse(_amtCtrl.text) ?? 0;
    final start = _startDate ?? DateTime.now();
    final end = DateTime(start.year, start.month + months, start.day);
    final newId = 'SCH${(_ctrl.schemes.length + 1).toString().padLeft(3,'0')}';
    _ctrl.addScheme(Scheme(
      id: newId, name: _nameCtrl.text.trim(), duration: '$months months',
      durationMonths: months, monthlyAmtNum: amt, status: 'Active',
      store: 'Rajmahal Jewellers - Main',
      startDate: start.toIso8601String().substring(0,10),
      endDate: end.toIso8601String().substring(0,10),
      bonusMonth: _bonus,
      description: _descCtrl.text.trim().isEmpty
          ? 'Pay ₹$amt/month for $months months. $_bonus'
          : _descCtrl.text.trim(),
      memberList: [],
    ));
    Get.back();
    Get.snackbar('Scheme Created', '"${_nameCtrl.text.trim()}" created!',
        backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18), onPressed: () => Get.back()),
        title: const Text('Create New Scheme', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _card('Scheme Details', Icons.card_giftcard_outlined, Column(children: [
          _tf(_nameCtrl, 'Scheme Name *', hint: 'e.g., Gold Monthly Plus'),
          _tf(_amtCtrl, 'Monthly Amount (₹) *', hint: '5000', keyboardType: TextInputType.number),
          _row2(
            _tf(_durationCtrl, 'Duration (Months) *', hint: '11', keyboardType: TextInputType.number),
            _datePicker(),
          ),
          _dd('Bonus Month', ['Yes (Free month)','Yes (Free + 5% extra)','No Bonus'], _bonus, (v) => setState(() => _bonus = v!)),
        ])),
        const SizedBox(height: 12),
        _card('Description', Icons.notes_outlined,
          Container(decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: TextField(controller: _descCtrl, maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(hintText: 'Scheme details, terms & conditions...',
                  hintStyle: TextStyle(color: AppColors.textMuted), border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12))))),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Cancel'))),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: ElevatedButton.icon(onPressed: _submit,
              icon: const Icon(Icons.check, size: 18, color: Colors.black),
              label: const Text('Create Scheme', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0))),
        ]),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _card(String title, IconData icon, Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: AppColors.goldPrimary, size: 15), const SizedBox(width: 7),
        Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13))]),
      const SizedBox(height: 12), child,
    ]));

  Widget _tf(TextEditingController c, String l, {String? hint, TextInputType? keyboardType}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: TextField(controller: c, keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11)))),
        const SizedBox(height: 10)]);

  Widget _dd(String l, List<String> items, String val, ValueChanged<String?> onChange) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: val, isExpanded: true, dropdownColor: AppColors.bgSecondary,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
            onChanged: onChange))),
        const SizedBox(height: 10)]);

  Widget _datePicker() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Start Date', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
    const SizedBox(height: 5),
    GestureDetector(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030),
            builder: (c, w) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.goldPrimary)), child: w!));
        if (d != null) setState(() => _startDate = d);
      },
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 14), const SizedBox(width: 8),
          Text(_startDate == null ? 'Select date' : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
              style: TextStyle(color: _startDate == null ? AppColors.textMuted : AppColors.textPrimary, fontSize: 13)),
        ]))),
    const SizedBox(height: 10)]);

  Widget _row2(Widget a, Widget b) => Row(children: [
    Expanded(child: Padding(padding: const EdgeInsets.only(right: 6), child: a)),
    Expanded(child: Padding(padding: const EdgeInsets.only(left: 6), child: b))]);
}

// ─────────────────────────────────────────────────────────────
// EDIT SCHEME SCREEN
// ─────────────────────────────────────────────────────────────
class EditSchemeScreen extends StatefulWidget {
  const EditSchemeScreen({super.key});
  @override State<EditSchemeScreen> createState() => _EditSchemeScreenState();
}

class _EditSchemeScreenState extends State<EditSchemeScreen> {
  final _ctrl = Get.find<RatesSchemesController>();
  late Scheme _scheme;
  late TextEditingController _nameCtrl, _amtCtrl, _endCtrl, _descCtrl;
  late String _status;

  @override
  void initState() {
    super.initState();
    final id = Get.arguments as String;
    _scheme = _ctrl.getScheme(id)!;
    _nameCtrl = TextEditingController(text: _scheme.name);
    _amtCtrl  = TextEditingController(text: '${_scheme.monthlyAmtNum}');
    _endCtrl  = TextEditingController(text: _scheme.endDate);
    _descCtrl = TextEditingController(text: _scheme.description);
    _status   = _scheme.status;
  }

  @override void dispose() { for (final c in [_nameCtrl,_amtCtrl,_endCtrl,_descCtrl]) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18), onPressed: () => Get.back()),
        title: Text('Edit ${_scheme.name}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _tf(_nameCtrl, 'Scheme Name *'),
        _tf(_amtCtrl, 'Monthly Amount (₹)', keyboardType: TextInputType.number),
        _dd('Status', ['Active','Closed'], _status, (v) => setState(() => _status = v!)),
        _tf(_endCtrl, 'End Date'),
        Container(decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: TextField(controller: _descCtrl, maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                border: InputBorder.none, contentPadding: EdgeInsets.all(12)))),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Cancel'))),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: ElevatedButton.icon(
            onPressed: () {
              _ctrl.updateScheme(_scheme.id, name: _nameCtrl.text, monthlyAmt: int.tryParse(_amtCtrl.text),
                  status: _status, endDate: _endCtrl.text, description: _descCtrl.text);
              Get.back();
              Get.snackbar('Updated', '"${_nameCtrl.text}" saved!',
                  backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
                  snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
            },
            icon: const Icon(Icons.check, size: 18, color: Colors.black),
            label: const Text('Save Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0))),
        ]),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _tf(TextEditingController c, String l, {TextInputType? keyboardType}) =>
      Padding(padding: const EdgeInsets.only(bottom: 10),
        child: TextField(controller: c, keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(labelText: l, labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            filled: true, fillColor: AppColors.inputFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))));

  Widget _dd(String l, List<String> items, String val, ValueChanged<String?> onChange) =>
      Padding(padding: const EdgeInsets.only(bottom: 10),
        child: DropdownButtonFormField<String>(value: val, dropdownColor: AppColors.bgSecondary,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(labelText: l, labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            filled: true, fillColor: AppColors.inputFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
          onChanged: onChange));
}
