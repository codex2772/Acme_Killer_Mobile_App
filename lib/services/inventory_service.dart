import 'package:get/get.dart';
import 'api_client.dart';

// ════════════════════════════════════════════════════════════════════
// InventoryService — mirrors Electron ipc-handlers.js inventory:*
// ════════════════════════════════════════════════════════════════════
class InventoryService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                            => _api.request('GET',    '/api/jewelry-items');
  Future<ApiResult<dynamic>> get(dynamic id)                                   => _api.request('GET',    '/api/jewelry-items/$id');
  Future<ApiResult<dynamic>> getBySku(String sku)                              => _api.request('GET',    '/api/jewelry-items/sku/${Uri.encodeComponent(sku)}');
  Future<ApiResult<dynamic>> byCategory(dynamic categoryId)                    => _api.request('GET',    '/api/jewelry-items/category/$categoryId');
  Future<ApiResult<dynamic>> byStatus(String status)                           => _api.request('GET',    '/api/jewelry-items/status/${Uri.encodeComponent(status)}');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data)                 => _api.request('POST',   '/api/jewelry-items', body: data);
  Future<ApiResult<dynamic>> update(dynamic id, Map<String, dynamic> data)     => _api.request('PUT',    '/api/jewelry-items/$id', body: data);
  Future<ApiResult<dynamic>> delete(dynamic id)                                => _api.request('DELETE', '/api/jewelry-items/$id');

  // ── Image upload for inventory item ──────────────────────────────
  // mirrors Electron: images:upload → POST /api/images/upload
  Future<ApiResult<dynamic>> uploadImage(List<int> bytes, String fileName, String mimeType) =>
      _api.uploadImage(bytes, fileName, mimeType, folder: 'jewelry-items');

  Future<ApiResult<dynamic>> deleteImage(String imageUrl) =>
      _api.deleteImage(imageUrl);
}

// ════════════════════════════════════════════════════════════════════
// CategoriesService — mirrors Electron ipc-handlers.js categories:*
// ════════════════════════════════════════════════════════════════════
class CategoriesService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                            => _api.request('GET',    '/api/categories');
  Future<ApiResult<dynamic>> get(dynamic id)                                   => _api.request('GET',    '/api/categories/$id');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data)                 => _api.request('POST',   '/api/categories', body: data);
  Future<ApiResult<dynamic>> update(dynamic id, Map<String, dynamic> data)     => _api.request('PUT',    '/api/categories/$id', body: data);
  Future<ApiResult<dynamic>> delete(dynamic id)                                => _api.request('DELETE', '/api/categories/$id');
}

// ════════════════════════════════════════════════════════════════════
// MetalTypesService — mirrors Electron ipc-handlers.js metal-types:*
// ════════════════════════════════════════════════════════════════════
class MetalTypesService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                            => _api.request('GET',    '/api/metal-types');
  Future<ApiResult<dynamic>> get(dynamic id)                                   => _api.request('GET',    '/api/metal-types/$id');
  Future<ApiResult<dynamic>> search(String name)                               => _api.request('GET',    '/api/metal-types/search?name=${Uri.encodeComponent(name)}');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data)                 => _api.request('POST',   '/api/metal-types', body: data);
  Future<ApiResult<dynamic>> update(dynamic id, Map<String, dynamic> data)     => _api.request('PUT',    '/api/metal-types/$id', body: data);
  Future<ApiResult<dynamic>> delete(dynamic id)                                => _api.request('DELETE', '/api/metal-types/$id');
}
