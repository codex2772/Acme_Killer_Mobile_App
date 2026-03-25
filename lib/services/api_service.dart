import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'storage_service.dart';

// ════════════════════════════════════════════════════════════════════
// ApiService — Flutter equivalent of Electron's api.js + ipc-handlers.js
//
// Architecture mirror:
//   Electron api.js      → ApiService._request()
//   Electron ipc-handlers → named methods on ApiService
//   Electron preload.js  → window.jewelERP.* → call ApiService.*
//
// Backend: Spring Boot at AWS ALB
// Base URL mirrors: process.env.JEWELERP_API_URL || jewel-erp-alb-*.amazonaws.com
// ════════════════════════════════════════════════════════════════════

// ── Change to your actual backend URL ──
const String kApiBaseUrl =
    'http://jewel-erp-alb-1837400403.ap-south-1.elb.amazonaws.com';

// ── Result type — mirrors Electron's { success, data, error, status } ──
class ApiResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final int status;

  const ApiResult._({
    required this.success,
    this.data,
    this.error,
    this.status = 0,
  });

  factory ApiResult.ok(T data, {int status = 200}) =>
      ApiResult._(success: true, data: data, status: status);

  factory ApiResult.fail(String error, {int status = 0}) =>
      ApiResult._(success: false, error: error, status: status);
}

// ════════════════════════════════════════════════════════════════════
// SERVICE
// ════════════════════════════════════════════════════════════════════

class ApiService extends GetxService {
  // Resolved from AuthService on every request (avoids circular dep)
  AuthService get _auth => Get.find<AuthService>();
  StorageService get _storage => Get.find<StorageService>();

  // ── Core HTTP method — mirrors api.js apiRequest() ───────────────
  //
  // Handles:
  //  • JWT Bearer injection
  //  • 401 → auto refresh → single retry   (mirrors retryOnAuth logic)
  //  • 403 → permission error
  //  • non-OK → extract backend message
  //  • JSON or plain-text response
  Future<ApiResult<dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool retryOnAuth = true,
  }) async {
    final url = Uri.parse('$kApiBaseUrl$path');
    final token = _auth.accessToken;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token != 'demo') 'Authorization': 'Bearer $token',
    };

    try {
      final http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(url, headers: headers)
              .timeout(const Duration(seconds: 15));
        case 'POST':
          response = await http
              .post(
                url,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 15));
        case 'PUT':
          response = await http
              .put(
                url,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 15));
        case 'PATCH':
          response = await http
              .patch(
                url,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 15));
        case 'DELETE':
          response = await http
              .delete(url, headers: headers)
              .timeout(const Duration(seconds: 15));
        default:
          return ApiResult.fail('Unsupported HTTP method: $method');
      }

      // ── 401 → try token refresh then retry once ──────────────────
      // Mirrors Electron: if (response.status === 401 && retryOnAuth)
      if (response.statusCode == 401 && retryOnAuth) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return request(method, path, body: body, retryOnAuth: false);
        }
        return ApiResult.fail(
          'Session expired. Please login again.',
          status: 401,
        );
      }

      if (response.statusCode == 401) {
        return ApiResult.fail('Authentication required', status: 401);
      }

      // ── 403 — permission denied ───────────────────────────────────
      // Mirrors Electron: if (response.status === 403)
      if (response.statusCode == 403) {
        return ApiResult.fail(
          'You do not have permission to perform this action.',
          status: 403,
        );
      }

      // ── Other non-OK ──────────────────────────────────────────────
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String errorMsg = 'Request failed (${response.statusCode})';
        try {
          final errBody = jsonDecode(response.body) as Map<String, dynamic>;
          errorMsg =
              errBody['message']?.toString() ??
              errBody['error']?.toString() ??
              errorMsg;
        } catch (_) {}
        return ApiResult.fail(errorMsg, status: response.statusCode);
      }

      // ── Parse successful response ─────────────────────────────────
      final ct = response.headers['content-type'] ?? '';
      if (ct.contains('application/json') && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        return ApiResult.ok(data, status: response.statusCode);
      }
      return ApiResult.ok(response.body, status: response.statusCode);
    } catch (e) {
      // Mirrors Electron's catch block with offline detection
      return ApiResult.fail('Connection error: ${e.toString()}', status: 0);
    }
  }

  // ── Token refresh — mirrors api.js refreshAccessToken() ──────────
  Future<bool> _refreshAccessToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken == 'demo') return false;

    try {
      final response = await http
          .post(
            Uri.parse('$kApiBaseUrl/api/auth/refresh-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Mirrors Electron's tokenSource resolution (handles { data: { token } } wrapper)
        final tokenSource =
            (data['data'] is Map && data['data']['token'] != null)
            ? data['data'] as Map<String, dynamic>
            : data;

        final newAt =
            tokenSource['token'] ??
            tokenSource['accessToken'] ??
            tokenSource['access_token'] ??
            tokenSource['jwt'];
        final newRt =
            tokenSource['refreshToken'] ??
            tokenSource['refresh_token'] ??
            refreshToken;

        if (newAt != null) {
          await _storage.saveAccessToken(newAt.toString());
          await _storage.saveRefreshToken(newRt.toString());
          // Update AuthService in-memory token
          // (AuthService exposes a setter for this purpose)
          _auth.updateAccessToken(newAt.toString());
          return true;
        }
      }
    } catch (_) {}

    return false;
  }

  // ════════════════════════════════════════════════════════════════
  // AUTH ENDPOINTS  (mirrors ipc-handlers.js auth:*)
  // ════════════════════════════════════════════════════════════════

  /// POST /api/auth/login   → mirrors auth:login
  Future<ApiResult<dynamic>> authLogin(String mobile, String password) =>
      request(
        'POST',
        '/api/auth/login',
        body: {'mobile': mobile, 'password': password},
      );

  /// POST /api/auth/refresh-token   → mirrors auth:refresh-token
  Future<ApiResult<dynamic>> authRefreshToken(String refreshToken) => request(
    'POST',
    '/api/auth/refresh-token',
    body: {'refreshToken': refreshToken},
  );

  /// POST /api/auth/change-password   → mirrors auth:change-password
  Future<ApiResult<dynamic>> authChangePassword(
    String currentPassword,
    String newPassword,
  ) => request(
    'POST',
    '/api/auth/change-password',
    body: {'currentPassword': currentPassword, 'newPassword': newPassword},
  );

  // ════════════════════════════════════════════════════════════════
  // INVENTORY ENDPOINTS  (mirrors ipc-handlers.js inventory:*)
  // ════════════════════════════════════════════════════════════════

  /// GET /api/jewelry-items
  Future<ApiResult<dynamic>> inventoryList() =>
      request('GET', '/api/jewelry-items');

  /// GET /api/jewelry-items/:id
  Future<ApiResult<dynamic>> inventoryGet(dynamic id) =>
      request('GET', '/api/jewelry-items/$id');

  /// GET /api/jewelry-items/sku/:sku
  Future<ApiResult<dynamic>> inventoryGetBySku(String sku) =>
      request('GET', '/api/jewelry-items/sku/${Uri.encodeComponent(sku)}');

  /// GET /api/jewelry-items/category/:categoryId
  Future<ApiResult<dynamic>> inventoryByCategory(dynamic categoryId) =>
      request('GET', '/api/jewelry-items/category/$categoryId');

  /// GET /api/jewelry-items/status/:status
  Future<ApiResult<dynamic>> inventoryByStatus(String status) => request(
    'GET',
    '/api/jewelry-items/status/${Uri.encodeComponent(status)}',
  );

  /// POST /api/jewelry-items
  Future<ApiResult<dynamic>> inventoryCreate(Map<String, dynamic> data) =>
      request('POST', '/api/jewelry-items', body: data);

  /// PUT /api/jewelry-items/:id
  Future<ApiResult<dynamic>> inventoryUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/jewelry-items/$id', body: data);

  /// DELETE /api/jewelry-items/:id
  Future<ApiResult<dynamic>> inventoryDelete(dynamic id) =>
      request('DELETE', '/api/jewelry-items/$id');

  // ════════════════════════════════════════════════════════════════
  // CATEGORIES  (mirrors ipc-handlers.js categories:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> categoriesList() =>
      request('GET', '/api/categories');

  Future<ApiResult<dynamic>> categoriesGet(dynamic id) =>
      request('GET', '/api/categories/$id');

  Future<ApiResult<dynamic>> categoriesCreate(Map<String, dynamic> data) =>
      request('POST', '/api/categories', body: data);

  Future<ApiResult<dynamic>> categoriesUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/categories/$id', body: data);

  Future<ApiResult<dynamic>> categoriesDelete(dynamic id) =>
      request('DELETE', '/api/categories/$id');

  // ════════════════════════════════════════════════════════════════
  // METAL TYPES  (mirrors ipc-handlers.js metal-types:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> metalTypesList() =>
      request('GET', '/api/metal-types');

  Future<ApiResult<dynamic>> metalTypesGet(dynamic id) =>
      request('GET', '/api/metal-types/$id');

  Future<ApiResult<dynamic>> metalTypesSearch(String name) => request(
    'GET',
    '/api/metal-types/search?name=${Uri.encodeComponent(name)}',
  );

  Future<ApiResult<dynamic>> metalTypesCreate(Map<String, dynamic> data) =>
      request('POST', '/api/metal-types', body: data);

  Future<ApiResult<dynamic>> metalTypesUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/metal-types/$id', body: data);

  Future<ApiResult<dynamic>> metalTypesDelete(dynamic id) =>
      request('DELETE', '/api/metal-types/$id');

  // ════════════════════════════════════════════════════════════════
  // CUSTOMERS  (mirrors ipc-handlers.js customers:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> customersList() =>
      request('GET', '/api/customers');

  Future<ApiResult<dynamic>> customersGet(dynamic id) =>
      request('GET', '/api/customers/$id');

  Future<ApiResult<dynamic>> customersByPhone(String phone) =>
      request('GET', '/api/customers/phone/${Uri.encodeComponent(phone)}');

  Future<ApiResult<dynamic>> customersSearch(String name) =>
      request('GET', '/api/customers/search?name=${Uri.encodeComponent(name)}');

  Future<ApiResult<dynamic>> customersCreate(Map<String, dynamic> data) =>
      request('POST', '/api/customers', body: data);

  Future<ApiResult<dynamic>> customersUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/customers/$id', body: data);

  Future<ApiResult<dynamic>> customersDelete(dynamic id) =>
      request('DELETE', '/api/customers/$id');

  // ════════════════════════════════════════════════════════════════
  // STAFF  (mirrors ipc-handlers.js staff:*)
  //
  //   staff:list    → GET  /api/staff
  //   staff:get     → GET  /api/staff/:id
  //   staff:create  → POST /api/staff
  //   staff:update  → PUT  /api/staff/:id
  //   staff:delete  → DELETE /api/staff/:id   (used for deactivate)
  // ════════════════════════════════════════════════════════════════

  /// GET /api/staff  — fetch all staff for this org
  Future<ApiResult<dynamic>> staffList() => request('GET', '/api/staff');

  /// GET /api/staff/:id
  Future<ApiResult<dynamic>> staffGet(dynamic id) =>
      request('GET', '/api/staff/$id');

  /// POST /api/staff
  Future<ApiResult<dynamic>> staffCreate(Map<String, dynamic> data) =>
      request('POST', '/api/staff', body: data);

  /// PUT /api/staff/:id
  Future<ApiResult<dynamic>> staffUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/staff/$id', body: data);

  /// DELETE /api/staff/:id  (deactivate — mirrors Electron staff:delete)
  Future<ApiResult<dynamic>> staffDelete(dynamic id) =>
      request('DELETE', '/api/staff/$id');

  // ════════════════════════════════════════════════════════════════
  // INVOICES  (mirrors ipc-handlers.js invoices:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> invoicesList({Map<String, String>? params}) {
    final qs = params != null ? '?${Uri(queryParameters: params).query}' : '';
    return request('GET', '/api/invoices$qs');
  }

  Future<ApiResult<dynamic>> invoicesGet(dynamic id) =>
      request('GET', '/api/invoices/$id');

  Future<ApiResult<dynamic>> invoicesCreate(Map<String, dynamic> data) =>
      request('POST', '/api/invoices', body: data);

  Future<ApiResult<dynamic>> invoicesUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/invoices/$id', body: data);

  Future<ApiResult<dynamic>> invoicesUpdateStatus(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PATCH', '/api/invoices/$id/status', body: data);

  Future<ApiResult<dynamic>> invoicesRecordPayment(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('POST', '/api/invoices/$id/payments', body: data);

  // ════════════════════════════════════════════════════════════════
  // ESTIMATES  (mirrors ipc-handlers.js estimates:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> estimatesList() =>
      request('GET', '/api/estimates');

  Future<ApiResult<dynamic>> estimatesGet(dynamic id) =>
      request('GET', '/api/estimates/$id');

  Future<ApiResult<dynamic>> estimatesCreate(Map<String, dynamic> data) =>
      request('POST', '/api/estimates', body: data);

  Future<ApiResult<dynamic>> estimatesUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/estimates/$id', body: data);

  Future<ApiResult<dynamic>> estimatesConvert(dynamic id) =>
      request('POST', '/api/estimates/$id/convert');

  // ════════════════════════════════════════════════════════════════
  // CREDIT NOTES  (mirrors ipc-handlers.js credit-notes:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> creditNotesList() =>
      request('GET', '/api/credit-notes');

  Future<ApiResult<dynamic>> creditNotesGet(dynamic id) =>
      request('GET', '/api/credit-notes/$id');

  Future<ApiResult<dynamic>> creditNotesCreate(Map<String, dynamic> data) =>
      request('POST', '/api/credit-notes', body: data);

  // ════════════════════════════════════════════════════════════════
  // LEDGER  (mirrors ipc-handlers.js ledger:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> ledgerList({Map<String, String>? params}) {
    final qs = params != null ? '?${Uri(queryParameters: params).query}' : '';
    return request('GET', '/api/ledger$qs');
  }

  Future<ApiResult<dynamic>> ledgerGet(dynamic id) =>
      request('GET', '/api/ledger/$id');

  Future<ApiResult<dynamic>> ledgerCreate(Map<String, dynamic> data) =>
      request('POST', '/api/ledger', body: data);

  // ════════════════════════════════════════════════════════════════
  // EXPENSES  (mirrors ipc-handlers.js expenses:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> expensesList({Map<String, String>? params}) {
    final qs = params != null ? '?${Uri(queryParameters: params).query}' : '';
    return request('GET', '/api/expenses$qs');
  }

  Future<ApiResult<dynamic>> expensesGet(dynamic id) =>
      request('GET', '/api/expenses/$id');

  Future<ApiResult<dynamic>> expensesCreate(Map<String, dynamic> data) =>
      request('POST', '/api/expenses', body: data);

  Future<ApiResult<dynamic>> expensesUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/expenses/$id', body: data);

  Future<ApiResult<dynamic>> expensesDelete(dynamic id) =>
      request('DELETE', '/api/expenses/$id');

  // ════════════════════════════════════════════════════════════════
  // CASH REGISTER  (mirrors ipc-handlers.js cash-register:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> cashRegisterList() =>
      request('GET', '/api/cash-register');

  Future<ApiResult<dynamic>> cashRegisterCurrent() =>
      request('GET', '/api/cash-register/current');

  Future<ApiResult<dynamic>> cashRegisterOpen(Map<String, dynamic> data) =>
      request('POST', '/api/cash-register/open', body: data);

  Future<ApiResult<dynamic>> cashRegisterClose(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PATCH', '/api/cash-register/$id/close', body: data);

  // ════════════════════════════════════════════════════════════════
  // SUPPLIERS  (mirrors ipc-handlers.js suppliers:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> suppliersList() =>
      request('GET', '/api/suppliers');

  Future<ApiResult<dynamic>> suppliersGet(dynamic id) =>
      request('GET', '/api/suppliers/$id');

  Future<ApiResult<dynamic>> suppliersCreate(Map<String, dynamic> data) =>
      request('POST', '/api/suppliers', body: data);

  Future<ApiResult<dynamic>> suppliersUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/suppliers/$id', body: data);

  Future<ApiResult<dynamic>> suppliersDelete(dynamic id) =>
      request('DELETE', '/api/suppliers/$id');

  // ════════════════════════════════════════════════════════════════
  // RATES  (mirrors ipc-handlers.js rates:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> ratesGet() => request('GET', '/api/rates');

  Future<ApiResult<dynamic>> ratesUpdate(Map<String, dynamic> data) =>
      request('PUT', '/api/rates', body: data);

  Future<ApiResult<dynamic>> ratesHistory({int days = 30}) =>
      request('GET', '/api/rates/history?days=$days');

  Future<ApiResult<dynamic>> ratesAlertsList() =>
      request('GET', '/api/rates/alerts');

  Future<ApiResult<dynamic>> ratesAlertsCreate(Map<String, dynamic> data) =>
      request('POST', '/api/rates/alerts', body: data);

  // ════════════════════════════════════════════════════════════════
  // OLD GOLD  (mirrors ipc-handlers.js old-gold:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> oldGoldList() => request('GET', '/api/old-gold');

  Future<ApiResult<dynamic>> oldGoldGet(dynamic id) =>
      request('GET', '/api/old-gold/$id');

  Future<ApiResult<dynamic>> oldGoldCreate(Map<String, dynamic> data) =>
      request('POST', '/api/old-gold', body: data);

  Future<ApiResult<dynamic>> oldGoldUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/old-gold/$id', body: data);

  // ════════════════════════════════════════════════════════════════
  // SCHEMES  (mirrors ipc-handlers.js schemes:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> schemesList() => request('GET', '/api/schemes');

  Future<ApiResult<dynamic>> schemesGet(dynamic id) =>
      request('GET', '/api/schemes/$id');

  Future<ApiResult<dynamic>> schemesCreate(Map<String, dynamic> data) =>
      request('POST', '/api/schemes', body: data);

  Future<ApiResult<dynamic>> schemesUpdate(
    dynamic id,
    Map<String, dynamic> data,
  ) => request('PUT', '/api/schemes/$id', body: data);

  Future<ApiResult<dynamic>> schemesMembers(dynamic schemeId) =>
      request('GET', '/api/schemes/$schemeId/members');

  Future<ApiResult<dynamic>> schemesAddMember(
    dynamic schemeId,
    Map<String, dynamic> data,
  ) => request('POST', '/api/schemes/$schemeId/members', body: data);

  Future<ApiResult<dynamic>> schemesRecordPayment(
    dynamic schemeId,
    dynamic memberId,
    Map<String, dynamic> data,
  ) => request(
    'POST',
    '/api/schemes/$schemeId/members/$memberId/payments',
    body: data,
  );

  Future<ApiResult<dynamic>> schemesMemberPayments(
    dynamic schemeId,
    dynamic memberId,
  ) => request('GET', '/api/schemes/$schemeId/members/$memberId/payments');

  // ════════════════════════════════════════════════════════════════
  // DASHBOARD  (mirrors ipc-handlers.js dashboard:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> dashboardSummary() =>
      request('GET', '/api/dashboard/summary');

  // ════════════════════════════════════════════════════════════════
  // SETTINGS  (mirrors ipc-handlers.js settings:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> settingsGet() => request('GET', '/api/settings');

  Future<ApiResult<dynamic>> settingsUpdate(Map<String, dynamic> data) =>
      request('PUT', '/api/settings', body: data);

  Future<ApiResult<dynamic>> settingsExpenseCategories() =>
      request('GET', '/api/settings/expense-categories');

  // ════════════════════════════════════════════════════════════════
  // ACTIVITY LOGS  (mirrors ipc-handlers.js activity-logs:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> activityLogsList({Map<String, String>? params}) {
    final qs = params != null ? '?${Uri(queryParameters: params).query}' : '';
    return request('GET', '/api/activity-logs$qs');
  }

  // ════════════════════════════════════════════════════════════════
  // ADMIN / DB INFO  (mirrors ipc-handlers.js admin:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> adminDbStatus() =>
      request('GET', '/api/db/status');

  Future<ApiResult<dynamic>> adminStores() => request('GET', '/api/db/stores');

  Future<ApiResult<dynamic>> adminUsers() => request('GET', '/api/db/users');

  Future<ApiResult<dynamic>> adminUserPermissions() =>
      request('GET', '/api/db/users/permissions');

  // ════════════════════════════════════════════════════════════════
  // HEALTH  (mirrors ipc-handlers.js health:*)
  // ════════════════════════════════════════════════════════════════

  Future<ApiResult<dynamic>> healthCheck() => request('GET', '/api');
}
