import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:vcare_attendance/api/error.dart';
import 'package:vcare_attendance/interceptor/logger.dart';
import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/router/router.dart';
import 'package:vcare_attendance/utils/token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenStorage _storage;
  AuthInterceptor(this._dio, this._storage);

  /// isRefreshing flag is used to control whether a token refresh is already in progress.
  ///
  /// If it's in progress, subsequent requests will skip the refresh attempt
  /// until the first one completes.
  bool isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    //TODO: check if the request is a login or refresh Token then don't auth headers
    final token = await _storage.accessToken;
    if (token != null) {
      options.headers.addAll({"Authorization": "Bearer $token"});
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    // Token is refreshing Token the return.
    if (isRefreshing) return handler.next(err);
    isRefreshing = true;
    final errorType = err.response?.data['error'] as String? ?? "";
    // print("Start Dio error Auth");
    if (errorType == kTokenExpired) {
      // print("Try Refresh =  Type: $errorType, retried: $retried");
      try {
        final accessToken = await _refreshToken();
        if (accessToken == null) {
          await _storage.clear();
          router.pushReplacementNamed(RouteNames.login);
          return handler.reject(err);
        } else {
          // Retry the original request.
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $accessToken';
          final clone = await _dio.fetch(opts);
          return handler.resolve(clone);
        }
      } catch (e) {
        // refresh failed
        if (kDebugMode) print('[Error] Refresh In On Error Token: $e');
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

  Future<String?> _refreshToken() async {
    try {
      final dioRefresh = Dio(_dio.options);
      final refreshToken = await _storage.refreshToken;
      if (refreshToken == null) return null;

      if (kDebugMode) dioRefresh.interceptors.add(dioLoggerInterceptor);
      final response = await dioRefresh
          .post('refresh.php', data: {'refresh_token': refreshToken});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAccess = response.data['access_token'] as String;
        final newRefresh = response.data['refresh_token'] as String;
        await _storage.save(access: newAccess, refresh: newRefresh);
        return newAccess;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('[Error] Refresh Token: $e');
      return null;
    }
  }
}
