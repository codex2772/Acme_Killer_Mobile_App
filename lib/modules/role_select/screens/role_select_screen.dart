import 'package:acme_killer_mobile_app/core/constants/app_colors.dart';
import 'package:acme_killer_mobile_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// LOGO
              SvgPicture.asset("assets/login/logo.svg", height: 70),

              const SizedBox(height: 30),

              /// TITLE
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: "Select Your ",
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    TextSpan(
                      text: "Role",
                      style: TextStyle(color: AppColors.goldPrimary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Choose how you'd like to access JewelERP",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),

              const SizedBox(height: 40),

              /// OWNER
              _roleCard(
                title: "Owner",
                description:
                    "Full access to stores, staff management, reports & analytics",
                icon: Icons.storefront_rounded,
                features: const ["Multi Store", "Analytics", "Full Control"],
                color: AppColors.goldPrimary,
                onTap: () {
                  Get.offNamed(AppRoutes.login, arguments: "owner");
                },
              ),

              const SizedBox(height: 20),

              /// STAFF
              _roleCard(
                title: "Staff",
                description:
                    "Billing, inventory & customer management for store operations",
                icon: Icons.badge_rounded,
                features: const ["Billing", "Inventory", "Customers"],
                color: AppColors.info,
                onTap: () {
                  Get.toNamed(AppRoutes.login, arguments: "staff");
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// ROLE CARD
  Widget _roleCard({
    required String title,
    required String description,
    required IconData icon,
    required List<String> features,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.15),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            /// ICON
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 34),
            ),

            const SizedBox(height: 18),

            /// TITLE
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// DESCRIPTION
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            /// FEATURES
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: features
                  .map(
                    (f) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// ARROW
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
