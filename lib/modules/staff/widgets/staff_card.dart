import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acme_killer_mobile_app/models/staff/staff_model.dart';
import '../controllers/staff_controller.dart';
import '../screens/staff_detail_screen.dart';

class StaffCard extends StatelessWidget {
  final Staff staff;

  StaffCard(this.staff);

  final controller = Get.find<StaffController>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isTablet = width > 600;

    double targetPercent = 0;

    if (staff.salesTarget > 0) {
      targetPercent = staff.currentSales / staff.salesTarget;
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 14),
      decoration: BoxDecoration(
        color: const Color(0xff1a1a2e),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),

      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,

              children: [
                /// TOP ROW
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: isTablet ? 26 : 22,
                      backgroundColor: const Color(0xffd4af37),

                      child: Text(
                        staff.name.split(" ").map((e) => e[0]).take(2).join(),

                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// NAME + ROLE
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),

                            decoration: BoxDecoration(
                              color: staff.role == "admin"
                                  ? Colors.amber.withOpacity(.2)
                                  : Colors.blue.withOpacity(.2),

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              staff.role.toUpperCase(),

                              style: TextStyle(
                                color: staff.role == "admin"
                                    ? Colors.amber
                                    : Colors.blue,
                                fontSize: isTablet ? 12 : 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// STATUS DOT
                    Container(
                      width: 10,
                      height: 10,

                      decoration: BoxDecoration(
                        color: staff.status == "Active"
                            ? Colors.green
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// META INFO
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    info(Icons.store, staff.store),

                    info(Icons.phone, staff.phone),

                    info(
                      Icons.currency_rupee,
                      "₹${staff.salary.toStringAsFixed(0)}/mo",
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// SALES TARGET
                if (staff.salesTarget > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Sales Target",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),

                      Text(
                        "₹${staff.currentSales} / ₹${staff.salesTarget}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),

                    child: LinearProgressIndicator(
                      value: targetPercent.clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: Colors.white12,

                      valueColor: AlwaysStoppedAnimation<Color>(
                        targetPercent >= .8
                            ? Colors.green
                            : targetPercent >= .5
                            ? Colors.orange
                            : Colors.red,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                /// PERMISSIONS
                if (staff.permissions.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,

                    children: staff.permissions
                        .take(isTablet ? 4 : 3)
                        .map(
                          (p) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              p,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                const SizedBox(height: 6),

                /// ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,

                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.white70),

                      onPressed: () {
                        Get.to(() => StaffDetailScreen(staff));
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),

                      onPressed: () {
                        // Get.to(() => AddStaffScreen(staff));
                      },
                    ),

                    IconButton(
                      icon: Icon(
                        staff.status == "Active"
                            ? Icons.toggle_on
                            : Icons.toggle_off,

                        color: staff.status == "Active"
                            ? Colors.green
                            : Colors.grey,

                        size: isTablet ? 32 : 28,
                      ),

                      onPressed: () {
                        controller.toggleStatus(staff.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// META INFO
  Widget info(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,

      children: [
        Icon(icon, size: 14, color: Colors.grey),

        const SizedBox(width: 4),

        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
