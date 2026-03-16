import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';

class CustomerWishlistPreview extends StatelessWidget {
  final Customer customer;
  const CustomerWishlistPreview({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    if (customer.wishlist.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No wishlist items',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    return Column(
      children: customer.wishlist.map((w) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bookmark_outline,
                color: AppColors.goldPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(w.itemName, style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 2),
            Text('Added ${_fmt(w.addedDate)}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
          Text(w.price, style: const TextStyle(
              color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      )).toList(),
    );
  }

  String _fmt(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month-1]} ${dt.year}';
    } catch (_) { return d; }
  }
}
