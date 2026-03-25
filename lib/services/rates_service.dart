import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';

// ════════════════════════════════════════════════════════════════════
// RatesService — mirrors Electron ipc-handlers.js rates:*
// ════════════════════════════════════════════════════════════════════
class RatesService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> get()                                             => _api.request('GET', '/api/rates');
  Future<ApiResult<dynamic>> update(Map<String, dynamic> data)                 => _api.request('PUT', '/api/rates', body: data);
  Future<ApiResult<dynamic>> history({int days = 30})                          => _api.request('GET', '/api/rates/history?days=$days');
  Future<ApiResult<dynamic>> alertsList()                                      => _api.request('GET', '/api/rates/alerts');
  Future<ApiResult<dynamic>> alertsCreate(Map<String, dynamic> data)           => _api.request('POST', '/api/rates/alerts', body: data);

  // ════════════════════════════════════════════════════════════════
  // fetchLive — mirrors Electron ipc-handlers.js rates:fetch-live
  //
  // Tries Swissquote → metals.live fallback → open.er-api.com for FX
  // Returns gold22k/24k/18k/14k, silver, platinum in INR per gram
  // ════════════════════════════════════════════════════════════════
  Future<ApiResult<dynamic>> fetchLive() async {
    try {
      double goldUsdOz = 0, silverUsdOz = 0, platinumUsdOz = 0;
      String source = '';

      // ── Source 1: Swissquote (free, real-time) ──────────────────
      final swissquotePairs = [
        {'url': 'https://forex-data-feed.swissquote.com/public-quotes/bboquotes/instrument/XAU/USD', 'key': 'gold'},
        {'url': 'https://forex-data-feed.swissquote.com/public-quotes/bboquotes/instrument/XAG/USD', 'key': 'silver'},
        {'url': 'https://forex-data-feed.swissquote.com/public-quotes/bboquotes/instrument/XPT/USD', 'key': 'platinum'},
      ];

      for (final pair in swissquotePairs) {
        try {
          final r = await http.get(Uri.parse(pair['url']!),
              headers: {'User-Agent': 'JewelERP-Mobile/1.0'})
              .timeout(const Duration(seconds: 8));
          if (r.statusCode == 200) {
            final data = jsonDecode(r.body);
            if (data is List && data.isNotEmpty) {
              final prices = data[0]?['spreadProfilePrices']?[0];
              if (prices != null) {
                final bid = (prices['bid'] as num?)?.toDouble() ?? 0;
                final ask = (prices['ask'] as num?)?.toDouble() ?? 0;
                if (bid > 0) {
                  final mid = (bid + ask) / 2;
                  if (pair['key'] == 'gold')     goldUsdOz     = mid;
                  if (pair['key'] == 'silver')   silverUsdOz   = mid;
                  if (pair['key'] == 'platinum') platinumUsdOz = mid;
                }
              }
            }
          }
        } catch (_) {}
      }

      if (goldUsdOz > 0) source = 'Swissquote';

      // ── Source 2: metals.live fallback ───────────────────────────
      if (goldUsdOz == 0) {
        try {
          final r = await http.get(Uri.parse('https://api.metals.live/v1/spot'))
              .timeout(const Duration(seconds: 8));
          if (r.statusCode == 200) {
            final data = jsonDecode(r.body);
            if (data is List) {
              for (final item in data) {
                if (item['gold'] != null)     goldUsdOz     = (item['gold']     as num).toDouble();
                if (item['silver'] != null)   silverUsdOz   = (item['silver']   as num).toDouble();
                if (item['platinum'] != null) platinumUsdOz = (item['platinum'] as num).toDouble();
              }
              if (goldUsdOz > 0) source = 'metals.live';
            }
          }
        } catch (_) {}
      }

      if (goldUsdOz == 0) {
        return ApiResult.fail('Could not fetch metal spot prices from any source');
      }

      // ── USD → INR exchange rate ───────────────────────────────────
      double usdToInr = 83.5;
      try {
        final r = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
            .timeout(const Duration(seconds: 6));
        if (r.statusCode == 200) {
          final d = jsonDecode(r.body) as Map<String, dynamic>;
          usdToInr = (d['rates']?['INR'] as num?)?.toDouble() ?? usdToInr;
        }
      } catch (_) {}

      // ── Convert: USD/troy-oz → INR/gram ─────────────────────────
      const troyOzToGram = 31.1035;
      final gold24k = (goldUsdOz     * usdToInr / troyOzToGram).round();
      final silver  = (silverUsdOz   * usdToInr / troyOzToGram * 100).round() / 100;
      final platinum = platinumUsdOz > 0 ? (platinumUsdOz * usdToInr / troyOzToGram).round() : 0;

      return ApiResult.ok({
        'gold24k':      gold24k,
        'gold22k':      (gold24k * 22 / 24).round(),
        'gold18k':      (gold24k * 18 / 24).round(),
        'gold14k':      (gold24k * 14 / 24).round(),
        'silver':       silver,
        'platinum':     platinum,
        'roseGold18k':  ((gold24k * 18 / 24) * 1.02).round(),
        'whiteGold18k': ((gold24k * 18 / 24) * 1.03).round(),
        'usdToInr':     (usdToInr * 100).round() / 100,
        'goldUsdOz':    (goldUsdOz * 100).round() / 100,
        'silverUsdOz':  (silverUsdOz * 100).round() / 100,
        'fetchedAt':    DateTime.now().toIso8601String(),
        'source':       '$source + open.er-api.com',
      });
    } catch (e) {
      return ApiResult.fail('Live rates fetch failed: $e');
    }
  }
}

// ════════════════════════════════════════════════════════════════════
// OldGoldService — mirrors Electron ipc-handlers.js old-gold:*
// ════════════════════════════════════════════════════════════════════
class OldGoldService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                            => _api.request('GET', '/api/old-gold');
  Future<ApiResult<dynamic>> get(dynamic id)                                   => _api.request('GET', '/api/old-gold/$id');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data)                 => _api.request('POST', '/api/old-gold', body: data);
  Future<ApiResult<dynamic>> update(dynamic id, Map<String, dynamic> data)     => _api.request('PUT',  '/api/old-gold/$id', body: data);
}

// ════════════════════════════════════════════════════════════════════
// SchemesService — mirrors Electron ipc-handlers.js schemes:*
// ════════════════════════════════════════════════════════════════════
class SchemesService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                            => _api.request('GET',  '/api/schemes');
  Future<ApiResult<dynamic>> get(dynamic id)                                   => _api.request('GET',  '/api/schemes/$id');
  Future<ApiResult<dynamic>> create(Map<String, dynamic> data)                 => _api.request('POST', '/api/schemes', body: data);
  Future<ApiResult<dynamic>> update(dynamic id, Map<String, dynamic> data)     => _api.request('PUT',  '/api/schemes/$id', body: data);
  Future<ApiResult<dynamic>> members(dynamic schemeId)                         => _api.request('GET',  '/api/schemes/$schemeId/members');
  Future<ApiResult<dynamic>> addMember(dynamic schemeId, Map<String, dynamic> d) => _api.request('POST', '/api/schemes/$schemeId/members', body: d);
  Future<ApiResult<dynamic>> recordPayment(dynamic schemeId, dynamic memberId, Map<String, dynamic> d) =>
      _api.request('POST', '/api/schemes/$schemeId/members/$memberId/payments', body: d);
  Future<ApiResult<dynamic>> memberPayments(dynamic schemeId, dynamic memberId) =>
      _api.request('GET', '/api/schemes/$schemeId/members/$memberId/payments');
}
