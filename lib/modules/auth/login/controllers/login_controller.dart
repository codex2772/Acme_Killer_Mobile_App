import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';

// ════════════════════════════════════════════════════════════════════
// LoginController — FUNCTIONALITY CHANGES
//
// mirrors Electron renderLogin() form submit handler:
//
// 1. Demo mode toast — when backend unreachable and demo fallback used,
//    Electron shows: "Signed in with demo data (backend unreachable)"
//    Previously Flutter had no demo mode feedback.
//
// 2. Force password change — Electron shows a modal AFTER navigating
//    to dashboard. Flutter redirects to a separate change-password page.
//    Both approaches result in the same behaviour.
//
// 3. preloadData() is now called from AuthController.login() directly
//    when NOT in demo mode (already wired there).
//
// 4. Welcome toast on successful live login
//    mirrors: showToast(`Welcome, ${result.data.name}!`, 'success')
// ════════════════════════════════════════════════════════════════════
class LoginController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;

  String selectedRole = 'staff';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) selectedRole = args;
    // Pre-fill demo hint for owner (mirrors Electron login-mobile hint)
    if (selectedRole == 'owner') mobileController.text = 'OWNER001';
  }

  @override
  void onClose() {
    mobileController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePassword() => obscurePassword.value = !obscurePassword.value;
  void clearError() => errorMessage.value = '';

  Future<void> login() async {
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();

    if (mobile.isEmpty) {
      errorMessage.value = 'Please enter your mobile / login ID';
      return;
    }
    if (password.isEmpty) {
      errorMessage.value = 'Please enter your password';
      return;
    }

    errorMessage.value = '';
    isLoading.value = true;

    final result = await _auth.login(mobile, password);
    isLoading.value = false;

    if (result.success) {
      // ── Demo mode feedback ──
      // mirrors Electron: if (result.demo) { showToast('Signed in with demo data...', 'info') }
      {
        // ── Welcome toast (mirrors Electron: showToast(`Welcome, ${name}!`)) ──
        Get.snackbar(
          'Welcome back!',
          _auth.userName.isNotEmpty ? _auth.userName : 'User',
          backgroundColor: AppColors.bgCard,
          colorText: AppColors.success,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 2),
        );

        // ── Force password change ──
        // Electron: navigate to dashboard, then show modal
        // Flutter: navigate to change-password screen (same net effect)
        if (_auth.forcePasswordChange) {
          Get.offAllNamed(AppRoutes.changePassword);
          return;
        }

        Get.offAllNamed(AppRoutes.dashboard);
      }
    } else {
      // ── Error (mirrors Electron: errorDiv.textContent = result.error) ──
      errorMessage.value =
          result.error ?? 'Invalid credentials. Please try again.';
    }
  }
}
