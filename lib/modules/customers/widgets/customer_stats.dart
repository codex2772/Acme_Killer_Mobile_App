import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/customer_controller.dart';

class CustomerStats extends GetView<CustomerController> {
  const CustomerStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(children: [
        _chip('${controller.totalCount}',     'Total',       AppColors.info),
        _chip('${controller.vipCount}',        'VIP',         AppColors.goldPrimary),
        _chip(controller.lifetimeRevenueFormatted, 'Revenue', AppColors.success),
        _chip('${controller.outstandingCount}','Outstanding', AppColors.error),
      ]),
    ));
  }

  Widget _chip(String val, String label, Color color) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(val, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ]),
    ),
  );
}
