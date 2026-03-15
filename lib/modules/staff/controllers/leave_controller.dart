import 'package:acme_killer_mobile_app/models/staff/leave_model.dart';
import 'package:get/get.dart';

class LeaveController extends GetxController {
  var leaveRequests = <LeaveRequest>[].obs;

  void applyLeave(LeaveRequest leave) {
    leaveRequests.add(leave);
  }

  void approveLeave(String id) {
    int index = leaveRequests.indexWhere((e) => e.id == id);
    leaveRequests[index].status = "Approved";
    leaveRequests.refresh();
  }

  void rejectLeave(String id) {
    int index = leaveRequests.indexWhere((e) => e.id == id);
    leaveRequests[index].status = "Rejected";
    leaveRequests.refresh();
  }
}
