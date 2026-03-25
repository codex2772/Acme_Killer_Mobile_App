import 'package:get/get.dart';
import 'api_client.dart';

// ════════════════════════════════════════════════════════════════════
// DashboardService — mirrors Electron ipc-handlers.js dashboard:*
// ════════════════════════════════════════════════════════════════════
class DashboardService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  /// GET /api/dashboard/summary — mirrors Electron: dashboard:summary
  Future<ApiResult<dynamic>> summary() => _api.request('GET', '/api/dashboard/summary');
}

// ════════════════════════════════════════════════════════════════════
// AdminService — mirrors Electron ipc-handlers.js admin:*
// ════════════════════════════════════════════════════════════════════
class AdminService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  /// GET /api/db/status
  Future<ApiResult<dynamic>> dbStatus() => _api.request('GET', '/api/db/status');

  /// GET /api/db/stores
  Future<ApiResult<dynamic>> stores() => _api.request('GET', '/api/db/stores');

  /// GET /api/db/users
  Future<ApiResult<dynamic>> users() => _api.request('GET', '/api/db/users');

  /// GET /api/db/users/permissions
  Future<ApiResult<dynamic>> userPermissions() =>
      _api.request('GET', '/api/db/users/permissions');
}

// ════════════════════════════════════════════════════════════════════
// HealthService — mirrors Electron ipc-handlers.js health:*
// ════════════════════════════════════════════════════════════════════
class HealthService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  /// GET /api
  Future<ApiResult<dynamic>> check() => _api.request('GET', '/api');
}

// ════════════════════════════════════════════════════════════════════
// ActivityLogsService — mirrors Electron ipc-handlers.js activity-logs:*
// ════════════════════════════════════════════════════════════════════
class ActivityLogsService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list({Map<String, String>? params}) {
    final qs = params != null ? '?${Uri(queryParameters: params).query}' : '';
    return _api.request('GET', '/api/activity-logs$qs');
  }
}
