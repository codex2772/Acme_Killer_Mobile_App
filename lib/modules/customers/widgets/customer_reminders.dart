import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/customer_controller.dart';
import '../../../models/customer_model.dart';

class CustomerReminders extends GetView<CustomerController> {
  const CustomerReminders({super.key});

  @override
  Widget build(BuildContext context) {
    final birthdays = controller.upcomingBirthdays;
    final anniversaries = controller.upcomingAnniversaries;

    if (birthdays.isEmpty && anniversaries.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text(
            "Upcoming Reminders",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),

        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...birthdays.map(
                (c) => reminderCard(c, "Birthday", Icons.cake, Colors.orange),
              ),

              ...anniversaries.map(
                (c) =>
                    reminderCard(c, "Anniversary", Icons.favorite, Colors.pink),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget reminderCard(
    Customer customer,
    String label,
    IconData icon,
    Color color,
  ) {
    final days = _daysRemaining(
      label == "Birthday" ? customer.dob : customer.anniversary,
    );

    return Container(
      width: 240,
      margin: const EdgeInsets.only(left: 14, bottom: 6),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bgCard, AppColors.bgCard.withOpacity(.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          /// AVATAR
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(.15),
            child: Text(
              customer.name[0],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),

                    const SizedBox(width: 4),

                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  customer.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  days == 0
                      ? "Today 🎉"
                      : days == 1
                      ? "Tomorrow"
                      : "In $days days",
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          /// NOTIFICATION ICON
          Icon(Icons.notifications_active, color: color, size: 20),
        ],
      ),
    );
  }

  int _daysRemaining(DateTime? date) {
    if (date == null) return 0;

    final today = DateTime.now();

    DateTime next = DateTime(today.year, date.month, date.day);

    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, date.month, date.day);
    }

    return next.difference(today).inDays;
  }
}
