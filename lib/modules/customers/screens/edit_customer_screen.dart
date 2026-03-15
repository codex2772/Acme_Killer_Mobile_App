import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../controllers/customer_controller.dart';
import '../widgets/customer_form.dart';

class EditCustomerScreen extends StatelessWidget {
  EditCustomerScreen({super.key});

  final controller = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    final Customer customer = Get.arguments;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text(
          "Edit Customer",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),

      body: CustomerForm(
        customer: customer,
        onSubmit: (updatedCustomer) {
          controller.deleteCustomer(customer.id);
          controller.addCustomer(updatedCustomer);
          Get.back();
        },
      ),
    );
  }
}
