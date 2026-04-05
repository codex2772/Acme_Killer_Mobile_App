import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/enquiries_controller.dart';
import '../../../services/enquiries_service.dart';

// ════════════════════════════════════════════════════════════════════
// EnquiryDetailScreen — mirrors Electron renderEnquiryDetail()
// ════════════════════════════════════════════════════════════════════
class EnquiryDetailScreen extends StatefulWidget {
  const EnquiryDetailScreen({super.key});

  @override
  State<EnquiryDetailScreen> createState() => _EnquiryDetailScreenState();
}

class _EnquiryDetailScreenState extends State<EnquiryDetailScreen> {
  late final EnquiriesController _ctrl;
  late final Enquiry? _enquiry;
  final _responseCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<EnquiriesController>();
    final id = Get.arguments;
    _enquiry = _ctrl.enquiries.firstWhereOrNull(
      (e) => e.id.toString() == id.toString(),
    );

    // Preselect if not already
    if (_enquiry != null) _ctrl.selected.value = _enquiry;
  }

  @override
  void dispose() {
    _responseCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.warning;
      case 'Responded':
        return AppColors.success;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_enquiry == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enquiry not found',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final enq = _enquiry!;
    final statusColor = _statusColor(enq.status);

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
          'Enquiry Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        actions: [
          if (enq.status != 'Closed')
            TextButton(
              onPressed: _closeEnquiry,
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Subject + Status ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        enq.subject,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        enq.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${enq.date}${enq.time.isNotEmpty ? " at ${enq.time}" : ""}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),

                // Message body
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    enq.message.isEmpty ? 'No message provided.' : enq.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),

                // Attached image
                if (enq.hasImage) ...[
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: AppColors.textMuted,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Attached Image',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      enq.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        height: 80,
                        color: AppColors.bgSecondary,
                        child: const Center(
                          child: Text(
                            'Image unavailable',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Admin response (if exists) ───────────────────────────
          if (enq.hasResponse) ...[
            _card(
              'Your Response',
              Icons.reply_outlined,
              AppColors.goldPrimary,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(
                          color: AppColors.goldPrimary,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      enq.adminResponse!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (enq.respondedAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Responded ${enq.respondedAt!.substring(0, 10)}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Response box (if open and no response yet) ───────────
          if (enq.isOpen && !enq.hasResponse) ...[
            _card(
              'Write Response',
              Icons.forum_outlined,
              AppColors.info,
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _responseCtrl,
                      maxLines: 4,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Type your response to the customer...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _closeEnquiry,
                          icon: const Icon(Icons.archive_outlined, size: 16),
                          label: const Text('Close Without Reply'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _isSending ? null : _sendResponse,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_outlined,
                                  size: 16,
                                  color: Colors.black,
                                ),
                          label: const Text(
                            'Send Response',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Customer Info ────────────────────────────────────────
          _card(
            'Customer Info',
            Icons.person_outline,
            AppColors.info,
            Column(
              children: [
                _infoRow('Name', enq.customer),
                _infoRow('Phone', enq.phone.isEmpty ? '—' : enq.phone),
                if (enq.email != null) _infoRow('Email', enq.email!),
                _infoRow('Store', enq.store.isEmpty ? '—' : enq.store),
                _infoRow('Submitted', enq.date),
                const SizedBox(height: 10),
                // Call + WhatsApp buttons (mirrors Electron detail actions)
                if (enq.phone.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          // mirrors Electron: href="tel:{phone}"
                          onPressed: () async {
                            final url = Uri.parse('tel:${enq.phone}');
                            if (await canLaunchUrl(url)) await launchUrl(url);
                          },
                          icon: const Icon(Icons.phone_outlined, size: 14),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          // mirrors Electron: wa.me/91{phone}
                          onPressed: () async {
                            final raw = enq.phone.replaceAll(
                              RegExp(r'[^\d]'),
                              '',
                            );
                            final wa = raw.startsWith('91') ? raw : '91$raw';
                            final msg = Uri.encodeComponent(
                              'Hello ${enq.customer}, regarding your enquiry: "${enq.subject}"',
                            );
                            final url = Uri.parse(
                              'https://wa.me/$wa?text=$msg',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 14),
                          label: const Text('WhatsApp'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: BorderSide(
                              color: AppColors.success.withOpacity(0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Linked jewelry item ──────────────────────────────────
          if (enq.hasLinkedItem)
            _card(
              'Linked Item',
              Icons.diamond_outlined,
              AppColors.goldPrimary,
              Column(
                children: [
                  _infoRow('Item', enq.jewelryItemName!),
                  if (enq.jewelryItemSku != null)
                    _infoRow('SKU', enq.jewelryItemSku!),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // ── View customer button ─────────────────────────────────
          if (enq.customerId != null)
            OutlinedButton.icon(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.customerProfile,
                  arguments: enq.customerId.toString(),
                );
              },
              icon: const Icon(Icons.person_search_outlined, size: 16),
              label: const Text('View Customer Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Send response ────────────────────────────────────────────────
  Future<void> _sendResponse() async {
    final text = _responseCtrl.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please write a response',
        backgroundColor: AppColors.error.withOpacity(0.2),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    setState(() => _isSending = true);
    final ok = await _ctrl.respond(_enquiry!.id, text);
    setState(() => _isSending = false);
    Get.snackbar(
      ok ? 'Response Sent!' : 'Failed',
      ok ? 'Customer will be notified.' : 'Could not send. Check connection.',
      backgroundColor: AppColors.bgCard,
      colorText: ok ? AppColors.success : AppColors.error,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
    if (ok) Get.back();
  }

  // ── Close enquiry ────────────────────────────────────────────────
  Future<void> _closeEnquiry() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          'Close Enquiry',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to close this enquiry?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
            ),
            child: const Text('Close', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await _ctrl.close(_enquiry!.id);
    Get.snackbar(
      ok ? 'Enquiry Closed' : 'Failed',
      ok ? 'Enquiry marked as closed.' : 'Could not close. Check connection.',
      backgroundColor: AppColors.bgCard,
      colorText: ok ? AppColors.textPrimary : AppColors.error,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
    if (ok) Get.back();
  }

  // ── Shared helpers ───────────────────────────────────────────────
  Widget _card(String title, IconData icon, Color accent, Widget child) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: 15),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}
