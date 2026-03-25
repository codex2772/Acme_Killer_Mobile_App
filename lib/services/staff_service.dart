import 'package:get/get.dart';
import 'api_client.dart';

// ════════════════════════════════════════════════════════════════════
// StaffService — mirrors Electron ipc-handlers.js staff:*
//   staff:list   → GET    /api/staff
//   staff:get    → GET    /api/staff/:id
//   staff:create → POST   /api/staff
//   staff:update → PUT    /api/staff/:id
//   staff:delete → DELETE /api/staff/:id  (deactivate)
// ════════════════════════════════════════════════════════════════════
class StaffService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                           => _api.request('GET',    '/api/staff');
  Future<ApiResult<dynamic>> get(dynamic id)                                  => _api.request('GET',    '/api/staff/$id');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data)                => _api.request('POST',   '/api/staff', body: data);
  Future<ApiResult<dynamic>> update(dynamic id, Map<String, dynamic> data)    => _api.request('PUT',    '/api/staff/$id', body: data);
  Future<ApiResult<dynamic>> delete(dynamic id)                               => _api.request('DELETE', '/api/staff/$id');
}
