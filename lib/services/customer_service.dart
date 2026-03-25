import 'package:get/get.dart';
import 'api_client.dart';

// ════════════════════════════════════════════════════════════════════
// CustomerService — mirrors Electron ipc-handlers.js customers:*
// ════════════════════════════════════════════════════════════════════
class CustomerService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list() => _api.request('GET', '/api/customers');

  Future<ApiResult<dynamic>> get(dynamic id) =>
      _api.request('GET', '/api/customers/$id');
  Future<ApiResult<dynamic>> byPhone(String phone) =>
      _api.request('GET', '/api/customers/phone/${Uri.encodeComponent(phone)}');
  Future<ApiResult<dynamic>> search(String name) => _api.request(
    'GET',
    '/api/customers/search?name=${Uri.encodeComponent(name)}',
  );
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data) =>
      _api.request('POST', '/api/customers', body: data);
  Future<ApiResult<dynamic>> update(dynamic id, Map<String, dynamic> data) =>
      _api.request('PUT', '/api/customers/$id', body: data);
  Future<ApiResult<dynamic>> delete(dynamic id) =>
      _api.request('DELETE', '/api/customers/$id');
}
