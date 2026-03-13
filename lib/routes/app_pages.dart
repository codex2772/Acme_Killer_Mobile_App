import 'package:acme_killer_mobile_app/modules/auth/login/bindings/login_binding.dart';
import 'package:acme_killer_mobile_app/modules/auth/login/screens/login_screen.dart';
import 'package:acme_killer_mobile_app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:acme_killer_mobile_app/modules/dashboard/screens/dashboard_screen.dart';
import 'package:acme_killer_mobile_app/modules/role_select/screens/role_select_screen.dart';
import 'package:acme_killer_mobile_app/modules/splash/screens/splash_screen.dart';
import 'package:acme_killer_mobile_app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),

    GetPage(name: AppRoutes.roleSelect, page: () => const RoleSelectScreen()),

    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),

    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
  ];
}
