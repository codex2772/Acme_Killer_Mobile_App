import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../controllers/customer_controller.dart';

class CustomerWishlistPreview extends StatelessWidget {
  final Customer customer;
  const CustomerWishlistPreview({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // mirrors Electron: Add wishlist item button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => _showAddWishlist(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.goldPrimary.withOpacity(0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 12, color: AppColors.goldPrimary),
                    SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (customer.wishlist.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No wishlist items',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ...customer.wishlist.map(
            (w) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.bookmark_outline,
                      color: AppColors.goldPrimary,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.itemName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Added ${_fmt(w.addedDate)}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    w.price,
                    style: const TextStyle(
                      color: AppColors.goldPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // mirrors Electron: remove wishlist item button
                  GestureDetector(
                    onTap: () => _removeItem(w),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // mirrors Electron: add wishlist item dialog
  void _showAddWishlist(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          'Add to Wishlist',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Item Name', nameCtrl),
            const SizedBox(height: 10),
            _field('Price (e.g. ₹2.5L)', priceCtrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              elevation: 0,
            ),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = priceCtrl.text.trim();
              if (name.isEmpty) return;
              final ctrl = Get.find<CustomerController>();
              final idx = ctrl.customers.indexWhere((c) => c.id == customer.id);
              if (idx != -1) {
                ctrl.customers[idx] = ctrl.customers[idx].copyWith(
                  wishlist: [
                    ...ctrl.customers[idx].wishlist,
                    WishlistItem(
                      itemName: name,
                      price: price.isEmpty ? '—' : price,
                      addedDate: DateTime.now().toIso8601String().substring(
                        0,
                        10,
                      ),
                    ),
                  ],
                );
                ctrl.customers.refresh();
              }
              Get.back();
              Get.snackbar(
                'Wishlist',
                '"$name" added to wishlist',
                backgroundColor: AppColors.bgCard,
                colorText: AppColors.success,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              );
            },
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // mirrors Electron: remove wishlist item
  void _removeItem(WishlistItem item) {
    final ctrl = Get.find<CustomerController>();
    final idx = ctrl.customers.indexWhere((c) => c.id == customer.id);
    if (idx != -1) {
      ctrl.customers[idx] = ctrl.customers[idx].copyWith(
        wishlist: ctrl.customers[idx].wishlist
            .where(
              (w) =>
                  w.itemName != item.itemName || w.addedDate != item.addedDate,
            )
            .toList(),
      );
      ctrl.customers.refresh();
    }
    Get.snackbar(
      'Removed',
      '"${item.itemName}" removed from wishlist',
      backgroundColor: AppColors.bgCard,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  Widget _field(String label, TextEditingController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ),
    ],
  );

  String _fmt(String d) {
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
