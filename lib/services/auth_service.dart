import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

// ─── Permission map — Backend ↔ Flutter (mirrors desktop auth.js) ───
const Map<String, String> kPermissionMap = {
  'VIEW_INVENTORY': 'inventory_view',
  'MANAGE_INVENTORY': 'inventory_manage',
  'VIEW_CUSTOMERS': 'customer_view',
  'MANAGE_CUSTOMERS': 'customer_manage',
  'VIEW_BILLING': 'billing_view',
  'MANAGE_BILLING': 'billing_create',
  'VIEW_ACCOUNTS': 'accounts_view',
  'MANAGE_ACCOUNTS': 'accounts_manage',
  'VIEW_REPORTS': 'reports_view',
  'MANAGE_OLD_GOLD': 'old_gold_manage',
  'MANAGE_SCHEMES': 'schemes_manage',
  'MANAGE_RATES': 'rates_manage',
  'MANAGE_STAFF': 'staff_manage',
};

// Module → required permission (mirrors Auth.canAccess in auth.js)
const Map<String, String?> kModulePerms = {
  'inventory': 'inventory_view',
  'customers': 'customer_view',
  'billing': 'billing_view',
  'accounts': 'accounts_view',
  'reports': 'reports_view',
  'staff': 'staff_manage',
  'todayRates': 'rates_manage',
  'oldGold': 'old_gold_manage',
  'schemes': 'schemes_manage',
  'settings': null,
  'dashboard': null,
};

// ─── Change this to your Spring Boot URL ───
const String kApiBaseUrl = 'https://api.jewelerp.com/api/v1';

class AuthService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();

  String? _accessToken;
  String? _refreshToken;

  // ── LOGIN ──
  Future<AuthResult> login(String mobile, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$kApiBaseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'mobile': mobile, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _handleSuccess(data, mobile);
      }
      return _demoLogin(mobile, password);
    } catch (_) {
      return _demoLogin(mobile, password);
    }
  }

  // ── DEMO / OFFLINE LOGIN (mirrors demoLogin in auth.js) ──
  AuthResult _demoLogin(String mobile, String password) {
    final isOwner =
        mobile.toUpperCase() == 'OWNER001' || mobile.toLowerCase() == 'owner';
    final role = isOwner ? 'owner' : 'staff';

    final user = UserSession(
      id: mobile,
      name: isOwner ? 'Store Owner' : 'Staff Member',
      mobile: mobile,
      role: role,
      stores: [
        StoreInfo(id: 1, name: 'Rajmahal Jewellers - Main'),
        StoreInfo(id: 2, name: 'Rajmahal Jewellers - Surat'),
      ],
      permissions: isOwner
          ? kPermissionMap.values.toList()
          : ['inventory_view', 'customer_view', 'billing_view', 'billing_create'],
      isOnline: false,
      forcePasswordChange: false,
    );

    _save(user, access: 'demo', refresh: 'demo');
    return AuthResult.ok(user, isDemo: true);
  }

  // ── HANDLE REAL RESPONSE ──
  AuthResult _handleSuccess(Map<String, dynamic> data, String mobile) {
    _accessToken = data['accessToken'] ?? data['token'];
    _refreshToken = data['refreshToken'];

    final role = (data['role'] ?? 'staff').toString().toLowerCase();
    final rawStores = (data['stores'] as List<dynamic>? ?? []);
    final stores = rawStores.map((s) {
      if (s is Map) return StoreInfo(id: s['id'] ?? 0, name: s['name']?.toString() ?? '');
      return StoreInfo(id: 0, name: s.toString());
    }).toList();

    final List<String> perms = role == 'owner'
        ? kPermissionMap.values.toList()
        : (data['permissions'] as List<dynamic>? ?? [])
            .map((p) => kPermissionMap[p.toString()] ?? p.toString().toLowerCase())
            .toList();

    final user = UserSession(
      id: (data['id'] ?? data['userId'] ?? mobile).toString(),
      name: (data['userName'] ?? data['name'] ?? mobile).toString(),
      mobile: mobile,
      role: role,
      stores: stores,
      permissions: perms,
      isOnline: true,
      forcePasswordChange: data['forcePasswordChange'] == true,
    );

    _save(user, access: _accessToken, refresh: _refreshToken);
    return AuthResult.ok(user);
  }

  // ── RESTORE SESSION ON APP OPEN ──
  Future<AuthResult> tryRestoreSession() async {
    final saved = await _storage.getSession();
    if (saved == null) return AuthResult.fail('No session');

    final savedRefresh = await _storage.getRefreshToken();
    if (savedRefresh != null && savedRefresh != 'demo') {
      try {
        final r = await http
            .post(
              Uri.parse('$kApiBaseUrl/auth/refresh'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refreshToken': savedRefresh}),
            )
            .timeout(const Duration(seconds: 8));
        if (r.statusCode == 200) {
          final d = jsonDecode(r.body) as Map<String, dynamic>;
          _accessToken = d['accessToken'] ?? d['token'];
          await _storage.saveAccessToken(_accessToken!);
          return AuthResult.ok(saved);
        }
      } catch (_) {
        return AuthResult.ok(saved, isDemo: true);
      }
    }
    return AuthResult.ok(saved, isDemo: savedRefresh == 'demo');
  }

  // ── CHANGE PASSWORD ──
  Future<AuthResult> changePassword(String current, String newPass) async {
    if (_accessToken == null || _accessToken == 'demo') {
      return AuthResult.fail('Not available in demo mode');
    }
    try {
      final r = await http
          .post(
            Uri.parse('$kApiBaseUrl/auth/change-password'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode({'currentPassword': current, 'newPassword': newPass}),
          )
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) return AuthResult.msg('Password changed!');
      return AuthResult.fail('Current password is incorrect');
    } catch (_) {
      return AuthResult.fail('Network error. Try again.');
    }
  }

  // ── LOGOUT ──
  Future<void> logout() async {
    if (_accessToken != null && _accessToken != 'demo') {
      try {
        await http.post(
          Uri.parse('$kApiBaseUrl/auth/logout'),
          headers: {'Authorization': 'Bearer $_accessToken'},
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
    _accessToken = null;
    _refreshToken = null;
    await _storage.clearSession();
  }

  void _save(UserSession u, {String? access, String? refresh}) {
    _storage.saveSession(u);
    if (access != null) _storage.saveAccessToken(access);
    if (refresh != null) _storage.saveRefreshToken(refresh);
  }

  String? get accessToken => _accessToken;
}

// ─── Result ───
class AuthResult {
  final bool success;
  final UserSession? user;
  final String? error;
  final String? message;
  final bool isDemo;
  const AuthResult._({required this.success, this.user, this.error, this.message, this.isDemo = false});
  factory AuthResult.ok(UserSession u, {bool isDemo = false}) => AuthResult._(success: true, user: u, isDemo: isDemo);
  factory AuthResult.msg(String m) => AuthResult._(success: true, message: m);
  factory AuthResult.fail(String e) => AuthResult._(success: false, error: e);
}

// ─── UserSession ───
class UserSession {
  final String id;
  final String name;
  final String mobile;
  final String role;
  final List<StoreInfo> stores;
  final List<String> permissions;
  final bool isOnline;
  final bool forcePasswordChange;

  const UserSession({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
    required this.stores,
    required this.permissions,
    required this.isOnline,
    required this.forcePasswordChange,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String get roleDisplay =>
      role.isNotEmpty ? '${role[0].toUpperCase()}${role.substring(1)}' : '';

  bool hasPermission(String permId) {
    if (role == 'owner' || role == 'admin') return true;
    return permissions.contains(permId);
  }

  bool canAccess(String module) {
    final perm = kModulePerms[module];
    if (perm == null) return true;
    return hasPermission(perm);
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'mobile': mobile, 'role': role,
        'stores': stores.map((s) => s.toJson()).toList(),
        'permissions': permissions, 'isOnline': isOnline,
        'forcePasswordChange': forcePasswordChange,
      };

  factory UserSession.fromJson(Map<String, dynamic> j) => UserSession(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        mobile: j['mobile']?.toString() ?? '',
        role: j['role']?.toString() ?? 'staff',
        stores: (j['stores'] as List<dynamic>? ?? [])
            .map((s) => StoreInfo.fromJson(s as Map<String, dynamic>))
            .toList(),
        permissions: List<String>.from(j['permissions'] ?? []),
        isOnline: j['isOnline'] == true,
        forcePasswordChange: j['forcePasswordChange'] == true,
      );
}

// ─── StoreInfo ───
class StoreInfo {
  final int id;
  final String name;
  const StoreInfo({required this.id, required this.name});
  String get shortName => name.replaceAll('Rajmahal Jewellers - ', '').replaceAll('Rajmahal - ', '');
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory StoreInfo.fromJson(Map<String, dynamic> j) =>
      StoreInfo(id: j['id'] ?? 0, name: j['name']?.toString() ?? '');
}
