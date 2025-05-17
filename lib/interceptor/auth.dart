import 'package:dio/dio.dart';
import 'package:vcare_attendance/api/error.dart';
import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/router/router.dart';
import 'package:vcare_attendance/utils/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _storage;
  AuthInterceptor(this._dio, this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.accessToken;
    if (token != null) {
      options.headers.addAll({"Authorization": "Bearer $token"});
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    final errorType = err.response?.data['error'] as String? ?? "";
    final retried = err.requestOptions.extra.containsKey('retried');
    // print("Start Dio error Auth");
    if (errorType == kTokenExpired && !retried) {
      // print("Try Refresh =  Type: $errorType, retried: $retried");
      try {
        final refresh = await _storage.refreshToken;
        if (refresh == null) throw Exception('No refresh token');

        // call refresh endpoint
        final resp = await _dio.post(
          'refresh.php',
          data: {'refresh_token': refresh},
        );

        final newAccess = resp.data['access_token'] as String;
        final newRefresh = resp.data['refresh_token'] as String;
        await _storage.save(access: newAccess, refresh: newRefresh);

        // Retry the original request.
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccess';
        opts.extra['retried'] = true;
        final clone = await _dio.fetch(opts);
        return handler.resolve(clone);
      } catch (_) {
        // refresh failed
        await _storage.clear();
        router.pushReplacementNamed(RouteNames.login);
      }
    } else if (errorType == kTokenNotFound || errorType == kTokenInvalid) {
      // print("Try valid or not found =  Type: $errorType, retried: $retried");
      // Access token invalid or not found
      await _storage.clear();
      router.pushReplacementNamed(RouteNames.login);
      return;
    }
    return handler.next(err);
  }
}
