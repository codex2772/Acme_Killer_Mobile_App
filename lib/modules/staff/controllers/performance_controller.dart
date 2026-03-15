import 'package:get/get.dart';
import '../../../models/staff/staff_model.dart';

class StaffPerformanceController extends GetxController {

  List<Staff> sortBySales(List<Staff> staff) {

    staff.sort((a,b) => b.currentSales.compareTo(a.currentSales));

    return staff;
  }

  double totalSales(List<Staff> staff) {
    return staff.fold(0,(sum,e)=> sum + e.currentSales);
  }
}