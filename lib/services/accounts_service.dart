import 'package:get/get.dart';
import 'api_client.dart';

// ════════════════════════════════════════════════════════════════════
// LedgerService — mirrors Electron ipc-handlers.js ledger:*
// ════════════════════════════════════════════════════════════════════
class LedgerService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list({Map<String, String>? params}) {
    final qs = params != null ? '?${Uri(queryParameters: params).query}' : '';
    return _api.request('GET', '/api/ledger$qs');
  }
  Future<ApiResult<dynamic>> get(dynamic id)               => _api.request('GET',  '/api/ledger/$id');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> d) => _api.request('POST', '/api/ledger', body: d);
}

// ════════════════════════════════════════════════════════════════════
// ExpensesService — mirrors Electron ipc-handlers.js expenses:*
// ════════════════════════════════════════════════════════════════════
class ExpensesService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list({Map<String, String>? params}) {
    final qs = params != null ? '?${Uri(queryParameters: params).query}' : '';
    return _api.request('GET', '/api/expenses$qs');
  }
  Future<ApiResult<dynamic>> get(dynamic id)                                   => _api.request('GET',    '/api/expenses/$id');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data)                 => _api.request('POST',   '/api/expenses', body: data);
  Future<ApiResult<dynamic>> update(dynamic id, Map<String, dynamic> data)     => _api.request('PUT',    '/api/expenses/$id', body: data);
  Future<ApiResult<dynamic>> delete(dynamic id)                                => _api.request('DELETE', '/api/expenses/$id');
}

// ════════════════════════════════════════════════════════════════════
// SuppliersService — mirrors Electron ipc-handlers.js suppliers:*
// ════════════════════════════════════════════════════════════════════
class SuppliersService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                            => _api.request('GET',    '/api/suppliers');
  Future<ApiResult<dynamic>> get(dynamic id)                                   => _api.request('GET',    '/api/suppliers/$id');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data)                 => _api.request('POST',   '/api/suppliers', body: data);
  Future<ApiResult<dynamic>> update(dynamic id, Map<String, dynamic> data)     => _api.request('PUT',    '/api/suppliers/$id', body: data);
  Future<ApiResult<dynamic>> delete(dynamic id)                                => _api.request('DELETE', '/api/suppliers/$id');
}

// ════════════════════════════════════════════════════════════════════
// CashRegisterService — mirrors Electron ipc-handlers.js cash-register:*
// ════════════════════════════════════════════════════════════════════
class CashRegisterService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                            => _api.request('GET',   '/api/cash-register');
  Future<ApiResult<dynamic>> current()                                         => _api.request('GET',   '/api/cash-register/current');
  Future<ApiResult<dynamic>> open(Map<String, dynamic> data)                   => _api.request('POST',  '/api/cash-register/open', body: data);
  Future<ApiResult<dynamic>> close(dynamic id, Map<String, dynamic> data)      => _api.request('PATCH', '/api/cash-register/$id/close', body: data);
}
