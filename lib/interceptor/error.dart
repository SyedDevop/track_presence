import 'package:dio/dio.dart';

final customErrorInterceptor = InterceptorsWrapper(
  onError: (DioException error, ErrorInterceptorHandler handler) {
    final response = error.response;
    int code = 0;
    String err = "";
    String message = "";

    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      err = data['error']?.toString() ?? "";
      message = data['message']?.toString() ?? "";
      final dynamic status = data['status'];
      code =
          status is int ? status : int.tryParse(status?.toString() ?? '') ?? 0;
    } else {
      message = "Unknown (api) error. Please try again.";
    }
    // Create a new DioException with additional information
    final enrichedError = error.copyWith(
      message: message,
      error: err,
    );
    enrichedError.requestOptions.extra['code'] = code;
    handler.next(enrichedError);
  },
);
