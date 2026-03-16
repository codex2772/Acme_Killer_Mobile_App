import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class AuthController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final Rx<UserSession?> user = Rx(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isOnline = false.obs;
  final RxBool isDemo = false.obs;
  final Rx<StoreInfo?> selectedStore = Rx(null);

  // ── Getters ──
  String get role => user.value?.role ?? '';
  String get userName => user.value?.name ?? '';
  String get userInitials => user.value?.initials ?? 'U';
  String get userMobile => user.value?.mobile ?? '';
  List<StoreInfo> get stores => user.value?.stores ?? [];
  List<String> get permissions => user.value?.permissions ?? [];
  bool get forcePasswordChange => user.value?.forcePasswordChange ?? false;
  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';

  bool hasPermission(String p) => user.value?.hasPermission(p) ?? false;
  bool canAccess(String module) => user.value?.canAccess(module) ?? false;

  // ── Login ──
  Future<AuthResult> login(String mobile, String password) async {
    final result = await _auth.login(mobile, password);
    if (result.success && result.user != null) {
      _apply(result.user!, isDemo: result.isDemo);
    }
    return result;
  }

  // ── Restore session on splash ──
  Future<bool> tryRestoreSession() async {
    final result = await _auth.tryRestoreSession();
    if (result.success && result.user != null) {
      _apply(result.user!, isDemo: result.isDemo);
      return true;
    }
    return false;
  }

  // ── Change password ──
  Future<AuthResult> changePassword(String current, String newPass) =>
      _auth.changePassword(current, newPass);

  // ── Logout ──
  Future<void> logout() async {
    await _auth.logout();
    user.value = null;
    isAuthenticated.value = false;
    isOnline.value = false;
    isDemo.value = false;
    selectedStore.value = null;
    Get.offAllNamed(AppRoutes.roleSelect);
  }

  void _apply(UserSession session, {bool isDemo = false}) {
    user.value = session;
    isAuthenticated.value = true;
    isOnline.value = session.isOnline;
    this.isDemo.value = isDemo;
    if (session.stores.isNotEmpty) selectedStore.value = session.stores.first;
  }
}
