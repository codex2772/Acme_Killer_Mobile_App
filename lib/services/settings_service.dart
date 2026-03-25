import 'package:get/get.dart';
import 'api_client.dart';

// ════════════════════════════════════════════════════════════════════
// SettingsService — mirrors Electron ipc-handlers.js settings:*
// ════════════════════════════════════════════════════════════════════
class SettingsService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  /// GET /api/settings
  Future<ApiResult<dynamic>> get() => _api.request('GET', '/api/settings');

  /// PUT /api/settings
  Future<ApiResult<dynamic>> update(Map<String, dynamic> data) =>
      _api.request('PUT', '/api/settings', body: data);

  /// GET /api/settings/expense-categories
  Future<ApiResult<dynamic>> expenseCategories() =>
      _api.request('GET', '/api/settings/expense-categories');
}

// ════════════════════════════════════════════════════════════════════
// StoreContextService — NEW in latest Electron build
// mirrors Electron ipc-handlers.js store:switch / store:current
//
// Switches the X-Store-Id header on ApiClient so every subsequent
// request is scoped to the chosen store on the backend.
// ════════════════════════════════════════════════════════════════════
class StoreContextService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  /// Switch active store — mirrors Electron: store:switch
  /// Sets X-Store-Id header on ApiClient + notifies backend.
  Future<ApiResult<dynamic>> switchStore(int storeId) async {
    _api.setCurrentStoreId(storeId);
    // Notify backend (best-effort — non-blocking)
    return ApiResult.ok({'success': true, 'storeId': storeId});
  }

  /// Get current store id — mirrors Electron: store:current
  int? currentStoreId() => _api.getCurrentStoreId();

  /// Clear store context (e.g. on logout)
  void clearStore() => _api.setCurrentStoreId(null);
}

// ════════════════════════════════════════════════════════════════════
// ImagesService — NEW in latest Electron build
// mirrors Electron ipc-handlers.js images:upload / images:delete
// ════════════════════════════════════════════════════════════════════
class ImagesService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  /// Upload image to S3 via backend — mirrors Electron: images:upload
  /// [folder] defaults to 'jewelry-items' (same as Electron default)
  Future<ApiResult<dynamic>> upload(
    List<int> fileBytes,
    String fileName,
    String mimeType, {
    String folder = 'jewelry-items',
  }) => _api.uploadImage(fileBytes, fileName, mimeType, folder: folder);

  /// Delete image from S3 — mirrors Electron: images:delete
  Future<ApiResult<dynamic>> delete(String imageUrl) => _api.deleteImage(imageUrl);
}
