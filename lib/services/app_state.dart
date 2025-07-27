// TODO: Rename this to app after all the auth update to jwt state.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vcare_attendance/utils/jwtToken.dart';
import 'package:vcare_attendance/utils/token_storage.dart';

const kProfileImagePath = "profile_image_path";

class AppStore {
  late JwtToken _token;
  String _profileImagePath = "";
  String get profileImagePathCached => _profileImagePath;
  JwtToken get token => _token;

  Future<void> initialize() async {
    await setTokenFromStorage();
    await profileImagePath;
  }

  Future<String> get profileImagePath async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    _profileImagePath = await asyncPrefs.getString(kProfileImagePath) ?? '';
    return _profileImagePath;
  }

  void setToken(JwtToken t) {
    _token = t;
  }

  Future<void> setProfileImagePath(String p) async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setString(kProfileImagePath, p);
    _profileImagePath = p;
  }

  Future<void> setTokenFromStorage() async {
    final storage = TokenStorage();
    final token = await storage.accessToken;

    if (token == null) throw Exception("No Jwt token Found stored");
    _token = JwtToken.fromRawToken(token);
  }

  Future<void> printToken() async {
    if (!kDebugMode) return;
    final storage = TokenStorage();
    final assessToken = await storage.accessToken;
    final refreshToken = await storage.refreshToken;
    print("Stored Token:\n$token");
    print("Stored Token Raw:\n${token.raw}");
    print("TokenRaw:\n\tAssess: $assessToken\n\tRefreshToken: $refreshToken");
  }
}
