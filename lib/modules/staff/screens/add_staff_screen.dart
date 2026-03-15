import 'package:acme_killer_mobile_app/core/constants/app_colors.dart';
import 'package:acme_killer_mobile_app/models/staff/staff_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/staff_controller.dart';

class AddStaffScreen extends StatelessWidget {
  final controller = Get.find<StaffController>();

  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final salary = TextEditingController();
  final commission = TextEditingController();
  final target = TextEditingController();
  final aadhaar = TextEditingController();
  final pan = TextEditingController();

  final role = "staff".obs;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),

      appBar: AppBar(
        title: const Text(
          "Add Staff",
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        backgroundColor: AppColors.bgSecondary,
      ),

      body: Center(
        child: Container(
          width: width > 700 ? 700 : double.infinity,

          padding: const EdgeInsets.all(20),

          child: SingleChildScrollView(
            child: Column(
              children: [
                formRow(name, "Full Name"),
                formRow(phone, "Phone"),
                formRow(email, "Email"),

                const SizedBox(height: 10),

                formRow(salary, "Salary"),
                formRow(commission, "Commission %"),
                formRow(target, "Sales Target"),

                const SizedBox(height: 10),

                formRow(aadhaar, "Aadhaar"),
                formRow(pan, "PAN"),

                const SizedBox(height: 15),

                /// ROLE
                Obx(
                  () => Row(
                    children: [
                      roleBtn("admin"),
                      const SizedBox(width: 10),
                      roleBtn("staff"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffd4af37),
                    minimumSize: const Size(double.infinity, 50),
                  ),

                  onPressed: () {
                    controller.addStaff(
                      Staff(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),

                        name: name.text,
                        phone: phone.text,
                        email: email.text,

                        role: role.value,
                        store: "Main Store",

                        status: "Active",

                        salary: double.tryParse(salary.text) ?? 0,
                        commission: double.tryParse(commission.text) ?? 0,
                        salesTarget: double.tryParse(target.text) ?? 0,

                        currentSales: 0,

                        joinDate: DateTime.now().toString(),

                        permissions: [],
                        attendance: [],

                        leaves: {
                          "total": 24,
                          "used": 0,
                          "pending": 0,
                          "balance": 24,
                        },
                        storeIds: [],
                      ),
                    );

                    Get.back();
                  },

                  child: const Text(
                    "Save Staff",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget formRow(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: TextField(
        controller: c,

        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          labelText: label,

          labelStyle: const TextStyle(color: Colors.grey),

          filled: true,
          fillColor: const Color(0xff111827),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget roleBtn(String value) {
    return Expanded(
      child: GestureDetector(
        onTap: () => role.value = value,

        child: Container(
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),

            color: role.value == value
                ? const Color(0xffd4af37)
                : const Color(0xff1a1a2e),
          ),

          child: Center(
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                color: role.value == value ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
