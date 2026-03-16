import 'package:flutter/material.dart';
import 'package:acme_killer_mobile_app/core/constants/app_colors.dart';
import '../controllers/dashboard_controller.dart';

class RecentInvoiceRow extends StatelessWidget {
  final DashInvoice invoice;
  final VoidCallback? onTap;

  const RecentInvoiceRow({super.key, required this.invoice, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(invoice.status);
    final typeLabel = invoice.type == 'credit-note'
        ? 'Credit Note'
        : invoice.type == 'estimate'
            ? 'Estimate'
            : 'Invoice';
    final typeColor = invoice.type == 'credit-note'
        ? AppColors.error
        : invoice.type == 'estimate'
            ? AppColors.warning
            : AppColors.info;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            // Invoice icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  color: AppColors.goldPrimary, size: 17),
            ),
            const SizedBox(width: 12),

            // Customer + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoice.customer,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(invoice.id,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(typeLabel,
                            style: TextStyle(
                                color: typeColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount + status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(invoice.formattedAmount,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(invoice.status,
                        style: TextStyle(color: statusColor, fontSize: 10)),
                  ],
                ),
              ],
            ),

            // Date
            const SizedBox(width: 10),
            Text(invoice.formattedDate,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':    return AppColors.success;
      case 'Pending': return AppColors.warning;
      case 'Partial': return AppColors.info;
      default:        return AppColors.textSecondary;
    }
  }
}
