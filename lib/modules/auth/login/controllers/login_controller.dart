import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';

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
    // Pre-fill demo hint for owner
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

    if (mobile.isEmpty) { errorMessage.value = 'Please enter your mobile / login ID'; return; }
    if (password.isEmpty) { errorMessage.value = 'Please enter your password'; return; }

    errorMessage.value = '';
    isLoading.value = true;
    final result = await _auth.login(mobile, password);
    isLoading.value = false;

    if (result.success) {
      if (_auth.forcePasswordChange) {
        Get.offAllNamed(AppRoutes.changePassword);
        return;
      }
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      errorMessage.value = result.error ?? 'Login failed. Please try again.';
    }
  }
}
