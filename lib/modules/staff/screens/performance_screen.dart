import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/staff_controller.dart';

class StaffPerformanceScreen extends StatelessWidget {
  final StaffController controller = Get.find<StaffController>();

  StaffPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),

      body: Obx(() {
        final staffList = controller.staffList;

        final sorted = [...staffList];

        sorted.sort((a, b) => b.currentSales.compareTo(a.currentSales));

        return ListView.builder(
          padding: const EdgeInsets.all(16),

          itemCount: sorted.length,

          itemBuilder: (_, i) {
            final s = sorted[i];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xff1a1a2e),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xffd4af37),
                    child: Text(
                      "${i + 1}",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
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

                        const SizedBox(height: 4),

                        Text(
                          "Sales ₹${s.currentSales}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    "#${i + 1}",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
