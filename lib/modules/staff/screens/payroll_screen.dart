import 'package:acme_killer_mobile_app/modules/staff/controllers/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payroll_controller.dart';

class PayrollScreen extends StatelessWidget {

  final payroll = Get.put(PayrollController());
  final staff = Get.find<StaffController>();

  PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),

      body: ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: staff.staffList.length,

        itemBuilder: (_, i) {

          final s = staff.staffList[i];

          final commission = payroll.calculateCommission(s);
          final total = payroll.totalSalary(s);

          return Container(

            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: const Color(0xff1a1a2e),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  s.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                row("Base Salary", "₹${s.salary}"),
                row("Commission", "₹${commission.toStringAsFixed(0)}"),
                row("Total Salary", "₹${total.toStringAsFixed(0)}"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget row(String label, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}