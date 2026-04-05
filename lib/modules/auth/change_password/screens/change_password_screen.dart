import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: controller.isForced
          ? null
          : AppBar(
              backgroundColor: AppColors.bgPrimary,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary, size: 18),
                onPressed: () => Get.back(),
              ),
              title: const Text('Change Password',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isForced) ...[
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded,
                        color: AppColors.goldPrimary, size: 38),
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text('Set New Password',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('Your account requires a password change\nbefore you can continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5)),
                ),
                const SizedBox(height: 32),
              ] else
                const SizedBox(height: 8),

              _label('Current Password'),
              const SizedBox(height: 8),
              Obx(() => _passField(
                    ctrl: controller.currentCtrl,
                    hint: 'Enter current password',
                    obscure: controller.obscureCurrent.value,
                    onToggle: controller.obscureCurrent.toggle,
                  )),
              const SizedBox(height: 16),

              _label('New Password'),
              const SizedBox(height: 8),
              Obx(() => _passField(
                    ctrl: controller.newCtrl,
                    hint: 'Min. 6 characters',
                    obscure: controller.obscureNew.value,
                    onToggle: controller.obscureNew.toggle,
                  )),
              const SizedBox(height: 16),

              _label('Confirm New Password'),
              const SizedBox(height: 8),
              Obx(() => _passField(
                    ctrl: controller.confirmCtrl,
                    hint: 'Re-enter new password',
                    obscure: controller.obscureConfirm.value,
                    onToggle: controller.obscureConfirm.toggle,
                  )),
              const SizedBox(height: 16),

              // rules hint
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Password requirements',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _rule('At least 6 characters'),
                    _rule('Mix of letters and numbers recommended'),
                    _rule('Avoid using your mobile number'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // error
              Obx(() => controller.error.value.isEmpty
                  ? const SizedBox.shrink()
                  : _banner(controller.error.value, AppColors.error, Icons.error_outline)),

              // success
              Obx(() => controller.success.value.isEmpty
                  ? const SizedBox.shrink()
                  : _banner(controller.success.value, AppColors.success,
                      Icons.check_circle_outline)),

              const SizedBox(height: 4),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        disabledBackgroundColor: AppColors.goldPrimary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2.5))
                          : const Text('Update Password',
                              style: TextStyle(
                                  color: AppColors.black, fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    )),
              ),

              if (!controller.isForced) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: controller.skip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Skip for now'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500));

  Widget _passField({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: ctrl,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.textSecondary, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary, size: 20,
              ),
              onPressed: onToggle,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
          ),
        ),
      );

  Widget _banner(String msg, Color color, IconData ico) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(ico, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: TextStyle(color: color, fontSize: 13))),
          ],
        ),
      );

  Widget _rule(String t) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 13),
            const SizedBox(width: 6),
            Text(t, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      );
}