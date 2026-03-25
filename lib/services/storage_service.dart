import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class StorageService extends GetxService {
  static const _kSession = 'jewel_session';
  static const _kAccess = 'jewel_access';
  static const _kRefresh = 'jewel_refresh';

  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveSession(UserSession s) async =>
      _prefs.setString(_kSession, jsonEncode(s.toJson()));

  Future<UserSession?> getSession() async {
    final raw = _prefs.getString(_kSession);
    if (raw == null) return null;
    try {
      return UserSession.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAccessToken(String t) => _prefs.setString(_kAccess, t);
  Future<void> saveRefreshToken(String t) => _prefs.setString(_kRefresh, t);
  Future<String?> getAccessToken() async => _prefs.getString(_kAccess);
  Future<String?> getRefreshToken() async => _prefs.getString(_kRefresh);

  Future<void> clearSession() async {
    await _prefs.remove(_kSession);
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
  }
}
