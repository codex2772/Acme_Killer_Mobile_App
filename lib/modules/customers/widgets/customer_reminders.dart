import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/customer_controller.dart';
import '../../../models/customer_model.dart';

class CustomerReminders extends GetView<CustomerController> {
  const CustomerReminders({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reminders = controller.upcomingReminders;
      if (reminders.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(children: [
              const Icon(Icons.notifications_active_outlined,
                  color: AppColors.goldPrimary, size: 15),
              const SizedBox(width: 7),
              Text('Upcoming Reminders (${reminders.length})',
                  style: const TextStyle(color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ),
          SizedBox(
            height: 82,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: reminders.length,
              itemBuilder: (_, i) {
                final r = reminders[i];
                final customer = r['customer'] as Customer;
                final type    = r['type'] as String;
                final days    = r['days'] as int;
                final isBday  = type == 'birthday';

                final color   = isBday
                    ? const Color(0xFFEC4899)
                    : const Color(0xFFEF4444);

                return GestureDetector(
                  onTap: () => Get.toNamed(
                      '/customer-profile', arguments: customer),
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isBday ? Icons.cake_outlined : Icons.favorite_outline,
                            color: color, size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(customer.name,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600, fontSize: 12),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(
                                isBday ? 'Birthday' : 'Anniversary',
                                style: TextStyle(color: color, fontSize: 10),
                              ),
                              Text(
                                _label(days),
                                style: TextStyle(color: color,
                                    fontWeight: FontWeight.w600, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.snackbar('Wish Sent',
                                '${isBday ? "Birthday" : "Anniversary"} wish sent to ${customer.name}!',
                                backgroundColor: AppColors.bgCard,
                                colorText: AppColors.textPrimary,
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(12));
                          },
                          child: Icon(Icons.send_outlined, color: color, size: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
        ],
      );
    });
  }

  String _label(int days) {
    if (days == 0) return '🎉 Today!';
    if (days == 1) return 'Tomorrow';
    return 'In $days days';
  }
}
