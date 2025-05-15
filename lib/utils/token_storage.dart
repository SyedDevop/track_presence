import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _secure = const FlutterSecureStorage();

  Future<String?> get accessToken => _secure.read(key: 'access_token');
  Future<String?> get refreshToken => _secure.read(key: 'refresh_token');

  Future<void> save({
    required String access,
    required String refresh,
  }) =>
      Future.wait([
        _secure.write(key: 'access_token', value: access),
        _secure.write(key: 'refresh_token', value: refresh),
      ]);

  Future<void> clear() => Future.wait([
        _secure.delete(key: 'access_token'),
        _secure.delete(key: 'refresh_token'),
      ]);
}
