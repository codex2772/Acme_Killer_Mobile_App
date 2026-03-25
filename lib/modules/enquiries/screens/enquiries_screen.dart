import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/enquiries_controller.dart';
import '../../../services/enquiries_service.dart';

// ════════════════════════════════════════════════════════════════════
// EnquiriesScreen — mirrors Electron renderEnquiries() / _renderEnquiriesPage()
// ════════════════════════════════════════════════════════════════════
class EnquiriesScreen extends GetView<EnquiriesController> {
  const EnquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text('Customer Enquiries',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: Column(children: [
        // ── Stats row ──────────────────────────────────────────────
        Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Row(children: [
            _chip('${controller.openCount}',      'Open',      AppColors.warning),
            _chip('${controller.respondedCount}', 'Responded', AppColors.success),
            _chip('${controller.closedCount}',    'Closed',    AppColors.textMuted),
          ]),
        )),

        // ── Search ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Container(
            decoration: BoxDecoration(color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search enquiries...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 11),
              ),
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),
        ),

        // ── Filter pills ───────────────────────────────────────────
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              _pill(controller, 'all',       'All (${controller.totalCount})'),
              _pill(controller, 'open',      'Open (${controller.openCount})'),
              _pill(controller, 'responded', 'Responded (${controller.respondedCount})'),
              _pill(controller, 'closed',    'Closed (${controller.closedCount})'),
            ],
          )),
        ),
        const SizedBox(height: 8),

        // ── List ───────────────────────────────────────────────────
        Expanded(child: Obx(() {
          if (controller.isLoading.value && controller.enquiries.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary));
          }
          final list = controller.filteredEnquiries;
          if (list.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.forum_outlined, color: AppColors.textMuted, size: 48),
              const SizedBox(height: 12),
              Text(
                controller.enquiries.isEmpty
                    ? 'No enquiries yet\nCustomer enquiries from the app appear here.'
                    : 'No enquiries match your search',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
            itemCount: list.length,
            itemBuilder: (_, i) => _EnquiryCard(enquiry: list[i], ctrl: controller),
          );
        })),
      ]),
    );
  }

  Widget _chip(String v, String l, Color c) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.3))),
      child: Column(children: [
        Text(v, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(l, style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
      ]),
    ),
  );

  Widget _pill(EnquiriesController c, String val, String label) => Obx(() {
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
        child: Text(label, style: TextStyle(
          color: active ? Colors.black : AppColors.goldPrimary,
          fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        )),
      ),
    );
  });
}

// ════════════════════════════════════════════════════════════════════
// Enquiry Card — mirrors Electron renderEnquiryCards()
// ════════════════════════════════════════════════════════════════════
class _EnquiryCard extends StatelessWidget {
  final Enquiry             enquiry;
  final EnquiriesController ctrl;
  const _EnquiryCard({required this.enquiry, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(enquiry.status);

    return GestureDetector(
      onTap: () {
        ctrl.selected.value = enquiry;
        Get.toNamed(AppRoutes.enquiryDetail, arguments: enquiry.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Thumbnail / placeholder ──
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: enquiry.hasImage
                ? Image.network(enquiry.imageUrl!, width: 56, height: 56, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          const SizedBox(width: 12),

          // ── Content ──
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Subject + status badge
              Row(children: [
                Expanded(child: Text(enquiry.subject,
                    style: const TextStyle(color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                _statusBadge(enquiry.status, statusColor),
              ]),
              const SizedBox(height: 4),

              // Message preview
              Text(enquiry.message,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 2, overflow: TextOverflow.ellipsis),

              const SizedBox(height: 8),

              // Meta row
              Wrap(spacing: 12, runSpacing: 4, children: [
                _meta(Icons.person_outline,    enquiry.customer),
                _meta(Icons.phone_outlined,    enquiry.phone.isEmpty ? '—' : enquiry.phone),
                _meta(Icons.schedule_outlined, '${enquiry.date}${enquiry.time.isNotEmpty ? ' ${enquiry.time}' : ''}'),
                if (enquiry.hasLinkedItem)
                  _meta(Icons.diamond_outlined, enquiry.jewelryItemName!),
                if (enquiry.hasImage)
                  _meta(Icons.image_outlined, 'Image attached'),
              ]),

              // Admin response preview
              if (enquiry.hasResponse) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                    border: Border(left: BorderSide(color: AppColors.goldPrimary, width: 2)),
                  ),
                  child: RichText(text: TextSpan(children: [
                    const TextSpan(text: 'Response: ',
                        style: TextStyle(color: AppColors.goldPrimary,
                            fontWeight: FontWeight.w600, fontSize: 12)),
                    TextSpan(
                      text: enquiry.adminResponse!.length > 100
                          ? '${enquiry.adminResponse!.substring(0, 100)}…'
                          : enquiry.adminResponse,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ])),
                ),
              ],
            ]),
          ),

          // ── Actions ──
          const SizedBox(width: 8),
          Column(mainAxisSize: MainAxisSize.min, children: [
            _iconBtn(Icons.visibility_outlined, AppColors.goldPrimary, () {
              ctrl.selected.value = enquiry;
              Get.toNamed(AppRoutes.enquiryDetail, arguments: enquiry.id);
            }),
            if (enquiry.isOpen) ...[
              const SizedBox(height: 6),
              _iconBtn(Icons.reply_outlined, AppColors.info, () {
                ctrl.selected.value = enquiry;
                _showRespondSheet(context, enquiry);
              }),
            ],
          ]),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 56, height: 56, color: AppColors.bgSecondary,
    child: const Icon(Icons.forum_outlined, color: AppColors.textMuted, size: 24),
  );

  Widget _statusBadge(String status, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.35))),
    child: Text(status, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  Widget _meta(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: AppColors.textMuted),
    const SizedBox(width: 3),
    Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
  ]);

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: color),
        ),
      );

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':      return AppColors.warning;
      case 'Responded': return AppColors.success;
      default:          return AppColors.textMuted;
    }
  }

  // ── Quick respond bottom sheet (mirrors Electron showRespondModal) ──
  void _showRespondSheet(BuildContext context, Enquiry enq) {
    final textCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Respond to ${enq.customer}',
              style: const TextStyle(color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(enq.subject,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8)),
            child: Text(enq.message,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border)),
            child: TextField(
              controller: textCtrl, maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Type your response to the customer...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final text = textCtrl.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(context);
                final ok = await ctrl.respond(enq.id, text);
                Get.snackbar(
                  ok ? 'Response Sent' : 'Failed',
                  ok ? 'Response sent to customer!' : 'Could not send response. Check connection.',
                  backgroundColor: AppColors.bgCard,
                  colorText: ok ? AppColors.success : AppColors.error,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(12),
                );
              },
              icon: const Icon(Icons.send_outlined, size: 16, color: Colors.black),
              label: const Text('Send Response',
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
      ),
    );
  }
}
