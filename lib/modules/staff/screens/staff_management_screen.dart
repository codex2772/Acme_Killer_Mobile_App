import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/staff/staff_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/staff_controller.dart';

class StaffManagementScreen extends GetView<StaffController> {
  StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Staff Management',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addStaff),
              icon: const Icon(
                Icons.person_add_outlined,
                size: 14,
                color: Colors.black,
              ),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats row ──
          Obx(
            () => Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  _chip(
                    '${controller.totalStaff}',
                    'Total',
                    AppColors.goldPrimary,
                  ),
                  _chip(
                    '${controller.adminCount}',
                    'Admins',
                    const Color(0xFFF472B6),
                  ),
                  _chip('${controller.staffCount}', 'Staff', AppColors.info),
                  _chip(
                    '${controller.activeCount}',
                    'Active',
                    AppColors.success,
                  ),
                ],
              ),
            ),
          ),

          // ── Store overview ──
          const SizedBox(height: 12),
          Obx(
            () => SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: controller.storeOverview.length,
                itemBuilder: (_, i) =>
                    _StoreCard(data: controller.storeOverview[i]),
              ),
            ),
          ),

          // ── Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search staff...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                      ),
                      onChanged: (v) => controller.searchQuery.value = v,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Filter pills ──
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _pill(controller, 'all', 'All'),
                _pill(controller, 'admin', 'Admins'),
                _pill(controller, 'staff', 'Staff'),
                _pill(controller, 'active', 'Active'),
                _pill(controller, 'inactive', 'Inactive'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Staff list ──
          Expanded(
            child: Obx(() {
              final list = controller.filteredStaff;
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'No staff found',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
                itemCount: list.length,
                itemBuilder: (_, i) =>
                    _StaffCard(staff: list[i], ctrl: controller),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _chip(String v, String l, Color c) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            v,
            style: TextStyle(
              color: c,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            l,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    ),
  );

  Widget _pill(StaffController c, String val, String label) => Obx(() {
    final active = c.activeFilter.value == val;
    return GestureDetector(
      onTap: () => c.activeFilter.value = val,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.goldPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldPrimary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : AppColors.goldPrimary,
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  });
}

// ── Store Card ───────────────────────────────────────────────

class _StoreCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _StoreCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.store_outlined,
            color: AppColors.goldPrimary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data['short'] as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _badge('${data['admin']} Admin', const Color(0xFFF472B6)),
                    const SizedBox(width: 4),
                    _badge('${data['staff']} Staff', AppColors.info),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      t,
      style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w600),
    ),
  );
}

// ── Staff Card ───────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  final Staff staff;
  final StaffController ctrl;
  const _StaffCard({required this.staff, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isAdmin = staff.role == 'admin';
    final roleColor = isAdmin ? const Color(0xFFF472B6) : AppColors.info;
    final isActive = staff.status == 'Active';
    final pct = ctrl.targetPct(staff);

    return GestureDetector(
      onTap: () {
        ctrl.selectedStaff.value = staff;
        Get.toNamed(AppRoutes.staffDetail, arguments: staff.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ctrl.initials(staff.name),
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _roleBadge(isAdmin ? 'Admin' : 'Staff', roleColor),
                          const SizedBox(width: 6),
                          _statusDot(isActive),
                          const SizedBox(width: 4),
                          Text(
                            staff.status,
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.success
                                  : AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBtn(
                      Icons.visibility_outlined,
                      AppColors.goldPrimary,
                      () {
                        ctrl.selectedStaff.value = staff;
                        Get.toNamed(AppRoutes.staffDetail, arguments: staff.id);
                      },
                    ),
                    const SizedBox(width: 6),
                    _iconBtn(Icons.edit_outlined, AppColors.info, () {
                      ctrl.selectedStaff.value = staff;
                      Get.toNamed(AppRoutes.editStaff, arguments: staff.id);
                    }),
                    const SizedBox(width: 6),
                    _iconBtn(
                      isActive
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      isActive ? AppColors.error : AppColors.success,
                      () => ctrl.toggleStatus(staff.id),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Meta row
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _meta(
                  Icons.store_outlined,
                  staff.store.replaceAll('Rajmahal Jewellers - ', ''),
                ),
                _meta(Icons.phone_outlined, staff.phone),
                _meta(
                  Icons.currency_rupee_rounded,
                  '₹${(staff.salary / 1000).toStringAsFixed(0)}K/mo',
                ),
                _meta(
                  Icons.calendar_today_outlined,
                  'Joined ${_fmtDate(staff.joinDate)}',
                ),
              ],
            ),

            // Sales target bar (if set)
            if (staff.salesTarget > 0) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sales Target',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                  Text(
                    '$pct%  (${ctrl.fmt(staff.currentSales)} / ${ctrl.fmt(staff.salesTarget)})',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(
                    pct >= 80
                        ? AppColors.success
                        : pct >= 50
                        ? AppColors.warning
                        : AppColors.error,
                  ),
                  minHeight: 5,
                ),
              ),
            ],

            // Permissions summary
            const SizedBox(height: 10),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.textMuted,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'Permissions: ${staff.permissions.length}/${kAllPermissions.length}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                ...staff.permissions.take(4).map((p) {
                  final def = kAllPermissions.firstWhereOrNull(
                    (d) => d.id == p,
                  );
                  if (def == null) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      def.label
                          .replaceAll('View ', 'V: ')
                          .replaceAll('Manage ', 'M: ')
                          .replaceAll('Create ', 'C: ')
                          .replaceAll('Update ', 'U: '),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  );
                }),
                if (staff.permissions.length > 4)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '+${staff.permissions.length - 4}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBadge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withOpacity(0.35)),
    ),
    child: Text(
      t,
      style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );

  Widget _statusDot(bool active) => Container(
    width: 7,
    height: 7,
    decoration: BoxDecoration(
      color: active ? AppColors.success : AppColors.textMuted,
      shape: BoxShape.circle,
    ),
  );

  Widget _meta(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
      ),
    ],
  );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      );

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return d;
    }
  }
}
