import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';

class AttendanceScreen extends StatelessWidget {
  final controller = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),

      body: Column(
        children: [
          ElevatedButton(
            onPressed: controller.clockIn,
            child: const Text("Clock In"),
          ),

          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.attendanceList.length,
                itemBuilder: (_, i) {
                  final a = controller.attendanceList[i];

                  return ListTile(
                    title: Text(a.date),
                    subtitle: Text("In: ${a.clockIn}  Out: ${a.clockOut}"),
                    trailing: Text(a.status),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
