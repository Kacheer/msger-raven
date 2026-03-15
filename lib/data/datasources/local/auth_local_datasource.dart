import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  final SharedPreferences _prefs;

  AuthLocalDataSource(this._prefs);

  Future<void> saveTokens(String token, String refreshToken, String userId) async {
    await Future.wait([
      _prefs.setString(_tokenKey, token),
      _prefs.setString(_refreshTokenKey, refreshToken),
      _prefs.setString(_userIdKey, userId),
    ]);
  }

  String? getToken() => _prefs.getString(_tokenKey);
  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);
  String? getUserId() => _prefs.getString(_userIdKey);

  bool isLoggedIn() => getToken() != null && getUserId() != null;

  Future<void> clearTokens() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_refreshTokenKey),
      _prefs.remove(_userIdKey),
    ]);
  }
}
