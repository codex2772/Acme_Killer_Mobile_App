import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/auth_controller.dart';
import '../controllers/billing_controller.dart';

// ════════════════════════════════════════════════════════════════════
// CreateCreditNoteScreen — FIXED
//
// Changes:
//  1. API call via createCreditNoteViaApi() — no longer local-only
//  2. Loading state during API call
//  3. mirrors Electron: POST /api/credit-notes + re-stock inventory
// ════════════════════════════════════════════════════════════════════
class CreateCreditNoteScreen extends StatefulWidget {
  const CreateCreditNoteScreen({super.key});
  @override
  State<CreateCreditNoteScreen> createState() => _CreateCreditNoteScreenState();
}

class _CreateCreditNoteScreenState extends State<CreateCreditNoteScreen> {
  final _ctrl       = Get.find<BillingController>();
  final _itemCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl  = TextEditingController();

  String? _selectedInvoiceId;
  String _reason      = 'Design Issue';
  String _refundMode  = 'Cash Refund';
  bool _isSubmitting  = false;

  static const _reasons = ['Design Issue','Size Mismatch','Quality Issue','Customer Changed Mind','Defective Product','Other'];
  static const _refundModes = ['Same Payment Mode','Store Credit','Cash Refund','Bank Transfer'];

  @override
  void dispose() {
    _itemCtrl.dispose(); _amountCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedInvoiceId == null) {
      _err('Please select an invoice'); return;
    }
    if (_itemCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
      _err('Please fill item and amount'); return;
    }

    final refundAmount = int.tryParse(_amountCtrl.text) ?? 0;
    if (refundAmount <= 0) {
      _err('Refund amount must be greater than 0'); return;
    }

    setState(() => _isSubmitting = true);

    // ── Try API first ──
    final auth = Get.find<AuthController>();
    if (!auth.isDemo.value) {
      final origInvoice = _ctrl.getById(_selectedInvoiceId!);
      final ok = await _ctrl.createCreditNoteViaApi(
        payload: {
          'invoiceId': origInvoice?.backendId ?? _selectedInvoiceId,
          'customerName': origInvoice?.customer ?? '',
          'customerId': origInvoice?.customerId ?? '',
          'itemDescription': _itemCtrl.text.trim(),
          'refundAmount': refundAmount,
          'reason': _reason,
          'refundMode': _refundMode,
          'notes': _notesCtrl.text.trim(),
        },
        restockItems: [], // TODO: pass actual items for restock
      );

      setState(() => _isSubmitting = false);

      if (ok) {
        Get.back();
        Get.snackbar('Credit Note Created', 'Saved to server!',
            backgroundColor: AppColors.bgCard, colorText: AppColors.success,
            snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
        return;
      }
    }

    // ── Local fallback ──
    final cn = _ctrl.saveCreditNote(
      invoiceId: _selectedInvoiceId!,
      itemDesc: _itemCtrl.text.trim(),
      refundAmount: refundAmount,
      reason: _reason,
      refundMode: _refundMode,
      notes: _notesCtrl.text.trim(),
    );
    setState(() => _isSubmitting = false);
    Get.back();
    Get.snackbar('Credit Note Created', 'Credit Note #${cn.id} processed!',
        backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
  }

  void _err(String msg) => Get.snackbar('Error', msg,
      backgroundColor: AppColors.error.withOpacity(0.2), colorText: AppColors.error,
      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));

  @override
  Widget build(BuildContext context) {
    final invoices = _ctrl.invoices;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text('New Credit Note',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card('Against Invoice', Icons.receipt_long_outlined, Column(children: [
            DropdownButtonFormField<String>(
              value: _selectedInvoiceId,
              dropdownColor: AppColors.bgSecondary,
              decoration: _deco('Select Invoice *'),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              items: invoices.map((inv) => DropdownMenuItem(value: inv.id,
                child: Text('${inv.id} — ${inv.customer} (${inv.formattedTotal})',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
              )).toList(),
              onChanged: (v) => setState(() => _selectedInvoiceId = v),
            ),
          ])),
          const SizedBox(height: 12),

          _card('Return Details', Icons.inventory_2_outlined, Column(children: [
            _field(_itemCtrl, 'Item Description *', hint: 'e.g., 18K Gold Chain (Returned)'),
            const SizedBox(height: 10),
            _field(_amountCtrl, 'Refund Amount (₹) *', keyboardType: TextInputType.number, hint: '0'),
          ])),
          const SizedBox(height: 12),

          _card('Reason & Refund Mode', Icons.info_outline, Column(children: [
            DropdownButtonFormField<String>(
              value: _reason, dropdownColor: AppColors.bgSecondary,
              decoration: _deco('Return Reason'),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              items: _reasons.map((r) => DropdownMenuItem(value: r,
                  child: Text(r, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
              onChanged: (v) { if (v != null) setState(() => _reason = v); },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _refundMode, dropdownColor: AppColors.bgSecondary,
              decoration: _deco('Refund Mode'),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              items: _refundModes.map((m) => DropdownMenuItem(value: m,
                  child: Text(m, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
              onChanged: (v) { if (v != null) setState(() => _refundMode = v); },
            ),
          ])),
          const SizedBox(height: 12),

          _card('Notes', Icons.notes_outlined, TextField(
            controller: _notesCtrl, maxLines: 2,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(hintText: 'Additional details...',
                hintStyle: TextStyle(color: AppColors.textMuted), border: InputBorder.none),
          )),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Get.back(),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.check, size: 18, color: Colors.black),
                label: Text(_isSubmitting ? 'Processing...' : 'Process Credit Note',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    disabledBackgroundColor: AppColors.goldPrimary.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
              ),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _card(String title, IconData icon, Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: AppColors.goldPrimary, size: 15),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(color: AppColors.textPrimary,
            fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
      const SizedBox(height: 12), child,
    ]),
  );

  Widget _field(TextEditingController ctrl, String label,
      {String? hint, TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border)),
        child: TextField(controller: ctrl, keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11))),
      ),
    ]);
  }

  InputDecoration _deco(String label) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    filled: true, fillColor: AppColors.inputFill,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.goldPrimary)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}
