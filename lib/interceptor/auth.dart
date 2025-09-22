import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:vcare_attendance/api/error.dart';
import 'package:vcare_attendance/interceptor/error.dart';
import 'package:vcare_attendance/interceptor/logger.dart';
import 'package:vcare_attendance/router/router.dart';
import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/utils/jwtToken.dart';
import 'package:vcare_attendance/utils/token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._baseClient, this._storage) {
    refreshClient = Dio();
    refreshClient.options = BaseOptions(baseUrl: _baseClient.options.baseUrl);
    refreshClient.interceptors.add(customErrorInterceptor);
    if (kDebugMode) refreshClient.interceptors.add(dioLoggerInterceptor);

    retryClient = Dio();
    retryClient.options = BaseOptions(baseUrl: _baseClient.options.baseUrl);
    retryClient.interceptors.add(customErrorInterceptor);
    if (kDebugMode) retryClient.interceptors.add(dioLoggerInterceptor);
  }

  /// The storage to load and save the JWT token.
  final TokenStorage _storage;

  /// The base client to make requests.
  final Dio _baseClient;

  /// The client to make requests to refresh the JWT token.
  late final Dio refreshClient;

  /// The client to retry the request after refreshing the JWT token.
  late final Dio retryClient;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (options.path.contains('login.php') ||
          options.path.contains('refresh.php')) {
        return handler.next(options);
      }
      String? token = await _storage.accessToken;
      if (token == null) {
        return handler.reject(
          RevokeTokenException(requestOptions: options),
          true,
        );
      }

      final jwt = JwtToken.fromRawToken(token);

      if (jwt.isValid()) {
        options.headers.addAll(_buildHeaders(token));
        return handler.next(options);
      } else {
        token = await _refreshToken(options: options);
        options.headers.addAll(_buildHeaders(token));
        return handler.next(options);
      }
    } on DioException catch (error) {
      if (error.response != null && error.response!.statusCode == 401) {
        return handler.reject(
          RevokeTokenException(requestOptions: options),
          true,
        );
      }
      return handler.reject(error);
    } on Exception {
      return handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err is RevokeTokenException) {
      final errorType = err.response?.data['error'] as String? ?? "";
      await _storage.clear();
      if (errorType == kTokenNotFound || errorType == kTokenInvalid) {
        router.pushReplacementNamed(RouteNames.login);
        return;
      }
      return handler.reject(err);
    }

    /// If the response status code is not 401, continue with the error.
    if (!shouldRefresh(err.response)) {
      return handler.next(err);
    }

    String? token = await _storage.accessToken;

    /// If the JWT token is null, reject the request.
    if (token == null) {
      return handler.reject(err);
    }

    final jwt = JwtToken.fromRawToken(token);

    try {
      if (jwt.isValid()) {
        final previousRequest = await retry(
          retryClient: retryClient,
          requestOptions: err.requestOptions,
          buildHeaders: _buildHeaders(token),
        );

        return handler.resolve(previousRequest);
      } else {
        token = await _refreshToken(options: err.requestOptions);

        /// Retry the request.
        final previousRequest = await retry(
          retryClient: retryClient,
          requestOptions: err.requestOptions,
          buildHeaders: _buildHeaders(token),
        );

        return handler.resolve(previousRequest);
      }
    } on RevokeTokenException {
      final errorType = err.response?.data['error'] as String? ?? "";
      await _storage.clear();
      if (errorType == kTokenNotFound || errorType == kTokenInvalid) {
        router.pushReplacementNamed(RouteNames.login);
        return;
      }
      return handler.reject(err);
    } on DioException catch (err) {
      return handler.next(err);
    }
  }

  Future<Response> retry({
    required Dio retryClient,
    required RequestOptions requestOptions,
    required Map<String, String> buildHeaders,
  }) async {
    return retryClient.request(
      requestOptions.path,
      cancelToken: requestOptions.cancelToken,
      data: requestOptions.data is FormData
          ? (requestOptions.data as FormData).clone()
          : requestOptions.data,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: requestOptions.extra,
        headers: requestOptions.headers..addAll(buildHeaders),
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        validateStatus: requestOptions.validateStatus,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        requestEncoder: requestOptions.requestEncoder,
        responseDecoder: requestOptions.responseDecoder,
        listFormat: requestOptions.listFormat,
      ),
    );
  }

  Future<String> _refreshToken({
    required RequestOptions options,
  }) async {
    try {
      final refreshToken = await _storage.refreshToken;
      if (refreshToken == null) {
        throw RevokeTokenException(requestOptions: options);
      }
      final response = await refreshClient.post(
        'refresh.php',
        data: {'refresh_token': refreshToken},
      );

      final newAccess = response.data['access_token'] as String;
      final newRefresh = response.data['refresh_token'] as String;
      await _storage.save(access: newAccess, refresh: newRefresh);
      return newAccess;
    } on DioException catch (e) {
      if (kDebugMode) print('[Error] Refresh Token: $e');
      if (e.response != null && e.response!.statusCode == 401) {
        await _storage.clear();
        throw RevokeTokenException(requestOptions: options);
      } else {
        rethrow;
      }
    }
  }

  /// Builds the headers with the JWT token.
  Map<String, String> _buildHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  /// Checks if the response should be refreshed.
  bool shouldRefresh<R>(Response<R>? response) => response?.statusCode == 401;
}

/// {template dio_exception}
/// Exception thrown when the token is revoked.
/// {endtemplate}
class RevokeTokenException extends DioException {
  /// {template dio_exception}
  RevokeTokenException({required super.requestOptions});
}
