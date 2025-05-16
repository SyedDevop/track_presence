import 'dart:convert';
import 'package:dio/dio.dart';

class AccountApi {
  Dio dio;
  AccountApi({required this.dio});

  Future<Map<String, dynamic>> login(String userId, String password) async {
    final res = await dio.post(
      "login.php",
      data: json.encode({"user-id": userId, "password": password}),
      options: Options(contentType: "application/json"),
    );
    return jsonDecode(res.data);
  }

  Future<void> changePassword(
      String userId, String currPassword, String password) async {
    await dio.post(
      "forgot_password.php",
      data: json.encode({
        "user-id": userId,
        "curr-password": currPassword,
        "password": password
      }),
      options: Options(contentType: "application/json"),
    );
  }
}
