import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const _tokenKey = "auth_token";
  static const _rememberKey = "remember_me";

  Future<void> saveToken(String token, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_rememberKey, rememberMe);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberKey) ?? false;

    if (!remember) return null;

    return prefs.getString(_tokenKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}