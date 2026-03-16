import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class AppDrawerController extends GetxController {
  AuthController get _auth {
    try { return Get.find<AuthController>(); } catch (_) { return AuthController(); }
  }

  String get role => _auth.role.isEmpty ? 'owner' : _auth.role;
  String get userName => _auth.userName;
  String get userInitials => _auth.userInitials;

  void logout() async {
    try { await _auth.logout(); }
    catch (_) { Get.offAllNamed(AppRoutes.roleSelect); }
  }
}
