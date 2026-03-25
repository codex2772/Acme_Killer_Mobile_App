import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'storage_service.dart';

// ════════════════════════════════════════════════════════════════════
// ApiResult — mirrors Electron { success, data, error, status,
//             moduleNotEnabled, module }
// ════════════════════════════════════════════════════════════════════
class ApiResult<T> {
  final bool    success;
  final T?      data;
  final String? error;
  final int     status;
  // NEW: module-gating fields (from updated 403 handling in api.js)
  final bool    moduleNotEnabled;
  final String? module;

  const ApiResult._({
    required this.success,
    this.data,
    this.error,
    this.status = 0,
    this.moduleNotEnabled = false,
    this.module,
  });

  factory ApiResult.ok(T data, {int status = 200}) =>
      ApiResult._(success: true, data: data, status: status);

  factory ApiResult.fail(String error, {
    int status = 0,
    bool moduleNotEnabled = false,
    String? module,
  }) => ApiResult._(
    success: false,
    error: error,
    status: status,
    moduleNotEnabled: moduleNotEnabled,
    module: module,
  );
}

// ════════════════════════════════════════════════════════════════════
// ApiClient — mirrors Electron api.js
//
// What's new in this build vs previous:
//  • 403 now parses body for moduleNotEnabled + module name
//  • X-Store-Id header on every request
//  • Image upload (multipart/form-data → S3)
//  • Image delete
// ════════════════════════════════════════════════════════════════════
class ApiClient extends GetxService {
  // ── ALB URL — mirrors Electron api.js BASE_URL ───────────────────
  static const String baseUrl =
      'http://jewel-erp-alb-2124014483.ap-south-1.elb.amazonaws.com';

  // ── Store context — mirrors api.js currentStoreId ────────────────
  int? _currentStoreId;

  void setCurrentStoreId(int? id) => _currentStoreId = id;
  int? getCurrentStoreId()        => _currentStoreId;

  AuthService    get _auth    => Get.find<AuthService>();
  StorageService get _storage => Get.find<StorageService>();

  // ════════════════════════════════════════════════════════════════
  // Core request — mirrors api.js apiRequest()
  // ════════════════════════════════════════════════════════════════
  Future<ApiResult<dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool retryOnAuth = true,
  }) async {
    final url   = Uri.parse('$baseUrl$path');
    final token = _auth.accessToken;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept':       'application/json',
      if (token != null && token != 'demo') 'Authorization': 'Bearer $token',
      if (_currentStoreId != null) 'X-Store-Id': '$_currentStoreId',
    };

    try {
      final encoded = body != null ? jsonEncode(body) : null;
      final http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers)
              .timeout(const Duration(seconds: 15));
        case 'POST':
          response = await http.post(url, headers: headers, body: encoded)
              .timeout(const Duration(seconds: 15));
        case 'PUT':
          response = await http.put(url, headers: headers, body: encoded)
              .timeout(const Duration(seconds: 15));
        case 'PATCH':
          response = await http.patch(url, headers: headers, body: encoded)
              .timeout(const Duration(seconds: 15));
        case 'DELETE':
          response = await http.delete(url, headers: headers)
              .timeout(const Duration(seconds: 15));
        default:
          return ApiResult.fail('Unsupported HTTP method: $method');
      }

      // ── 401 → refresh → retry once ───────────────────────────────
      if (response.statusCode == 401 && retryOnAuth) {
        final refreshed = await _refreshToken();
        if (refreshed) return request(method, path, body: body, retryOnAuth: false);
        return ApiResult.fail('Session expired. Please login again.', status: 401);
      }
      if (response.statusCode == 401) {
        return ApiResult.fail('Authentication required', status: 401);
      }

      // ── 403 — permission denied OR module not enabled ─────────────
      // NEW: parse body to distinguish module-gating from plain 403
      if (response.statusCode == 403) {
        String  errorMsg        = 'You do not have permission to perform this action.';
        bool    moduleNotEnabled = false;
        String? moduleName;
        try {
          final errBody = jsonDecode(response.body) as Map<String, dynamic>;
          errorMsg = errBody['message']?.toString() ?? errBody['error']?.toString() ?? errorMsg;
          if (errBody['error'] == 'Module not enabled' ||
              (errBody['module'] != null &&
               (errBody['message']?.toString() ?? '').contains('Module not enabled'))) {
            moduleNotEnabled = true;
            moduleName = errBody['module']?.toString();
            errorMsg   = 'Module not enabled: ${moduleName ?? 'Unknown'}';
          }
        } catch (_) {}
        return ApiResult.fail(
          errorMsg,
          status: 403,
          moduleNotEnabled: moduleNotEnabled,
          module: moduleName,
        );
      }

      // ── Other errors ──────────────────────────────────────────────
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String msg = 'Request failed (${response.statusCode})';
        try {
          final e = jsonDecode(response.body) as Map<String, dynamic>;
          msg = e['message']?.toString() ?? e['error']?.toString() ?? msg;
        } catch (_) {}
        return ApiResult.fail(msg, status: response.statusCode);
      }

      // ── Parse success ─────────────────────────────────────────────
      final ct = response.headers['content-type'] ?? '';
      if (ct.contains('application/json') && response.body.isNotEmpty) {
        return ApiResult.ok(jsonDecode(response.body), status: response.statusCode);
      }
      return ApiResult.ok(response.body, status: response.statusCode);

    } catch (e) {
      return ApiResult.fail('Connection error: $e', status: 0);
    }
  }

  // ════════════════════════════════════════════════════════════════
  // Image upload — POST /api/images/upload (multipart/form-data)
  // mirrors api.js uploadImage()
  // ════════════════════════════════════════════════════════════════
  Future<ApiResult<dynamic>> uploadImage(
    List<int> fileBytes,
    String fileName,
    String mimeType, {
    String folder = 'jewelry-items',
  }) async {
    try {
      final token = _auth.accessToken;
      final uri   = Uri.parse('$baseUrl/api/images/upload');
      final req   = http.MultipartRequest('POST', uri)
        ..fields['folder'] = folder
        ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

      if (token != null && token != 'demo') req.headers['Authorization'] = 'Bearer $token';
      if (_currentStoreId != null) req.headers['X-Store-Id'] = '$_currentStoreId';

      final streamed  = await req.send().timeout(const Duration(seconds: 30));
      final response  = await http.Response.fromStream(streamed);

      if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) return uploadImage(fileBytes, fileName, mimeType, folder: folder);
        return ApiResult.fail('Authentication required', status: 401);
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.ok(jsonDecode(response.body), status: response.statusCode);
      }
      return ApiResult.fail('Upload failed (${response.statusCode})', status: response.statusCode);
    } catch (e) {
      return ApiResult.fail('Upload error: $e');
    }
  }

  // ── Image delete — DELETE /api/images?url=<encoded> ──────────────
  Future<ApiResult<dynamic>> deleteImage(String imageUrl) =>
      request('DELETE', '/api/images?url=${Uri.encodeComponent(imageUrl)}');

  // ── Token refresh ─────────────────────────────────────────────────
  Future<bool> _refreshToken() async {
    final rt = await _storage.getRefreshToken();
    if (rt == null || rt == 'demo') return false;
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': rt}),
      ).timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) {
        final d   = jsonDecode(r.body) as Map<String, dynamic>;
        final src = (d['data'] is Map && (d['data'] as Map)['token'] != null)
            ? d['data'] as Map<String, dynamic> : d;
        final at  = src['token'] ?? src['accessToken'] ?? src['access_token'] ?? src['jwt'];
        final newRt = src['refreshToken'] ?? src['refresh_token'] ?? rt;
        if (at != null) {
          await _storage.saveAccessToken(at.toString());
          await _storage.saveRefreshToken(newRt.toString());
          _auth.updateAccessToken(at.toString());
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
}
