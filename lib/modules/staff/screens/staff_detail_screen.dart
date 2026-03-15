import 'package:acme_killer_mobile_app/modules/staff/attendance/screens/attendance_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/document_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/leave_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/payroll_screen.dart';
import 'package:acme_killer_mobile_app/modules/staff/screens/performance_screen.dart';
import 'package:flutter/material.dart';
import 'package:acme_killer_mobile_app/models/staff/staff_model.dart';

class StaffDetailScreen extends StatelessWidget {
  final Staff staff;

  const StaffDetailScreen(this.staff, {super.key});

  @override
  Widget build(BuildContext context) {
    double targetPercent = 0;

    if (staff.salesTarget > 0) {
      targetPercent = staff.currentSales / staff.salesTarget;
    }

    double commissionEarned = (staff.currentSales * staff.commission) / 100;

    return DefaultTabController(
      length: 6,

      child: Scaffold(
        backgroundColor: const Color(0xff0f0f1a),

        appBar: AppBar(
          backgroundColor: const Color(0xff0f0f1a),
          elevation: 0,
          title: Text(staff.name),

          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Attendance"),
              Tab(text: "Performance"),
              Tab(text: "Leaves"),
              Tab(text: "Documents"),
              Tab(text: "Payroll"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            /// OVERVIEW TAB
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// PROFILE
                  profileHeader(),

                  const SizedBox(height: 20),

                  /// CONTACT
                  sectionCard("Contact Information", [
                    detailRow(Icons.phone, "Phone", staff.phone),
                    detailRow(Icons.email, "Email", staff.email),
                    detailRow(Icons.store, "Store", staff.store),
                    detailRow(Icons.calendar_today, "Joined", staff.joinDate),
                  ]),

                  const SizedBox(height: 16),

                  /// SALARY
                  sectionCard("Salary & Commission", [
                    detailRow(
                      Icons.currency_rupee,
                      "Salary",
                      "₹${staff.salary} / month",
                    ),

                    detailRow(
                      Icons.percent,
                      "Commission",
                      "${staff.commission}%",
                    ),

                    detailRow(
                      Icons.attach_money,
                      "Commission Earned",
                      "₹${commissionEarned.toStringAsFixed(0)}",
                    ),
                  ]),

                  const SizedBox(height: 16),

                  /// SALES TARGET
                  sectionCard("Sales Performance", [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Target Progress",
                          style: TextStyle(color: Colors.white),
                        ),

                        Text(
                          "₹${staff.currentSales} / ₹${staff.salesTarget}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),

                      child: LinearProgressIndicator(
                        value: targetPercent.clamp(0, 1),
                        minHeight: 8,
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
                  ]),

                  const SizedBox(height: 16),

                  /// LEAVES SUMMARY
                  sectionCard("Leave Summary", [
                    detailRow(
                      Icons.calendar_today,
                      "Total",
                      staff.leaves["total"].toString(),
                    ),

                    detailRow(
                      Icons.event_busy,
                      "Used",
                      staff.leaves["used"].toString(),
                    ),

                    detailRow(
                      Icons.pending,
                      "Pending",
                      staff.leaves["pending"].toString(),
                    ),

                    detailRow(
                      Icons.check_circle,
                      "Balance",
                      staff.leaves["balance"].toString(),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  /// PERMISSIONS
                  if (staff.permissions.isNotEmpty)
                    sectionCard("Permissions", [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,

                        children: staff.permissions.map((p) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              p,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ]),
                ],
              ),
            ),

            /// ATTENDANCE TAB
            AttendanceScreen(),

            /// PERFORMANCE TAB
            StaffPerformanceScreen(),

            /// LEAVES TAB
            LeaveScreen(),

            /// DOCUMENT TAB
            DocumentScreen(),

            /// PAYROLL TAB
            PayrollScreen(),
          ],
        ),
      ),
    );
  }

  /// PROFILE HEADER
  Widget profileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff1a1a2e),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xffd4af37),

            child: Text(
              staff.name.split(" ").map((e) => e[0]).take(2).join(),

              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  staff.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    roleBadge(),

                    const SizedBox(width: 8),

                    statusBadge(),
                  ],
                ),

                const SizedBox(height: 6),

                Text(staff.store, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ROLE BADGE
  Widget roleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

      decoration: BoxDecoration(
        color: staff.role == "admin"
            ? Colors.amber.withOpacity(.2)
            : Colors.blue.withOpacity(.2),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        staff.role.toUpperCase(),

        style: TextStyle(
          color: staff.role == "admin" ? Colors.amber : Colors.blue,
        ),
      ),
    );
  }

  /// STATUS BADGE
  Widget statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

      decoration: BoxDecoration(
        color: staff.status == "Active"
            ? Colors.green.withOpacity(.2)
            : Colors.red.withOpacity(.2),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        staff.status,

        style: TextStyle(
          color: staff.status == "Active" ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  /// SECTION CARD
  Widget sectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff1a1a2e),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          ...children,
        ],
      ),
    );
  }

  /// DETAIL ROW
  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),

          const SizedBox(width: 10),

          Text("$label:", style: const TextStyle(color: Colors.grey)),

          const SizedBox(width: 6),

          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
