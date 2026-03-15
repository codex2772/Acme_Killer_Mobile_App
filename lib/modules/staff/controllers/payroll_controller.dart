import 'package:get/get.dart';
import '../../../models/staff/staff_model.dart';

class PayrollController extends GetxController {

  double calculateCommission(Staff staff) {
    return (staff.currentSales * staff.commission) / 100;
  }

  double totalSalary(Staff staff) {

    double commission = calculateCommission(staff);

    return staff.salary + commission;
  }
}