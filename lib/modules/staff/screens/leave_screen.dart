import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/leave_controller.dart';

class LeaveScreen extends StatelessWidget {
  final controller = Get.put(LeaveController());

  LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffd4af37),
        child: const Icon(Icons.add, color: Colors.black),

        onPressed: () {
          // controller.applyLeave();
        },
      ),

      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.all(16),

          itemCount: controller.leaveRequests.length,

          itemBuilder: (_, i) {
            final leave = controller.leaveRequests[i];

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
                    "Leave Request",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${leave.fromDate} → ${leave.toDate}",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      statusBadge(leave.status),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),

                            onPressed: () {
                              controller.approveLeave(leave.id);
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),

                            onPressed: () {
                              controller.rejectLeave(leave.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget statusBadge(String status) {
    Color color = Colors.orange;

    if (status == "Approved") color = Colors.green;
    if (status == "Rejected") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

      decoration: BoxDecoration(
        color: color.withOpacity(.2),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(status, style: TextStyle(color: color)),
    );
  }
}
