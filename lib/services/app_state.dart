// TODO: Rename this to app after all the auth update to jwt state.
import 'package:flutter/foundation.dart';
import 'package:vcare_attendance/utils/jwtToken.dart';
import 'package:vcare_attendance/utils/token_storage.dart';

class AppStore {
  late JwtToken _token;
  JwtToken get token => _token;

  void setToken(JwtToken t) {
    _token = t;
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
