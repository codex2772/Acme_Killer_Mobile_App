import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/staff_controller.dart';

// ════════════════════════════════════════════════════════════════
// STAFF DETAIL SCREEN  — mirrors Electron's renderStaffDetail()
// Tabs: Overview | Attendance | Performance | Leaves
// ════════════════════════════════════════════════════════════════

class StaffDetailScreen extends StatelessWidget {
  const StaffDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl  = Get.find<StaffController>();
    final id    = Get.arguments as String;
    final staff = ctrl.staffMembers.firstWhereOrNull((s) => s.id == id);

    if (staff == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin    = staff.role == 'admin';
    final roleColor  = isAdmin ? const Color(0xFFF472B6) : AppColors.info;
    final pct        = ctrl.targetPct(staff);
    final commEarned = ctrl.commissionEarned(staff);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
            onPressed: () => Get.back(),
          ),
          title: Text(
            staff.name,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.editStaff, arguments: staff.id),
              child: const Text('Edit',
                  style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.w600)),
            ),
            IconButton(
              icon: const Icon(Icons.receipt_outlined, color: AppColors.textSecondary),
              tooltip: 'Salary Slip',
              onPressed: () => Get.snackbar(
                'Salary Slip', 'Salary slip sent to printer',
                backgroundColor: AppColors.bgCard,
                colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.goldPrimary,
            labelColor: AppColors.goldPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Attendance'),
              Tab(text: 'Performance'),
              Tab(text: 'Leaves'),
            ],
          ),
        ),
        body: Column(children: [
          // ── Header (avatar + badges + contact) ──
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.bgPrimary,
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: roleColor.withOpacity(0.15), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(ctrl.initials(staff.name),
                    style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(staff.name,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Row(children: [
                    _badge(isAdmin ? 'Admin' : 'Staff', roleColor),
                    const SizedBox(width: 6),
                    _badge(staff.status, staff.status == 'Active' ? AppColors.success : AppColors.textMuted),
                    const SizedBox(width: 6),
                    const Icon(Icons.store_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      staff.store.replaceAll('Rajmahal Jewellers - ', ''),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    _metaTag(Icons.phone_outlined, staff.phone),
                    const SizedBox(width: 10),
                    _metaTag(Icons.calendar_today_outlined, 'Joined ${_fmtDate(staff.joinDate)}'),
                  ]),
                ]),
              ),
            ]),
          ),

          // ── Mini stats ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(children: [
              _stat('₹${(staff.salary / 1000).toStringAsFixed(0)}K', 'Monthly Salary', AppColors.goldPrimary),
              _stat('$pct%', 'Target Achieved', AppColors.success),
              _stat(ctrl.fmt(commEarned), 'Commission (${staff.commission}%)', AppColors.info),
              _stat('${staff.leaves['balance'] ?? 0}', 'Leave Balance', const Color(0xFFF0D060)),
            ]),
          ),

          // ── Tab views ──
          Expanded(
            child: TabBarView(children: [
              _OverviewTab(staff: staff),
              _AttendanceTab(staff: staff),
              _PerformanceTab(staff: staff, ctrl: ctrl, pct: pct, commEarned: commEarned),
              _LeavesTab(staff: staff),
            ]),
          ),
        ]),
      ),
    );
  }

  static Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withOpacity(0.35)),
    ),
    child: Text(t, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  static Widget _metaTag(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
    ],
  );

  static Widget _stat(String v, String l, Color c) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Column(children: [
        Text(v, style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(l,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
            textAlign: TextAlign.center),
      ]),
    ),
  );

  static String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) { return d; }
  }
}

// ════════════════════════════════════════════════════════════════
// OVERVIEW TAB — permissions by group + personal details (with aadhaar/pan)
// ════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final dynamic staff;
  const _OverviewTab({required this.staff});

  @override
  Widget build(BuildContext context) {
    final groups = kPermGroups;
    return ListView(padding: const EdgeInsets.all(14), children: [
      // ── Permissions card ──
      _card(
        'Permissions (${staff.permissions.length})',
        Icons.shield_outlined,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groups.keys.map((group) {
            final perms   = groups[group]!;
            final granted = perms.where((p) => staff.permissions.contains(p.id)).toList();
            if (granted.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(group,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: granted.map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(p.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11)),
                  )).toList(),
                ),
              ]),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 12),

      // ── Personal details (aadhaar/pan from model, not hardcoded) ──
      _card('Personal Details', Icons.person_outline,
        Column(children: [
          _row('Aadhaar', staff.aadhaar.isEmpty ? '—' : staff.aadhaar),
          _row('PAN',     staff.pan.isEmpty     ? '—' : staff.pan),
          _row('Commission Rate', '${staff.commission}%'),
          _row('Email',   staff.email),
        ]),
      ),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════
// ATTENDANCE TAB
// ════════════════════════════════════════════════════════════════

class _AttendanceTab extends StatelessWidget {
  final dynamic staff;
  const _AttendanceTab({required this.staff});

  @override
  Widget build(BuildContext context) {
    final records = staff.attendance as List;
    if (records.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.event_busy_outlined, color: AppColors.textMuted, size: 48),
          SizedBox(height: 12),
          Text('No attendance records', style: TextStyle(color: AppColors.textMuted)),
        ]),
      );
    }
    return ListView(padding: const EdgeInsets.all(14), children: [
      _card('Recent Attendance', Icons.schedule_outlined,
        Column(children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(children: [
              Expanded(flex: 2, child: Text('Date',   style: _hStyle)),
              Expanded(child: Text('In',     style: _hStyle)),
              Expanded(child: Text('Out',    style: _hStyle)),
              Expanded(child: Text('Hrs',    style: _hStyle)),
              Expanded(child: Text('Status', style: _hStyle)),
            ]),
          ),
          ...records.map((a) {
            final status = a.status as String;
            final sc = switch (status) {
              'Present' => AppColors.success,
              'Leave'   => AppColors.warning,
              'Sunday'  => AppColors.textMuted,
              _         => AppColors.error,
            };
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Row(children: [
                Expanded(flex: 2,
                  child: Text(_fmtDate(a.date as String),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                Expanded(child: Text(
                    (a.clockIn as String).isEmpty ? '—' : a.clockIn as String,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                Expanded(child: Text(
                    (a.clockOut as String).isEmpty ? '—' : a.clockOut as String,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                Expanded(child: Text(
                    a.hours > 0 ? '${a.hours}h' : '—',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                Expanded(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(status, style: TextStyle(color: sc, fontSize: 10, fontWeight: FontWeight.w600)),
                )),
              ]),
            );
          }),
        ]),
      ),
    ]);
  }

  static const _hStyle = TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600);

  static String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month - 1]}';
    } catch (_) { return d; }
  }
}

// ════════════════════════════════════════════════════════════════
// PERFORMANCE TAB
// ════════════════════════════════════════════════════════════════

class _PerformanceTab extends StatelessWidget {
  final dynamic staff;
  final StaffController ctrl;
  final int pct;
  final double commEarned;
  const _PerformanceTab({required this.staff, required this.ctrl, required this.pct, required this.commEarned});

  @override
  Widget build(BuildContext context) {
    final pctColor = pct >= 80 ? AppColors.success : pct >= 50 ? AppColors.warning : AppColors.error;
    return ListView(padding: const EdgeInsets.all(14), children: [
      _card('Sales Performance', Icons.trending_up_rounded,
        Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Monthly Target', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text('${ctrl.fmt(staff.currentSales)} / ${ctrl.fmt(staff.salesTarget)}',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(pctColor),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text('$pct% achieved',
                style: TextStyle(color: pctColor, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
          const Divider(color: AppColors.border, height: 24),
          _row('Current Sales',     ctrl.fmt(staff.currentSales)),
          _row('Target',            ctrl.fmt(staff.salesTarget)),
          _row('Achievement',       '$pct%'),
          _row('Commission Rate',   '${staff.commission}%'),
          _row('Commission Earned', ctrl.fmt(commEarned)),
          _row('Total CTC',         ctrl.fmt(staff.salary + commEarned)),
        ]),
      ),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════
// LEAVES TAB
// ════════════════════════════════════════════════════════════════

class _LeavesTab extends StatelessWidget {
  final dynamic staff;
  const _LeavesTab({required this.staff});

  @override
  Widget build(BuildContext context) {
    final leaves = staff.leaves as Map<String, dynamic>;
    final total   = (leaves['total']   as int?) ?? 0;
    final used    = (leaves['used']    as int?) ?? 0;
    final pending = (leaves['pending'] as int?) ?? 0;
    final balance = (leaves['balance'] as int?) ?? 0;

    return ListView(padding: const EdgeInsets.all(14), children: [
      // Leave stat chips
      Row(children: [
        _leaveStat('$total',   'Total',   AppColors.info),
        _leaveStat('$used',    'Used',    AppColors.error),
        _leaveStat('$pending', 'Pending', AppColors.warning),
        _leaveStat('$balance', 'Balance', AppColors.success),
      ]),
      const SizedBox(height: 14),

      _card('Leave Summary', Icons.event_note_outlined,
        Column(children: [
          _row('Total Leaves',      '$total'),
          _row('Leaves Used',       '$used'),
          _row('Pending Approval',  '$pending'),
          _row('Balance Leaves',    '$balance'),
        ]),
      ),
      const SizedBox(height: 12),

      // Leave utilization bar
      if (total > 0)
        _card('Leave Utilization', Icons.pie_chart_outline,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('$used used of $total',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('${(used * 100 / total).round()}%',
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: used / total,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.error),
                minHeight: 8,
              ),
            ),
          ]),
        ),
    ]);
  }

  Widget _leaveStat(String v, String l, Color c) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Column(children: [
        Text(v, style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(l, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ]),
    ),
  );
}

// ════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ════════════════════════════════════════════════════════════════

Widget _card(String title, IconData icon, Widget child) => Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.bgCard,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.border),
  ),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Icon(icon, color: AppColors.goldPrimary, size: 15),
      const SizedBox(width: 7),
      Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
    ]),
    const SizedBox(height: 12),
    child,
  ]),
);

Widget _row(String l, String v) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    Text(v, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
  ]),
);
