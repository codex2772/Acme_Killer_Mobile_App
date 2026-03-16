import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/inventory_model.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const InventoryCard({super.key, required this.item, this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);
    final ageOld  = item.stockAge > 90;
    final ageMid  = item.stockAge > 30;
    final ageColor = ageOld ? AppColors.error : ageMid ? AppColors.warning : AppColors.success;
    final marginPct = item.margin.round();

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
            // ── Top row ──
            Row(
              children: [
                // Metal icon
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: _metalColor(item.metal).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_metalIcon(item.metal),
                      color: _metalColor(item.metal), size: 20),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text('${item.category}  •  ${item.metal} ${item.purity}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item.formattedPrice,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 3),
                    _statusBadge(item.status, statusColor),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),

            // ── Bottom meta row ──
            Row(
              children: [
                _meta(Icons.scale_outlined, '${item.netWeight}g'),
                const SizedBox(width: 14),
                _meta(Icons.tag_outlined, item.huid),
                const Spacer(),

                // Age badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: ageColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${item.stockAge}d',
                      style: TextStyle(color: ageColor, fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),

                // Margin badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: (marginPct > 15 ? AppColors.success : AppColors.warning)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('$marginPct%',
                      style: TextStyle(
                          color: marginPct > 15 ? AppColors.success : AppColors.warning,
                          fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),

                // Edit button
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: AppColors.textSecondary, size: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          maxLines: 1, overflow: TextOverflow.ellipsis),
    ],
  );

  Widget _statusBadge(String status, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.35)),
    ),
    child: Text(status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  Color _statusColor(String s) {
    switch (s) {
      case 'In Stock':  return AppColors.success;
      case 'Low Stock': return AppColors.warning;
      case 'Sold':      return AppColors.error;
      default:          return AppColors.info;
    }
  }

  Color _metalColor(String m) {
    switch (m.toLowerCase()) {
      case 'gold':     return AppColors.goldPrimary;
      case 'silver':   return AppColors.info;
      case 'platinum': return const Color(0xFFE5E4E2);
      case 'rose gold':return const Color(0xFFF4A7B9);
      default:         return AppColors.textSecondary;
    }
  }

  IconData _metalIcon(String m) {
    switch (m.toLowerCase()) {
      case 'silver':   return Icons.circle_outlined;
      case 'platinum': return Icons.circle;
      default:         return Icons.circle;
    }
  }
}
