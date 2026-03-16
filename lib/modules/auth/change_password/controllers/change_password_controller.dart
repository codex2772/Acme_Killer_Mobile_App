import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';

class ChangePasswordController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();

  final TextEditingController currentCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscureCurrent = true.obs;
  final RxBool obscureNew = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxString error = ''.obs;
  final RxString success = ''.obs;

  bool get isForced => _auth.forcePasswordChange;

  @override
  void onClose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    final cur = currentCtrl.text.trim();
    final nw = newCtrl.text.trim();
    final cf = confirmCtrl.text.trim();

    if (cur.isEmpty || nw.isEmpty || cf.isEmpty) {
      error.value = 'All fields are required'; return;
    }
    if (nw.length < 6) { error.value = 'Password must be at least 6 characters'; return; }
    if (nw != cf) { error.value = 'Passwords do not match'; return; }

    error.value = '';
    isLoading.value = true;
    final result = await _auth.changePassword(cur, nw);
    isLoading.value = false;

    if (result.success) {
      success.value = result.message ?? 'Password changed!';
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      error.value = result.error ?? 'Failed. Please try again.';
    }
  }

  void skip() { if (!isForced) Get.back(); }
}
