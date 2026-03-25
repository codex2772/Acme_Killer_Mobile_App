import 'package:get/get.dart';
import 'api_client.dart';

// ════════════════════════════════════════════════════════════════════
// BillingService — mirrors Electron ipc-handlers.js invoices:*
// ════════════════════════════════════════════════════════════════════
class BillingService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> listInvoices({Map<String, String>? params}) {
    final qs = params != null ? '?${Uri(queryParameters: params).query}' : '';
    return _api.request('GET', '/api/invoices$qs');
  }
  Future<ApiResult<dynamic>> getInvoice(dynamic id)                            => _api.request('GET',   '/api/invoices/$id');
  Future<ApiResult<dynamic>> createInvoice(Map<String, dynamic> data)          => _api.request('POST',  '/api/invoices', body: data);
  Future<ApiResult<dynamic>> updateInvoice(dynamic id, Map<String, dynamic> d) => _api.request('PUT',   '/api/invoices/$id', body: d);
  Future<ApiResult<dynamic>> updateStatus(dynamic id, Map<String, dynamic> d)  => _api.request('PATCH', '/api/invoices/$id/status', body: d);
  Future<ApiResult<dynamic>> recordPayment(dynamic id, Map<String, dynamic> d) => _api.request('POST',  '/api/invoices/$id/payments', body: d);
}

// ════════════════════════════════════════════════════════════════════
// EstimatesService — mirrors Electron ipc-handlers.js estimates:*
// ════════════════════════════════════════════════════════════════════
class EstimatesService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                            => _api.request('GET',  '/api/estimates');
  Future<ApiResult<dynamic>> get(dynamic id)                                   => _api.request('GET',  '/api/estimates/$id');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data)                 => _api.request('POST', '/api/estimates', body: data);
  Future<ApiResult<dynamic>> update(dynamic id, Map<String, dynamic> data)     => _api.request('PUT',  '/api/estimates/$id', body: data);
  Future<ApiResult<dynamic>> convert(dynamic id)                               => _api.request('POST', '/api/estimates/$id/convert');
}

// ════════════════════════════════════════════════════════════════════
// CreditNotesService — mirrors Electron ipc-handlers.js credit-notes:*
// ════════════════════════════════════════════════════════════════════
class CreditNotesService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                            => _api.request('GET',  '/api/credit-notes');
  Future<ApiResult<dynamic>> get(dynamic id)                                   => _api.request('GET',  '/api/credit-notes/$id');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data)                 => _api.request('POST', '/api/credit-notes', body: data);
}
