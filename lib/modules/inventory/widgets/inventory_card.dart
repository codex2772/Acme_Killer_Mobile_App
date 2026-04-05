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
    /// ✅ NULL-SAFE VALUES (CRASH FIX)
    final stockAge = item.stockAge;
    final quantity = item.quantity ?? 0;
    final margin = item.margin ?? 0.0;

    final status = item.status ?? '';
    final name = item.name ?? '';
    final category = item.category ?? '';
    final metal = item.metal ?? '';
    final purity = item.purity ?? '';
    final huid = item.huid ?? '';
    final showcaseLocation = item.showcaseLocation ?? '';
    final imageUrl = item.imageUrl ?? '';

    final netWeight = item.netWeight ?? 0;
    final formattedPrice = item.formattedPrice ?? '₹0';

    /// ✅ LOGIC (SAFE)
    final statusColor = _statusColor(status);

    final ageOld = stockAge > 90;
    final ageMid = stockAge > 30;

    final ageColor = ageOld
        ? AppColors.error
        : ageMid
        ? AppColors.warning
        : AppColors.success;

    final marginPct = margin.round();

    final qtyColor = quantity <= 0
        ? AppColors.error
        : quantity <= 2
        ? AppColors.warning
        : AppColors.success;

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
            /// ── Top row ──
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _metalColor(metal).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.diamond_outlined,
                              color: _metalColor(metal),
                              size: 20,
                            ),
                          ),
                        )
                      : Icon(
                          _metalIcon(metal),
                          color: _metalColor(metal),
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),

                /// Name + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$category  •  $metal $purity',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Price + status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedPrice,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _statusBadge(status, statusColor),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),

            /// ── Bottom row ──
            Row(
              children: [
                _meta(Icons.scale_outlined, '${netWeight}g'),
                const SizedBox(width: 10),
                _meta(Icons.tag_outlined, huid),

                if (showcaseLocation.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  _meta(Icons.location_on_outlined, showcaseLocation),
                ],

                const Spacer(),

                /// Quantity
                _badge(Icons.inventory_2_outlined, '$quantity', qtyColor),

                const SizedBox(width: 6),

                /// Age
                _badge(null, '${stockAge}d', ageColor),

                const SizedBox(width: 6),

                /// Margin
                _badge(
                  null,
                  '$marginPct%',
                  marginPct > 15 ? AppColors.success : AppColors.warning,
                ),

                const SizedBox(width: 6),

                /// Edit
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.textSecondary,
                      size: 14,
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

  /// ── Small reusable badge
  Widget _badge(IconData? icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _statusBadge(String status, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.35)),
    ),
    child: Text(
      status,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );

  Color _statusColor(String s) {
    switch (s) {
      case 'In Stock':
        return AppColors.success;
      case 'Low Stock':
        return AppColors.warning;
      case 'Sold':
      case 'Out of Stock':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  Color _metalColor(String m) {
    switch (m.toLowerCase()) {
      case 'gold':
        return AppColors.goldPrimary;
      case 'silver':
        return AppColors.info;
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'rose gold':
        return const Color(0xFFF4A7B9);
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _metalIcon(String m) {
    switch (m.toLowerCase()) {
      case 'silver':
        return Icons.circle_outlined;
      case 'platinum':
        return Icons.circle;
      default:
        return Icons.diamond_outlined;
    }
  }
}
