import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

// ── Permission map: Backend enum → Flutter local id ──────────────────────────
const Map<String, String> kPermissionMap = {
  'VIEW_INVENTORY':   'inventory_view',
  'MANAGE_INVENTORY': 'inventory_manage',
  'VIEW_CUSTOMERS':   'customer_view',
  'MANAGE_CUSTOMERS': 'customer_manage',
  'VIEW_BILLING':     'billing_view',
  'MANAGE_BILLING':   'billing_create',
  'VIEW_ACCOUNTS':    'accounts_view',
  'MANAGE_ACCOUNTS':  'accounts_manage',
  'VIEW_REPORTS':     'reports_view',
  'MANAGE_OLD_GOLD':  'old_gold_manage',
  'MANAGE_SCHEMES':   'schemes_manage',
  'MANAGE_RATES':     'rates_manage',
  'MANAGE_STAFF':     'staff_manage',
};

const Map<String, String?> kModulePerms = {
  'inventory':  'inventory_view',
  'customers':  'customer_view',
  'billing':    'billing_view',
  'accounts':   'accounts_view',
  'reports':    'reports_view',
  'staff':      'staff_manage',
  'todayRates': 'rates_manage',
  'oldGold':    'old_gold_manage',
  'schemes':    'schemes_manage',
  'enquiries':  null,
  'settings':   null,
  'dashboard':  null,
};

// ── Backend URL ───────────────────────────────────────────────────────────────
const String kApiBaseUrl =
    'http://jewel-erp-alb-2124014483.ap-south-1.elb.amazonaws.com';

// ════════════════════════════════════════════════════════════════════════════
// AuthService
// ════════════════════════════════════════════════════════════════════════════
class AuthService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  void updateAccessToken(String token) => _accessToken = token;

  // ── LOGIN ─────────────────────────────────────────────────────────────────
  Future<AuthResult> login(String mobile, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$kApiBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return _handleLoginResponse(jsonDecode(response.body) as Map<String, dynamic>, mobile);
      }
      return _demoLogin(mobile, password);
    } catch (_) { return _demoLogin(mobile, password); }
  }

  AuthResult _handleLoginResponse(Map<String, dynamic> data, String mobile) {
    final src = (data['data'] is Map && (data['data'] as Map)['token'] != null)
        ? data['data'] as Map<String, dynamic> : data;

    final at = src['token'] ?? src['accessToken'] ?? src['access_token'] ?? src['jwt'];
    final rt = src['refreshToken'] ?? src['refresh_token'];
    if (at == null) return _demoLogin(mobile, '');

    _accessToken  = at.toString();
    _refreshToken = rt?.toString();

    final role = (src['role'] ?? 'staff').toString().toLowerCase();

    // Parse stores WITH enabledModules (new in this Electron build)
    // mirrors Electron auth.js: userData.stores.forEach(s => storeModules[s.id] = s.enabledModules)
    final stores = (src['stores'] as List<dynamic>? ?? []).map((s) {
      if (s is Map) {
        return StoreInfo(
          id:   s['id'] ?? 0,
          name: s['name']?.toString() ?? '',
          enabledModules: s['enabledModules'] != null
              ? List<String>.from(s['enabledModules'])
              : null,
        );
      }
      return StoreInfo(id: 0, name: s.toString());
    }).toList();

    final perms = role == 'owner'
        ? kPermissionMap.values.toList()
        : (src['permissions'] as List<dynamic>? ?? [])
            .map((p) => kPermissionMap[p.toString()] ?? p.toString().toLowerCase())
            .toList();

    final user = UserSession(
      id:                  (src['id'] ?? src['userId'] ?? mobile).toString(),
      name:                (src['userName'] ?? src['name'] ?? mobile).toString(),
      mobile:              mobile,
      role:                role,
      stores:              stores,
      permissions:         perms,
      isOnline:            true,
      forcePasswordChange: src['forcePasswordChange'] == true,
    );

    _save(user, access: _accessToken, refresh: _refreshToken);
    return AuthResult.ok(user);
  }

  AuthResult _demoLogin(String mobile, String _) {
    final isOwner = mobile.toUpperCase() == 'OWNER001' || mobile.toLowerCase() == 'owner';
    final user = UserSession(
      id: mobile, name: isOwner ? 'Store Owner' : 'Staff Member',
      mobile: mobile, role: isOwner ? 'owner' : 'staff',
      stores: [
        StoreInfo(id: 1, name: 'Rajmahal Jewellers - Main',
            enabledModules: ['DASHBOARD','INVENTORY','BILLING','CUSTOMERS','ACCOUNTS','RATES','SCHEMES','REPORTS','SETTINGS']),
        StoreInfo(id: 2, name: 'Rajmahal Jewellers - Mall Road',
            enabledModules: ['DASHBOARD','INVENTORY','BILLING','CUSTOMERS','ACCOUNTS','RATES']),
        StoreInfo(id: 3, name: 'Rajmahal Jewellers - City Center',
            enabledModules: ['DASHBOARD','INVENTORY','BILLING','CUSTOMERS']),
      ],
      permissions: isOwner
          ? kPermissionMap.values.toList()
          : ['inventory_view', 'customer_view', 'billing_view', 'billing_create'],
      isOnline: false, forcePasswordChange: false,
    );
    _save(user, access: 'demo', refresh: 'demo');
    return AuthResult.ok(user, isDemo: true);
  }

  // ── RESTORE SESSION ───────────────────────────────────────────────────────
  Future<AuthResult> tryRestoreSession() async {
    final saved        = await _storage.getSession();
    if (saved == null) return AuthResult.fail('No session');
    final savedRefresh = await _storage.getRefreshToken();
    if (savedRefresh == null || savedRefresh == 'demo') {
      return AuthResult.ok(saved, isDemo: savedRefresh == 'demo');
    }
    try {
      final r = await http.post(
        Uri.parse('$kApiBaseUrl/api/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': savedRefresh}),
      ).timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        final d   = jsonDecode(r.body) as Map<String, dynamic>;
        final src = (d['data'] is Map && (d['data'] as Map)['token'] != null)
            ? d['data'] as Map<String, dynamic> : d;
        final at  = src['token'] ?? src['accessToken'] ?? src['access_token'] ?? src['jwt'];
        final newRt = src['refreshToken'] ?? src['refresh_token'] ?? savedRefresh;
        if (at != null) {
          _accessToken  = at.toString();
          _refreshToken = newRt.toString();
          await _storage.saveAccessToken(_accessToken!);
          await _storage.saveRefreshToken(_refreshToken!);
          return AuthResult.ok(saved);
        }
      }
    } catch (_) { return AuthResult.ok(saved, isDemo: true); }
    return AuthResult.fail('Session expired');
  }

  // ── CHANGE PASSWORD ───────────────────────────────────────────────────────
  Future<AuthResult> changePassword(String current, String newPass) async {
    if (_accessToken == null || _accessToken == 'demo') {
      return AuthResult.fail('Not available in demo mode');
    }
    try {
      final r = await http.post(
        Uri.parse('$kApiBaseUrl/api/auth/change-password'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_accessToken'},
        body: jsonEncode({'currentPassword': current, 'newPassword': newPass}),
      ).timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) return AuthResult.msg('Password changed!');
      return AuthResult.fail('Current password is incorrect');
    } catch (_) { return AuthResult.fail('Network error. Try again.'); }
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _accessToken  = null;
    _refreshToken = null;
    await _storage.clearSession();
  }

  void _save(UserSession u, {String? access, String? refresh}) {
    _storage.saveSession(u);
    if (access  != null) _storage.saveAccessToken(access);
    if (refresh != null) _storage.saveRefreshToken(refresh);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// AuthResult
// ════════════════════════════════════════════════════════════════════════════
class AuthResult {
  final bool success; final UserSession? user; final String? error;
  final String? message; final bool isDemo;
  const AuthResult._({required this.success, this.user, this.error, this.message, this.isDemo = false});
  factory AuthResult.ok(UserSession u, {bool isDemo = false}) =>
      AuthResult._(success: true, user: u, isDemo: isDemo);
  factory AuthResult.msg(String m) => AuthResult._(success: true, message: m);
  factory AuthResult.fail(String e) => AuthResult._(success: false, error: e);
}

// ════════════════════════════════════════════════════════════════════════════
// UserSession
// ════════════════════════════════════════════════════════════════════════════
class UserSession {
  final String id, name, mobile, role;
  final List<StoreInfo> stores;
  final List<String> permissions;
  final bool isOnline, forcePasswordChange;

  const UserSession({
    required this.id, required this.name, required this.mobile, required this.role,
    required this.stores, required this.permissions,
    required this.isOnline, required this.forcePasswordChange,
  });

  String get initials {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
  String get roleDisplay =>
      role.isNotEmpty ? '${role[0].toUpperCase()}${role.substring(1)}' : '';

  bool hasPermission(String p) =>
      role == 'owner' || role == 'admin' || permissions.contains(p);
  bool canAccess(String module) {
    final p = kModulePerms[module];
    if (p == null) return true;
    return hasPermission(p);
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'mobile': mobile, 'role': role,
    'stores': stores.map((s) => s.toJson()).toList(),
    'permissions': permissions, 'isOnline': isOnline,
    'forcePasswordChange': forcePasswordChange,
  };

  factory UserSession.fromJson(Map<String, dynamic> j) => UserSession(
    id: j['id']?.toString() ?? '', name: j['name']?.toString() ?? '',
    mobile: j['mobile']?.toString() ?? '', role: j['role']?.toString() ?? 'staff',
    stores: (j['stores'] as List<dynamic>? ?? [])
        .map((s) => StoreInfo.fromJson(s as Map<String, dynamic>)).toList(),
    permissions: List<String>.from(j['permissions'] ?? []),
    isOnline: j['isOnline'] == true, forcePasswordChange: j['forcePasswordChange'] == true,
  );
}

// ════════════════════════════════════════════════════════════════════════════
// StoreInfo — updated to carry enabledModules from backend
// mirrors Electron: stores[].enabledModules = ['DASHBOARD','BILLING',...]
// ════════════════════════════════════════════════════════════════════════════
class StoreInfo {
  final int    id;
  final String name;
  // NEW: list of enabled module codes for this store
  final List<String>? enabledModules;

  const StoreInfo({required this.id, required this.name, this.enabledModules});

  String get shortName =>
      name.replaceAll('Rajmahal Jewellers - ', '').replaceAll('Rajmahal - ', '');

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name,
    if (enabledModules != null) 'enabledModules': enabledModules,
  };

  factory StoreInfo.fromJson(Map<String, dynamic> j) => StoreInfo(
    id:   j['id'] ?? 0,
    name: j['name']?.toString() ?? '',
    enabledModules: j['enabledModules'] != null
        ? List<String>.from(j['enabledModules'])
        : null,
  );
}
