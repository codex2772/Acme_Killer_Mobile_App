import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onNewInvoice;
  final VoidCallback? onEdit;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    this.onWhatsApp,
    this.onNewInvoice,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = _tierColor(customer.loyaltyTier);
    final typeColor = _typeColor(customer.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                // Avatar
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: typeColor.withOpacity(0.4), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(customer.initials,
                      style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name,
                          style: const TextStyle(color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        _typeBadge(customer.type, typeColor),
                        const SizedBox(width: 6),
                        _tierBadge(customer.loyaltyTier, tierColor),
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${customer.loyaltyPoints}', style: TextStyle(
                        color: tierColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('pts', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Meta row ──
            Row(children: [
              _meta(Icons.phone_outlined, customer.phone),
              const SizedBox(width: 14),
              _meta(Icons.location_on_outlined, customer.city),
              if (customer.daysUntilBirthday != null && customer.daysUntilBirthday! <= 30) ...[
                const SizedBox(width: 14),
                _meta(Icons.cake_outlined, _daysLabel(customer.daysUntilBirthday!),
                    color: const Color(0xFFEC4899)),
              ],
            ]),

            // ── Tags ──
            if (customer.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 4,
                  children: customer.tags.take(3).map((t) => _tag(t)).toList()),
            ],

            const SizedBox(height: 10),

            // ── Stats ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat(customer.totalPurchasesFormatted, 'Spent'),
                  _vertDiv(),
                  _stat('${customer.purchaseHistory.length}', 'Orders'),
                  _vertDiv(),
                  _stat(customer.hasOutstanding ? customer.outstandingDisplay : '₹0',
                      customer.hasOutstanding ? 'Due' : 'No Dues',
                      valueColor: customer.hasOutstanding ? AppColors.error : AppColors.success),
                ],
              ),
            ),

            // ── Wishlist peek ──
            if (customer.wishlist.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.bookmark_border_outlined, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('${customer.wishlist.length} wishlist item${customer.wishlist.length > 1 ? 's' : ''}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ]),
            ],

            const SizedBox(height: 10),

            // ── Action buttons ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _iconBtn(Icons.visibility_outlined, AppColors.goldPrimary, onTap),
                const SizedBox(width: 6),
                _iconBtn(Icons.message_outlined, const Color(0xFF25D366), onWhatsApp),
                const SizedBox(width: 6),
                _iconBtn(Icons.receipt_long_outlined, AppColors.info, onNewInvoice),
                const SizedBox(width: 6),
                _iconBtn(Icons.edit_outlined, AppColors.textSecondary, onEdit),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text, {Color? color}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: color ?? AppColors.textMuted),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: color ?? AppColors.textMuted, fontSize: 11),
          maxLines: 1, overflow: TextOverflow.ellipsis),
    ],
  );

  Widget _typeBadge(String type, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.35)),
    ),
    child: Text(type, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  Widget _tierBadge(String tier, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.star_rounded, size: 9, color: color),
      const SizedBox(width: 3),
      Text(tier, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _tag(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(t, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
  );

  Widget _stat(String val, String label, {Color? valueColor}) => Column(children: [
    Text(val, style: TextStyle(
        color: valueColor ?? AppColors.textPrimary,
        fontWeight: FontWeight.bold, fontSize: 12)),
    Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
  ]);

  Widget _vertDiv() => Container(height: 28, width: 1, color: AppColors.border);

  Widget _iconBtn(IconData icon, Color color, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icon, size: 14, color: color),
    ),
  );

  Color _typeColor(String t) {
    switch (t.toLowerCase()) {
      case 'vip':     return const Color(0xFFD4AF37);
      case 'premium': return AppColors.info;
      default:        return AppColors.textSecondary;
    }
  }

  Color _tierColor(String t) {
    switch (t) {
      case 'Platinum': return const Color(0xFFE2E8F0);
      case 'Gold':     return AppColors.goldPrimary;
      case 'Bronze':   return const Color(0xFFCD7F32);
      default:         return const Color(0xFF94A3B8);
    }
  }

  String _daysLabel(int days) {
    if (days == 0) return '🎉 Today!';
    if (days == 1) return 'Tomorrow';
    return 'In ${days}d';
  }
}
