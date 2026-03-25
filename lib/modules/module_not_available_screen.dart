import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../services/localization_service.dart';

// ════════════════════════════════════════════════════════════════════
// ModuleNotAvailableScreen
//
// Shown when a user navigates to a route whose module is disabled
// for the currently selected store.
//
// mirrors Electron router.js:
//   if (!isPageEnabled(state.currentPage)) {
//     app.innerHTML = `... Module Not Available ...`
//   }
// ════════════════════════════════════════════════════════════════════
class ModuleNotAvailableScreen extends StatelessWidget {
  const ModuleNotAvailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc        = Get.find<LocalizationService>();
    final moduleName = Get.arguments as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          loc.t('moduleNotAvailable'),
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon — matches Electron icon('lock', 48)
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.textMuted, size: 36),
              ),
              const SizedBox(height: 20),

              Obx(() => Text(
                loc.t('moduleNotAvailable'),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )),
              const SizedBox(height: 10),

              if (moduleName.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Text(
                    moduleName,
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              Obx(() => Text(
                loc.t('moduleNotAvailableDesc'),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              )),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                icon: const Icon(Icons.dashboard_outlined, size: 16, color: Colors.black),
                label: Obx(() => Text(
                  loc.t('goToDashboard'),
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
