// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dio/dio.dart';

String prettyJson(Object? json) {
  if (json == null ) return "Empty";
  if (json is String && json.isEmpty) return "Empty";
  try {
    var encoder = const JsonEncoder();
    if (json is String) {
      return encoder.convert(jsonDecode(json));
    }
    return encoder.convert(json);
  } catch (e) {
    return json.toString();
  }
}

String now() {
  return DateTime.now().toIso8601String().split('T').join(' ').substring(0, 19);
}

final dioLoggerInterceptor = InterceptorsWrapper(
  onRequest: (RequestOptions options, handler) {
    print('\x1B[36m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
    print('┃ 📤 [REQUEST] ${options.method} ${options.uri}');
    print('┃ 🕓 ${now()}');
    print('┃ ─ Query  : ${prettyJson(options.queryParameters)}');
    print('┃ ─ Data   : ${prettyJson(options.data)}');
    print('┃ ─ Headers:');
    options.headers.forEach((key, value) {
      print('┃    • $key: $value');
    });
    print("┃");
    print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\x1B[0m');
    handler.next(options);
  },
  onResponse: (Response response, handler) {
    print('\x1B[32m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
    print('┃ 📥 [RESPONSE] ${response.requestOptions.method} ${response.requestOptions.uri}');
    print('┃ 🕓 ${now()}');
    print('┃ ─ Status : ${response.statusCode}');
    print('┃ ─ Data   : ${prettyJson(response.data)}');
    print('┃ ─ Headers:');
    response.headers.forEach((key, value) {
      print('┃    • $key: $value');
    });
    print("┃");
    print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\x1B[0m');
    handler.next(response);
  },
  onError: (DioException error, handler) {
    print('\x1B[31m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
    print('┃ ❌ [ERROR] ${error.requestOptions.method} ${error.requestOptions.uri}');
    print('┃ 🕓 ${now()}');
    print('┃ ─ Error  : ${error.error}');
    print('┃ ─ Status : ${error.response?.statusCode}');
    print('┃ ─ Data   : ${prettyJson(error.response.toString())}');
    // print("┃ ─ Stack:");
    // print("┃ ─ ${error.stackTrace}");
    print("┃");
    print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\x1B[0m');
    handler.next(error);
  },
);
