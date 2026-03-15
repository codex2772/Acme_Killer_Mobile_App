import 'package:get/get.dart';
import '../controllers/staff_controller.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StaffController>(StaffController(), permanent: true);
  }
}
