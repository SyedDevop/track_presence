import 'package:dio/dio.dart';
import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/router/router.dart';
import 'package:vcare_attendance/utils/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _storage;
  AuthInterceptor(this._dio, this._storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
    // super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // if 401 and not already retried:
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.extra.containsKey('retried')) {
      try {
        final refresh = await _storage.refreshToken;
        if (refresh == null) throw Exception('No refresh token');

        // call refresh endpoint
        final resp = await _dio.post(
          '/api/refresh.php',
          data: {'refresh_token': refresh},
        );

        final newAccess = resp.data['access_token'] as String;
        final newRefresh = resp.data['refresh_token'] as String;

        // store new tokens
        await _storage.save(access: newAccess, refresh: newRefresh);

        // retry original request
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccess';
        opts.extra['retried'] = true;

        final clone = await _dio.fetch(opts);
        return handler.resolve(clone);
      } catch (_) {
        // refresh failed → clear and let app handle logout
        await _storage.clear();
        // Use the global router key to go to login—even outside a widget.
        router.pushReplacementNamed(RouteNames.login);
      }
    }
    return handler.next(err);
  }
}