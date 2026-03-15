import 'package:acme_killer_mobile_app/routes/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final loginIdController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;

  void login() async {
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    Get.offAllNamed(AppRoutes.dashboard);
  }
}
