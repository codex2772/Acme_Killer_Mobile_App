import 'package:acme_killer_mobile_app/models/staff/attendance_model.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  var attendanceList = <Attendance>[].obs;

  void clockIn() {
    attendanceList.add(
      Attendance(
        date: DateTime.now().toString(),
        clockIn: DateTime.now().toString(),
        status: "Present",
      ),
    );
  }

  void clockOut(int index) {
    attendanceList[index].clockOut = DateTime.now().toString();
    attendanceList.refresh();
  }
}
