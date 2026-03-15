import 'package:acme_killer_mobile_app/core/controllers/store_controller.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/staff_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/staff_controller.dart';
import '../widgets/staff_card.dart';
import 'add_staff_screen.dart';

class StaffManagementScreen extends StatelessWidget {
  final StaffController controller = Get.put(StaffController());
  final StoreController storeController = Get.find<StoreController>();

  StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxis = 1;
    if (width > 700) crossAxis = 2;
    if (width > 1100) crossAxis = 3;

    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),

      appBar: AppBar(
        backgroundColor: const Color(0xff0f0f1a),
        elevation: 0,
        title: const Text(
          "Staff Management",
          style: TextStyle(color: Colors.white),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffd4af37),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              onPressed: () => Get.to(() => AddStaffScreen()),
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                "Add Staff",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          /// HEADER CONTENT
          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// STATS
                Obx(() {
                  final list = controller.staffList;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      statCard("Total Staff", list.length),
                      statCard(
                        "Admins",
                        list.where((e) => e.role == "admin").length,
                      ),
                      statCard(
                        "Staff",
                        list.where((e) => e.role == "staff").length,
                      ),
                      statCard(
                        "Active",
                        list.where((e) => e.status == "Active").length,
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 20),

                /// SEARCH + STORE FILTER
                Row(
                  children: [
                    /// SEARCH
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),

                        decoration: BoxDecoration(
                          color: const Color(0xff111827),
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: TextField(
                          style: const TextStyle(color: Colors.white),

                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.grey),
                            hintText: "Search staff...",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),

                          onChanged: (v) => controller.search.value = v,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// STORE SELECTOR
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),

                        decoration: BoxDecoration(
                          color: const Color(0xff111827),
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: storeController.selectedStore.value,
                            dropdownColor: const Color(0xff1a1a2e),

                            iconEnabledColor: Colors.white,

                            items: storeController.stores.map((store) {
                              return DropdownMenuItem(
                                value: store,
                                child: Text(
                                  store,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),

                            onChanged: (v) {
                              storeController.changeStore(v);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// FILTER PILLS
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    filter("all", "All"),
                    filter("admin", "Admins"),
                    filter("staff", "Staff"),
                    filter("active", "Active"),
                    filter("inactive", "Inactive"),
                  ],
                ),
              ],
            ),
          ),

          /// STAFF GRID
          Expanded(
            child: Obx(
              () => GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                itemCount: controller.filteredStaff.length,

                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxis,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.65,
                ),

                itemBuilder: (_, i) {
                  final staff = controller.filteredStaff[i];

                  return GestureDetector(
                    onTap: () => Get.to(() => StaffDetailScreen(staff)),
                    child: StaffCard(staff),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// FILTER BUTTON
  Widget filter(String value, String label) {
    final controller = Get.find<StaffController>();

    return Obx(
      () => GestureDetector(
        onTap: () => controller.filter.value = value,

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

          decoration: BoxDecoration(
            color: controller.filter.value == value
                ? const Color(0xffd4af37)
                : Colors.transparent,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(color: const Color(0xffd4af37)),
          ),

          child: Text(
            label,
            style: TextStyle(
              color: controller.filter.value == value
                  ? Colors.black
                  : const Color(0xffd4af37),
            ),
          ),
        ),
      ),
    );
  }

  /// STAT CARD
  Widget statCard(String title, int value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$value",
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
